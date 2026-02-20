"""Central controller coordinating WS ↔ UDP relay, match state, and API calls.

All cross-component wiring lives here. UI pages connect to this controller's
signals. The controller owns the WSClient, UDPRelay, and session state.
"""

import logging
import threading

import requests

from PySide6.QtCore import QObject, Signal, QTimer

import api_client
import match_cache
from ws_client import WSClient
from udp_relay import UDPRelay
from config import QUEUE_POLL_INTERVAL, BRIDGE_VERSION

log = logging.getLogger(__name__)


class BridgeController(QObject):
    """Owns networking objects and session state. Bridges WS ↔ UDP."""

    # ---- Session signals ----
    login_success = Signal(dict)    # player data
    login_failed = Signal(str)      # error message
    registration_needed = Signal(str)  # steam_id (new player, needs a name)
    registration_failed = Signal(str)  # error message from server (name taken, blocked, etc.)
    player_data_refreshed = Signal(dict)  # updated player data

    # ---- Active matches signals ----
    active_matches_updated = Signal(dict)  # {active_matches, recently_finished}
    queue_joined = Signal()
    queue_left = Signal()

    # ---- Match lifecycle signals (forwarded from WS, also relayed to UDP) ----
    paired = Signal(dict)           # {opponent_name, opponent_elo, categories, ban_order_first}
    ban_update = Signal(list)       # remaining categories
    match_started = Signal(dict)    # {category, seed}
    opponent_progress = Signal(int, int) # area, theme
    match_result = Signal(dict)     # {result, match_data}
    match_scrapped = Signal()

    # ---- Connection signals ----
    ws_connected = Signal()
    ws_disconnected = Signal()
    game_connected = Signal()
    game_disconnected = Signal()

    # ---- Version mismatch signals ----
    bridge_version_mismatch = Signal(str)   # bridge download URL
    game_version_mismatch = Signal(str)     # game mod download URL

    def __init__(self, parent=None):
        super().__init__(parent)

        # Session state
        self.steam_id: str = ""
        self.player_name: str = ""
        self.player_data: dict = {}
        self.in_queue: bool = False
        self.in_ban_phase: bool = False
        self.in_match: bool = False
        self.match_category: str = ""
        self.match_opponent: str = ""
        self.match_opponent_elo: int = 0

        # Server version info (populated during login)
        self._server_version: float = 0.0
        self._game_mod_download_url: str = ""

        # Whether the WS was deliberately stopped (logout/stop_networking)
        self._ws_intentional_disconnect: bool = False

        # Networking
        self.ws = WSClient()
        self.udp = UDPRelay()

        # Active matches polling timer
        self._poll_timer = QTimer(self)
        self._poll_timer.setInterval(QUEUE_POLL_INTERVAL * 1000)
        self._poll_timer.timeout.connect(self._poll_active_matches)

        # Wire WS signals → controller signals + UDP relay
        self.ws.connected.connect(self._on_ws_connected)
        self.ws.disconnected.connect(self._on_ws_disconnected)
        self.ws.paired.connect(self._on_ws_paired)
        self.ws.ban_update.connect(self._on_ws_ban_update)
        self.ws.match_start.connect(self._on_ws_match_start)
        self.ws.opponent_progress.connect(self._on_ws_opponent_progress)
        self.ws.match_result.connect(self._on_ws_match_result)
        self.ws.match_scrapped.connect(self._on_ws_match_scrapped)
        self.ws.receive_chat.connect(self._on_ws_receive_chat)
        self.ws.receive_seed_change_request.connect(self._on_ws_receive_seed_change_request)
        self.ws.do_seed_change.connect(self._on_ws_do_seed_change)
        self.ws.receive_draw_request.connect(self._on_ws_receive_draw_request)
        self.ws.postmatch_closed.connect(self._on_ws_postmatch_closed)

        # Wire UDP signals → WS relay
        self.udp.game_queue_ready.connect(self._on_game_queue_ready)
        self.udp.game_queue_leave.connect(self._on_game_queue_leave)
        self.udp.game_ban.connect(self._on_game_ban)
        self.udp.game_progress.connect(self._on_game_progress)
        self.udp.game_death.connect(self._on_game_death)
        self.udp.game_instant_restart.connect(self._on_game_instant_restart)
        self.udp.game_completion.connect(self._on_game_completion)
        self.udp.game_connected.connect(self._on_game_connected)
        self.udp.game_disconnected.connect(self._on_game_disconnected)
        self.udp.game_version_received.connect(self._on_game_version_received)
        self.udp.game_send_chat.connect(self._on_game_send_chat)
        self.udp.game_request_seed_change.connect(self._on_game_request_seed_change)
        self.udp.game_request_draw.connect(self._on_game_request_draw)
        self.udp.game_forfeit.connect(self._on_game_forfeit)
        self.udp.game_close_postmatch.connect(self._on_game_close_postmatch)

    # ---- Public API ----

    def login(self, steam_id: str) -> None:
        """Authenticate with the server. Runs in background thread.

        First checks the bridge version against the server. If mismatched,
        emits bridge_version_mismatch instead of proceeding.

        If the steam_id is not yet registered, emits registration_needed
        so the UI can prompt for a display name.
        """
        def _do():
            try:
                log.info("Login attempt for steam_id=%s", steam_id)
                # Check bridge version before login
                version_info = api_client.get_server_version()
                self._server_version = version_info.get("version", 0.0)
                self._game_mod_download_url = version_info.get("game_mod_download_url", "")
                bridge_download_url = version_info.get("bridge_download_url", "")
                log.info("Server version=%.1f bridge_version=%.1f", self._server_version, BRIDGE_VERSION)

                if BRIDGE_VERSION != self._server_version:
                    log.warning("Bridge version mismatch — emitting bridge_version_mismatch")
                    self.bridge_version_mismatch.emit(bridge_download_url)
                    return

                data = api_client.login(steam_id)
                if data.get("new_player"):
                    log.info("New player detected, registration needed")
                    self.steam_id = steam_id
                    self.registration_needed.emit(steam_id)
                else:
                    log.info("Login success for %s (%s)", data.get("player_name"), steam_id)
                    self.steam_id = steam_id
                    self.player_name = data.get("player_name", "")
                    self.player_data = data
                    self.login_success.emit(data)
            except Exception as e:
                log.error("Login failed: %s", e)
                self.login_failed.emit(str(e))

        threading.Thread(target=_do, daemon=True).start()

    def register(self, steam_id: str, player_name: str) -> None:
        """Create a new player account with the chosen name. Runs in background thread."""
        def _do():
            try:
                resp = api_client.register_raw(steam_id, player_name)
                if resp.status_code != 200:
                    error = resp.json().get("error", "Registration failed")
                    self.registration_failed.emit(error)
                    return
                data = resp.json()
                self.steam_id = steam_id
                self.player_name = player_name
                self.player_data = data
                self.login_success.emit(data)
            except Exception as e:
                self.registration_failed.emit(str(e))

        threading.Thread(target=_do, daemon=True).start()

    def start_networking(self) -> None:
        """Start UDP server and WS connection after login."""
        self._ws_intentional_disconnect = False
        self.udp.start()
        self.ws.connect_to_server(self.steam_id)

    def stop_networking(self) -> None:
        """Shut down all networking."""
        self._ws_intentional_disconnect = True
        self.stop_active_matches_polling()
        self.ws.disconnect_from_server()
        self.udp.stop()

    def logout(self) -> None:
        """Leave queue if active, stop all networking, clear cache, and reset session state."""
        if self.in_queue:
            steam_id = self.steam_id
            threading.Thread(
                target=lambda: api_client.queue_leave(steam_id),
                daemon=True,
            ).start()
        self.stop_networking()
        match_cache.save_cached_matches([])
        self.steam_id = ""
        self.player_name = ""
        self.player_data = {}
        self.in_queue = False
        self.in_ban_phase = False
        self.in_match = False
        self.match_category = ""
        self.match_opponent = ""
        self.match_opponent_elo = 0

    def start_active_matches_polling(self) -> None:
        """Immediately poll active matches, then repeat every QUEUE_POLL_INTERVAL."""
        self._poll_active_matches()
        self._poll_timer.start()

    def stop_active_matches_polling(self) -> None:
        """Stop the active matches polling timer."""
        self._poll_timer.stop()

    def fetch_my_matches(self, offset: int = 0, limit: int = 10) -> list[dict]:
        """Fetch player's matches. Returns cached + server data."""
        return api_client.get_matches(
            player_id=self.steam_id, offset=offset, limit=limit
        )

    def fetch_all_matches(self, offset: int = 0, limit: int = 10) -> list[dict]:
        """Fetch all matches from server."""
        return api_client.get_matches(offset=offset, limit=limit)

    def fetch_leaderboard(self) -> list[dict]:
        """Fetch leaderboard from server."""
        return api_client.get_leaderboard()

    def fetch_fastest_times(self) -> dict:
        """Fetch fastest times from server."""
        return api_client.get_fastest_times()

    def refresh_player_data(self) -> None:
        """Re-fetch player data from server."""
        def _do():
            try:
                data = api_client.login(self.steam_id)
                if not data.get("new_player"):
                    self.player_data = data
                    self.player_data_refreshed.emit(data)
            except Exception:
                pass
        threading.Thread(target=_do, daemon=True).start()

    def initialize_match_cache(self) -> None:
        """On first login, fetch all player matches and populate cache."""
        cached = match_cache.load_cached_matches()
        if cached:
            return  # Cache already populated

        def _do():
            try:
                offset = 0
                all_matches = []
                while True:
                    batch = api_client.get_matches(
                        player_id=self.steam_id, offset=offset, limit=100
                    )
                    if not batch:
                        break
                    all_matches.extend(batch)
                    offset += len(batch)
                match_cache.save_cached_matches(all_matches)
            except Exception:
                pass

        threading.Thread(target=_do, daemon=True).start()

    # ---- Active matches polling ----

    def _poll_active_matches(self) -> None:
        def _do():
            try:
                data = api_client.get_active_matches()
                self.active_matches_updated.emit(data)
            except Exception as e:
                log.error("Failed to poll active matches: %s", e)
        threading.Thread(target=_do, daemon=True).start()

    # ---- WS connect/disconnect ----

    def _on_ws_connected(self) -> None:
        log.info("WebSocket connected to server")
        # Issue 1: if the server removed us from the queue during a WS blip, re-join
        if self.in_queue:
            log.info("WS reconnected while in_queue=True — re-joining queue for %s", self.steam_id)
            steam_id = self.steam_id
            def _rejoin():
                try:
                    api_client.queue_join(steam_id)
                    log.info("Re-queue join succeeded for %s", steam_id)
                except requests.HTTPError as e:
                    if e.response is not None and e.response.status_code == 403:
                        log.warning("Re-queue join rejected — player is banned: %s", steam_id)
                        self.in_queue = False
                        self.udp.send_to_game({"event": "is_banned"})
                    else:
                        log.error("Re-queue join failed: %s", e)
                except Exception as e:
                    log.error("Re-queue join failed: %s", e)
            threading.Thread(target=_rejoin, daemon=True).start()
        self.ws_connected.emit()

    def _on_ws_disconnected(self) -> None:
        log.warning("WebSocket disconnected from server (intentional=%s)", self._ws_intentional_disconnect)
        self.ws_disconnected.emit()
        # Issue 4: reconnect automatically if this wasn't a deliberate shutdown
        if self.steam_id and not self._ws_intentional_disconnect:
            log.info("Scheduling WS reconnect in 5s for %s", self.steam_id)
            QTimer.singleShot(5000, self._attempt_ws_reconnect)

    def _attempt_ws_reconnect(self) -> None:
        if self.steam_id and not self._ws_intentional_disconnect:
            log.info("Attempting WS reconnect for %s", self.steam_id)
            self.ws.reconnect()

    # ---- Game version check ----

    def _on_game_connected(self) -> None:
        """When the game connects, request its version."""
        log.info("Game connected over UDP")
        self.game_connected.emit()
        self.udp.request_game_version()

    def _on_game_version_received(self, game_version: float) -> None:
        """Check the game mod version against the server version."""
        log.info("Game version=%.1f server_version=%.1f", game_version, self._server_version)
        if game_version != self._server_version:
            log.warning("Game mod version mismatch")
            self.udp.send_to_game({"event": "version_mismatch"})
            self.stop_networking()
            self.game_version_mismatch.emit(self._game_mod_download_url)

    # ---- Game → Server relay (UDP events forwarded to WS) ----

    def _on_game_queue_ready(self) -> None:
        log.info("UDP: game_queue_ready received, steam_id=%s", self.steam_id)
        def _do():
            try:
                api_client.queue_join(self.steam_id)
                log.info("Queue join succeeded for %s", self.steam_id)
                self.in_queue = True
                self.queue_joined.emit()
            except requests.HTTPError as e:
                if e.response is not None and e.response.status_code == 403:
                    log.warning("Queue join rejected — player is banned: %s", self.steam_id)
                    self.udp.send_to_game({"event": "is_banned"})
                else:
                    log.error("Queue join failed: %s", e)
            except Exception as e:
                log.error("Queue join failed: %s", e)
        threading.Thread(target=_do, daemon=True).start()

    def _on_game_queue_leave(self) -> None:
        self._leave_queue()

    def _on_game_disconnected(self) -> None:
        if self.in_queue:
            self._leave_queue()
        if self.in_match or self.in_ban_phase:
            self.in_match = False
            self.in_ban_phase = False
            self.ws.send_game_disconnect()
            self.match_scrapped.emit()
        self.game_disconnected.emit()

    def _leave_queue(self) -> None:
        log.info("Leaving queue for steam_id=%s", self.steam_id)
        def _do():
            try:
                api_client.queue_leave(self.steam_id)
                log.info("Queue leave succeeded for %s", self.steam_id)
                self.in_queue = False
                self.queue_left.emit()
            except Exception as e:
                log.error("Queue leave failed: %s", e)
        threading.Thread(target=_do, daemon=True).start()

    def _on_game_ban(self, category: str) -> None:
        if not self.in_ban_phase:
            return
        self.ws.send_ban(category)

    def _on_game_progress(self, area: int, level: int, theme: int) -> None:
        if not self.in_match:
            return
        self.ws.send_progress(area, level, theme)

    def _on_game_death(self) -> None:
        if not self.in_match:
            return
        self.ws.send_death()

    def _on_game_instant_restart(self) -> None:
        if not self.in_match:
            return
        self.ws.send_instant_restart()

    def _on_game_completion(self) -> None:
        if not self.in_match:
            return
        self.ws.send_completion()

    # ---- Server → Game relay (WS events forwarded to UDP) ----

    def _on_ws_paired(self, data: dict) -> None:
        log.info("WS: paired — opponent=%s elo=%s", data.get("opponent_name"), data.get("opponent_elo"))
        self.in_queue = False
        self.in_ban_phase = True
        self.match_opponent = data.get("opponent_name", "")
        self.match_opponent_elo = data.get("opponent_elo", 0)
        self.udp.send_to_game({"event": "paired", **data})
        self.paired.emit(data)

    def _on_ws_ban_update(self, categories: list) -> None:
        log.info("WS: ban_update — remaining=%s", categories)
        self.udp.send_to_game({"event": "ban_update", "categories": categories})
        self.ban_update.emit(categories)

    def _on_ws_match_start(self, data: dict) -> None:
        log.info("WS: match_start — category=%s seed=%s", data.get("category"), data.get("seed"))
        self.in_ban_phase = False
        self.in_match = True
        self.match_category = data.get("category", "")
        # Critical message — retry until ack
        self.udp.send_critical({"event": "match_start", **data})
        self.match_started.emit(data)

    def _on_ws_opponent_progress(self, area: int, theme: int) -> None:
        self.udp.send_to_game({"event": "opponent_progress", "area": area, "theme": theme})
        self.opponent_progress.emit(area, theme)

    def _on_ws_match_result(self, data: dict) -> None:
        log.info("WS: match_result — result=%s elo_change=%s", data.get("result"), data.get("elo_change"))
        self.in_match = False
        self.in_ban_phase = False
        # Send the result string and elo change to the Game, not the full match record
        self.udp.send_critical({
            "event": "match_result",
            "result": data.get("result", ""),
            "elo_change": data.get("elo_change", 0),
        })
        # Cache the match
        match_data = data.get("match_data")
        if match_data:
            match_cache.append_match(match_data)
        # Refresh player data after match completes
        self.refresh_player_data()
        self.match_result.emit(data)

    def _on_ws_match_scrapped(self) -> None:
        self.in_match = False
        self.in_ban_phase = False
        self.udp.send_to_game({"event": "match_scrapped"})
        self.match_scrapped.emit()

    def _on_game_send_chat(self, message: str) -> None:
        self.ws.send_chat(message)

    def _on_ws_receive_chat(self, message: str, sender_name: str) -> None:
        self.udp.send_to_game({"event": "receive_chat", "message": message, "sender_name": sender_name})

    def _on_game_request_seed_change(self) -> None:
        if not self.in_match:
            return
        self.ws.send_request_seed_change()

    def _on_game_request_draw(self) -> None:
        if not self.in_match:
            return
        self.ws.send_request_draw()

    def _on_game_forfeit(self) -> None:
        if not self.in_match:
            return
        self.ws.send_forfeit()

    def _on_game_close_postmatch(self) -> None:
        self.ws.send_close_postmatch()

    def _on_ws_postmatch_closed(self) -> None:
        self.udp.send_to_game({"event": "postmatch_closed"})

    def _on_ws_receive_seed_change_request(self) -> None:
        self.udp.send_to_game({"event": "receive_seed_change_request"})

    def _on_ws_do_seed_change(self, data: dict) -> None:
        self.udp.send_critical({"event": "do_seed_change", "seed": data.get("seed", "")})

    def _on_ws_receive_draw_request(self) -> None:
        self.udp.send_to_game({"event": "receive_draw_request"})

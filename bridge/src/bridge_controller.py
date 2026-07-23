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
from config import QUEUE_POLL_INTERVAL, BRIDGE_VERSION, BRIDGE_COMPONENT_VERSION
import updater_service

log = logging.getLogger(__name__)


class BridgeController(QObject):
    """Owns networking objects and session state. Bridges WS ↔ UDP."""

    # ---- Session signals ----
    login_success = Signal(dict)    # player data
    login_failed = Signal(str)      # error message
    login_banned = Signal()         # steam id is permanently banned
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
    opponent_progress = Signal(int, int, int) # area, level, theme
    match_result = Signal(dict)     # {result, match_data}
    match_scrapped = Signal()

    # ---- Connection signals ----
    ws_connected = Signal()
    ws_disconnected = Signal()
    game_connected = Signal()
    game_disconnected = Signal()
    seed_changed = Signal()
    match_resumed = Signal(dict)    # WS reconnected mid-match within grace window; payload has match state

    # ---- Version mismatch signals ----
    bridge_version_mismatch = Signal(dict)   # structured mismatch payload
    game_version_mismatch = Signal(dict)     # structured mismatch payload

    # ---- Private room lifecycle signals (forwarded from WS/REST, also relayed to UDP) ----
    room_joined = Signal(dict)          # full room snapshot {room_code, host_id, players, config, phase}
    room_create_failed = Signal(str)    # error code, e.g. "at_capacity"
    room_players_updated = Signal(dict)   # {players, host_id}
    room_config_updated = Signal(dict)
    room_alert = Signal(list)           # issues
    room_starting = Signal(dict)        # {seed, category, config}
    room_live = Signal(dict)            # {players}
    room_progress = Signal(dict)        # {player_id, player_name, area, level, theme}
    room_player_finished = Signal(dict) # {steam_id, player_name, completion_time}
    room_player_forfeited = Signal(dict)# {steam_id, player_name}
    room_result = Signal(dict)          # {participants, finalize_reason}
    room_time_remaining = Signal(int)   # seconds
    room_lobby_reset = Signal(dict)     # same shape as room_joined
    room_closed = Signal(dict)          # {reason}
    room_left = Signal()                # this player's own leave was confirmed
    room_inactivity_warning = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        # Session state
        self.steam_id: str = ""
        self.player_name: str = ""
        self.player_data: dict = {}
        self.in_queue: bool = False
        self.in_ban_phase: bool = False
        self.in_match: bool = False
        self.in_postmatch: bool = False
        self.match_category: str = ""
        self.match_opponent: str = ""
        self.match_opponent_elo: int = 0
        self.placements_remaining: int = -1  # -1 = ranked; 9→0 during placements
        self._rank_reveal_pending: bool = False
        # Set when WS reconnects while in_match/in_ban_phase; cleared by server-sent
        # reconnected/match_scrapped. If still set after a timeout, stale state is cleaned up.
        self._ws_reconnect_pending: bool = False
        # True after sending game_disconnect to server; cleared when game reconnects
        # (sends game_reconnected) or server resolves the match.
        self._game_in_grace: bool = False

        # Private room state. Spans the whole room lifecycle (lobby/starting/live/results);
        # in_room_race narrows to just the "live" phase, mirroring in_match's role for ranked —
        # it gates the shared progress/death/instant_restart/completion/forfeit relay below.
        self.in_room: bool = False
        self.in_room_race: bool = False
        self.room_code: str = ""

        # Login token (server-signed, required for all auth requests)
        self._login_token: str = ""
        self._login_ts: int = 0

        # Server version info (populated during login)
        self._server_version: float = 0.0
        self._game_mod_download_url: str = ""
        self._server_bridge_component_version: str = ""
        self._server_game_component_version: str = ""
        self.last_game_component_version: str = ""
        self.last_version_info: dict = {}

        # Deferred version mismatch — set when a mismatch is detected during an active
        # match so the match isn't interrupted. Emitted when postmatch closes.
        self._pending_version_mismatch: tuple | None = None  # ("bridge"|"game", payload)

        # Whether the WS was deliberately stopped (logout/stop_networking)
        self._ws_intentional_disconnect: bool = False
        # Set when game_disconnect couldn't be sent because WS was down;
        # cleared and retried on the next WS reconnect.
        self._pending_match_disconnect: bool = False

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
        self.ws.rank_reveal.connect(self._on_ws_rank_reveal)
        self.ws.opponent_disconnected.connect(self._on_ws_opponent_disconnected)
        self.ws.opponent_reconnected.connect(self._on_ws_opponent_reconnected)
        self.ws.reconnected.connect(self._on_ws_reconnected)
        self.ws.auto_forfeit.connect(self._on_ws_auto_forfeit)
        self.ws.verify_winner_connection.connect(self._on_ws_verify_winner_connection)
        self.ws.server_error.connect(self._on_ws_server_error)

        # Wire WS signals → controller signals + UDP relay — private rooms
        self.ws.room_joined.connect(self._on_ws_room_joined)
        self.ws.room_players_update.connect(self._on_ws_room_players_update)
        self.ws.room_config_update.connect(self._on_ws_room_config_update)
        self.ws.room_alert.connect(self._on_ws_room_alert)
        self.ws.room_starting.connect(self._on_ws_room_starting)
        self.ws.room_live.connect(self._on_ws_room_live)
        self.ws.room_progress.connect(self._on_ws_room_progress)
        self.ws.room_player_finished.connect(self._on_ws_room_player_finished)
        self.ws.confirm_completion.connect(self._on_ws_confirm_completion)
        self.ws.room_player_forfeited.connect(self._on_ws_room_player_forfeited)
        self.ws.confirm_forfeit.connect(self._on_ws_confirm_forfeit)
        self.ws.room_result.connect(self._on_ws_room_result)
        self.ws.room_time_remaining.connect(self._on_ws_room_time_remaining)
        self.ws.room_lobby_reset.connect(self._on_ws_room_lobby_reset)
        self.ws.room_closed.connect(self._on_ws_room_closed)
        self.ws.confirm_leave.connect(self._on_ws_confirm_leave)
        self.ws.room_inactivity_warning.connect(self._on_ws_room_inactivity_warning)

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
        self.udp.game_rank_reveal_complete.connect(self._on_game_rank_reveal_complete)

        # Wire UDP signals → WS relay — private rooms
        self.udp.game_create_room.connect(self._on_game_create_room)
        self.udp.game_join_room.connect(self._on_game_join_room)
        self.udp.game_leave_room.connect(self._on_game_leave_room)
        self.udp.game_update_room_config.connect(self._on_game_update_room_config)
        self.udp.game_start_room.connect(self._on_game_start_room)
        self.udp.game_room_forfeit.connect(self._on_game_room_forfeit)
        self.udp.game_room_seed_change.connect(self._on_game_room_seed_change)
        self.udp.game_room_force_end.connect(self._on_game_room_force_end)
        self.udp.game_room_dismiss_inactivity_warning.connect(self._on_game_room_dismiss_inactivity_warning)

    def _apply_version_info(self, version_info: dict) -> None:
        component_versions = version_info.get("component_versions", {}) or {}
        self._server_version = version_info.get("version", 0.0)
        self._game_mod_download_url = version_info.get("game_mod_download_url", "")
        self._server_bridge_component_version = updater_service.normalize_version(component_versions.get("bridge", ""))
        self._server_game_component_version = updater_service.normalize_version(component_versions.get("game", ""))
        self.last_version_info = {**version_info, "version_text": updater_service.normalize_version(version_info.get("version", "")), "bridge_component_version": self._server_bridge_component_version, "game_component_version": self._server_game_component_version}

    def _build_version_payload(self, scope: str, bridge_download_url: str = "") -> dict:
        return {
            "scope": scope,
            "standard_version": updater_service.normalize_version(self._server_version),
            "local_bridge_standard": updater_service.normalize_version(BRIDGE_VERSION),
            "local_bridge_component": updater_service.normalize_version(BRIDGE_COMPONENT_VERSION),
            "local_game_component": self.last_game_component_version,
            "server_bridge_component": self._server_bridge_component_version,
            "server_game_component": self._server_game_component_version,
            "bridge_download_url": bridge_download_url,
            "game_download_url": self._game_mod_download_url,
        }

    def _bridge_version_mismatch_detected(self) -> bool:
        if self._server_version and updater_service.normalize_version(self._server_version) != updater_service.normalize_version(BRIDGE_VERSION):
            return True
        if self._server_bridge_component_version and self._server_bridge_component_version != updater_service.normalize_version(BRIDGE_COMPONENT_VERSION):
            return True
        return False

    # ---- Public API ----

    def login(self, steam_id: str, token: str, ts: int) -> None:
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
                self._apply_version_info(version_info)
                bridge_download_url = version_info.get("bridge_download_url", "")
                log.info("Server version=%s bridge_version=%s bridge_component(local=%s server=%s)", updater_service.normalize_version(self._server_version), updater_service.normalize_version(BRIDGE_VERSION), updater_service.normalize_version(BRIDGE_COMPONENT_VERSION), self._server_bridge_component_version or "<none>")

                if self._bridge_version_mismatch_detected():
                    log.warning("Bridge version mismatch — emitting bridge_version_mismatch")
                    self.bridge_version_mismatch.emit(self._build_version_payload("bridge", bridge_download_url))
                    return

                data = api_client.login(steam_id, token, ts)
                if data.get("new_player"):
                    log.info("New player detected, registration needed")
                    self.steam_id = steam_id
                    self._login_token = token
                    self._login_ts = ts
                    self.registration_needed.emit(steam_id)
                else:
                    log.info("Login success for %s (%s)", data.get("player_name"), steam_id)
                    self.steam_id = steam_id
                    self._login_token = token
                    self._login_ts = ts
                    self.player_name = data.get("player_name", "")
                    self.player_data = data
                    self.placements_remaining = data.get("placements_remaining", -1)
                    self.login_success.emit(data)
            except requests.HTTPError as e:
                if e.response is not None and e.response.status_code == 403:
                    log.warning("Login blocked — steam_id is banned: %s", steam_id)
                    self.login_banned.emit()
                else:
                    log.error("Login failed: %s", e)
                    self.login_failed.emit("Server returned an error. Please try again.")
            except requests.RequestException as e:
                log.error("Login failed — could not reach server: %s", e)
                self.login_failed.emit("Could not connect to the server.")
            except Exception as e:
                log.error("Login failed: %s", e)
                self.login_failed.emit("An unexpected error occurred. Please try again.")

        threading.Thread(target=_do, daemon=True).start()

    def register(self, steam_id: str, player_name: str, token: str, ts: int) -> None:
        """Create a new player account with the chosen name. Runs in background thread."""
        def _do():
            try:
                resp = api_client.register_raw(steam_id, player_name, token, ts)
                if resp.status_code != 200:
                    error = resp.json().get("error", "Registration failed")
                    self.registration_failed.emit(error)
                    return
                data = resp.json()
                self.steam_id = steam_id
                self._login_token = token
                self._login_ts = ts
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
        self.ws.connect_to_server(self.steam_id, self._login_token, self._login_ts)

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
            token = self._login_token
            ts = self._login_ts
            threading.Thread(
                target=lambda: api_client.queue_leave(steam_id, token, ts),
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
        self.in_postmatch = False
        self.match_category = ""
        self.match_opponent = ""
        self.match_opponent_elo = 0
        self.placements_remaining = -1
        self._rank_reveal_pending = False
        self._login_token = ""
        self._login_ts = 0
        self._pending_match_disconnect = False
        self._game_in_grace = False
        self._pending_version_mismatch = None
        self.in_room = False
        self.in_room_race = False
        self.room_code = ""

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
        token = self._login_token
        ts = self._login_ts
        def _do():
            try:
                data = api_client.login(self.steam_id, token, ts)
                if not data.get("new_player"):
                    self.player_data = data
                    self.placements_remaining = data.get("placements_remaining", -1)
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
        # If a game_disconnect couldn't be sent while the WS was down, send it now
        # so the server can scrap the match and notify the opponent.
        if self._pending_match_disconnect:
            self._pending_match_disconnect = False
            self.ws.send_game_disconnect()
            if self.in_match or self.in_ban_phase or self.in_room:
                if self.udp.is_game_connected():
                    # Game already reconnected while WS was down — notify server now.
                    self.ws.send_game_reconnected()
                else:
                    self._game_in_grace = True
        elif self.in_match or self.in_ban_phase:
            # WS reconnected while a match was still active on the bridge side.
            # Wait for the server to tell us the outcome — it will send either
            # `reconnected` (live match resumed via grace period) or `match_scrapped`
            # (scrap path). Only if neither arrives within 8 seconds do we self-correct,
            # which covers the rare case where the WS was down >5 min and the server
            # already cleaned up without anything left in its pending-reconnect dicts.
            log.warning(
                "WS reconnected with active match state (in_match=%s in_ban_phase=%s) — waiting for server",
                self.in_match, self.in_ban_phase,
            )
            self._ws_reconnect_pending = True
            QTimer.singleShot(8000, self._check_stale_match_state)
        # Issue 1: if the server removed us from the queue during a WS blip, re-join
        if self.in_queue:
            log.info("WS reconnected while in_queue=True — re-joining queue for %s", self.steam_id)
            steam_id = self.steam_id
            token = self._login_token
            ts = self._login_ts
            def _rejoin():
                try:
                    api_client.queue_join(steam_id, token, ts)
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
        if not self._ws_intentional_disconnect:
            if (self.in_match or self.in_ban_phase) and self.udp.is_game_connected():
                self.udp.send_to_game({"event": "disconnect_detected"})
            # Issue 4: reconnect automatically if this wasn't a deliberate shutdown
            if self.steam_id:
                log.info("Scheduling WS reconnect in 5s for %s", self.steam_id)
                QTimer.singleShot(5000, self._attempt_ws_reconnect)

    def _attempt_ws_reconnect(self) -> None:
        if not self.steam_id or self._ws_intentional_disconnect:
            return

        def _check_and_reconnect():
            # Re-validate bridge version before reconnecting — server may have been
            # updated during the outage. If mismatched, stop and prompt for update.
            # If the HTTP call itself fails, proceed anyway; the WS connect will
            # fail and schedule another retry if the server is still unreachable.
            try:
                version_info = api_client.get_server_version()
                self._apply_version_info(version_info)
                if self._bridge_version_mismatch_detected():
                    payload = self._build_version_payload("bridge", version_info.get("bridge_download_url", ""))
                    if self.in_match or self.in_ban_phase or self.in_postmatch:
                        log.warning("Bridge version mismatch detected mid-match — deferring until postmatch closes")
                        self._pending_version_mismatch = ("bridge", payload)
                    else:
                        log.warning(
                            "Bridge version mismatch on reconnect (bridge=%s/%s server=%s/%s) — stopping",
                            updater_service.normalize_version(BRIDGE_VERSION), updater_service.normalize_version(BRIDGE_COMPONENT_VERSION),
                            updater_service.normalize_version(self._server_version), self._server_bridge_component_version or "<none>",
                        )
                        self._ws_intentional_disconnect = True
                        self.bridge_version_mismatch.emit(payload)
                        return
            except Exception as e:
                log.warning("Version check on reconnect failed (%s) — proceeding", e)

            if not self._ws_intentional_disconnect:
                log.info("Attempting WS reconnect for %s", self.steam_id)
                self.ws.reconnect()

        threading.Thread(target=_check_and_reconnect, daemon=True).start()

    def _check_stale_match_state(self) -> None:
        """Fallback: if the server hasn't resolved our match state 8s after WS reconnect,
        query the server to see if the match is still active. If not, exit match mode
        and notify the game. Never self-scrap or send game_disconnect from here."""
        if not self._ws_reconnect_pending:
            return  # Already resolved by server-sent event
        if not (self.in_match or self.in_ban_phase):
            self._ws_reconnect_pending = False
            return  # Match was already resolved by a handler (e.g. auto_forfeit)
        self._ws_reconnect_pending = False
        log.warning(
            "No server response after WS reconnect (in_match=%s in_ban_phase=%s) — querying server",
            self.in_match, self.in_ban_phase,
        )
        threading.Thread(target=self._query_active_match, args=(1,), daemon=True).start()

    def _query_active_match(self, attempt: int) -> None:
        """Query the server for an active match. If none found, exit match mode.
        Retries up to 3 times (10s apart) if the server reports active (should be impossible)."""
        try:
            active = api_client.check_active_match(self.steam_id, self._login_token, self._login_ts)
        except Exception as e:
            log.error("check_active_match failed (attempt %d) — staying in match mode: %s", attempt, e)
            return
        if not active:
            log.warning(
                "Server has no active match for %s (attempt %d) — exiting match mode, notifying game",
                self.steam_id, attempt,
            )
            self.in_match = False
            self.in_ban_phase = False
            self.udp.send_to_game({"event": "match_not_found"})
            self._emit_pending_version_mismatch()
        elif attempt < 3:
            log.warning(
                "Server still reports active match for %s (attempt %d) — retrying in 10s",
                self.steam_id, attempt,
            )
            t = threading.Timer(10, self._query_active_match, args=(attempt + 1,))
            t.daemon = True
            t.start()
        else:
            log.error(
                "Server still reports active match for %s after %d attempts — giving up, waiting for server resolution",
                self.steam_id, attempt,
            )

    # ---- Game version check ----

    def _on_game_connected(self) -> None:
        """When the game connects over UDP, check if we're in a server grace window."""
        log.info("Game connected over UDP")
        if self._game_in_grace:
            self._game_in_grace = False
            log.info("Game reconnected during server grace — notifying server")
            self.ws.send_game_reconnected()
            self.game_connected.emit()
            return  # Skip version check; match is resuming via server
        self.game_connected.emit()
        self.udp.request_game_version()

    def _on_game_version_received(self, game_version: float, game_component_version: str = "") -> None:
        """Check the game mod version against the server standard and optional component version."""
        self.last_game_component_version = updater_service.normalize_version(game_component_version)
        standard_mismatch = updater_service.normalize_version(game_version) != updater_service.normalize_version(self._server_version)
        component_mismatch = bool(self._server_game_component_version and self.last_game_component_version and self.last_game_component_version != self._server_game_component_version)
        log.info("Game version=%s server_version=%s game_component(local=%s server=%s)", updater_service.normalize_version(game_version), updater_service.normalize_version(self._server_version), self.last_game_component_version or "<none>", self._server_game_component_version or "<none>")
        if standard_mismatch or component_mismatch:
            if self.in_match or self.in_ban_phase or self.in_postmatch:
                log.warning("Game mod version mismatch detected mid-match — deferring until postmatch closes")
                self._pending_version_mismatch = ("game", self._build_version_payload("game"))
                return
            log.warning("Game mod version mismatch")
            self.udp.send_to_game({"event": "version_mismatch"})
            self.stop_networking()
            self.game_version_mismatch.emit(self._build_version_payload("game"))

    # ---- Game → Server relay (UDP events forwarded to WS) ----

    def _on_game_queue_ready(self) -> None:
        log.info("UDP: game_queue_ready received, steam_id=%s", self.steam_id)
        steam_id = self.steam_id
        token = self._login_token
        ts = self._login_ts
        def _do():
            try:
                api_client.queue_join(steam_id, token, ts)
                log.info("Queue join succeeded for %s", steam_id)
                self.in_queue = True
                self.queue_joined.emit()
            except requests.HTTPError as e:
                if e.response is not None and e.response.status_code == 403:
                    log.warning("Queue join rejected — player is banned: %s", steam_id)
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
        if self.in_match or self.in_ban_phase or self.in_room:
            # Notify the server immediately so it can start its grace period
            # and inform the opponent. Bridge stays in match mode and waits
            # for the game to reconnect or the server to resolve the match.
            # For a room, this maps to room_manager.handle_game_disconnect, which skips
            # any grace period and removes the player immediately — see its docstring
            # server-side for why (no mod-side persistence to resync from on relaunch).
            if self.ws.send_game_disconnect():
                self._game_in_grace = True
            else:
                # WS is down — send on reconnect; _on_ws_connected handles _game_in_grace.
                self._pending_match_disconnect = True
        self.game_disconnected.emit()

    def _leave_queue(self) -> None:
        log.info("Leaving queue for steam_id=%s", self.steam_id)
        steam_id = self.steam_id
        token = self._login_token
        ts = self._login_ts
        def _do():
            try:
                api_client.queue_leave(steam_id, token, ts)
                log.info("Queue leave succeeded for %s", steam_id)
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
        # progress/death/instant_restart/completion are shared events — the server tries
        # match_manager first and falls back to room_manager, so the Bridge relays them
        # whenever either a ranked match or a room race is live.
        if not (self.in_match or self.in_room_race):
            return
        self.ws.send_progress(area, level, theme)

    def _on_game_death(self) -> None:
        if not (self.in_match or self.in_room_race):
            return
        self.ws.send_death()

    def _on_game_instant_restart(self) -> None:
        if not (self.in_match or self.in_room_race):
            return
        self.ws.send_instant_restart()

    def _on_game_completion(self) -> None:
        if not (self.in_match or self.in_room_race):
            return
        self.ws.send_completion()

    # ---- Server → Game relay (WS events forwarded to UDP) ----

    def _on_ws_paired(self, data: dict) -> None:
        log.info("WS: paired — opponent=%s elo=%s", data.get("opponent_name"), data.get("opponent_elo"))
        self.in_queue = False
        self.in_ban_phase = True
        self.match_opponent = data.get("opponent_name", "")
        # -1 means the opponent is unranked; store as-is so UI can display "[Unranked]"
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

    def _on_ws_opponent_progress(self, area: int, level: int, theme: int) -> None:
        self.udp.send_to_game({"event": "opponent_progress", "area": area, "level": level, "theme": theme})
        self.opponent_progress.emit(area, level, theme)

    def _on_ws_match_result(self, data: dict) -> None:
        self._ws_reconnect_pending = False
        self._game_in_grace = False
        log.info("WS: match_result — result=%s elo_change=%s", data.get("result"), data.get("elo_change"))
        self.in_match = False
        self.in_ban_phase = False
        self.in_postmatch = True
        placements_remaining = data.get("placements_remaining", -1)
        self.placements_remaining = placements_remaining
        if placements_remaining == 0:
            self._rank_reveal_pending = True
        # Send result to game; include placements_remaining so the game can display it
        udp_payload: dict = {
            "event": "match_result",
            "result": data.get("result", ""),
            "elo_change": data.get("elo_change", 0),
        }
        if placements_remaining >= 0:
            udp_payload["placements_remaining"] = placements_remaining
        self.udp.send_critical(udp_payload)
        # Cache the match
        match_data = data.get("match_data")
        if match_data:
            match_cache.append_match(match_data)
        # Refresh player data after match completes
        self.refresh_player_data()
        self.match_result.emit(data)

    def _on_ws_match_scrapped(self) -> None:
        self._ws_reconnect_pending = False
        self._game_in_grace = False
        self.in_match = False
        self.in_ban_phase = False
        self.udp.send_to_game({"event": "match_scrapped"})
        self.match_scrapped.emit()
        self._emit_pending_version_mismatch()

    def _on_game_send_chat(self, message: str) -> None:
        # Chat is a shared event too — no phase restriction in a room (see specs.md), so
        # in_room alone (not in_room_race) is the right gate here.
        if not (self.in_match or self.in_ban_phase or self.in_postmatch or self.in_room):
            return
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

    # ---- Game → Server relay — private rooms ----

    def _enter_room(self, room: dict) -> None:
        """Shared by the create_room (REST) and join_room (WS) success paths — both hand back
        the same room-snapshot shape (room_joined's payload), just over different transports."""
        self.in_room = True
        self.in_room_race = False
        self.room_code = room.get("room_code", "")
        log.info("Entered private room %s", self.room_code)
        self.udp.send_to_game({"event": "room_joined", **room})
        self.room_joined.emit(room)

    def _on_game_create_room(self) -> None:
        """create_room is the one room action that's a REST call, not a WS event — the server
        has no WS push for the creator, so the HTTP response IS the room snapshot."""
        log.info("UDP: game_create_room received, steam_id=%s", self.steam_id)
        steam_id = self.steam_id
        token = self._login_token
        ts = self._login_ts
        def _do():
            try:
                room = api_client.rooms_create(steam_id, token, ts)
                self._enter_room(room)
            except requests.HTTPError as e:
                code = "could not create room"
                try:
                    code = e.response.json().get("error", code)
                except Exception:
                    pass
                log.warning("Room create rejected: %s", code)
                self.udp.send_to_game({"event": "error", "code": code})
                self.room_create_failed.emit(code)
            except Exception as e:
                log.error("Room create failed: %s", e)
        threading.Thread(target=_do, daemon=True).start()

    def _on_game_join_room(self, room_code: str) -> None:
        self.ws.send_join_room(room_code)

    def _on_game_leave_room(self) -> None:
        if not self.in_room:
            return
        self.ws.send_leave_room()

    def _on_game_update_room_config(self, config: dict) -> None:
        if not self.in_room:
            return
        self.ws.send_update_room_config(config)

    def _on_game_start_room(self) -> None:
        if not self.in_room:
            return
        self.ws.send_start_room()

    def _on_game_room_forfeit(self) -> None:
        if not self.in_room_race:
            return
        self.ws.send_room_forfeit()

    def _on_game_room_seed_change(self) -> None:
        if not self.in_room:
            return
        self.ws.send_room_seed_change()

    def _on_game_room_force_end(self) -> None:
        if not self.in_room_race:
            return
        self.ws.send_room_force_end()

    def _on_game_room_dismiss_inactivity_warning(self) -> None:
        if not self.in_room:
            return
        self.ws.send_room_dismiss_inactivity_warning()

    def _emit_pending_version_mismatch(self) -> None:
        if not self._pending_version_mismatch:
            return
        kind, payload = self._pending_version_mismatch
        self._pending_version_mismatch = None
        log.info("Emitting deferred %s version mismatch after postmatch", kind)
        if kind == "bridge":
            self.stop_networking()
            self.bridge_version_mismatch.emit(payload)
        else:
            self.udp.send_to_game({"event": "version_mismatch"})
            self.stop_networking()
            self.game_version_mismatch.emit(payload)

    def _on_game_close_postmatch(self) -> None:
        self.in_postmatch = False
        self.ws.send_close_postmatch()
        self._emit_pending_version_mismatch()

    def _on_ws_rank_reveal(self, data: dict) -> None:
        """Server fires this after the postmatch window closes on the 10th placement match."""
        log.info("WS: rank_reveal — elo=%s rank=%s", data.get("elo"), data.get("rank_name"))
        self.udp.send_critical({"event": "rank_reveal", "elo": data.get("elo"), "rank_name": data.get("rank_name")})

    def _on_game_rank_reveal_complete(self) -> None:
        """Game has finished the rank reveal animation; acknowledge and navigate to profile."""
        log.info("UDP: rank_reveal_complete from game")
        self._rank_reveal_pending = False
        self.ws.send_rank_reveal_complete()
        self.refresh_player_data()

    def _on_ws_postmatch_closed(self) -> None:
        self.in_postmatch = False
        self.udp.send_to_game({"event": "postmatch_closed"})
        self._emit_pending_version_mismatch()

    def _on_ws_receive_seed_change_request(self) -> None:
        self.udp.send_to_game({"event": "receive_seed_change_request"})

    def _on_ws_do_seed_change(self, data: dict) -> None:
        self.udp.send_critical({"event": "do_seed_change", "seed": data.get("seed", "")})
        self.seed_changed.emit()

    def _on_ws_receive_draw_request(self) -> None:
        self.udp.send_to_game({"event": "receive_draw_request"})

    def _on_ws_opponent_disconnected(self) -> None:
        self.udp.send_to_game({"event": "opponent_disconnected"})

    def _on_ws_opponent_reconnected(self) -> None:
        self.udp.send_to_game({"event": "opponent_reconnected"})

    def _on_ws_reconnected(self, data: dict) -> None:
        self._ws_reconnect_pending = False
        self.in_match = True
        if data.get("opponent_name"):
            self.match_opponent = data["opponent_name"]
            self.match_opponent_elo = data.get("opponent_elo", self.match_opponent_elo)
        if data.get("category"):
            self.match_category = data["category"]
        self.udp.send_to_game({"event": "reconnected", **data})
        self.match_resumed.emit(data)

    def _on_ws_verify_winner_connection(self) -> None:
        """Server asks if bridge and game are both connected (post-grace verification)."""
        if self.udp.is_game_connected():
            self.ws.send_winner_connection_verified()
        else:
            self.ws.send_winner_connection_failed()

    def _on_ws_auto_forfeit(self, data: dict) -> None:
        self._ws_reconnect_pending = False
        self._game_in_grace = False
        self.in_match = False
        self.in_ban_phase = False
        self.in_postmatch = True
        placements_remaining = data.get("placements_remaining", -1)
        if placements_remaining is not None and placements_remaining >= 0:
            self.placements_remaining = placements_remaining
        self.udp.send_critical({
            "event": "auto_forfeit",
            "elo_change": data.get("elo_change", 0),
            "placements_remaining": data.get("placements_remaining"),
        })
        self.refresh_player_data()

    def _on_ws_server_error(self, data: dict) -> None:
        """Generic WS rejection (wrong_phase, or a room-specific code like at_capacity/
        not_found/full/banned/already_in_room/in_queue/already_in_match/not_joinable —
        the same codes routes.py's /rooms/create returns, matched deliberately so main.lua's
        error handler doesn't need to distinguish which transport an error came from)."""
        self.udp.send_to_game({"event": "error", "code": data.get("code", "")})

    # ---- Server → Game relay — private rooms ----

    def _on_ws_room_joined(self, room: dict) -> None:
        log.info("WS: room_joined — room_code=%s", room.get("room_code"))
        self._enter_room(room)

    def _on_ws_room_players_update(self, data: dict) -> None:
        self.udp.send_to_game({"event": "room_players_update", "players": data["players"], "host_id": data["host_id"]})
        self.room_players_updated.emit(data)

    def _on_ws_room_config_update(self, config: dict) -> None:
        self.udp.send_to_game({"event": "room_config_update", "config": config})
        self.room_config_updated.emit(config)

    def _on_ws_room_alert(self, issues: list) -> None:
        self.udp.send_to_game({"event": "room_alert", "issues": issues})
        self.room_alert.emit(issues)

    def _on_ws_room_starting(self, data: dict) -> None:
        log.info("WS: room_starting — category=%s seed=%s", data.get("category"), data.get("seed"))
        # Critical message — retry until ack
        self.udp.send_critical({"event": "room_starting", **data})
        self.room_starting.emit(data)

    def _on_ws_room_live(self, data: dict) -> None:
        log.info("WS: room_live")
        self.in_room_race = True
        # Critical message — retry until ack
        self.udp.send_critical({"event": "room_live", **data})
        self.room_live.emit(data)

    def _on_ws_room_progress(self, data: dict) -> None:
        self.udp.send_to_game({"event": "room_progress", **data})
        self.room_progress.emit(data)

    def _on_ws_room_player_finished(self, data: dict) -> None:
        self.udp.send_to_game({"event": "room_player_finished", **data})
        self.room_player_finished.emit(data)

    def _on_ws_confirm_completion(self, data: dict) -> None:
        self.udp.send_to_game({"event": "confirm_completion", **data})

    def _on_ws_room_player_forfeited(self, data: dict) -> None:
        self.udp.send_to_game({"event": "room_player_forfeited", **data})
        self.room_player_forfeited.emit(data)

    def _on_ws_confirm_forfeit(self, data: dict) -> None:
        self.udp.send_to_game({"event": "confirm_forfeit", **data})

    def _on_ws_room_result(self, data: dict) -> None:
        log.info("WS: room_result — finalize_reason=%s", data.get("finalize_reason"))
        self.in_room_race = False
        self.udp.send_to_game({"event": "room_result", **data})
        self.room_result.emit(data)

    def _on_ws_room_time_remaining(self, seconds: int) -> None:
        self.udp.send_to_game({"event": "room_time_remaining", "seconds": seconds})
        self.room_time_remaining.emit(seconds)

    def _on_ws_room_lobby_reset(self, room: dict) -> None:
        self.room_code = room.get("room_code", self.room_code)
        self.udp.send_to_game({"event": "room_lobby_reset", **room})
        self.room_lobby_reset.emit(room)

    def _on_ws_room_closed(self, data: dict) -> None:
        log.info("WS: room_closed — reason=%s", data.get("reason"))
        self.in_room = False
        self.in_room_race = False
        self.room_code = ""
        self.udp.send_to_game({"event": "room_closed", **data})
        self.room_closed.emit(data)

    def _on_ws_confirm_leave(self) -> None:
        self.in_room = False
        self.in_room_race = False
        self.room_code = ""
        self.udp.send_to_game({"event": "confirm_leave"})
        self.room_left.emit()

    def _on_ws_room_inactivity_warning(self) -> None:
        self.udp.send_to_game({"event": "room_inactivity_warning"})
        self.room_inactivity_warning.emit()

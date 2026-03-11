"""WebSocket client wrapping python-socketio with Qt signals for thread-safe UI updates."""

import threading
import socketio

from PySide6.QtCore import QObject, Signal

from config import WS_URL, WS_NAMESPACE


class WSClient(QObject):
    """Manages the socketio.Client connection to the server's /ws/match namespace.

    Connection runs on a background Python thread. socketio manages its own
    transport threads internally. All server events are re-emitted as Qt
    signals so UI code can connect to them safely.
    """

    # Signals for server → bridge events
    connected = Signal()
    disconnected = Signal()
    paired = Signal(dict)
    ban_update = Signal(list)
    match_start = Signal(dict)
    opponent_progress = Signal(int, int, int)  # area, level, theme
    match_result = Signal(dict)
    match_scrapped = Signal()
    receive_chat = Signal(str, str)  # message, sender_name
    receive_seed_change_request = Signal()
    do_seed_change = Signal(dict)   # {seed}
    receive_draw_request = Signal()
    postmatch_closed = Signal()
    rank_reveal = Signal(dict)      # {elo, rank_name} — fired after 10th placement match
    server_error = Signal(dict)     # {code, event} — server rejected an out-of-phase event
    opponent_disconnected = Signal()       # opponent disconnected; 30s grace window started
    opponent_reconnected = Signal()        # opponent reconnected within grace window
    reconnected = Signal(dict)             # this player reconnected within grace window; match resumes
    auto_forfeit = Signal(dict)            # {elo_change, placements_remaining} — grace expired, forfeit recorded
    verify_winner_connection = Signal()    # server asks: are bridge and game both connected?

    def __init__(self, parent=None):
        super().__init__(parent)
        self._sio: socketio.Client | None = None
        self._steam_id: str = ""
        self._token: str = ""
        self._ts: int = 0
        # Set True during reconnect() while explicitly disconnecting the old client
        # to suppress the re-entrant _on_disconnect → disconnected signal cascade.
        self._reconnecting: bool = False

    def connect_to_server(self, steam_id: str, token: str, ts: int) -> None:
        """Connect to the server WebSocket. Call from main thread."""
        self._steam_id = steam_id
        self._token = token
        self._ts = ts

        sio = socketio.Client(reconnection=False)
        self._sio = sio
        self._register_events(sio)
        threading.Thread(target=self._do_connect, args=(sio,), daemon=True).start()

    def _register_events(self, sio: socketio.Client) -> None:
        sio.on("connect", self._on_connect, namespace=WS_NAMESPACE)
        sio.on("disconnect", self._on_disconnect, namespace=WS_NAMESPACE)
        sio.on("paired", self._on_paired, namespace=WS_NAMESPACE)
        sio.on("ban_update", self._on_ban_update, namespace=WS_NAMESPACE)
        sio.on("match_start", self._on_match_start, namespace=WS_NAMESPACE)
        sio.on("opponent_progress", self._on_opponent_progress, namespace=WS_NAMESPACE)
        sio.on("match_result", self._on_match_result, namespace=WS_NAMESPACE)
        sio.on("match_scrapped", self._on_match_scrapped, namespace=WS_NAMESPACE)
        sio.on("receive_chat", self._on_receive_chat, namespace=WS_NAMESPACE)
        sio.on("receive_seed_change_request", self._on_receive_seed_change_request, namespace=WS_NAMESPACE)
        sio.on("do_seed_change", self._on_do_seed_change, namespace=WS_NAMESPACE)
        sio.on("receive_draw_request", self._on_receive_draw_request, namespace=WS_NAMESPACE)
        sio.on("postmatch_closed", self._on_postmatch_closed, namespace=WS_NAMESPACE)
        sio.on("rank_reveal", self._on_rank_reveal, namespace=WS_NAMESPACE)
        sio.on("error", self._on_server_error, namespace=WS_NAMESPACE)
        sio.on("opponent_disconnected", self._on_opponent_disconnected, namespace=WS_NAMESPACE)
        sio.on("opponent_reconnected", self._on_opponent_reconnected, namespace=WS_NAMESPACE)
        sio.on("reconnected", self._on_reconnected, namespace=WS_NAMESPACE)
        sio.on("auto_forfeit", self._on_auto_forfeit, namespace=WS_NAMESPACE)
        sio.on("verify_winner_connection", self._on_verify_winner_connection, namespace=WS_NAMESPACE)

    def reconnect(self) -> None:
        """Create a fresh client and reconnect. Call from main thread.

        Sets _reconnecting before calling disconnect() on the old client so that
        the synchronous _on_disconnect callback (which fires on this same thread)
        does not emit the disconnected signal and cascade into another reconnect
        attempt via bridge_controller's _on_ws_disconnected handler.
        """
        self._reconnecting = True
        if self._sio:
            try:
                self._sio.disconnect()
            except Exception:
                pass
        self._reconnecting = False

        sio = socketio.Client(reconnection=False)
        self._sio = sio
        self._register_events(sio)
        threading.Thread(target=self._do_connect, args=(sio,), daemon=True).start()

    def disconnect_from_server(self) -> None:
        if self._sio:
            try:
                self._sio.disconnect()
            except Exception:
                pass

    def send_ban(self, category: str) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("ban", {"category": category}, namespace=WS_NAMESPACE)

    def send_progress(self, area: int, level: int, theme: int) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("progress", {"area": area, "level": level, "theme": theme}, namespace=WS_NAMESPACE)

    def send_death(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("death", {}, namespace=WS_NAMESPACE)

    def send_instant_restart(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("instant_restart", {}, namespace=WS_NAMESPACE)

    def send_completion(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("completion", {}, namespace=WS_NAMESPACE)

    def send_chat(self, message: str) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("send_chat", {"message": message}, namespace=WS_NAMESPACE)

    def send_game_disconnect(self) -> bool:
        """Notify the server that the game process disconnected mid-match.
        Returns True if the message was sent, False if the WS was not connected."""
        if self._sio and self._sio.connected:
            self._sio.emit("game_disconnect", {}, namespace=WS_NAMESPACE)
            return True
        return False

    def send_game_reconnected(self) -> None:
        """Notify the server that the game process reconnected during a grace window."""
        if self._sio and self._sio.connected:
            self._sio.emit("game_reconnected", {}, namespace=WS_NAMESPACE)

    def send_request_seed_change(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("request_seed_change", {}, namespace=WS_NAMESPACE)

    def send_request_draw(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("request_draw", {}, namespace=WS_NAMESPACE)

    def send_forfeit(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("forfeit", {}, namespace=WS_NAMESPACE)

    def send_close_postmatch(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("close_postmatch", {}, namespace=WS_NAMESPACE)

    def send_rank_reveal_complete(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("rank_reveal_complete", {}, namespace=WS_NAMESPACE)

    def send_winner_connection_verified(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("winner_connection_verified", {}, namespace=WS_NAMESPACE)

    def send_winner_connection_failed(self) -> None:
        if self._sio and self._sio.connected:
            self._sio.emit("winner_connection_failed", {}, namespace=WS_NAMESPACE)

    # ---- socketio event handlers (called from socketio's internal thread) ----

    def _on_connect(self):
        self.connected.emit()

    def _on_disconnect(self):
        if self._reconnecting:
            return
        self.disconnected.emit()

    def _on_paired(self, data):
        self.paired.emit(data)

    def _on_ban_update(self, data):
        self.ban_update.emit(data.get("categories", []))

    def _on_match_start(self, data):
        self.match_start.emit(data)

    def _on_opponent_progress(self, data):
        self.opponent_progress.emit(data.get("area", 0), data.get("level", 0), data.get("theme", 0))

    def _on_match_result(self, data):
        self.match_result.emit(data)

    def _on_match_scrapped(self, *args):
        self.match_scrapped.emit()

    def _on_receive_chat(self, data):
        self.receive_chat.emit(data.get("message", ""), data.get("sender_name", ""))

    def _on_receive_seed_change_request(self, data=None):
        self.receive_seed_change_request.emit()

    def _on_do_seed_change(self, data):
        self.do_seed_change.emit(data if data else {})

    def _on_receive_draw_request(self, data=None):
        self.receive_draw_request.emit()

    def _on_postmatch_closed(self, data=None):
        self.postmatch_closed.emit()

    def _on_rank_reveal(self, data):
        self.rank_reveal.emit(data if isinstance(data, dict) else {})

    def _on_server_error(self, data):
        import logging
        logging.getLogger(__name__).warning("Server rejected event: %s", data)
        self.server_error.emit(data if isinstance(data, dict) else {})

    def _on_opponent_disconnected(self, data=None):
        self.opponent_disconnected.emit()

    def _on_opponent_reconnected(self, data=None):
        self.opponent_reconnected.emit()

    def _on_reconnected(self, data=None):
        self.reconnected.emit(data if isinstance(data, dict) else {})

    def _on_auto_forfeit(self, data):
        self.auto_forfeit.emit(data if isinstance(data, dict) else {})

    def _on_verify_winner_connection(self, data=None):
        self.verify_winner_connection.emit()

    def _do_connect(self, sio: socketio.Client) -> None:
        """Run on a background thread. Uses the captured sio instance, not self._sio,
        so a later reconnect() call replacing self._sio does not affect this thread.
        Only emits disconnected if this sio is still the active one — prevents a stale
        thread from triggering a reconnect cycle after a newer one has already started."""
        try:
            sio.connect(
                WS_URL,
                namespaces=[WS_NAMESPACE],
                auth={"steam_id": self._steam_id, "token": self._token, "ts": self._ts},
                wait_timeout=10,
            )
        except Exception:
            if sio is self._sio:
                self.disconnected.emit()

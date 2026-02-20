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
    opponent_progress = Signal(int, int)  # area, theme
    match_result = Signal(dict)
    match_scrapped = Signal()
    receive_chat = Signal(str, str)  # message, sender_name
    receive_seed_change_request = Signal()
    do_seed_change = Signal(dict)   # {seed}
    receive_draw_request = Signal()
    postmatch_closed = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._sio: socketio.Client | None = None
        self._steam_id: str = ""

    def connect_to_server(self, steam_id: str) -> None:
        """Connect to the server WebSocket. Call from main thread."""
        self._steam_id = steam_id

        self._sio = socketio.Client(reconnection=True, reconnection_attempts=5)

        # Register event handlers on the namespace
        self._sio.on("connect", self._on_connect, namespace=WS_NAMESPACE)
        self._sio.on("disconnect", self._on_disconnect, namespace=WS_NAMESPACE)
        self._sio.on("paired", self._on_paired, namespace=WS_NAMESPACE)
        self._sio.on("ban_update", self._on_ban_update, namespace=WS_NAMESPACE)
        self._sio.on("match_start", self._on_match_start, namespace=WS_NAMESPACE)
        self._sio.on("opponent_progress", self._on_opponent_progress, namespace=WS_NAMESPACE)
        self._sio.on("match_result", self._on_match_result, namespace=WS_NAMESPACE)
        self._sio.on("match_scrapped", self._on_match_scrapped, namespace=WS_NAMESPACE)
        self._sio.on("receive_chat", self._on_receive_chat, namespace=WS_NAMESPACE)
        self._sio.on("receive_seed_change_request", self._on_receive_seed_change_request, namespace=WS_NAMESPACE)
        self._sio.on("do_seed_change", self._on_do_seed_change, namespace=WS_NAMESPACE)
        self._sio.on("receive_draw_request", self._on_receive_draw_request, namespace=WS_NAMESPACE)
        self._sio.on("postmatch_closed", self._on_postmatch_closed, namespace=WS_NAMESPACE)

        # Run connection on a background thread
        threading.Thread(target=self._do_connect, daemon=True).start()

    def _do_connect(self):
        try:
            self._sio.connect(
                WS_URL,
                namespaces=[WS_NAMESPACE],
                auth={"steam_id": self._steam_id},
                wait_timeout=10,
            )
        except Exception:
            self.disconnected.emit()

    def reconnect(self) -> None:
        """Attempt to reconnect to the server. Call from main thread."""
        if self._sio:
            try:
                self._sio.disconnect()
            except Exception:
                pass
        self._sio = socketio.Client(reconnection=True, reconnection_attempts=5)
        self._sio.on("connect", self._on_connect, namespace=WS_NAMESPACE)
        self._sio.on("disconnect", self._on_disconnect, namespace=WS_NAMESPACE)
        self._sio.on("paired", self._on_paired, namespace=WS_NAMESPACE)
        self._sio.on("ban_update", self._on_ban_update, namespace=WS_NAMESPACE)
        self._sio.on("match_start", self._on_match_start, namespace=WS_NAMESPACE)
        self._sio.on("opponent_progress", self._on_opponent_progress, namespace=WS_NAMESPACE)
        self._sio.on("match_result", self._on_match_result, namespace=WS_NAMESPACE)
        self._sio.on("match_scrapped", self._on_match_scrapped, namespace=WS_NAMESPACE)
        self._sio.on("receive_chat", self._on_receive_chat, namespace=WS_NAMESPACE)
        self._sio.on("receive_seed_change_request", self._on_receive_seed_change_request, namespace=WS_NAMESPACE)
        self._sio.on("do_seed_change", self._on_do_seed_change, namespace=WS_NAMESPACE)
        self._sio.on("receive_draw_request", self._on_receive_draw_request, namespace=WS_NAMESPACE)
        self._sio.on("postmatch_closed", self._on_postmatch_closed, namespace=WS_NAMESPACE)
        threading.Thread(target=self._do_connect, daemon=True).start()

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

    def send_game_disconnect(self) -> None:
        """Notify the server that the game process disconnected mid-match."""
        if self._sio and self._sio.connected:
            self._sio.emit("game_disconnect", {}, namespace=WS_NAMESPACE)

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

    # ---- socketio event handlers (called from socketio's internal thread) ----

    def _on_connect(self):
        self.connected.emit()

    def _on_disconnect(self):
        self.disconnected.emit()

    def _on_paired(self, data):
        self.paired.emit(data)

    def _on_ban_update(self, data):
        self.ban_update.emit(data.get("categories", []))

    def _on_match_start(self, data):
        self.match_start.emit(data)

    def _on_opponent_progress(self, data):
        self.opponent_progress.emit(data.get("area", 0), data.get("theme", 0))

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

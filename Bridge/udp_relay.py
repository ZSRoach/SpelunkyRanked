"""UDP relay for Game <-> Bridge communication with heartbeat.

Both sides listen on known ports. The Game initiates contact by sending
a ping to the Bridge's port. The Bridge only starts its heartbeat pings
after receiving that first message, so nothing is sent when no Game is
running.
"""

import json
import socket
import threading
import time

from PySide6.QtCore import QObject, Signal

from config import (
    UDP_HOST,
    GAME_UDP_PORT,
    BRIDGE_UDP_PORT,
    UDP_BUFFER_SIZE,
    UDP_PING_INTERVAL,
    UDP_PONG_TIMEOUT,
    UDP_RETRY_INTERVAL,
    UDP_RETRY_MAX,
)


class UDPRelay(QObject):
    """Communicates with the Game over UDP.

    The Bridge binds to BRIDGE_UDP_PORT and waits for the Game to send
    the first message.  Once a message arrives, the Game's address is
    captured and heartbeat pings begin.  When the Game stops responding,
    pings stop until the Game makes contact again.
    """

    # Signals for game -> bridge events
    game_queue_ready = Signal()
    game_queue_leave = Signal()
    game_ban = Signal(str)           # category
    game_progress = Signal(int, int, int) # area, level, theme
    game_death = Signal()
    game_instant_restart = Signal()
    game_completion = Signal()
    game_connected = Signal()
    game_disconnected = Signal()
    game_ack = Signal(str)           # ack for event name
    game_version_received = Signal(float)  # game mod version
    game_send_chat = Signal(str)     # message to relay to server
    game_request_seed_change = Signal()
    game_request_draw = Signal()
    game_forfeit = Signal()
    game_close_postmatch = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._sock: socket.socket | None = None
        self._game_addr: tuple[str, int] = (UDP_HOST, GAME_UDP_PORT)
        self._running = False
        self._last_pong_time: float = 0.0
        self._game_alive = False
        self._recv_thread: threading.Thread | None = None
        self._ping_thread: threading.Thread | None = None

    def start(self) -> None:
        """Bind to the Bridge's known port and start listener threads.

        No pings are sent until the Game makes first contact.
        """
        self._sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self._sock.bind((UDP_HOST, BRIDGE_UDP_PORT))
        self._sock.settimeout(1.0)
        self._running = True

        self._recv_thread = threading.Thread(target=self._recv_loop, daemon=True)
        self._recv_thread.start()

        self._ping_thread = threading.Thread(target=self._ping_loop, daemon=True)
        self._ping_thread.start()

    def stop(self) -> None:
        """Shut down the UDP relay."""
        self._running = False
        if self._sock:
            try:
                self._sock.close()
            except Exception:
                pass
            self._sock = None

    def send_to_game(self, data: dict) -> None:
        """Send a JSON message to the Game's server."""
        if self._sock:
            try:
                raw = json.dumps(data).encode("utf-8")
                self._sock.sendto(raw, self._game_addr)
            except Exception:
                pass

    def request_game_version(self) -> None:
        """Ask the Game to report its mod version."""
        self.send_to_game({"event": "version_request"})

    def send_critical(self, data: dict) -> None:
        """Send a critical message with retry-until-ack.

        Retries up to UDP_RETRY_MAX times at UDP_RETRY_INTERVAL intervals.
        Waits for an ack message from the Game with the matching event name.
        """
        event_name = data.get("event", "")

        def _retry():
            for _ in range(UDP_RETRY_MAX):
                self.send_to_game(data)
                # Wait for ack (checked via _ack_received flag)
                time.sleep(UDP_RETRY_INTERVAL)
                if self._ack_received == event_name:
                    self._ack_received = ""
                    return
            # Give up after max retries — message may have been received anyway

        self._ack_received = ""
        threading.Thread(target=_retry, daemon=True).start()

    _ack_received: str = ""

    def _recv_loop(self) -> None:
        while self._running:
            try:
                raw, addr = self._sock.recvfrom(UDP_BUFFER_SIZE)
            except socket.timeout:
                continue
            except OSError as e:
                # On Windows, sending UDP to a port with no listener causes
                # ICMP "port unreachable" to be delivered as WSAECONNRESET
                # (WinError 10054) on the next recvfrom. This is recoverable —
                # keep looping until the Game starts listening.
                if getattr(e, 'winerror', None) == 10054:
                    continue
                break

            try:
                data = json.loads(raw.decode("utf-8"))
            except (json.JSONDecodeError, UnicodeDecodeError):
                continue

            event = data.get("event")
            if not event:
                continue

            if not self._game_alive:
                self._game_alive = True
                self._last_pong_time = time.time()
                self.game_connected.emit()

            if event == "pong":
                self._last_pong_time = time.time()
            elif event == "ping":
                self.send_to_game({"event": "pong"})
                self._last_pong_time = time.time()
            elif event == "ack":
                self._ack_received = data.get("ack_event", "")
                self.game_ack.emit(self._ack_received)
            elif event == "queue_ready":
                self.game_queue_ready.emit()
            elif event == "queue_leave":
                self.game_queue_leave.emit()
            elif event == "ban":
                self.game_ban.emit(data.get("category", ""))
            elif event == "progress":
                self.game_progress.emit(data.get("area", 0), data.get("level", 0), data.get("theme", 0))
            elif event == "death":
                self.game_death.emit()
            elif event == "instant_restart":
                self.game_instant_restart.emit()
            elif event == "completion":
                self.game_completion.emit()
            elif event == "version_response":
                self.game_version_received.emit(float(data.get("version", 0.0)))
            elif event == "send_chat":
                self.game_send_chat.emit(data.get("message", ""))
            elif event == "request_seed_change":
                self.game_request_seed_change.emit()
            elif event == "request_draw":
                self.game_request_draw.emit()
            elif event == "forfeit":
                self.game_forfeit.emit()
            elif event == "close_postmatch":
                self.game_close_postmatch.emit()

    def _ping_loop(self) -> None:
        while self._running:
            time.sleep(UDP_PING_INTERVAL)
            self.send_to_game({"event": "ping"})
            if self._game_alive:
                elapsed = time.time() - self._last_pong_time
                if elapsed > UDP_PONG_TIMEOUT:
                    self._game_alive = False
                    self.game_disconnected.emit()

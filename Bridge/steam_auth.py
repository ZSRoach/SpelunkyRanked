"""Steam OpenID authentication flow.

Opens the user's browser to the server's Steam auth page. The server handles
the OpenID exchange with Steam directly, verifies the assertion, signs the
resulting steam_id, and redirects back to a local HTTP listener with
the steam_id, a server-signed token, and a timestamp.
"""

import threading
import urllib.parse
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler

from PySide6.QtCore import QObject, Signal

from config import SERVER_URL


class _CallbackHandler(BaseHTTPRequestHandler):
    """Captures the server's redirect containing steam_id, token, and ts."""

    result: dict | None = None

    def do_GET(self):
        query = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(query)

        steam_id = params.get("steam_id", [None])[0]
        token = params.get("token", [None])[0]
        ts = params.get("ts", [None])[0]

        if steam_id and token and ts:
            _CallbackHandler.result = {
                "steam_id": steam_id,
                "token": token,
                "ts": int(ts),
            }

        page = b"""<!DOCTYPE html>
<html><head><style>
body { background: #1b2838; color: #c9c9c9; font-family: sans-serif;
       display: flex; justify-content: center; align-items: center;
       height: 100vh; margin: 0; }
p { font-size: 20px; }
</style></head><body>
<p>Authentication complete. You may close this tab.</p>
<script>window.close();</script>
</body></html>"""
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.send_header("Content-Length", str(len(page)))
        self.end_headers()
        self.wfile.write(page)

    def log_message(self, format, *args):
        pass  # Suppress log output


class SteamAuthWorker(QObject):
    """Runs Steam auth on a background thread, emits result via signal."""

    finished = Signal(str, str, int)  # steam_id, token, ts (empty/0 on failure)

    def run(self):
        _CallbackHandler.result = None

        # Start local HTTP server on a free port
        server = HTTPServer(("127.0.0.1", 0), _CallbackHandler)
        port = server.server_address[1]

        # Open browser to server-side Steam auth
        auth_url = f"{SERVER_URL}/auth/steam/begin?port={port}"
        webbrowser.open(auth_url)

        # Wait for the server's callback redirect (2 minute timeout)
        server.timeout = 120
        server.handle_request()
        server.server_close()

        result = _CallbackHandler.result
        if result:
            self.finished.emit(result["steam_id"], result["token"], result["ts"])
        else:
            self.finished.emit("", "", 0)

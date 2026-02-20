"""Steam OpenID authentication flow.

Opens the user's browser to Steam's OpenID login page. A local HTTP server
listens for the callback and extracts the Steam ID from the response.
"""

import re
import threading
import urllib.parse
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler

from PySide6.QtCore import QObject, Signal

# Steam OpenID endpoint
STEAM_OPENID_URL = "https://steamcommunity.com/openid/login"


class _CallbackHandler(BaseHTTPRequestHandler):
    """HTTP request handler that captures the Steam OpenID callback."""

    steam_id: str | None = None

    def do_GET(self):
        query = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(query)

        claimed_id = params.get("openid.claimed_id", [None])[0]
        if claimed_id:
            # Format: https://steamcommunity.com/openid/id/<steam_id>
            match = re.search(r"/openid/id/(\d+)$", claimed_id)
            if match:
                _CallbackHandler.steam_id = match.group(1)

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
    """Runs Steam OpenID auth on a background thread, emits result via signal."""

    finished = Signal(str)  # steam_id or empty string on failure

    def run(self):
        _CallbackHandler.steam_id = None

        # Start local HTTP server on a free port
        server = HTTPServer(("127.0.0.1", 0), _CallbackHandler)
        port = server.server_address[1]
        callback_url = f"http://localhost:{port}/callback"

        # Build Steam OpenID URL
        params = {
            "openid.ns": "http://specs.openid.net/auth/2.0",
            "openid.mode": "checkid_setup",
            "openid.return_to": callback_url,
            "openid.realm": callback_url,
            "openid.identity": "http://specs.openid.net/auth/2.0/identifier_select",
            "openid.claimed_id": "http://specs.openid.net/auth/2.0/identifier_select",
        }
        auth_url = f"{STEAM_OPENID_URL}?{urllib.parse.urlencode(params)}"

        webbrowser.open(auth_url)

        # Wait for single callback request (with timeout)
        server.timeout = 120  # 2 minute timeout
        server.handle_request()
        server.server_close()

        self.finished.emit(_CallbackHandler.steam_id or "")

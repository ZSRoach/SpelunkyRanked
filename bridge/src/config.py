"""Constants for the Bridge application."""

import os
import sys

# Bridge version — must match server VERSION (float)
BRIDGE_VERSION = 1.20

BRIDGE_COMPONENT_VERSION = "1.20.0"
GAME_COMPONENT_VERSION = "1.20.0" #fallback, mostly ignored
GITHUB_OWNER = "ZSRoach"
GITHUB_REPO = "SpelunkyRanked"
LATEST_RELEASE_API = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases/latest"
GITHUB_RELEASES_PAGE = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/releases"
BRIDGE_ASSET_NAME = "S2Ranked.zip"
GAME_ASSET_NAME = "SpelunkyRanked.zip"
APP_FOLDER_NAME = "Ranked App"
MOD_SUBPATH = os.path.join("Mods", "Packs", "SpelunkyRanked")

# Server connection — HTTPS is always enforced even if the env var is set to http://
def _ensure_https(url: str) -> str:
    if url.startswith("http://"):
        return "https://" + url[7:]
    return url

SERVER_URL = _ensure_https(os.environ.get("SPEEDRUN_SERVER_URL", "https://spelunkyranked.duckdns.org"))
WS_URL = _ensure_https(os.environ.get("SPEEDRUN_WS_URL", "https://spelunkyranked.duckdns.org"))
WS_NAMESPACE = "/ws/match"

# UDP — both sides listen on known ports
UDP_HOST = "127.0.0.1"
GAME_UDP_PORT = 21587
BRIDGE_UDP_PORT = 21588
UDP_BUFFER_SIZE = 4096

# Timing (seconds)
QUEUE_POLL_INTERVAL = 15  # seconds between /matches/active polls
FINISHED_MATCH_DISPLAY_SECONDS = 60  # seconds to show finished matches on active page
UDP_PING_INTERVAL = 2.5   # seconds between pings to Game
UDP_PONG_TIMEOUT = 5.0     # seconds before considering Game disconnected
UDP_RETRY_INTERVAL = 0.5   # seconds between critical message retries
UDP_RETRY_MAX = 5           # max retry attempts for critical messages

# Local file storage — relative to executable for PyInstaller
if getattr(sys, "frozen", False):
    _BASE_DIR = os.path.dirname(sys.executable)
    _BUNDLE_DIR = sys._MEIPASS
else:
    _BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    _BUNDLE_DIR = _BASE_DIR

MATCH_CACHE_PATH = os.path.join(_BASE_DIR, "match_cache.json")
SETTINGS_PATH = os.path.join(_BASE_DIR, "settings.json")
ASSETS_DIR = os.path.join(_BUNDLE_DIR, "assets")

PLACEMENT_MATCHES_REQUIRED = 10

# Default settings
DEFAULT_OVERLAY_COLOR = "#00FF00"


def format_time(seconds: float) -> str:
    """Format seconds as m:ss.000 (e.g. 1:23.450)."""
    mins = int(seconds // 60)
    secs = seconds % 60
    return f"{mins}:{secs:06.3f}"


def relative_time(match_start_time: str) -> str:
    """Return a human-readable relative time like '4 minutes ago'."""
    from datetime import datetime, timezone
    if not match_start_time:
        return ""
    try:
        dt = datetime.fromisoformat(match_start_time)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        diff = int((datetime.now(timezone.utc) - dt).total_seconds())
        if diff < 60:
            return "just now"
        minutes = diff // 60
        if minutes < 60:
            return f"{minutes} minute{'s' if minutes != 1 else ''} ago"
        hours = minutes // 60
        if hours < 24:
            return f"{hours} hour{'s' if hours != 1 else ''} ago"
        days = hours // 24
        return f"{days} day{'s' if days != 1 else ''} ago"
    except Exception:
        return ""


def full_match_datetime(match_start_time: str) -> str:
    """Return a full date/time string like 'Played on April 17, 2024 at 3:10 PM'."""
    from datetime import datetime, timezone
    if not match_start_time:
        return ""
    try:
        dt = datetime.fromisoformat(match_start_time)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        local = dt.astimezone()
        hour = local.hour % 12 or 12
        minute = local.strftime("%M")
        am_pm = "AM" if local.hour < 12 else "PM"
        return f"Played on {local.strftime('%B')} {local.day}, {local.year} at {hour}:{minute} {am_pm}"
    except Exception:
        return ""

# ---- UI Colors ----
CLR_UNRANKED = "#b8a07a"       # "[Unranked]" text color
CLR_MAIN_BG = "#191b36"        # main window background
CLR_WIDGET_BG = "#23264a"      # sidebar, widget/card backgrounds
CLR_BUTTON_BG = "#323666"      # button, table header backgrounds
CLR_ACTIVE_BTN = "#3c6bc2"     # active/checked button
CLR_TEXT = "#c9c9c9"           # regular text
CLR_TEXT_BRIGHT = "#ffffff"    # times and category names

# Rank name text colors (keyed by rank name from RANK_THRESHOLDS)
RANK_COLORS = {
    "gold": "#f0d229",
    "emerald": "#1bc908",
    "sapphire": "#11b2f2",
    "ruby": "#f21142",
    "diamond": "#ebebeb",
    "cosmic": "#5c40db",
}
COSMIC_GRADIENT = ("5c40db", "4061db")  # for QSS gradient stops

# Spelunky 2 theme IDs → display names
# Theme IDs match state.theme from the game engine
THEME_NAMES = {
    1: "Dwelling",
    2: "Jungle",
    3: "Volcana",
    4: "Olmec",
    5: "Tide Pool",
    6: "Temple",
    7: "Ice Caves",
    8: "Neo Babylon",
    9: "Sunken City",
    10: "Cosmic Ocean",
}

# Rank thresholds: (name, min_elo, max_elo) — None means no ceiling
RANK_THRESHOLDS = [
    ("gold", 0, 299),
    ("emerald", 300, 599),
    ("sapphire", 600, 899),
    ("ruby", 900, 1199),
    ("diamond", 1200, 1599),
    ("cosmic", 1600, None),
]

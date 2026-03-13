"""Persistent settings stored in settings.json next to the executable."""

import base64
import json
import os

import win32crypt

from config import SETTINGS_PATH, DEFAULT_OVERLAY_COLOR


def _protect(value: str) -> str:
    """Encrypt a string with Windows DPAPI (current user scope)."""
    encrypted = win32crypt.CryptProtectData(value.encode(), None, None, None, None, 0)
    return base64.b64encode(encrypted).decode()


def _unprotect(value: str) -> str | None:
    """Decrypt a DPAPI-encrypted string. Returns None if decryption fails."""
    try:
        _, decrypted = win32crypt.CryptUnprotectData(
            base64.b64decode(value), None, None, None, 0
        )
        return decrypted.decode()
    except Exception:
        return None


def _load() -> dict:
    if os.path.exists(SETTINGS_PATH):
        with open(SETTINGS_PATH, "r") as f:
            return json.load(f)
    return {}


def _save(data: dict) -> None:
    with open(SETTINGS_PATH, "w") as f:
        json.dump(data, f, indent=2)


def get_overlay_color() -> str:
    data = _load()
    return data.get("overlay_color", DEFAULT_OVERLAY_COLOR)


def get_overlay_always_on_top() -> bool:
    return _load().get("overlay_always_on_top", True)


def set_overlay_always_on_top(value: bool) -> None:
    data = _load()
    data["overlay_always_on_top"] = value
    _save(data)


def set_overlay_color(color: str) -> None:
    data = _load()
    data["overlay_color"] = color
    _save(data)


def get_login_creds() -> tuple[str, str, int] | None:
    """Return (steam_id, token, ts) from stored credentials, or None if absent/unreadable."""
    data = _load()
    blob = data.get("login_creds", "")
    if not blob:
        return None
    plaintext = _unprotect(blob)
    if not plaintext:
        return None
    try:
        steam_id, token, ts_str = plaintext.split("|", 2)
        return steam_id, token, int(ts_str)
    except Exception:
        return None


def set_login_creds(steam_id: str, token: str, ts: int) -> None:
    """DPAPI-encrypt and store the login credentials."""
    plaintext = f"{steam_id}|{token}|{ts}"
    data = _load()
    data["login_creds"] = _protect(plaintext)
    _save(data)


def is_creds_tampered() -> bool:
    """Return True if the login_creds blob cannot be decrypted.

    DPAPI decryption fails if the ciphertext was modified externally.
    A valid token still requires server-side HMAC verification on login.
    """
    data = _load()
    blob = data.get("login_creds", "")
    if not blob:
        return False
    return _unprotect(blob) is None


def clear_login_creds() -> None:
    data = _load()
    data.pop("login_creds", None)
    _save(data)

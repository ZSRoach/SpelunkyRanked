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


def set_overlay_color(color: str) -> None:
    data = _load()
    data["overlay_color"] = color
    _save(data)


def get_steam_id() -> str:
    """Return the decrypted steam_id, or empty string if absent or unreadable."""
    data = _load()
    blob = data.get("steam_id", "")
    if not blob:
        return ""
    return _unprotect(blob) or ""


def set_steam_id(steam_id: str) -> None:
    data = _load()
    data["steam_id"] = _protect(steam_id)
    _save(data)


def is_steam_id_tampered() -> bool:
    """Return True if the steam_id blob in settings.json cannot be decrypted.

    DPAPI decryption fails if the ciphertext was modified, copied from another
    machine, or belongs to a different Windows user — all forms of tampering.
    """
    data = _load()
    blob = data.get("steam_id", "")
    if not blob:
        return False
    return _unprotect(blob) is None


def clear_steam_id() -> None:
    data = _load()
    data.pop("steam_id", None)
    _save(data)

"""Persistent settings stored in settings.json next to the executable."""

import json
import os

from config import SETTINGS_PATH, DEFAULT_OVERLAY_COLOR


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
    data = _load()
    return data.get("steam_id", "")


def set_steam_id(steam_id: str) -> None:
    data = _load()
    data["steam_id"] = steam_id
    _save(data)


def clear_steam_id() -> None:
    data = _load()
    data.pop("steam_id", None)
    _save(data)

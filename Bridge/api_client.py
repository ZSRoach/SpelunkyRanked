"""REST client for Server communication. All calls are synchronous (use from worker threads)."""

import requests

from config import SERVER_URL


def get_server_version() -> dict:
    resp = requests.get(f"{SERVER_URL}/version", timeout=10)
    resp.raise_for_status()
    return resp.json()


def login(steam_id: str) -> dict:
    resp = requests.post(
        f"{SERVER_URL}/auth/login",
        json={"steam_id": steam_id},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def register(steam_id: str, player_name: str) -> dict:
    resp = requests.post(
        f"{SERVER_URL}/auth/register",
        json={"steam_id": steam_id, "player_name": player_name},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def register_raw(steam_id: str, player_name: str) -> requests.Response:
    """Like register() but returns the raw Response so the caller can inspect status codes."""
    return requests.post(
        f"{SERVER_URL}/auth/register",
        json={"steam_id": steam_id, "player_name": player_name},
        timeout=10,
    )


def queue_join(steam_id: str) -> dict:
    resp = requests.post(
        f"{SERVER_URL}/queue/join",
        json={"steam_id": steam_id},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def queue_leave(steam_id: str) -> dict:
    resp = requests.post(
        f"{SERVER_URL}/queue/leave",
        json={"steam_id": steam_id},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def queue_stats() -> dict:
    resp = requests.get(f"{SERVER_URL}/queue/stats", timeout=10)
    resp.raise_for_status()
    return resp.json()


def get_active_matches() -> dict:
    resp = requests.get(f"{SERVER_URL}/matches/active", timeout=10)
    resp.raise_for_status()
    return resp.json()


def get_matches(player_id: str | None = None, offset: int = 0, limit: int = 10) -> list[dict]:
    params: dict = {"offset": offset, "limit": limit}
    if player_id:
        params["player_id"] = player_id
    resp = requests.get(f"{SERVER_URL}/matches", params=params, timeout=10)
    resp.raise_for_status()
    return resp.json().get("matches", [])


def get_leaderboard() -> list[dict]:
    resp = requests.get(f"{SERVER_URL}/leaderboard", timeout=10)
    resp.raise_for_status()
    return resp.json().get("players", [])


def get_fastest_times() -> dict:
    resp = requests.get(f"{SERVER_URL}/leaderboard/fastest", timeout=10)
    resp.raise_for_status()
    return resp.json().get("fastest_times", {})

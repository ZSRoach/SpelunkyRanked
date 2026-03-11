"""REST client for Server communication. All calls are synchronous (use from worker threads)."""

import requests

from config import SERVER_URL


def get_server_version() -> dict:
    resp = requests.get(f"{SERVER_URL}/version", timeout=10)
    resp.raise_for_status()
    return resp.json()


def login(steam_id: str, token: str, ts: int) -> dict:
    resp = requests.post(
        f"{SERVER_URL}/auth/login",
        json={"steam_id": steam_id, "token": token, "ts": ts},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def register_raw(steam_id: str, player_name: str, token: str, ts: int) -> requests.Response:
    """Like register() but returns the raw Response so the caller can inspect status codes."""
    return requests.post(
        f"{SERVER_URL}/auth/register",
        json={"steam_id": steam_id, "player_name": player_name, "token": token, "ts": ts},
        timeout=10,
    )


def queue_join(steam_id: str, token: str, ts: int) -> dict:
    resp = requests.post(
        f"{SERVER_URL}/queue/join",
        json={"steam_id": steam_id, "token": token, "ts": ts},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def queue_leave(steam_id: str, token: str, ts: int) -> dict:
    resp = requests.post(
        f"{SERVER_URL}/queue/leave",
        json={"steam_id": steam_id, "token": token, "ts": ts},
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


def get_seasons() -> dict:
    resp = requests.get(f"{SERVER_URL}/seasons", timeout=10)
    resp.raise_for_status()
    return resp.json()


def get_leaderboard(season: int | None = None) -> list[dict]:
    params = {}
    if season is not None:
        params["season"] = season
    resp = requests.get(f"{SERVER_URL}/leaderboard", params=params, timeout=10)
    resp.raise_for_status()
    return resp.json().get("players", [])


def get_fastest_times(season: int | str | None = None) -> dict:
    params = {}
    if season is not None:
        params["season"] = season
    resp = requests.get(f"{SERVER_URL}/leaderboard/fastest", params=params, timeout=10)
    resp.raise_for_status()
    return resp.json().get("fastest_times", {})


def check_active_match(steam_id: str, token: str, ts: int) -> bool:
    resp = requests.get(
        f"{SERVER_URL}/matches/mine",
        params={"steam_id": steam_id, "token": token, "ts": ts},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json().get("active", False)


def get_player_season_stats(steam_id: str, season: int) -> dict:
    resp = requests.get(
        f"{SERVER_URL}/profile/stats",
        params={"steam_id": steam_id, "season": season},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()

"""Local match cache stored in match_cache.json next to the executable."""

import json
import os

from config import MATCH_CACHE_PATH


def load_cached_matches() -> list[dict]:
    if os.path.exists(MATCH_CACHE_PATH):
        with open(MATCH_CACHE_PATH, "r") as f:
            return json.load(f)
    return []


def save_cached_matches(matches: list[dict]) -> None:
    with open(MATCH_CACHE_PATH, "w") as f:
        json.dump(matches, f, indent=2)


def append_match(match_data: dict) -> None:
    matches = load_cached_matches()
    # Avoid duplicates by match_id
    existing_ids = {m["match_id"] for m in matches}
    if match_data.get("match_id") not in existing_ids:
        matches.insert(0, match_data)  # newest first
        save_cached_matches(matches)


def normalize_match_pov(match: dict, my_id: str) -> dict:
    """Return a copy of match with p1/p2 fields swapped if my_id is player 2.

    Ensures the current user always appears on the left side. If my_id is not
    in the match or is already player 1, returns a copy unchanged. Idempotent.
    """
    if not my_id or match.get("player_2_id") != my_id:
        return dict(match)
    m = dict(match)
    for suffix in ("id", "name", "elo", "elo_change", "placements_completed", "area", "theme"):
        k1, k2 = f"player_1_{suffix}", f"player_2_{suffix}"
        if k1 in m or k2 in m:
            m[k1], m[k2] = m.get(k2), m.get(k1)
    return m

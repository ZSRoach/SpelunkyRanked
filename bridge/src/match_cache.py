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

"""Tiny JSON-backed best-turn-count tracker, one entry per difficulty."""

import json
import os

DEFAULT_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "scores.json")


def load_scores(path=DEFAULT_PATH):
    if not os.path.exists(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as fh:
            return json.load(fh)
    except (json.JSONDecodeError, OSError):
        return {}


def record_win(difficulty, turns, path=DEFAULT_PATH):
    """Save ``turns`` as the best score for ``difficulty`` if it beats (or
    is the first for) the existing record. Returns (is_new_best, best)."""
    scores = load_scores(path)
    best = scores.get(difficulty)
    is_new_best = best is None or turns < best
    if is_new_best:
        scores[difficulty] = turns
        try:
            with open(path, "w", encoding="utf-8") as fh:
                json.dump(scores, fh, indent=2, sort_keys=True)
        except OSError:
            pass
    return is_new_best, scores.get(difficulty, turns)

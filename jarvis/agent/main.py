"""JARVIS server. Step 1: `python3 agent/main.py index` prints what was found."""
import sys
import data
from vault import Vault


def cmd_index():
    v = Vault(data.folders())
    print(f"mode: {'DEMO' if data.DEMO else 'REAL'}  roots: {[str(r) for r in data.folders()]}")
    print(f"{len(v.nodes)} notes, {len(v.edges)} links, {v.skipped} skipped (>2MB)\n")
    print("by type:")
    for t, c in v.counts().most_common():
        print(f"  {t:<12}{c}")
    print("\ntop 10 hubs:")
    for n in v.hubs():
        print(f"  {n['degree']:>3}  {n['title']}  ({n['type']})")


if __name__ == "__main__":
    {"index": cmd_index}.get(sys.argv[1] if len(sys.argv) > 1 else "index", cmd_index)()

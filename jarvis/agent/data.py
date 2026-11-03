"""THE ONLY FILE THAT TOUCHES REAL DATA, and the only one that reads JARVIS_DEMO.

JARVIS_DEMO=1 (default) -> invented fixtures in data/demo
JARVIS_DEMO=0           -> folders listed in JARVIS_FOLDERS (os.pathsep-separated)
"""
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def _load_env():
    env = ROOT / ".env"
    if env.exists():
        for line in env.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))


_load_env()
DEMO = os.environ.get("JARVIS_DEMO", "1") != "0"


def folders():
    """Read-only roots to index."""
    if DEMO:
        return [ROOT / "data" / "demo"]
    raw = os.environ.get("JARVIS_FOLDERS", "")
    return [Path(p).expanduser() for p in raw.split(os.pathsep) if p.strip()]

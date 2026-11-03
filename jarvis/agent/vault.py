"""Folders -> searchable graph. Strictly read-only."""
import re
import zlib
from collections import Counter
from pathlib import Path

EXTS = {".md", ".markdown", ".txt", ".pdf"}
SKIP_DIRS = {"node_modules", ".git", "__pycache__", ".obsidian"}
MAX_BYTES = 2 * 1024 * 1024
WIKI = re.compile(r"\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]")
FRONT = re.compile(r"\A---\n(.*?)\n---\n", re.S)


def _pdf_text(raw: bytes) -> str:
    """Best-effort stdlib PDF text: inflate streams, pull Tj/TJ strings."""
    out = []
    for m in re.finditer(rb"stream\r?\n(.*?)\r?\nendstream", raw, re.S):
        data = m.group(1)
        try:
            data = zlib.decompress(data)
        except Exception:
            pass
        for s in re.findall(rb"\((.*?)(?<!\\)\)", data):
            t = s.decode("latin-1", "ignore")
            if re.search(r"[A-Za-z]{2}", t):
                out.append(t)
    return " ".join(out)


def _read(p: Path) -> str:
    raw = p.read_bytes()
    if p.suffix.lower() == ".pdf":
        return _pdf_text(raw)
    return raw.decode("utf-8", "ignore")


def _type_of(rel: Path, text: str) -> str:
    m = FRONT.match(text)
    if m:
        t = re.search(r"^type:\s*(\S+)", m.group(1), re.M)
        if t:
            return t.group(1).lower()
    if rel.suffix.lower() == ".pdf":
        return "pdf"
    return rel.parts[0].lower().rstrip("s") if len(rel.parts) > 1 else "note"


class Vault:
    def __init__(self, roots):
        self.nodes = {}   # id -> dict
        self.edges = set()
        self.roots = [Path(r) for r in roots]
        self.skipped = 0
        self._build()

    def _build(self):
        stems = {}
        for root in self.roots:
            if not root.exists():
                continue
            for p in sorted(root.rglob("*")):
                if any(part in SKIP_DIRS for part in p.parts) or not p.is_file():
                    continue
                if p.suffix.lower() not in EXTS:
                    continue
                if p.stat().st_size > MAX_BYTES:
                    self.skipped += 1
                    continue
                text = _read(p)
                rel = p.relative_to(root)
                nid = f"{root.name}/{rel}"
                h1 = re.search(r"^#\s+(.+)$", text, re.M)
                self.nodes[nid] = {
                    "id": nid, "title": h1.group(1).strip() if h1 else p.stem,
                    "type": _type_of(rel, text), "path": str(p), "text": text,
                    "links": WIKI.findall(text),
                }
                stems[p.stem.lower()] = nid
                stems[self.nodes[nid]["title"].lower()] = nid
        for nid, n in self.nodes.items():
            for l in n["links"]:
                tgt = stems.get(l.strip().lower())
                if tgt and tgt != nid:
                    self.edges.add(tuple(sorted((nid, tgt))))
        deg = Counter()
        for a, b in self.edges:
            deg[a] += 1
            deg[b] += 1
        for nid, n in self.nodes.items():
            n["degree"] = deg[nid]

    def counts(self):
        return Counter(n["type"] for n in self.nodes.values())

    def hubs(self, k=10):
        return sorted(self.nodes.values(), key=lambda n: -n["degree"])[:k]

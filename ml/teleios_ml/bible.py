"""Lectura de la Biblia de la app (assets/bible/rv1909.sqlite.gz): versículos y referencias cruzadas."""

from __future__ import annotations

import gzip
import shutil
import sqlite3
import tempfile
from functools import lru_cache
from pathlib import Path

from . import APP

ASSET = APP / "assets" / "bible" / "rv1909.sqlite.gz"

CANON = [
    "GEN", "EXO", "LEV", "NUM", "DEU", "JOS", "JDG", "RUT", "1SA", "2SA", "1KI", "2KI",
    "1CH", "2CH", "EZR", "NEH", "EST", "JOB", "PSA", "PRO", "ECC", "SOL", "ISA", "JER",
    "LAM", "EZE", "DAN", "HOS", "JOE", "AMO", "OBA", "JON", "MIC", "NAH", "HAB", "ZEP",
    "HAG", "ZEC", "MAL", "MAT", "MAR", "LUK", "JOH", "ACT", "ROM", "1CO", "2CO", "GAL",
    "EPH", "PHI", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAM", "1PE",
    "2PE", "1JO", "2JO", "3JO", "JUD", "REV",
]


def verse_id(book: str, ch: int, vs: int) -> int:
    return (CANON.index(book) + 1) * 1_000_000 + ch * 1_000 + vs


@lru_cache(maxsize=1)
def connect() -> sqlite3.Connection:
    tmp = Path(tempfile.gettempdir()) / "teleios_rv1909.sqlite"
    if not tmp.exists() or tmp.stat().st_mtime < ASSET.stat().st_mtime:
        with gzip.open(ASSET, "rb") as src, open(tmp, "wb") as dst:
            shutil.copyfileobj(src, dst)
    return sqlite3.connect(tmp, check_same_thread=False)


def text(vid: int) -> str:
    row = connect().execute("SELECT text FROM verses WHERE id = ?", (vid,)).fetchone()
    return row[0] if row else ""


def label(vid: int) -> str:
    row = connect().execute("SELECT book, chapter, verse FROM verses WHERE id = ?", (vid,)).fetchone()
    return f"{row[0]} {row[1]}:{row[2]}" if row else str(vid)


def all_verses() -> list[tuple[int, str]]:
    """(id, texto) de los 31 102 versículos en orden canónico; los vacíos (fusionados) incluidos."""
    return connect().execute("SELECT id, text FROM verses ORDER BY id").fetchall()


def crossrefs(vid: int, limit: int = 5) -> list[tuple[int, int]]:
    return connect().execute(
        "SELECT dst, votes FROM crossrefs WHERE src = ? ORDER BY votes DESC LIMIT ?", (vid, limit)
    ).fetchall()

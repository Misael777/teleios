"""Genera assets/bible/rv1909.sqlite.gz a partir del texto VPL de eBible.org.

Fuente: Reina-Valera 1909 (dominio público) — https://ebible.org/details.php?id=spaRV1909
Formato de entrada (spaRV1909_vpl.txt): "GEN 1:1 EN el principio crió Dios..."

Uso:
    python tool/build_bible_db.py            # descarga la fuente y genera el asset
    python tool/build_bible_db.py ruta.txt   # usa un VPL ya descargado

El archivo resultante es de solo lectura y NO se cifra: es texto público.
"""

import gzip
import io
import os
import re
import shutil
import sqlite3
import sys
import tempfile
import urllib.request
import zipfile

SOURCE_URL = "https://ebible.org/Scriptures/spaRV1909_vpl.zip"
SCHEMA_VERSION = 1  # tool/add_crossrefs.py lo sube a 2 (referencias cruzadas)
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "bible", "rv1909.sqlite.gz")

# Orden canónico protestante (66 libros). Debe coincidir con lib/shared/domain/bible_books.dart.
CANON = [
    "GEN", "EXO", "LEV", "NUM", "DEU", "JOS", "JDG", "RUT", "1SA", "2SA", "1KI", "2KI",
    "1CH", "2CH", "EZR", "NEH", "EST", "JOB", "PSA", "PRO", "ECC", "SOL", "ISA", "JER",
    "LAM", "EZE", "DAN", "HOS", "JOE", "AMO", "OBA", "JON", "MIC", "NAH", "HAB", "ZEP",
    "HAG", "ZEC", "MAL", "MAT", "MAR", "LUK", "JOH", "ACT", "ROM", "1CO", "2CO", "GAL",
    "EPH", "PHI", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAM", "1PE",
    "2PE", "1JO", "2JO", "3JO", "JUD", "REV",
]

# Algunas líneas vienen vacías: la RV1909 fusiona ciertos versículos con el anterior.
# Se conservan con texto vacío para que la numeración sea estable.
LINE = re.compile(r"^(\w{3}) (\d+):(\d+) ?(.*)$")


def read_source(path: str | None) -> str:
    if path:
        with open(path, encoding="utf-8-sig") as f:
            return f.read()
    print(f"Descargando {SOURCE_URL} ...")
    with urllib.request.urlopen(SOURCE_URL) as resp:
        data = resp.read()
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        return z.read("spaRV1909_vpl.txt").decode("utf-8-sig")


def build(text: str, db_path: str) -> int:
    con = sqlite3.connect(db_path)
    con.executescript(
        """
        PRAGMA page_size = 4096;
        CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
        CREATE TABLE verses (
          id      INTEGER PRIMARY KEY,
          book    TEXT    NOT NULL,
          chapter INTEGER NOT NULL,
          verse   INTEGER NOT NULL,
          text    TEXT    NOT NULL,
          UNIQUE (book, chapter, verse)
        );
        CREATE VIRTUAL TABLE verses_fts USING fts5(
          text, content='verses', content_rowid='id',
          tokenize = 'unicode61 remove_diacritics 2'
        );
        """
    )
    order = {code: i for i, code in enumerate(CANON)}
    rows = []
    for raw in text.splitlines():
        m = LINE.match(raw.strip())
        if not m:
            continue
        book, ch, vs, body = m.group(1), int(m.group(2)), int(m.group(3)), m.group(4).strip()
        if book not in order:
            raise ValueError(f"Libro desconocido: {book}")
        # id ordenable: libro(2) capítulo(3) versículo(3) → 01001001
        rows.append(((order[book] + 1) * 1_000_000 + ch * 1_000 + vs, book, ch, vs, body))

    rows.sort()
    con.executemany("INSERT INTO verses VALUES (?,?,?,?,?)", rows)
    con.execute("INSERT INTO verses_fts(verses_fts) VALUES ('rebuild')")
    con.executemany(
        "INSERT INTO meta VALUES (?,?)",
        [
            ("schema_version", str(SCHEMA_VERSION)),
            ("translation", "RV1909"),
            ("license", "Dominio público"),
            ("source", "https://ebible.org/details.php?id=spaRV1909"),
        ],
    )
    con.commit()
    con.execute("VACUUM")
    con.close()
    return len(rows)


def main() -> None:
    text = read_source(sys.argv[1] if len(sys.argv) > 1 else None)
    with tempfile.TemporaryDirectory() as tmp:
        db_path = os.path.join(tmp, "rv1909.sqlite")
        count = build(text, db_path)
        if count != 31102:
            raise SystemExit(f"Se esperaban 31102 versiculos y se obtuvieron {count}")
        os.makedirs(os.path.dirname(OUT), exist_ok=True)
        with open(db_path, "rb") as src, gzip.open(OUT, "wb", compresslevel=9) as dst:
            shutil.copyfileobj(src, dst)
        raw_size = os.path.getsize(db_path)
    print(f"OK: {count} versiculos | {raw_size / 1e6:.1f} MB -> {os.path.getsize(OUT) / 1e6:.1f} MB gz")


if __name__ == "__main__":
    main()

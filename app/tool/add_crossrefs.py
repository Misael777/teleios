"""Agrega las referencias cruzadas de OpenBible.info a assets/bible/rv1909.sqlite.gz (esquema 2).

Fuente: https://www.openbible.info/labs/cross-references/ (CC-BY). Cada referencia trae los votos de
la comunidad: ponderan el soporte canónico (docs/PLAN-COHERENCIA.md §4.1). Llevan el sesgo de su
tradición; se declara en la app.

Uso:
    python tool/add_crossrefs.py                 # descarga la fuente
    python tool/add_crossrefs.py cross_refs.txt  # usa un archivo ya descargado

Tabla resultante (ids de versículo con el mismo esquema que `verses.id`):
    crossrefs(src INTEGER, dst INTEGER, dst_end INTEGER, votes INTEGER)
Solo se guardan las de MIN_VOTES o más votos, para no inflar el APK.
"""

import gzip
import io
import os
import shutil
import sqlite3
import sys
import tempfile
import urllib.request
import zipfile

SOURCE_URL = "https://a.openbible.info/data/cross-references.zip"
SCHEMA_VERSION = 2
MIN_VOTES = 5
ASSET = os.path.join(os.path.dirname(__file__), "..", "assets", "bible", "rv1909.sqlite.gz")

# Abreviaturas OSIS de OpenBible → códigos de la app, en orden canónico.
OSIS = [
    ("Gen", "GEN"), ("Exod", "EXO"), ("Lev", "LEV"), ("Num", "NUM"), ("Deut", "DEU"), ("Josh", "JOS"),
    ("Judg", "JDG"), ("Ruth", "RUT"), ("1Sam", "1SA"), ("2Sam", "2SA"), ("1Kgs", "1KI"), ("2Kgs", "2KI"),
    ("1Chr", "1CH"), ("2Chr", "2CH"), ("Ezra", "EZR"), ("Neh", "NEH"), ("Esth", "EST"), ("Job", "JOB"),
    ("Ps", "PSA"), ("Prov", "PRO"), ("Eccl", "ECC"), ("Song", "SOL"), ("Isa", "ISA"), ("Jer", "JER"),
    ("Lam", "LAM"), ("Ezek", "EZE"), ("Dan", "DAN"), ("Hos", "HOS"), ("Joel", "JOE"), ("Amos", "AMO"),
    ("Obad", "OBA"), ("Jonah", "JON"), ("Mic", "MIC"), ("Nah", "NAH"), ("Hab", "HAB"), ("Zeph", "ZEP"),
    ("Hag", "HAG"), ("Zech", "ZEC"), ("Mal", "MAL"), ("Matt", "MAT"), ("Mark", "MAR"), ("Luke", "LUK"),
    ("John", "JOH"), ("Acts", "ACT"), ("Rom", "ROM"), ("1Cor", "1CO"), ("2Cor", "2CO"), ("Gal", "GAL"),
    ("Eph", "EPH"), ("Phil", "PHI"), ("Col", "COL"), ("1Thess", "1TH"), ("2Thess", "2TH"), ("1Tim", "1TI"),
    ("2Tim", "2TI"), ("Titus", "TIT"), ("Phlm", "PHM"), ("Heb", "HEB"), ("Jas", "JAM"), ("1Pet", "1PE"),
    ("2Pet", "2PE"), ("1John", "1JO"), ("2John", "2JO"), ("3John", "3JO"), ("Jude", "JUD"), ("Rev", "REV"),
]
BOOK_INDEX = {osis: i + 1 for i, (osis, _) in enumerate(OSIS)}


def verse_id(osis_ref: str) -> int:
    book, ch, vs = osis_ref.split(".")
    return BOOK_INDEX[book] * 1_000_000 + int(ch) * 1_000 + int(vs)


def read_source(path: str | None) -> str:
    if path:
        with open(path, encoding="utf-8") as f:
            return f.read()
    print(f"Descargando {SOURCE_URL} ...")
    with urllib.request.urlopen(SOURCE_URL) as resp:
        data = resp.read()
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        return z.read("cross_references.txt").decode("utf-8")


def parse(text: str) -> list[tuple[int, int, int, int]]:
    rows = []
    for line in text.splitlines()[1:]:
        parts = line.split("\t")
        if len(parts) < 3:
            continue
        votes = int(parts[2])
        if votes < MIN_VOTES:
            continue
        start, _, end = parts[1].partition("-")
        dst = verse_id(start)
        rows.append((verse_id(parts[0]), dst, verse_id(end) if end else dst, votes))
    return rows


def main() -> None:
    rows = parse(read_source(sys.argv[1] if len(sys.argv) > 1 else None))
    with tempfile.TemporaryDirectory() as tmp:
        db_path = os.path.join(tmp, "rv1909.sqlite")
        with gzip.open(ASSET, "rb") as src, open(db_path, "wb") as dst:
            shutil.copyfileobj(src, dst)
        con = sqlite3.connect(db_path)
        con.executescript(
            """
            DROP TABLE IF EXISTS crossrefs;
            CREATE TABLE crossrefs (
              src     INTEGER NOT NULL,
              dst     INTEGER NOT NULL,
              dst_end INTEGER NOT NULL,
              votes   INTEGER NOT NULL
            );
            """
        )
        con.executemany("INSERT INTO crossrefs VALUES (?,?,?,?)", rows)
        con.execute("CREATE INDEX crossrefs_src ON crossrefs (src)")
        con.executemany(
            "INSERT OR REPLACE INTO meta VALUES (?,?)",
            [
                ("schema_version", str(SCHEMA_VERSION)),
                ("crossrefs_source", "https://www.openbible.info/labs/cross-references/"),
                ("crossrefs_license", "CC-BY"),
                ("crossrefs_min_votes", str(MIN_VOTES)),
            ],
        )
        con.commit()
        con.execute("VACUUM")
        con.close()
        with open(db_path, "rb") as src, gzip.open(ASSET, "wb", compresslevel=9) as dst:
            shutil.copyfileobj(src, dst)
        raw_size = os.path.getsize(db_path)
    print(f"OK: {len(rows)} referencias | {raw_size / 1e6:.1f} MB -> {os.path.getsize(ASSET) / 1e6:.1f} MB gz")


if __name__ == "__main__":
    main()

"""Genera los recursos de marca de TELEIOS a partir de la marca (círculo + Chi).

Salida en app/assets/brand/:
  teleios-mark.svg            marca vectorial para la app (flutter_svg; sin filtros)
  icon-1024.png               ícono cuadrado con fondo (iOS, macOS, Windows, Web)
  icon-foreground-1024.png    capa frontal del ícono adaptativo de Android (transparente)
  icon-monochrome-1024.png    ícono temático de Android 13+ (silueta blanca)
  splash-mark.png             marca para la pantalla de arranque
  splash-android12.png        marca para el splash de Android 12+ (zona segura circular)

Uso:  python tool/build_brand_assets.py
Requiere Google Chrome (o Edge) para rasterizar; ruta configurable con CHROME=...
"""

import os
import pathlib
import subprocess
import tempfile

from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "brand"

MIDNIGHT = "#0E1320"
MIDNIGHT_EDGE = "#090C15"
MIDNIGHT_CENTER = "#18203A"

CHROME_CANDIDATES = [
    os.environ.get("CHROME", ""),
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "/usr/bin/google-chrome",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
]


def mark_group(gradient: str, glow: bool = True, solid: str | None = None, bold: bool = False) -> str:
    """Marca en un lienzo de 220x220. `solid` pinta todo de un color (monocromo).

    `bold` engrosa los trazos (ajuste óptico) para que el ícono se lea a 48 px.
    """
    ring, inner, axis, diag, chi = (3.8, 1.0, 3.0, 1.6, 8) if bold else (2.2, 0.5, 2, 0.9, 6)
    g = solid or f"url(#{gradient})"
    center = solid or "#FFF8E1"
    # Halo radial (no se usa en monocromo: Android lo exige de un solo color).
    glow_layer = '<circle cx="110" cy="110" r="38" fill="url(#halo)"/>' if glow and not solid else ""
    return f"""
    <g transform="rotate(45 110 110)">
      <circle cx="110" cy="110" r="88" fill="none" stroke="{g}" stroke-width="{ring}"/>
      <circle cx="110" cy="110" r="80" fill="none" stroke="{g}" stroke-width="{inner}" opacity="0.35"/>
      <line x1="110" y1="46" x2="110" y2="174" stroke="{g}" stroke-width="{axis}"/>
      <line x1="46" y1="110" x2="174" y2="110" stroke="{g}" stroke-width="{axis}"/>
      <line x1="110" y1="110" x2="65" y2="65" stroke="{g}" stroke-width="{diag}" opacity="0.45"/>
      <line x1="110" y1="110" x2="155" y2="65" stroke="{g}" stroke-width="{diag}" opacity="0.45"/>
      <line x1="110" y1="110" x2="65" y2="155" stroke="{g}" stroke-width="{diag}" opacity="0.45"/>
      <line x1="110" y1="110" x2="155" y2="155" stroke="{g}" stroke-width="{diag}" opacity="0.45"/>
      <circle cx="110" cy="46" r="7" fill="{g}"/>
      <circle cx="110" cy="174" r="7" fill="{g}"/>
      <circle cx="46" cy="110" r="7" fill="{g}"/>
      <circle cx="174" cy="110" r="7" fill="{g}"/>
      <circle cx="65" cy="65" r="4.5" fill="{g}" opacity="0.75"/>
      <circle cx="155" cy="65" r="4.5" fill="{g}" opacity="0.75"/>
      <circle cx="65" cy="155" r="4.5" fill="{g}" opacity="0.75"/>
      <circle cx="155" cy="155" r="4.5" fill="{g}" opacity="0.75"/>
      {glow_layer}
      <line x1="110" y1="88" x2="110" y2="132" stroke="{g}" stroke-width="{chi}" stroke-linecap="round"/>
      <line x1="88" y1="110" x2="132" y2="110" stroke="{g}" stroke-width="{chi}" stroke-linecap="round"/>
      <circle cx="110" cy="110" r="2.5" fill="{center}"/>
    </g>"""


# Degradado en coordenadas absolutas: con objectBoundingBox las líneas rectas
# (caja de ancho/alto cero) no se pintan según la especificación SVG.
GOLD_DEFS = """
    <linearGradient id="gold" gradientUnits="userSpaceOnUse" x1="20" y1="20" x2="200" y2="200">
      <stop offset="0%" stop-color="#F0D48A"/>
      <stop offset="50%" stop-color="#C9A961"/>
      <stop offset="100%" stop-color="#8C6B2E"/>
    </linearGradient>
    <radialGradient id="halo" cx="110" cy="110" r="38" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#F0D48A" stop-opacity="0.45"/>
      <stop offset="55%" stop-color="#C9A961" stop-opacity="0.12"/>
      <stop offset="100%" stop-color="#C9A961" stop-opacity="0"/>
    </radialGradient>"""


def mark_svg() -> str:
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="220" height="220" viewBox="0 0 220 220">
  <defs>{GOLD_DEFS}
  </defs>{mark_group("gold")}
</svg>
"""


def canvas_svg(size: int, mark_size: float, background: bool, solid: str | None = None, bold: bool = True) -> str:
    scale = mark_size / 220
    offset = (size - mark_size) / 2
    bg = (
        f"""
  <defs>
    <radialGradient id="bg" cx="50%" cy="45%" r="70%">
      <stop offset="0%" stop-color="{MIDNIGHT_CENTER}"/>
      <stop offset="60%" stop-color="{MIDNIGHT}"/>
      <stop offset="100%" stop-color="{MIDNIGHT_EDGE}"/>
    </radialGradient>{GOLD_DEFS}
  </defs>
  <rect width="{size}" height="{size}" fill="url(#bg)"/>"""
        if background
        else f"""
  <defs>{GOLD_DEFS}
  </defs>"""
    )
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">{bg}
  <g transform="translate({offset} {offset}) scale({scale})">{mark_group("gold", solid=solid, bold=bold)}
  </g>
</svg>
"""


def find_chrome() -> str:
    for c in CHROME_CANDIDATES:
        if c and pathlib.Path(c).exists():
            return c
    raise SystemExit("No se encontró Chrome/Edge. Define la variable CHROME con su ruta.")


def render(chrome: str, svg: str, size: int, out: pathlib.Path) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        svg_path = pathlib.Path(tmp) / "img.svg"
        svg_path.write_text(svg, encoding="utf-8")
        html = pathlib.Path(tmp) / "page.html"
        html.write_text(
            f'<html><body style="margin:0;overflow:hidden;background:transparent">'
            f'<img src="{svg_path.as_uri()}" width="{size}" height="{size}" style="display:block"></body></html>',
            encoding="utf-8",
        )
        subprocess.run(
            [
                chrome,
                "--headless=new",
                "--disable-gpu",
                "--hide-scrollbars",
                "--allow-file-access-from-files",
                "--default-background-color=00000000",
                # En headless el área visible es menor que la ventana: se renderiza
                # más grande y luego se recorta exacto.
                f"--window-size={size + 200},{size + 200}",
                f"--screenshot={out}",
                html.as_uri(),
            ],
            check=True,
            capture_output=True,
            timeout=120,
        )
    if not out.exists():
        raise SystemExit(f"Chrome no generó {out.name}")
    with Image.open(out) as img:
        img.crop((0, 0, size, size)).save(out)
    print(f"  {out.name}")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    chrome = find_chrome()

    (OUT / "teleios-mark.svg").write_text(mark_svg(), encoding="utf-8")
    print("  teleios-mark.svg")

    # Ícono cuadrado: la marca ocupa ~65% (el anillo exterior queda con aire).
    render(chrome, canvas_svg(1024, 820, background=True), 1024, OUT / "icon-1024.png")
    # Android adaptativo: el anillo dentro de la zona segura (66 de 108 dp).
    render(chrome, canvas_svg(1024, 720, background=False), 1024, OUT / "icon-foreground-1024.png")
    render(chrome, canvas_svg(1024, 720, background=False, solid="#FFFFFF"), 1024, OUT / "icon-monochrome-1024.png")
    # Splash.
    render(chrome, canvas_svg(768, 768, background=False, bold=False), 768, OUT / "splash-mark.png")
    render(chrome, canvas_svg(1152, 760, background=False, bold=False), 1152, OUT / "splash-android12.png")


if __name__ == "__main__":
    main()

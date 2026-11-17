"""Laboratorio de coherencia medida de TELEIOS (docs/PLAN-COHERENCIA.md §8, §10, §11).

Nunca toca diarios reales: solo datos sintéticos, ítems compartidos y etiquetas confirmadas.
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
OUT = ROOT / "out"
MODELS = ROOT / "models"
APP = ROOT.parent / "app"

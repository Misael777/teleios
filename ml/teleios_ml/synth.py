"""S12 · Generador sintético en español con etiquetas correctas por construcción (§11.4 paso 1).

Cada *cadena* es una estructura de razonamiento (el patrón que buscamos) con su cadena antagónica.
Una plantilla realiza la cadena en superficie; los huecos {dom} / {res} cambian el tema, no la cadena.
De ahí salen, sin etiquetado manual:
  - pensamientos con sus cabezas (esquema, agente, polaridad, modalidad, distorsión);
  - pares NLI: misma cadena → entailment; cadena antagónica o negación explícita → contradiction;
    otra cadena → neutral;
  - tripletas (ancla, paráfrasis, negación) para los embeddings con negativos duros (§11.2).
La cadena es además la verdad de referencia para evaluar el clusterizador.

Nunca usa el test de pares mínimos: se filtra todo lo que se le parezca (ngramas de caracteres).
"""

from __future__ import annotations

import random
from dataclasses import dataclass, field

from .minimal_pairs import sentences as test_sentences

ESQUEMA = ["condicional_causal", "deber", "generalizacion", "promesa", "concesivo", "identidad", "descriptivo"]
AGENTE = ["yo", "dios", "otros", "circunstancias"]
POLARIDAD = ["positiva", "negativa"]
MODALIDAD = ["necesidad", "posibilidad", "hecho"]
DISTORSION = ["catastrofizacion", "todo_o_nada", "deberia", "etiquetado", "culpar", "ninguna"]
HEADS = {"esquema": ESQUEMA, "agente": AGENTE, "polaridad": POLARIDAD, "modalidad": MODALIDAD, "distorsion": DISTORSION}

DOMINIOS = ["mi trabajo", "mi familia", "mis finanzas", "mi salud", "la iglesia", "mis estudios", "mis amistades",
            "mi futuro", "mi matrimonio", "la crianza de mis hijos", "mi ministerio", "mis proyectos"]
RECURSOS = ["mi dinero", "mi tiempo", "lo que tengo", "mi comida", "mis fuerzas", "mis bienes"]


@dataclass
class Chain:
    id: str
    name: str
    antagonist: str | None
    agente: str
    polaridad: str
    distorsion: str
    # (plantilla, esquema, modalidad)
    templates: list[tuple[str, str, str]] = field(default_factory=list)


C, D_, G, P, K, I, X = ESQUEMA
NEC, POS, HEC = MODALIDAD

CHAINS = [
    Chain("control_catastrofe", "Control propio → catástrofe", "confianza_descanso", "yo", "negativa", "catastrofizacion", [
        ("Si no controlo {dom}, todo se va a derrumbar.", C, HEC),
        ("Cuando suelto el control de {dom}, viene el desastre.", C, HEC),
        ("Tengo que tener {dom} bajo control o todo saldrá mal.", D_, NEC),
        ("Si dejo {dom} en otras manos, terminará en ruina.", C, HEC),
        ("Necesito vigilar cada detalle de {dom} para que no se arruine.", D_, NEC),
    ]),
    Chain("confianza_descanso", "Dios gobierna → descanso", "control_catastrofe", "dios", "positiva", "ninguna", [
        ("Aunque no controle {dom}, Dios sigue obrando.", K, HEC),
        ("Puedo descansar en Dios respecto a {dom}.", P, POS),
        ("Dios gobierna {dom}, así que puedo soltarlo.", P, POS),
        ("Aunque {dom} no esté en mis manos, está en las de Dios.", K, HEC),
        ("Soltar el control de {dom} no lo arruina, porque Dios cuida.", P, HEC),
    ]),
    Chain("valor_desempeno", "Valor según desempeño", "identidad_gracia", "yo", "negativa", "etiquetado", [
        ("Si fallo en {dom}, no valgo nada.", C, HEC),
        ("Mi valor depende de cómo me vaya en {dom}.", I, HEC),
        ("Fracasar en {dom} demuestra que soy un inútil.", I, HEC),
        ("Solo valgo algo cuando tengo éxito en {dom}.", I, HEC),
        ("Si no rindo en {dom}, soy un fracaso como persona.", C, HEC),
    ]),
    Chain("identidad_gracia", "Identidad en la gracia", "valor_desempeno", "dios", "positiva", "ninguna", [
        ("Aunque falle en {dom}, mi valor está en ser hijo de Dios.", K, HEC),
        ("Dios me acepta aunque me vaya mal en {dom}.", K, HEC),
        ("Mi identidad no depende de {dom}, sino de Cristo.", I, HEC),
        ("Fallar en {dom} no cambia lo que valgo para Dios.", I, HEC),
        ("Soy amado por Dios, me vaya bien o mal en {dom}.", I, HEC),
    ]),
    Chain("generalizacion_fracaso", "Todo o nada → fracaso", "realismo_esperanza", "yo", "negativa", "todo_o_nada", [
        ("Todo lo que intento en {dom} sale mal.", G, HEC),
        ("Nunca me sale nada bien en {dom}.", G, HEC),
        ("Siempre arruino {dom}.", G, HEC),
        ("En {dom} jamás logro hacer algo bien.", G, HEC),
        ("Cada cosa que hago en {dom} termina mal.", G, HEC),
    ]),
    Chain("realismo_esperanza", "Realismo con esperanza", "generalizacion_fracaso", "yo", "positiva", "ninguna", [
        ("Algunas cosas en {dom} me salen bien y otras no.", G, HEC),
        ("No todo en {dom} sale mal; también aprendo.", G, POS),
        ("A veces fallo en {dom}, pero también acierto.", G, HEC),
        ("En {dom} tengo aciertos además de errores.", G, HEC),
        ("Puedo mejorar en {dom} aunque a veces me equivoque.", K, POS),
    ]),
    Chain("deber_complacer", "Deber de complacer", "libertad_servicio", "otros", "negativa", "deberia", [
        ("Debo complacer a todos en {dom} o me rechazarán.", D_, NEC),
        ("Tengo que tener contentos a todos en {dom}.", D_, NEC),
        ("Si no agrado a los demás en {dom}, me dejarán solo.", C, HEC),
        ("Debería decir que sí a todo lo que me piden en {dom}.", D_, NEC),
        ("Necesito la aprobación de todos en {dom} para estar bien.", D_, NEC),
    ]),
    Chain("libertad_servicio", "Libertad para servir", "deber_complacer", "dios", "positiva", "ninguna", [
        ("No necesito agradar a todos en {dom}; busco agradar a Dios.", D_, POS),
        ("Puedo servir en {dom} sin depender de la aprobación ajena.", P, POS),
        ("La aprobación de Dios me basta en {dom}.", I, HEC),
        ("Puedo decir que no en {dom} sin perder mi valor.", P, POS),
        ("Aunque alguien se moleste en {dom}, Dios me sostiene.", K, HEC),
    ]),
    Chain("castigo_divino", "Desgracia = castigo divino", "providencia_bondad", "dios", "negativa", "catastrofizacion", [
        ("Si algo malo pasa en {dom}, es porque Dios me castiga.", C, HEC),
        ("Los problemas en {dom} son castigo de Dios por mis pecados.", I, HEC),
        ("Dios me está castigando con lo que pasa en {dom}.", X, HEC),
        ("Cada dificultad en {dom} es Dios cobrándome mis faltas.", G, HEC),
        ("Si sufro en {dom}, Dios está enojado conmigo.", C, HEC),
    ]),
    Chain("providencia_bondad", "Providencia buena", "castigo_divino", "dios", "positiva", "ninguna", [
        ("Aun lo difícil en {dom} Dios lo usa para mi bien.", P, HEC),
        ("Lo que pasa en {dom} no es castigo; Dios es bueno conmigo.", I, HEC),
        ("Dios obra para bien incluso en {dom}.", P, HEC),
        ("Aunque sufra en {dom}, Dios no está en mi contra.", K, HEC),
        ("Las dificultades en {dom} no significan que Dios me rechace.", I, HEC),
    ]),
    Chain("escasez", "Escasez → no dar", "provision_generosidad", "circunstancias", "negativa", "catastrofizacion", [
        ("Si comparto {res}, me quedaré sin nada.", C, HEC),
        ("No puedo ser generoso con {res} porque no alcanzará.", C, NEC),
        ("Dar {res} me llevará a la ruina.", C, HEC),
        ("Tengo que guardar {res} o vendrá la escasez.", D_, NEC),
        ("Si ayudo a otros con {res}, después me faltará a mí.", C, HEC),
    ]),
    Chain("provision_generosidad", "Provisión → generosidad", "escasez", "dios", "positiva", "ninguna", [
        ("Dios provee, por eso puedo compartir {res}.", P, POS),
        ("Ser generoso con {res} no me deja en escasez porque Dios suple.", P, HEC),
        ("Puedo dar {res} confiando en que Dios proveerá.", P, POS),
        ("Aunque comparta {res}, no me faltará lo necesario.", K, HEC),
        ("Dar {res} es posible porque Dios es mi proveedor.", P, POS),
    ]),
    Chain("culpar_otros", "Los otros tienen la culpa", "responsabilidad_propia", "otros", "negativa", "culpar", [
        ("Los demás tienen la culpa de cómo me siento en {dom}.", I, HEC),
        ("Me enojo en {dom} porque otros me provocan.", C, HEC),
        ("Si la gente en {dom} cambiara, yo estaría bien.", C, HEC),
        ("Lo que me pasa en {dom} es culpa de otros.", I, HEC),
        ("No es mi responsabilidad cómo reacciono en {dom}; me provocan.", I, HEC),
    ]),
    Chain("responsabilidad_propia", "Responsabilidad propia", "culpar_otros", "yo", "positiva", "ninguna", [
        ("Soy responsable de cómo respondo en {dom}.", I, HEC),
        ("Puedo elegir cómo reacciono en {dom}, aunque otros fallen.", P, POS),
        ("Mi respuesta en {dom} depende de mí, no de los demás.", I, HEC),
        ("Aunque otros me provoquen en {dom}, yo decido cómo actuar.", K, POS),
        ("Lo que hago en {dom} es mi responsabilidad.", I, HEC),
    ]),
]

# Otra cadena: mismas palabras del tema, sin creencia sobre él (neutral frente a todas).
NEUTRAS = [
    "Organizo {dom} los lunes por la mañana.",
    "Hoy hablé de {dom} con un amigo.",
    "Anoté en mi agenda varias cosas de {dom}.",
    "Esta semana {dom} tuvo cambios de horario.",
    "Leí un artículo sobre {dom}.",
]

PREFIJOS = ["", "", "", "Pienso que ", "Siento que ", "Creo que ", "En el fondo creo que "]

BY_ID = {c.id: c for c in CHAINS}


def _with_prefix(text: str, rng: random.Random) -> str:
    p = rng.choice(PREFIJOS)
    return p + text[0].lower() + text[1:] if p else text


def _ngrams(s: str, n: int = 5) -> set[str]:
    s = s.lower()
    return {s[i : i + n] for i in range(max(1, len(s) - n + 1))}


_TEST = [_ngrams(s) for s in test_sentences()]


def leaks(text: str, limit: float = 0.55) -> bool:
    g = _ngrams(text)
    return any(len(g & t) / len(g | t) > limit for t in _TEST)


def thought(chain: Chain, ti: int, slot: str, rng: random.Random, prefix: bool = True) -> dict:
    t, esquema, modalidad = chain.templates[ti]
    text = t.replace("{res}", slot).replace("{dom}", slot)
    return {
        "text": _with_prefix(text, rng) if prefix else text,
        "chain": chain.id,
        "slot": slot,
        "esquema": esquema,
        "agente": chain.agente,
        "polaridad": chain.polaridad,
        "modalidad": modalidad,
        "distorsion": chain.distorsion,
    }


def _slot_for(chain: Chain, rng: random.Random) -> str:
    return rng.choice(RECURSOS if "{res}" in chain.templates[0][0] else DOMINIOS)


def negate(text: str) -> str:
    """Negación explícita de toda la proposición (enseña que "no es cierto que X" ≠ X)."""
    return "No es cierto que " + text[0].lower() + text[1:]


def generate(n_thoughts: int = 2500, n_pairs: int = 30000, seed: int = 7) -> dict:
    rng = random.Random(seed)
    thoughts, seen = [], set()
    while len(thoughts) < n_thoughts:
        c = rng.choice(CHAINS)
        th = thought(c, rng.randrange(len(c.templates)), _slot_for(c, rng), rng)
        if th["text"] in seen or leaks(th["text"]):
            continue
        seen.add(th["text"])
        thoughts.append(th)

    pairs, triplets = [], []
    labels = ["entailment", "contradiction", "neutral", "neutral_neg"]
    while len(pairs) < n_pairs:
        c = rng.choice(CHAINS)
        slot = _slot_for(c, rng)
        i, j = rng.sample(range(len(c.templates)), 2)
        a = thought(c, i, slot, rng)
        kind = rng.choices(labels, weights=[0.34, 0.33, 0.23, 0.10])[0]
        if kind == "entailment":
            b = thought(c, j, slot, rng)["text"]
        elif kind == "contradiction":
            if rng.random() < 0.4:
                b = negate(c.templates[i][0].replace("{res}", slot).replace("{dom}", slot))
            else:
                anti = BY_ID[c.antagonist]
                b = thought(anti, rng.randrange(len(anti.templates)), slot, rng)["text"]
        elif kind == "neutral":
            others = [o for o in CHAINS if o.id not in (c.id, c.antagonist)
                      and ("{res}" in o.templates[0][0]) == ("{res}" in c.templates[0][0])]
            if others:
                o = rng.choice(others)
                b = thought(o, rng.randrange(len(o.templates)), slot, rng)["text"]
            else:
                o = rng.choice([o for o in CHAINS if o.id not in (c.id, c.antagonist)])
                b = thought(o, rng.randrange(len(o.templates)), _slot_for(o, rng), rng)["text"]
        else:
            b = rng.choice(NEUTRAS).replace("{dom}", slot if "{res}" not in c.templates[0][0] else "mis gastos")
            kind = "neutral"
        if leaks(a["text"]) or leaks(b):
            continue
        pairs.append({"premise": a["text"], "hypothesis": b, "label": kind, "chain": c.id})
        # Tripleta con negativo duro: misma superficie temática, cadena opuesta.
        if kind == "entailment":
            anti = BY_ID[c.antagonist]
            neg = rng.choice([negate(a["text"]), thought(anti, rng.randrange(len(anti.templates)), slot, rng)["text"]])
            # La mitad de las paráfrasis cambia de tema: el espacio debe juntar la cadena, no el tema.
            pos = b if rng.random() < 0.5 else thought(c, j, _slot_for(c, rng), rng)["text"]
            triplets.append({"anchor": a["text"], "positive": pos, "negative": neg})
    return {"thoughts": thoughts, "pairs": pairs, "triplets": triplets}


def corpus_for_clustering(per_chain: int = 40, seed: int = 11) -> list[dict]:
    """Pensamientos con su cadena verdadera, sin prefijos, para evaluar el clusterizador."""
    rng = random.Random(seed)
    out = []
    for c in CHAINS:
        seen = set()
        combos = len(c.templates) * len(RECURSOS if "{res}" in c.templates[0][0] else DOMINIOS)
        while len(seen) < min(per_chain, combos - 2):
            th = thought(c, rng.randrange(len(c.templates)), _slot_for(c, rng), rng, prefix=False)
            if th["text"] not in seen and not leaks(th["text"]):
                seen.add(th["text"])
                out.append(th)
    return out

"""Test de pares mínimos (docs/PLAN-COHERENCIA.md §11.3). FIJO: nunca se usa para entrenar.

Cada ancla A trae:
  B  misma cadena de razonamiento (paráfrasis)        → el juez debe decir "vincula"
  C  opuesto, con la categoría de la transformación    → el juez debe decir "contradice"
  D  mismas palabras, otra cadena                       → debe quedar aparte ("neutral")

100 anclas × 3 = 300 pares. Escritos a mano para que la gramática sea natural; el generador
sintético de entrenamiento (synth.py) usa otras anclas y se verifica que no se solapen.
"""

from __future__ import annotations

import json
from pathlib import Path

NEG, CUANT, AGENTE, ANT = "negacion", "cuantificador", "agente", "antonimo"

# (A, B, C, categoría de C, D)
ANCHORS: list[tuple[str, str, str, str, str]] = [
    ("Si no controlo todo, todo sale mal.", "Cuando dejo algo fuera de mi control, termina en desastre.", "Aunque no controle todo, Dios obra para bien.", AGENTE, "Controlar mis finanzas es buena mayordomía."),
    ("Dios siempre suple lo que necesito.", "Nunca me falta lo necesario porque Dios provee.", "Dios no suple lo que necesito.", NEG, "Siempre necesito que Dios me hable antes de dar."),
    ("Si me equivoco, Dios deja de amarme.", "Mis errores hacen que Dios me ame menos.", "Aunque me equivoque, Dios no deja de amarme.", NEG, "Si me equivoco, debo pedir perdón a quien herí."),
    ("Todo lo que hago termina en fracaso.", "Nada de lo que intento me sale bien.", "Algunas cosas que hago salen bien.", CUANT, "Todo lo que hago lo hago para la gloria de Dios."),
    ("Mi valor depende de lo que otros piensan de mí.", "Valgo según la opinión de los demás.", "Mi valor no depende de lo que otros piensan de mí.", NEG, "Me importa lo que otros piensan de mi testimonio."),
    ("Dios escucha mis oraciones.", "Mis oraciones llegan a oídos de Dios.", "Dios ignora mis oraciones.", ANT, "Escucho a Dios cuando oro en silencio."),
    ("Perdonar me hace débil.", "Quien perdona demuestra debilidad.", "Perdonar me hace fuerte.", ANT, "Pedir perdón me cuesta cuando estoy débil."),
    ("Debo ganarme la gracia con mis obras.", "La gracia se obtiene haciendo méritos.", "La gracia no se gana con obras.", NEG, "Mis obras muestran la gracia que recibí."),
    ("Siempre que me enojo tengo razón.", "Mi enojo está justificado en todos los casos.", "A veces me enojo sin tener razón.", CUANT, "Siempre que me enojo, oro antes de hablar."),
    ("El sufrimiento significa que Dios me abandonó.", "Si sufro es porque Dios me dejó solo.", "En el sufrimiento Dios sigue conmigo.", ANT, "El sufrimiento de otros me mueve a ayudar."),
    ("Yo tengo que resolver todos mis problemas solo.", "Nadie más que yo puede arreglar lo que me pasa.", "Dios y mi comunidad me ayudan a resolver mis problemas.", AGENTE, "Tengo que resolver este problema con mi jefe hoy."),
    ("Dar con generosidad me deja en escasez.", "Si doy mucho, me quedaré sin nada.", "Dar con generosidad no me deja en escasez.", NEG, "Doy con generosidad cuando tengo abundancia."),
    ("Nunca podré cambiar mis malos hábitos.", "Mis malos hábitos no tienen remedio.", "Con ayuda de Dios puedo cambiar mis malos hábitos.", AGENTE, "Nunca cambio mis hábitos de oración en vacaciones."),
    ("Mis hijos son responsabilidad solo mía.", "Solo yo respondo por lo que pase con mis hijos.", "Mis hijos están en manos de Dios, no solo en las mías.", AGENTE, "Mis hijos son mi mayor alegría."),
    ("Si oro con suficiente fe, Dios hará lo que pido.", "Con bastante fe, Dios cumplirá exactamente mi petición.", "Aunque ore con fe, Dios puede responder distinto a lo que pido.", NEG, "Si oro con mi esposa, nuestra fe crece."),
    ("La gente siempre me decepciona.", "Todos terminan fallándome.", "Algunas personas no me decepcionan.", CUANT, "La gente de mi iglesia siempre me saluda."),
    ("Descansar es perder el tiempo.", "Tomarme un descanso es tiempo desperdiciado.", "Descansar es aprovechar bien el tiempo.", ANT, "Pierdo el tiempo cuando no planeo mi descanso."),
    ("Dios está en control de mi futuro.", "Mi futuro está en las manos de Dios.", "Mi futuro depende solo de mí.", AGENTE, "Controlo mi agenda para el futuro próximo."),
    ("Tengo que ser perfecto para que me acepten.", "Solo me aceptarán si no cometo errores.", "Me aceptan aunque no sea perfecto.", NEG, "Tengo que aceptar que nadie es perfecto."),
    ("La ansiedad me protege de lo malo.", "Preocuparme evita que me pasen cosas malas.", "La ansiedad no me protege de lo malo.", NEG, "Lo malo me causa ansiedad cuando estoy cansado."),
    ("Dios castiga cada pecado con desgracias.", "Toda desgracia es el castigo de Dios por un pecado.", "No toda desgracia es castigo por un pecado.", CUANT, "El pecado trae consecuencias en las relaciones."),
    ("Mi pasado define quién soy.", "Soy lo que hice antes.", "Mi pasado no define quién soy.", NEG, "Mi pasado me enseñó a valorar a mi familia."),
    ("Confiar en otros siempre termina en traición.", "Cada vez que confío en alguien, me traiciona.", "Confiar en otros a veces termina bien.", CUANT, "Confiar en Dios me ayuda a perdonar una traición."),
    ("Dios me ama incondicionalmente.", "El amor de Dios por mí no tiene condiciones.", "Dios me ama solo si me porto bien.", NEG, "Mi madre me ama incondicionalmente."),
    ("Si me humillo, los demás se aprovecharán de mí.", "Ser humilde hace que otros abusen de mí.", "Humillarme no hace que los demás se aprovechen de mí.", NEG, "Los demás se humillan cuando reconocen su error."),
    ("Mi trabajo es lo más importante de mi vida.", "Nada en mi vida importa más que mi trabajo.", "Mi trabajo no es lo más importante de mi vida.", NEG, "Mi trabajo es importante para sostener a mi familia."),
    ("Dios nunca me daría más de lo que puedo soportar.", "Lo que Dios permite siempre está dentro de mis fuerzas.", "A veces enfrento más de lo que puedo soportar solo.", CUANT, "Dios me da fuerzas para soportar a mi vecino."),
    ("Expresar tristeza es falta de fe.", "Llorar demuestra que no confío en Dios.", "Expresar tristeza no es falta de fe.", NEG, "La falta de sueño me pone triste."),
    ("Siempre llego tarde a todo.", "Nunca soy puntual.", "Casi siempre llego a tiempo.", CUANT, "Llegar tarde al trabajo me causa estrés."),
    ("Dios quiere que yo sea feliz a toda costa.", "Mi felicidad es lo primero que Dios busca.", "Dios no busca mi felicidad a toda costa.", NEG, "Ser feliz con poco es un regalo de Dios."),
    ("Si alguien me ofende, debo devolverle el golpe.", "Quien me hiere merece que le responda igual.", "Si alguien me ofende, no debo devolverle el golpe.", NEG, "Si alguien me ofende en público, me duele más."),
    ("Soy un fracaso como padre.", "Fallé por completo en criar a mis hijos.", "No soy un fracaso como padre.", NEG, "Mi padre nunca me habló de fracasos."),
    ("Leer la Biblia me da paz.", "Encuentro paz cuando leo las Escrituras.", "Leer la Biblia me quita la paz.", ANT, "Leer noticias me roba la paz."),
    ("Dios está lejos de mí.", "Siento que Dios no está cerca.", "Dios está cerca de mí.", ANT, "Mi familia está lejos de mí."),
    ("El dinero me dará seguridad.", "Tener dinero es lo que me hará sentir seguro.", "El dinero no me dará seguridad.", NEG, "El dinero de la ofrenda se usa con transparencia."),
    ("Todos en la iglesia me juzgan.", "Cada persona de la congregación me critica.", "Nadie en la iglesia me juzga.", CUANT, "En la iglesia todos cantamos juntos."),
    ("Si Dios me ama, no permitirá que me enferme.", "Una persona amada por Dios no se enferma.", "Dios me ama aunque permita que me enferme.", NEG, "Si me enfermo, mi iglesia ora por mí."),
    ("Tengo que complacer a todos.", "Debo hacer felices a todas las personas.", "No tengo que complacer a todos.", NEG, "Me complace ayudar a mis vecinos."),
    ("Dios me guía en mis decisiones.", "Mis decisiones cuentan con la guía de Dios.", "Tomo mis decisiones sin ninguna guía de Dios.", AGENTE, "Guío a mis hijos en sus decisiones."),
    ("Mis emociones siempre dicen la verdad.", "Lo que siento es siempre lo que es real.", "Mis emociones a veces me engañan.", CUANT, "Mis emociones cambian cuando estoy cansado."),
    ("Pedir ayuda es señal de debilidad.", "Quien pide ayuda es débil.", "Pedir ayuda es señal de sabiduría.", ANT, "Pedir ayuda a Dios es lo primero que hago."),
    ("Si no doy el diezmo, Dios me castigará.", "Dejar de diezmar trae castigo divino.", "Si no doy el diezmo, Dios no me castigará con desgracias.", NEG, "Si doy el diezmo, lo hago con alegría."),
    ("Mi cónyuge debe hacerme feliz.", "La felicidad es responsabilidad de mi pareja.", "Mi cónyuge no es responsable de mi felicidad.", NEG, "Hacer feliz a mi cónyuge me llena de gozo."),
    ("Dios no puede usar a alguien como yo.", "Alguien como yo es inútil para Dios.", "Dios puede usar a alguien como yo.", NEG, "Alguien como yo necesita descansar más."),
    ("Todo pasa por una razón buena.", "Cada cosa que ocurre tiene un buen propósito.", "No todo lo que pasa es bueno en sí mismo.", CUANT, "Todo pasa rápido cuando estoy ocupado."),
    ("La oración cambia mi corazón.", "Al orar, mi corazón se transforma.", "La oración no cambia nada en mí.", NEG, "Mi corazón late rápido cuando hablo en público."),
    ("Debo esconder mis pecados para que no me rechacen.", "Si confieso mis pecados, me rechazarán.", "Confesar mis pecados no hará que me rechacen.", NEG, "Debo confesar mis pecados a Dios cada noche."),
    ("El futuro será peor que el presente.", "Lo que viene será más difícil que lo de ahora.", "El futuro puede ser mejor que el presente.", ANT, "El presente es un regalo para disfrutar con mi familia."),
    ("Yo merezco todo lo bueno que tengo.", "Lo bueno que tengo me lo he ganado.", "Lo bueno que tengo es gracia, no lo merezco.", ANT, "Mis hijos merecen tiempo de calidad."),
    ("Dios perdona todos mis pecados cuando me arrepiento.", "Al arrepentirme, Dios borra todas mis faltas.", "Dios no perdona algunos de mis pecados aunque me arrepienta.", CUANT, "Perdono a quienes se arrepienten de verdad."),
    ("Si fallo en público, nunca me lo perdonarán.", "Un error delante de otros no se olvida jamás.", "Si fallo en público, pueden perdonármelo.", NEG, "Si fallo en público, aprendo a ser humilde."),
    ("Dios es fiel a sus promesas.", "Las promesas de Dios siempre se cumplen.", "Dios no cumple sus promesas.", ANT, "Soy fiel a mis promesas con mis amigos."),
    ("Necesito la aprobación de mi jefe para sentirme bien.", "Me siento bien solo si mi jefe me aprueba.", "No necesito la aprobación de mi jefe para sentirme bien.", NEG, "Mi jefe aprobó mis vacaciones."),
    ("Las cosas malas solo me pasan a mí.", "Soy el único al que le va mal.", "A todos les pasan cosas malas, no solo a mí.", CUANT, "Las cosas buenas me pasan cuando menos lo espero."),
    ("Servir a otros me agota y no vale la pena.", "Ayudar a los demás solo me cansa sin sentido.", "Servir a otros vale la pena aunque me canse.", ANT, "Servir la comida a mi familia me alegra."),
    ("La Biblia es irrelevante para mi vida diaria.", "Las Escrituras no tienen que ver con mi día a día.", "La Biblia es relevante para mi vida diaria.", ANT, "Mi vida diaria está llena de rutinas."),
    ("Si me rechazan, es porque no valgo nada.", "El rechazo prueba que no tengo valor.", "Aunque me rechacen, sigo teniendo valor.", NEG, "Si me rechazan una solicitud, la vuelvo a enviar."),
    ("Dios me hizo con un propósito.", "Fui creado para algo.", "Mi vida no tiene ningún propósito.", NEG, "Hice este mueble con un propósito práctico."),
    ("No puedo estar en paz hasta que todo esté resuelto.", "Mientras haya problemas pendientes, no tendré paz.", "Puedo tener paz aunque no todo esté resuelto.", NEG, "No puedo dormir hasta que mis hijos llegan a casa."),
    ("Enojarme me da control sobre la situación.", "Con el enojo domino lo que pasa.", "Enojarme me hace perder el control.", ANT, "Controlar el tráfico es trabajo de la policía."),
    ("Dios usa mis debilidades para mostrar su poder.", "En mi debilidad se ve la fuerza de Dios.", "Mis debilidades impiden que Dios muestre su poder.", ANT, "Mis debilidades físicas aumentan con la edad."),
    ("Siempre tengo que tener la última palabra.", "No puedo dejar que otro termine una discusión.", "No necesito tener la última palabra.", NEG, "La última palabra del sermón me impactó."),
    ("Si mi familia está mal, yo tengo la culpa.", "Todo lo malo en mi casa es culpa mía.", "No todo lo malo en mi familia es culpa mía.", CUANT, "Si mi familia está mal, oramos juntos."),
    ("Dios me da sabiduría cuando se la pido.", "Al pedirle sabiduría, Dios me la concede.", "Dios me niega la sabiduría aunque se la pida.", ANT, "Le pido consejo a mi abuelo por su sabiduría."),
    ("Ser vulnerable es peligroso.", "Mostrar mis heridas me pone en riesgo.", "Ser vulnerable puede ser seguro con las personas correctas.", ANT, "Los niños son vulnerables y necesitan protección."),
    ("Mi salvación depende de mi esfuerzo.", "Me salvo gracias a lo que yo hago.", "Mi salvación depende de la obra de Cristo, no de mi esfuerzo.", AGENTE, "Mi esfuerzo en el trabajo depende de mi descanso."),
    ("Nadie me entiende.", "No hay una sola persona que me comprenda.", "Algunas personas me entienden.", CUANT, "Nadie entiende este manual de instrucciones."),
    ("Agradecer cambia mi forma de ver las cosas.", "La gratitud transforma mi perspectiva.", "Agradecer no cambia nada en cómo veo las cosas.", NEG, "Las cosas que veo en redes me cambian el ánimo."),
    ("Debo tener miedo de Dios como de un tirano.", "Dios es un amo cruel al que hay que temer.", "Dios es un Padre bueno, no un tirano.", ANT, "Debo tener cuidado al manejar de noche."),
    ("Si no tengo éxito, mi vida no sirve.", "Una vida sin éxito es inútil.", "Mi vida sirve aunque no tenga éxito.", NEG, "Si no tengo éxito en el examen, lo repito."),
    ("Dios provee para mis necesidades del día.", "Cada día Dios me da lo que necesito.", "Yo solo me proveo lo que necesito cada día.", AGENTE, "Mis necesidades del día incluyen hacer ejercicio."),
    ("Las personas no cambian.", "Nadie cambia realmente.", "Las personas pueden cambiar.", NEG, "Las personas cambian de casa con frecuencia."),
    ("Hablar de mis problemas los empeora.", "Si comparto lo que me pasa, se pone peor.", "Hablar de mis problemas me ayuda a sanar.", ANT, "Hablar con mi hermano me divierte."),
    ("Dios está enojado conmigo.", "Siento la ira de Dios sobre mí.", "Dios no está enojado conmigo.", NEG, "Mi vecino está enojado por el ruido."),
    ("Merezco ser castigado por lo que hice.", "Lo que hice exige que sufra un castigo.", "Cristo cargó el castigo que yo merecía.", AGENTE, "Mi hijo merece un premio por su esfuerzo."),
    ("Siempre debo estar ocupado para ser útil.", "Solo soy útil si no paro de trabajar.", "Puedo ser útil aunque no esté ocupado.", NEG, "Estar ocupado los lunes es normal en mi trabajo."),
    ("El que me hizo daño nunca cambiará.", "Quien me lastimó seguirá igual para siempre.", "El que me hizo daño puede cambiar.", NEG, "El que me hizo el pastel es un gran cocinero."),
    ("Dios me sostiene en la tormenta.", "En medio de la crisis, Dios me mantiene firme.", "En la tormenta estoy solo, sin sostén.", AGENTE, "La tormenta de anoche tumbó un árbol."),
    ("Si confieso que dudo, pierdo mi fe.", "Admitir mis dudas destruye mi fe.", "Confesar mis dudas puede fortalecer mi fe.", ANT, "Si dudo de una dirección, uso el mapa."),
    ("Mis logros me hacen digno de amor.", "Merezco amor por lo que he logrado.", "Soy digno de amor sin importar mis logros.", NEG, "Mis logros académicos alegran a mis padres."),
    ("La crítica siempre es un ataque.", "Toda crítica busca herirme.", "Algunas críticas buscan ayudarme.", CUANT, "La crítica de cine me parece interesante."),
    ("Dios trabaja aun cuando no lo veo.", "Aunque no lo note, Dios está obrando.", "Si no lo veo, Dios no está trabajando.", NEG, "Trabajo aun cuando estoy enfermo."),
    ("Tengo que tener todo planeado para estar tranquilo.", "Sin un plan completo, no puedo estar en calma.", "Puedo estar tranquilo sin tener todo planeado.", NEG, "Tengo que planear la fiesta de mi hija."),
    ("Mi enfermedad es un castigo.", "Estoy enfermo porque Dios me está castigando.", "Mi enfermedad no es un castigo.", NEG, "Mi enfermedad requiere tomar medicinas a diario."),
    ("Perdonar significa olvidar lo que pasó.", "Si perdono, debo hacer como que nada pasó.", "Puedo perdonar sin olvidar lo que pasó.", NEG, "Olvidar las llaves me pasa seguido."),
    ("La alabanza me acerca a Dios.", "Cuando adoro, me siento más cerca de Dios.", "La alabanza me aleja de Dios.", ANT, "La música me acerca a mis amigos."),
    ("Nunca seré suficiente.", "Jamás estaré a la altura.", "En Cristo soy suficiente.", AGENTE, "Nunca hay suficiente pan en la cena del domingo."),
    ("Los demás tienen la culpa de mi enojo.", "Me enojo porque otros me provocan.", "Yo soy responsable de mi enojo.", AGENTE, "Los demás tienen la culpa del tráfico de la ciudad."),
    ("Dios me consuela en el duelo.", "En la pérdida encuentro consuelo en Dios.", "Dios me deja sin consuelo en el duelo.", ANT, "Consuelo a mi amiga que perdió a su madre."),
    ("Callar mis opiniones evita conflictos.", "Si no digo lo que pienso, no hay problemas.", "Callar mis opiniones no evita los conflictos.", NEG, "Mis opiniones sobre fútbol causan risas."),
    ("Es imposible que Dios me perdone esto.", "Lo que hice no tiene perdón de Dios.", "Dios puede perdonarme esto.", NEG, "Es imposible terminar este proyecto hoy."),
    ("Ayunar me hace más santo que los demás.", "Por ayunar soy mejor que otros.", "Ayunar no me hace más santo que los demás.", NEG, "Ayunar me da hambre por la tarde."),
    ("Dios abre caminos donde no los hay.", "Cuando no veo salida, Dios crea una.", "Si no hay camino, Dios no puede abrir uno.", NEG, "Abrimos un camino nuevo hacia la finca."),
    ("Siempre arruino mis relaciones.", "Todas mis relaciones terminan mal por mi culpa.", "No siempre arruino mis relaciones.", CUANT, "Mis relaciones laborales requieren paciencia."),
    ("Mi identidad está en ser hijo de Dios.", "Soy, ante todo, hijo de Dios.", "Mi identidad está en mi profesión, no en Dios.", ANT, "Mi hijo tiene una identidad propia."),
    ("La tristeza nunca se irá.", "Esta tristeza durará para siempre.", "La tristeza pasará.", ANT, "La tristeza de mi amigo me preocupa."),
    ("Debo vengarme para que se haga justicia.", "La justicia solo llega si yo me vengo.", "Dios hará justicia, no necesito vengarme.", AGENTE, "Debo estudiar para ser abogado de justicia."),
    ("Dios se alegra de mí.", "Soy motivo de gozo para Dios.", "Dios se avergüenza de mí.", ANT, "Mi madre se alegra de mis visitas."),
    ("Si espero en Dios, renuevo mis fuerzas.", "Esperar en el Señor me da nuevas fuerzas.", "Esperar en Dios me deja sin fuerzas.", ANT, "Si espero el autobús, llego tarde."),
    ("Todo depende de mí.", "Nada sale bien si yo no lo hago.", "No todo depende de mí.", NEG, "Mi familia depende de mí económicamente."),
]

assert len(ANCHORS) == 100, len(ANCHORS)


def pairs() -> list[dict]:
    """300 pares: relación esperada en NLI = entailment / contradiction / neutral."""
    out = []
    for i, (a, b, c, cat, d) in enumerate(ANCHORS):
        out.append({"id": f"mp{i:03d}b", "anchor": i, "a": a, "b": b, "relation": "misma_cadena", "category": "parafrasis", "nli": "entailment"})
        out.append({"id": f"mp{i:03d}c", "anchor": i, "a": a, "b": c, "relation": "opuesto", "category": cat, "nli": "contradiction"})
        out.append({"id": f"mp{i:03d}d", "anchor": i, "a": a, "b": d, "relation": "otra_cadena", "category": "mismas_palabras", "nli": "neutral"})
    return out


def sentences() -> set[str]:
    return {s for row in ANCHORS for s in (row[0], row[1], row[2], row[4])}


def write(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        for p in pairs():
            f.write(json.dumps(p, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    write(Path(__file__).resolve().parents[1] / "data" / "minimal_pairs_v1.jsonl")

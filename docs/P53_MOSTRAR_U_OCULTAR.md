# P53 - Mostrar u ocultar según un encuentro superado

- Segunda pieza del paso del castillo en la Fase 2 de `TASK.md`: el castillo sin hechizo (soldados NPC y el Capitán) y el rey encadenado de las profundidades.
- Pieza: `scripts/environment/encounter_visibility.gd` (`UnderkingdomEncounterVisibility`), un `Node` que se pone como hijo del nodo a controlar. No lleva escena propia.
- Decisión de `docs/historial/FASE2_DECISIONES.md` que aplica: K3. No toca `GameManager` ni guarda estado: lee `completed_encounters`, que ya se guarda.

## 1. Comportamiento

| Propiedad | Valor | Qué hace |
|---|---|---|
| `target` | vacío (el padre) | nodo controlado |
| `show_when_encounter` | vacío | oculto hasta que este encuentro esté superado |
| `hide_when_encounter` | vacío | oculto en cuanto este encuentro esté superado |

- Oculto: `visible = false`, capa y máscara de colisión a 0 en el nodo y sus descendientes (`CollisionObject2D`, se recuerdan y se restauran) y `process_mode` desactivado.
- Se evalúa al cargar (otra vez en diferido, porque el `_ready` del padre corre después) y cuando `GameManager.encounter_completed` marca uno de sus dos ids. Así sirve en la misma escena y al volver a cargarla.
- Con las dos exportaciones vacías no hace nada. Con las dos, se muestra tras `show_when_encounter` y se oculta con `hide_when_encounter`.
- `story_hidden_actor.gd` se queda como está (lo usa `primer_boss_mundo_1`, sin cambios).
- Limitación: solo los `CollisionObject2D` que existen al cargar; los añadidos después no se tocan.

## 2. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`, junto a la palanca (encuentro `pruebas_palanca_trampilla`): `AncianoAparece` en `(1000, 300)` con `show_when_encounter`, y `BarqueroDesaparece` en `(1150, 300)` con `hide_when_encounter`.
- **Oculta/cierra:** al empezar solo se ve el Barquero.
- **Muestra/abre:** tirando de la palanca (E) aparece el Anciano y desaparece el Barquero.

## 3. Pruebas

- Escena temporal sin ventana (borrada): Anciano `visible=false`, `process_mode` 4 (desactivado) y Barquero visible antes; tras `mark_encounter_completed` se invierten. Con un `StaticBody2D` de capa 5 y máscara 3: 5/3 → 0/0 al ocultarse → 5/3 al volver a mostrarse.
- Arrancan sin errores el juego y la zona de pruebas. No se tocó Player, enemigos, `GameManager` ni el Capitán, así que no se probó `mundo_1`.

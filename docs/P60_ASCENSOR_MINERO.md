# P60 - Ascensor minero (`:C:`)

- Primera pieza del paso de las minas de la Fase 2 de `TASK.md` (la de atuendos que G2 adelantaba ya estaba hecha, P59).
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: M1, M2, G3, G4 y G5.
- Piezas: `escenas/objetos/ascensor.tscn` con `scripts/environment/mine_elevator.gd` (`UnderkingdomMineElevator`).

## 1. Qué es

- `:C:` une dos escenas (el sótano del castillo y la estación de las minas, 53 piezas de pozo), así que hay **una cabina en cada escena** y no recorre el pozo. El jugador entra, pulsa E ("E  Subir" / "E  Bajar", la misma acción que `npc.gd` y la palanca; grupo `interactable`), la cabina traquetea 1 s, la pantalla se funde a negro y se cambia de escena al spawn de la cabina gemela.
- Origen en el centro de la base de la cabina (3 x 3 piezas, el ancho del pozo de `:C:`, x 20-22 en las minas). Se coloca en `Objetos` de la `_combate`: `(columna central * 16 + 8, (fila del suelo + 1) * 16)`.
- Cada cabina lleva su propio spawn (`Spawn`, hijo creado por el script, en el origen del Player: 62 px sobre la base) con `arrival_spawn_id`. No hace falta un `SpawnPoint` aparte en el mapa.

## 2. Propiedades

| Propiedad | Valor | Qué hace |
|---|---|---|
| `target_scene_path` | `""` | escena de la cabina gemela |
| `target_spawn_id` | `&""` | `arrival_spawn_id` de la gemela |
| `arrival_spawn_id` | `&""` | spawn de esta cabina (donde sale quien llega) |
| `requires_encounter` | `""` | si se rellena, no funciona hasta que `GameManager` marque ese encuentro (la palanca de las minas, M2): sale "NO HAY CORRIENTE" |
| `size_tiles` / `cabin_texture` | 3 x 3 / vacío | tamaño y dibujo; sin textura se dibuja una cabina provisional |
| `prompt_text` / `no_power_message` | `E  Subir` / `NO HAY CORRIENTE` | textos (G3) |
| `interaction_radius` / `interaction_vertical_range` | 24 / 72 | zona de uso, desde el centro de la cabina |
| `travel_time` / `fade_time` / `arrival_hold` | 1.0 / 0.4 / 0.3 | duración del traqueteo, fundido final y negro al llegar |
| `shake_strength` | 2 | sacudida de cámara durante el viaje |

- Señales `travel_started` y `blocked`; `travel()` y `has_power()` son públicos.

## 3. Viaje

- Bloquea los controles del Player (`set_controls_locked`), traquetea la cabina ±1 px (escala entera), sacude la cámara y funde a negro con una capa de la raíz del árbol (`CanvasLayer` 100). Esa capa sobrevive al cambio de escena y se funde de vuelta en la nueva.
- Al final: `GameManager.set_transition(target_spawn_id)`, autoguardado si la escena es de región (como `map_transition.gd`) y `change_scene_to_file` diferido.
- Sin escena destino válida: `push_error` y la cabina no se mueve.
- Guardado: sin variables nuevas; usa `completed_encounters`. `SAVE_FORMAT_VERSION` sigue en 5.

## 4. Cómo se monta en la Fase 3

- Minas: cabina en la estación (x 20-22, suelo en la fila 41), `requires_encounter` = el `encounter_id` de la palanca de (12, 40); destino `tiles_castillo_combate.tscn`.
- Castillo: cabina en el sótano, bajo la trampilla de `:C:` (x 34-36), que escucha el mismo id con `open_on_encounter`; destino `tiles_mineria_combate.tscn`.
- Ids de spawn y de encuentro: se fijan al montar cada zona.

## 5. Arte provisional

- Cabina dibujada con rectángulos (hierro y madera). **Pendiente:** arte propio (cabina, y si se quiere puerta y cadena) y sonido del traqueteo, que no hay en el proyecto.

## 6. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`:
  - `AscensorAbajo` en `(552, 320)`: x 33-35, junto al foso de pinchos, con `requires_encounter` `pruebas_palanca_trampilla` (la palanca de x 67).
  - `AscensorArriba` en `(1160, 176)`: sobre la galería, a la derecha de la escalera x 69. Siempre funciona.
  - Ambos apuntan a la propia zona de pruebas, con el spawn de la gemela.
- **Cierra:** `AscensorAbajo` dice "NO HAY CORRIENTE" hasta tirar de la palanca de x 67.
- **Abre:** tirada la palanca, E en `AscensorAbajo` lleva a la galería y E en `AscensorArriba` baja.

## 7. Pruebas

- Escena temporal sin ventana, con la zona cargada (borrada): sin corriente la E responde pero no viaja ni bloquea al Player; marcado el encuentro, la E de una cabina lejana no actúa; la E de la cercana bloquea los controles y viaja; tras 3.5 s la escena es la zona de pruebas, el Player está en el spawn de la gemela `(1160, 114)`, con controles libres y sin capa de fundido.
- Arrancan sin errores el juego y la zona de pruebas. No se toca Player, enemigos, `GameManager` ni el Capitán: `mundo_1` no se ha probado.

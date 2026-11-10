# P49 - Palanca y barrera según `completed_encounters`

- Segunda pieza de la Fase 2 de `TASK.md` (paso del calabozo): una palanca que se tira con E y las barreras que se abren cuando se tiró, en esa escena o en otra.
- Sirve a los atajos `:B:` a `:F:` (palanca del lado de abajo, trampilla o reja del de arriba), a la compuerta de los desagües de la mazmorra y a la rejilla de la jaula del rey encadenado, que se abre con un encuentro del infierno y no con una palanca.
- Piezas:
  - `escenas/objetos/palanca.tscn`, con `scripts/environment/lever.gd` (`UnderkingdomLever`);
  - una exportación nueva en `scripts/environment/arena_barrier.gd`: `open_on_encounter`.
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: C1 a C4, G3, G4 y G5.

## 1. La palanca

- Raíz `AnimatedSprite2D` en el grupo `interactable`, como el cofre y `npc.gd`. Con el Player cerca sale el aviso "E  Tirar" y la E la tira (C1: no se acciona a golpes).
- Mide 1 x 2 piezas (16 x 32 px) y el origen está arriba a la izquierda (`centered = false`). Las coordenadas de los ASCII, como (67, 21) en la mazmorra, son la pieza del pie: se coloca en `(columna * 16, (fila - 1) * 16)` dentro de `Objetos` de la `_combate`.
- Al tirar (C3):
  - pasa al cuadro `pulled_frame`;
  - marca `encounter_id` con `GameManager.mark_encounter_completed`, que emite `encounter_completed` y guarda la partida;
  - sacudida ligera de la cámara (`shake()`, solo `offset`, la misma que la pared agrietada) y el texto "SE OYE UN MECANISMO" sobre la palanca. La cámara no se desplaza hasta la barrera.
  - Emite la señal `pulled`, por si otra pieza la necesita (el ascensor de `:C:`).
- Se tira una sola vez. Tirada, ya no muestra el aviso ni acepta la E, que vuelve a hacer lo de siempre (la Ultimate).
- Al cargar la escena, si el encuentro ya está marcado, sale tirada.
- Sin `encounter_id` avisa con `push_warning` y no se puede tirar.

| Propiedad | Valor | Qué hace |
|---|---|---|
| `encounter_id` | `""` | id que marca; las barreras que abre lo llevan en `open_on_encounter` |
| `idle_frame` / `pulled_frame` | 0 / 1 | cuadros de la animación `states` |
| `interaction_radius` | 24 | distancia en horizontal desde el centro de la palanca |
| `interaction_vertical_range` | 72 | distancia en vertical (el origen del Player está 62 px sobre sus pies) |
| `prompt_text` | `E  Tirar` | aviso flotante (G5) |
| `pulled_message` | `SE OYE UN MECANISMO` | texto al tirar (G3); vacío para no mostrar nada |
| `shake_strength` / `shake_time` | 3 / 0.25 | sacudida de la cámara; 0 para quitarla |

## 2. La barrera: `open_on_encounter`

- Exportación nueva de `arena_barrier.gd`, vacía por defecto: las barreras que ya había no cambian.
- Con un id:
  - si el encuentro ya está marcado al cargar la escena, la barrera empieza abierta, sin fundido;
  - si no, escucha `GameManager.encounter_completed` y se abre con su fundido de siempre cuando se marca ese id.
- Vale para cualquier encuentro, no solo palancas: la rejilla de la jaula del rey encadenado se abre con `infierno_animas_liberadas`, que marca el coliseo del infierno.
- Varias barreras pueden escuchar el mismo id (C2). La palanca de las minas, por ejemplo, abre la trampilla del sótano del castillo, en otra escena.
- La heredan `locked_door.gd` y las demás hijas de `arena_barrier.gd`.
- **No combinar con `Atajos` de `boss_arena.gd`:** la sala de jefe cierra y abre sus atajos ella misma en su `_ready`, que va después del de la barrera, y pisaría el estado.
- **C4, la barrera del otro lado:** no hace falta código. La palanca solo existe del lado de abajo; desde arriba la barrera se ve cerrada y no hay nada que la abra.
- Ids que ya fijan los ASCII: `mazmorra_atajo_b_abierto` (`:B:`), `mazmorra_atajo_f_abierto` (`:F:`) e `infierno_animas_liberadas` (rejilla de la jaula). Los demás (`:C:`, `:D:`, `:E:` y la compuerta de la mazmorra) se ponen al montar cada zona en la Fase 3.

## 3. Guardado

- No hay variable nueva: la palanca y la barrera usan `completed_encounters`, que ya se guardaba en la partida (`_make_save_data` / `_restore_game_state`) y se vaciaba en `reset_for_new_game`. `SAVE_FORMAT_VERSION` sigue en 2.
- Como el id lo pone el editor y no la ruta del nodo, una palanca o una barrera se puede mover o renombrar sin perder el estado.

## 4. Arte provisional

- Palanca: dos piezas del tileset CC0 de la mazmorra, `assets/terceros/dungeon_platformer/dungeontilesetfull.png`, de 16 x 32 cada una:
  - sin tirar: la lanza clavada en un barril, columna 28, filas 8-9 (región `(448, 128, 16, 32)`);
  - tirada: la espada inclinada en un barril, columna 27, filas 8-9 (región `(432, 128, 16, 32)`).
- **Pendiente:**
  - arte propio de palanca, con al menos los dos cuadros (y, si se quiere, una tira de tirar que se reproduzca entre los dos);
  - sonido del mecanismo, que no hay en el proyecto.
- Las barreras siguen dibujándose con piezas del tileset del nivel, como hasta ahora.

## 5. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`:
  - `Palanca` en `(1072, 288)`: columna 67, filas 18-19, en el piso de abajo, junto al pie de la escalera x 69. `encounter_id` `pruebas_palanca_trampilla`.
  - `TrampillaPalanca`, una `arena_barrier.gd` de 3 x 1 piezas en `(1112, 184)`: tapa el hueco de la escalera x 69 en el suelo de la galería (x 68-70, fila 11), con las losas del tileset `castillo` que usa la trampilla del castillo. `start_closed` y `open_on_encounter` `pruebas_palanca_trampilla`.
- **Cierra:** subiendo por la escalera x 69, la cabeza choca con la trampilla. Desde la galería (por las plataformas) la trampilla es suelo y no hay palanca de ese lado.
- **Abre:** E junto a la palanca. La trampilla se desvanece y la escalera llega a la galería. Tras morir (K) o reaparecer (R), sigue abierta. Para verla cerrada otra vez, reiniciar con F6 sin cargar partida.

## 6. Pruebas

- Escena temporal sin ventana que carga la zona de pruebas y simula entradas (borrada al terminar):
  - al empezar, la palanca sin tirar (cuadro 0) y la trampilla cerrada, con colisión;
  - **cierra:** con arriba pulsado 2.5 s en la escalera, el pie más alto queda en y 235: la cabeza (43 px) toca el borde de abajo de la trampilla, en y 192;
  - E lejos de la palanca no la tira; junto a ella sale el aviso y la tira: cuadro 1, `completed_encounters` con `pruebas_palanca_trampilla`, trampilla abierta y sin colisión, y el texto "SE OYE UN MECANISMO";
  - una segunda E ya no la acepta;
  - **abre:** con arriba pulsado, el pie llega a y 150, por encima del suelo de la galería (y 176);
  - al volver a instanciar el mapa, la palanca sale tirada y la trampilla abierta, sin colisión.
- Arrancan sin errores el juego, la zona de pruebas, `mundo_1` (el aviso de SpawnPoint ya salía antes) y `tiles_castillo_combate`, que usa `arena_barrier.gd`.

# P59 - Atuendo actual y `OUTFIT_DEFINITIONS`

- Primera pieza de atuendos de la Fase 2 de `TASK.md`, adelantada al paso de las minas (G2 de `docs/historial/FASE2_DECISIONES.md`): el fuego infernal necesita saber si el jugador lleva E5.
- Decisiones que aplica: A1, A2 (solo la base, el menú es otra pieza), G1, G3 y G4.
- No hay escena nueva: la pieza es la tabla y el estado en `GameManager`, tres puntos de lectura en el Player y una opción del modo dev.

## 1. La tabla

`GameManager.OUTFIT_DEFINITIONS`, por id, con `name`, `level`, `sword`, `sprite_frames` y `hint`, más los rasgos que dé cada uno:

| Id | Nivel | Rasgos (provisionales, A1) |
|---|---|---|
| `desnudo` (E0) | 0 | sin espada |
| `harapos` (E1) | 1 | espada y tajos |
| `soldado` (E2) | 2 | `sword_reach` 1.25 |
| `caballero_cripta` (E3) | 3 | `ability` `agility`, `damage_reduction` 0.25 |
| `abrigo` (E4) | 4 | `resist` `cold` (el daño por frío no existe todavía) |
| `fire_knight` (E5) | 5 | `slash_damage` 0.25, `sword_reach` 1.25, `resist` `infernal_fire` |

- `sprite_frames` está vacío en todos: hasta que cada atuendo tenga el suyo se usa el del anterior (pieza "Un `SpriteFrames` por atuendo").

## 2. Estado y API

- `outfits_found` (ids encontrados; el desnudo no cuenta) y la señal `outfit_changed(outfit_id)`.
- `get_outfit_id()`: el de más nivel de los encontrados. Con espada y sin atuendo encontrado (armería, modo dev, `has_sword` de antes) devuelve `harapos`; sin espada, `desnudo`. Así `has_sword` se mantiene como "E1 o más" sin cambiar nada de lo que ya lo pone.
- `grant_outfit(id, player)`: lo apunta, da su `ability` (`unlock_ability`), da la espada si el atuendo trae y no se tenía (misma ruta que `recover_castle_equipment`), emite la señal y guarda. Devuelve false si ya estaba o no existe.
- `get_outfit_info`, `has_outfit`, `get_outfit_sword_reach()`, `get_outfit_slash_bonus()`, `get_outfit_damage_reduction()`, `has_outfit_resistance(tipo)` y `reduce_damage_for_outfit(cantidad)`.
- Los rasgos se combinan entre **todos** los atuendos encontrados, no solo el que se lleva: el mayor alcance, la mayor reducción, la suma del daño de tajo y la unión de resistencias. Así un abrigo opcional no quita el alcance del soldado.

## 3. Qué hace en el Player

- `_place_sword_hitbox`: la caja de la espada se escala por `get_outfit_sword_reach()` (0.60 pasa a 0.75 con 1.25).
- `_start_attack`: el daño de los tres tajos suma `get_outfit_slash_bonus()` junto a la empuñadura.
- `take_damage`: tras el posible daño extra de ir sin espada, `reduce_damage_for_outfit`: solo golpes de 0.75 o más, restan 0.25 y nunca bajan de 0.25. Cubrirse y el parry se resuelven antes, sin cambios.
- La agilidad ya la leía `GameManager.has_ability("agility")`: el atuendo E3 la desbloquea.
- Las resistencias (`cold`, `infernal_fire`) solo se consultan con `has_outfit_resistance`; las usarán el fuego infernal (siguiente pieza) y la zona de frío, que sigue sin existir.

## 4. Guardado

- `SAVE_FORMAT_VERSION` pasa a 5. Se guarda `outfits` (lista de ids, solo los que existen en la tabla), se restaura en `_restore_game_state` y se vacía en `reset_for_new_game`. Las partidas de la versión 4 dejan de cargar (G1).

## 5. Zona de pruebas

- Modo dev (tecla º): opción nueva "Siguiente atuendo", que da el siguiente por nivel (harapos, soldado... Fire Knight). No hay objeto que recoger todavía (pieza "Escena de atuendo para recoger").
- **Cierra:** sin atuendos el alcance es 1.0, un golpe de 1.0 quita 1.0 y la Agilidad no está.
- **Abre:** con el soldado la caja del tajo mide 0.75; con el caballero llega la Agilidad y el golpe de 1.0 quita 0.75; con el Fire Knight los tajos hacen 0.25 más.
- **Pendiente:** el cambio de aspecto (otra pieza) y el arte de E2, E3 y E4.

## 6. Pruebas

- Escena temporal sin ventana (borrada), con la zona de pruebas cargada: desnudo sin espada; `grant_outfit("harapos")` da la espada y repetirlo devuelve false; el soldado deja la caja en 0.75; el caballero desbloquea la Agilidad y reduce 1.0 a 0.75, 0.75 a 0.5, y deja 0.5 y 0.25 igual; el abrigo mantiene el alcance y da `cold`; el Fire Knight suma 0.25 y da `infernal_fire`; el guardado trae los cinco ids con versión 5 y `reset_for_new_game` los vacía.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1` (su aviso de SpawnPoint sin suelo seguro ya estaba).

# P68 - Un `SpriteFrames` por atuendo (el Fire Knight separado de los harapos)

- Segunda pieza de "En paralelo: atuendos" de la Fase 2 de `TASK.md` (P46, sección 10, "Implementación").
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: A3 (cada atuendo sin arte usa el `SpriteFrames` del anterior) y G4; las nuevas están al final de ese archivo.
- Archivos nuevos: `escenas/atuendos/fire_knight.tres` (el aspecto de E5) y su generador, `herramientas/sprites/generar_atuendo_fire_knight.gd` (+ `.tscn`).
- Cambian: `player.gd` (elige y compone el aspecto con espada del atuendo actual) y `OUTFIT_DEFINITIONS` (el Fire Knight apunta a su recurso).
- Sin guardado nuevo: el aspecto se deduce de `get_outfit_id()`. `SAVE_FORMAT_VERSION` sigue en 5.

## 1. Antes y después

- Antes, el `SpriteFrames` de `player.tscn` mezclaba las tiras IA de los harapos (E1: `idle`, `run`, `attack` / `attack 2`, `air attack`, `jump up` / `jump down`, `take hit`, `death`, `escaleras`) con animaciones del paquete Fire Knight (`roll`, `defende`, `defese idle 3 golpes`, `attack ultimate`, `jump`), y todos los atuendos se veían igual.
- Ahora el Fire Knight tiene su propio `SpriteFrames`, con los PNG sueltos del paquete (`Elementals_fire_knight_FREE_v1.1/.../png/fire_knight/`), y el Player lo usa al llevar E5.
- `player.tscn` no cambia: su `SpriteFrames` sigue siendo el de los harapos. Las cinco animaciones del Fire Knight que tiene son prestadas mientras E1 no tenga sus tiras (pendiente de P42 y de la pieza de arte con IA).

## 2. La tabla

- `OUTFIT_DEFINITIONS[id].sprite_frames`: ruta a un `SpriteFrames` aparte que solo trae las animaciones propias del atuendo.
  - Vacío en `harapos` (es el de `player.tscn`), `soldado`, `caballero_cripta` y `abrigo` (sin arte, A3).
  - `fire_knight`: `res://escenas/atuendos/fire_knight.tres`.
  - El desnudo no usa el campo: su aspecto es el de `prisn.tscn`, sin espada.
- Escala de dibujo: cada recurso puede llevar el metadato `animation_scales` (animación → escala; 1 si no está). Las hojas IA de los harapos siguen con `ARMED_ANIMATION_SCALES` (1/3). Las dos miden lo mismo en pantalla: 288 x 128 por cuadro a escala 1, o 864 x 384 a 1/3, con los pies en la misma fila (comprobado: fila 127 en los dos).
- Para añadir el aspecto de E2, E3 o E4: un `.tres` en `escenas/atuendos/` con solo sus animaciones y su ruta en la tabla. Lo que no traiga sale del atuendo anterior.

## 3. Qué hace el Player

- `_build_outfit_look(id)`: parte del `SpriteFrames` de los harapos (con la `fireball` ya añadida) y le superpone, por nivel, los de los atuendos con espada hasta el pedido. Cada animación sale del último que la tiene, con su escala. Si ninguno tiene recurso propio, devuelve el de los harapos sin copiarlo. Se guarda en caché por atuendo.
- `_select_outfit_look()`: elige el del atuendo que se lleva (los harapos si todavía es el desnudo). Lo llaman `_ready` y `set_sword_equipped`.
- Al encontrar un atuendo (`GameManager.outfit_changed`), si el Player lleva espada cambia de `SpriteFrames` conservando la animación y el cuadro, sin cortar la acción en curso.
- `_current_armed_scale()` lee la escala de la animación del aspecto actual, no la constante.
- Con E5 la `escaleras` y la `fireball` siguen siendo las de los harapos, porque el paquete no las trae.

## 4. El recurso del Fire Knight

Lo genera `godot --headless res://herramientas/sprites/generar_atuendo_fire_knight.tscn` (escena y no `-s`, porque lee `player.tscn`, que usa los autoloads). Reglas:
- Los tajos con perfil por cuadro (`ATTACK_PROFILES`) llevan los mismos cuadros y velocidad que los harapos, para que el golpe caiga igual:
  - `attack` (descendente, 3 cuadros a 7): `1_atk` 4, 5 y 8 (el arco en el cuadro del golpe);
  - `attack 2` (ascendente, 3 a 7): `2_atk` 10, 13 y 15;
  - `air attack` (5 a 8, golpe en los cuadros 1-2): `air_atk` 3, 4, 5, 7 y 8.
- `idle`, `run`, `jump up`, `jump down`, `take hit` y `death` llevan todos los cuadros del paquete, con la velocidad ajustada para durar lo mismo que en los harapos (las acciones esperan esa duración).
- `roll`, `defende`, `defese idle 3 golpes`, `attack ultimate` y `jump` se copian tal cual de `player.tscn` (ya eran del Fire Knight).

## 5. Zona de pruebas

- `zona_pruebas_combate.tscn`, `Objetos/ManiquiFireKnight`: el `idle` del recurso nuevo, detrás del spawn (x 92), para ver el aspecto sin cambiar de atuendo.
- **Cierra:** con "Dar espada" el Player lleva los harapos; con "Siguiente atuendo" (modo dev) el soldado, el caballero y el abrigo siguen con el mismo aspecto (no tienen arte).
- **Abre:** el siguiente "Siguiente atuendo" da el Fire Knight y el Player cambia a sus sprites en el momento; sus tajos golpean en el mismo cuadro y la escalera usa la de los harapos.

## 6. Pruebas

- Escena temporal sin ventana (borrada), con la zona de pruebas cargada: sin espada no hay `attack`; con espada, `idle` es la hoja IA a 1/3; harapos, soldado, caballero y abrigo dejan el mismo `SpriteFrames`; con el Fire Knight cambia a mitad de `run` sin perder el cuadro, `idle` sale de `idle_1.png` a escala 1, `escaleras` de la hoja IA a 1/3, tiene `fireball`, los tajos tienen 3, 3 y 5 cuadros y `attack` dura lo mismo; el `SpriteFrames` de los harapos queda intacto y volver a equipar mantiene el del Fire Knight.
- Arrancan sin errores el juego, la zona de pruebas, el castillo y `mundo_1` (su aviso de SpawnPoint sin suelo seguro ya estaba).

## 7. Pendiente

- Arte de E2, E3 y E4 (pieza "Arte con IA") y las tiras propias de E1 para `roll`, defensa, Ultimate y `escaleras`; mientras tanto, prestadas del Fire Knight o de los harapos.
- `escaleras` del Fire Knight: el paquete no la trae.
- Los cuadros elegidos para los tajos del Fire Knight son provisionales: revisarlos jugando.

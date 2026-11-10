# P48 - Pared agrietada

- Primera pieza de la Fase 2 de `TASK.md` (paso del calabozo): una pared que se rompe a golpes, también a puños. Sirve a los dos secretos de tipo pared falsa de P46: el escondite del preso en el calabozo (columna 63, filas 24-26) y la sala de la galería de las profundidades (columna 8, filas 23-25).
- Escena `escenas/objetos/pared_agrietada.tscn`, con el script que ya tenían la caja y la estatua: `scripts/environment/breakable_object.gd`.

## 1. La pieza

- Mide 1 x 3 piezas (16 x 48 px), lo que piden los dos sitios. El origen está arriba a la izquierda: se coloca en `(columna * 16, fila de arriba * 16)` dentro de `Objetos` de la escena `_combate`.
- La raíz es un `AnimatableBody2D` con `sync_to_physics = false` y está en el grupo `breakable` (ver la sección 3).
- `collision_layer = 5`:
  - la capa 1 bloquea al Player y a los enemigos, como un muro;
  - la capa 3 la detecta la AttackHitbox.
  - La caja y la estatua usan solo la capa 3 y por eso se atraviesan.
- Valores de la escena (decididos el 2026-11-08), que se pueden cambiar por instancia en el inspector:

| Propiedad | Valor | Qué hace |
|---|---|---|
| `max_health` | 1.0 | 4 puñetazos (0.25), 2 tajos (0.5) o 1 ascendente con Golpe final (1.0) |
| `hide_sprite_when_destroyed` | sí | al romperse desaparece (falta arte de escombros) |
| `break_puff` | sí | nube de polvo (`death_puff` de `combat_fx.gd`) |
| `break_shake_strength` / `break_shake_time` | 3 / 0.25 | sacudida ligera de la cámara (`shake()`, solo `offset`) |
| `coin_drop_count` / `potion_drop_count` | 0 / 0 | sin botín: el premio es el cofre de detrás |

- Al golpearla da el destello blanco que el Player ya pone a todo lo que golpea.
- **Se recuerda:** al romperse se marca en `GameManager.consumed_objects` (mapa y ruta del nodo). Al volver al mapa, al morir o al cargar la partida, aparece rota y sin colisión. Ese diccionario ya se guardaba en la partida y se vaciaba en `reset_for_new_game`, así que no hay variable nueva y `SAVE_FORMAT_VERSION` sigue en 2.
- Como la clave es la ruta del nodo, una pared no se debe renombrar ni mover de nodo padre una vez que haya partidas que la hayan roto.

## 2. Cambios en `breakable_object.gd`

Tres exportaciones nuevas. Su valor por defecto deja la caja y la estatua como estaban:
- `hide_sprite_when_destroyed` (`false`), en "Objeto rompible": oculta el sprite al romperse.
- En la categoría nueva "Al romperse", que solo actúa cuando lo rompe el Player y no al recargar el mapa ya roto:
  - `break_puff` (`false`): nube de polvo en el centro de la colisión;
  - `break_shake_strength` (`0`, sin sacudida) y `break_shake_time` (`0.2`): llaman a `shake()` de la cámara activa si lo tiene.

## 3. La AttackHitbox no detecta los `StaticBody2D`

- Probando sin ventana, la AttackHitbox del Player (un `Area2D`) no devolvía la pared en `get_overlapping_bodies()`, aunque la tocaba. Una consulta directa de física sí la encontraba.
- Pasa igual con `caja_rompible.tscn`: tampoco la detecta. En cambio, un `AnimatableBody2D` en el mismo sitio sí lo detecta.
- Por eso la raíz de la pared es un `AnimatableBody2D`. Hereda de `StaticBody2D`, así que usa `breakable_object.gd` sin cambios, y con `sync_to_physics = false` y sin moverse se comporta como un muro.
- **Pendiente:** la caja y la estatua rompibles (`caja_rompible.tscn`, `estatua_rompible.tscn`, usadas en `mundo_1`) siguen siendo `StaticBody2D` y, según esta prueba, los golpes no las alcanzan. No se tocaron: arreglarlas es cambiar su raíz al mismo tipo.

## 4. Arte provisional

- La columna de ladrillo morado del tileset `castillo`: piezas (3, 16-18) de `assets/terceros/raou_castillo/tileset_castillo.png`, región `(48, 256, 16, 48)`, igual en los cuatro estados (intacta, dañada, crítica y rota).
- **Pendiente:**
  - arte propio de ladrillo con grietas, en tres grados de daño más los escombros. Con los escombros, `hide_sprite_when_destroyed` pasa a `false`;
  - para las profundidades (tileset `mazmorra`, bloques `oro`), una escena heredada `pared_agrietada_profundidades.tscn` que solo cambie el `SpriteFrames` (decidido el 2026-11-08). Se hace al montar esa zona en la Fase 3.
- No hay sonido de derrumbe en el proyecto. Cuando lo haya, se añade aquí.

## 5. Zona de pruebas

- `zona_pruebas_combate.tscn`, `Objetos/ParedAgrietada` en `(1424, 32)`: columna 89, filas 2-4, sobre la cornisa de la escalera x 83. El techo deja 3 piezas, como en el calabozo.
- **Cierra:** se sube por la escalera y la pared corta el paso a la poción de x 91. Desde la galería no se llega a la cornisa: hay 6 piezas.
- **Abre:** se rompe a puñetazos o con la espada (Modo dev, "Dar espada") y se llega a la poción. Tras morir (K) o reaparecer (R), sigue rota. Para verla entera otra vez, reiniciar con F6 sin cargar partida.

## 6. Pruebas

- Escena temporal sin ventana que carga la zona de pruebas, deja al Player junto a la pared y simula entradas (borrada al terminar):
  - **sin espada:**
    - tras empujar 1 s hacia la derecha, el Player se queda en x 1413, contra la pared;
    - 4 puñetazos la dejan en 0.75, 0.5, 0.25 y rota;
    - queda marcada en `consumed_objects`, sin sprite, y el Player la cruza (x 1542);
  - **con espada:** 2 tajos (0.5 y rota), y el Player la cruza;
  - en los dos casos, al volver a instanciar el mapa sale rota, con la colisión desactivada y la capa a 0.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1` (el aviso de SpawnPoint de `mundo_1` ya salía antes).

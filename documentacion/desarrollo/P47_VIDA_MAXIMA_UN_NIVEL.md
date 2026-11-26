# P47 - Vida máxima en un solo nivel

- Ajuste previo de la Fase 2 de `TASK.md`, decidido en P46 (sección 6): la tienda vende un solo nivel de vida máxima y el sexto corazón saldrá de los 4 fragmentos de vida de las puertas hacia atrás.

## 1. Qué cambia

| | Antes | Ahora |
|---|---|---|
| `max_level` de `"max_health"` en `UPGRADE_DEFINITIONS` | 2 | 1 |
| Precio | 5 y 10 monedas | 10 monedas |
| Vida máxima | 4 → 5 → 6 | 4 → 5 |

- El precio sube a 10 (decidido el 2026-11-08): un corazón entero en una sola compra.
- El menú de pausa no cambia: lee la tabla y muestra "Nv 0/1" y, tras comprarla, "Máximo".
- Mientras no existan los fragmentos de vida (Fase 2, paso del castillo), el tope real es 5 corazones.

## 2. Partidas guardadas de antes

- Al cargar, `_restore_game_state` ya recortaba cada mejora a su `max_level`: una partida con la vida en nivel 2 queda en nivel 1.
- Pero `restore_saved_player` volvía a poner la `max_health` del guardado, y esa partida seguía con 6 corazones. Ahora la vida máxima no se lee del guardado: la pone `apply_upgrades_to_player` desde las mejoras, que es lo único que la cambia. La vida actual se recorta a ese tope.
- La partida vieja queda en 5 corazones y pierde las monedas del segundo nivel; no se devuelven.
- `max_health` se sigue escribiendo en el guardado y validando al leerlo, pero no se usa. No hay variable nueva, así que `SAVE_FORMAT_VERSION` sigue en 2.
- Cuando lleguen los fragmentos de vida, su parte se suma en ese mismo cálculo (`apply_upgrades_to_player`), no leyendo la vida guardada.

## 3. Pruebas

- Escena temporal sin ventana, con el Player de `prisn.tscn` y 30 monedas:
  - empieza con 4 corazones, nivel 0/1, precio 10;
  - la primera compra funciona: 5 corazones, 5 de vida, quedan 20 monedas;
  - la segunda se rechaza (`at_max`), sin gastar monedas;
  - un estado viejo (mejora en nivel 2, `max_health` y vida en 6) queda en nivel 1, 5 corazones y 5 de vida.
- En la zona de pruebas, con ventana: Modo dev (º), "+monedas", y en el menú de pausa la fila "Vida máxima" de las mejoras.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1` (el aviso de SpawnPoint de `mundo_1` ya salía antes).

# P32 - Modo dev para probar el juego

- Nuevo autoload `DevMode` (`scripts/core/dev_mode.gd`, `UnderkingdomDevMode`), registrado en `project.godot` después de `PauseMenu`. Es un `CanvasLayer` (capa 120) que arma su panel por código; no tiene escena.
- Solo funciona en builds de depuración (`OS.is_debug_build()`: el editor y las exportaciones debug). En una exportación release queda apagado y el juego se comporta normal.
- Los ajustes duran la sesión: no se guardan en disco y "Nueva partida" no los cambia.

## Controles

- **º** (la tecla debajo de Esc; ` en teclado inglés, se lee por posición física): abre o cierra el panel, arriba a la derecha, debajo del inventario.
- Con el panel abierto, **1-8** o un clic activan cada opción. Los botones no toman foco, así que Espacio sigue siendo saltar.
- El juego no se pausa con el panel abierto. También funciona dentro del menú de pausa.
- Con el panel cerrado y alguna opción activa, se ve un aviso `DEV: ...` con lo que está encendido.

| Tecla | Opción | Qué hace |
|---|---|---|
| 1 | Vida infinita | El Player recibe el golpe (animación, empuje, invulnerabilidad) pero no pierde vida. Al caer a un vacío o a una kill zone vuelve al último punto de reaparición sin recargar el mapa. Al activarla cura al máximo. |
| 2 | Pociones infinitas | Tomar poción (C) cura sin gastar pociones, aunque haya 0. Con la vida llena no se toma, como siempre. |
| 3 | Monedas infinitas | Comprar mejoras en el menú de pausa no gasta monedas, aunque haya 0. |
| 4 | Ultimate sin enfriamiento | La Ultimate se puede repetir en cuanto termina. Al activarla, la barra se llena. |
| 5 | Curar al máximo | Una vez. |
| 6 | +100 monedas | Una vez. |
| 7 | +5 pociones | Una vez. |
| 8 | Dar llaves de jefe | Da las llaves de `BOSS_KEY_IDS` (`cementerio_capitan`, `minas_caballero`). |

## Cambios en otros scripts

- `player.gd`: `take_damage` no resta vida con vida infinita; `die` llama a `respawn_now` en su lugar; `request_ultimate` deja el enfriamiento en 0; `drink_potion` no gasta poción.
- `game_manager.gd`: nuevo `can_spend_coins(amount)`; `try_spend_coins` devuelve true sin restar con monedas infinitas.
- `pause_menu_overlay.gd`: el botón de mejora usa `GameManager.can_spend_coins` para saber si se puede comprar.

## Notas

- Al añadir la llave de un mundo nuevo, sumar su `key_id` a `BOSS_KEY_IDS` en `dev_mode.gd`.
- Las teclas de prueba del Player (H, J, K, R con `enable_debug_keys`) siguen igual. Con vida infinita, K ya no mata: devuelve al punto de reaparición.

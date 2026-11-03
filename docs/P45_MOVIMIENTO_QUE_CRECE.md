# P45 - Movimiento que crece: la Agilidad

- Tras jugarlo: desnudo el protagonista se movía mejor. Con la espada oxidada y el atuendo, y con el fire knight de la espada grande, corría demasiado y saltaba demasiado alto.
- Ahora el movimiento con espada se parece más al de sin espada. El de antes se recupera con una habilidad nueva, **Agilidad** (`agility`).

## 1. Valores

En `player.gd`, categoría "Movimiento". Valen para `prisn.tscn` y `player.tscn`, que no los sobrescriben.

| Estado | Velocidad | Salto | Altura |
|---|---|---|---|
| Sin espada (`unarmed_*`, P42) | 130 | -380 | unos 50 px, 3 piezas |
| Con espada (`move_speed`, `jump_velocity`) | 170 | -470 | unos 74 px, 4,6 piezas |
| Con espada y Agilidad (`agility_move_speed`, `agility_jump_velocity`) | 230 | -560 | unos 104 px, 6,5 piezas (los de antes) |

- `get_move_speed()` y `get_jump_velocity()` eligen el valor. Los usan el movimiento normal y la pestaña de estadísticas del menú de pausa.
- La Agilidad solo cuenta con espada.
- Gravedad, aceleración y frenado no cambian.

## 2. Por qué crece y no se baja en todo el juego

Se simularon los saltos sobre los PNG con la física del Player. La simulación es aproximada e ignora los techos.

- Con 170 y -470 se llega a todo en el calabozo, el castillo, el cementerio, la mazmorra y las profundidades.
- Se pierden objetos opcionales, ninguna salida:
  - en las minas, la poción de (29, 6);
  - en la ruina, el cofre de (33, 9) y las monedas de (39-41, 6). Piden el salto y la velocidad de antes;
  - en `tiles_jefe`, 15 objetos, entre ellos el cofre de (95, 15).
- Esas zonas se van a rediseñar. Mientras tanto la Agilidad devuelve el movimiento de antes.

## 3. Pendiente

- **Dónde se consigue.** Todavía no tiene fuente. En una "Nueva partida" no se tiene, así que en las minas, la ruina y `tiles_jefe` los objetos de arriba no se alcanzan. Debería darse antes de las minas: una reliquia o el `ability_reward` de un jefe.
- **Probar con F6:** al abrir un mapa directo el Player tiene todas las habilidades, también la Agilidad, y se mueve como antes. Para notar el cambio hay que entrar desde "Nueva partida".

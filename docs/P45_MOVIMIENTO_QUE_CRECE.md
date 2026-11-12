# P45 - Movimiento que crece: la Agilidad

- Tras jugarlo: desnudo el protagonista se movía mejor. Con la espada oxidada y el atuendo, y con el fire knight de la espada grande, corría demasiado y saltaba demasiado alto.
- Ahora el movimiento con espada se parece más al de sin espada. El de antes se recupera con una habilidad nueva, **Agilidad** (`agility`).

## 1. Valores

En `player.gd`, categoría "Movimiento". Valen para `prisn.tscn` y `player.tscn`, que no los sobrescriben.

| Estado | Velocidad | Salto | Altura |
|---|---|---|---|
| Sin espada (`unarmed_*`, P42) | 130 | -380 | unos 50 px, 3 piezas |
| Con espada (`move_speed`, `jump_velocity`) | 170 | -440 | 68 px, 4,3 piezas (hasta el 2026-11-10, -470: 78 px, 4,85) |
| Con espada y Agilidad (`agility_move_speed`, `agility_jump_velocity`) | 230 | -540 | 102 px, 6,4 piezas (hasta el 2026-11-10, -560: 109 px, 6,8) |

Las alturas con espada están medidas en el juego (sección 4). Las de antes de esa sección salían de la fórmula v²/2g, que da unos píxeles menos que la física real a 60 fotogramas por segundo.

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

## 4. Segundo ajuste (2026-11-10): el salto al mínimo que permiten los ASCII

- Con la espada y el atuendo, el salto se seguía sintiendo demasiado alto. Se bajó al mínimo que permiten los ASCII de la Fase 1, con un pequeño margen. La velocidad, la gravedad y el salto sin espada no cambian.
- **Medido en el juego**, con una escena temporal que hacía saltar a `player.tscn` sobre un suelo y anotaba cuánto subía, ya borrada:

  | Velocidad | Sube |
  |---|---|
  | -430 | 65,3 px |
  | -440 | 68,3 px |
  | -450 | 71,3 px |
  | -470 | 77,6 px |
  | -530 | 98,1 px |
  | -540 | 101,8 px |
  | -550 | 105,4 px |
  | -560 | 109,3 px |

- **Con espada, -440 (68 px):**
  - el camino obligatorio del infierno y algunos tramos de la ruina y las profundidades se comprobaron con saltos de 4 piezas (64 px): el refugio del Abrigo y la vuelta del coliseo a `[S7]`;
  - las demás zonas, con saltos de 3;
  - -440 deja 4 px de margen; -430 solo 1. No bajar de -440.
- **Con la Agilidad, -540 (102 px):** los secretos de la Agilidad (minas, profundidades) se comprobaron con saltos de 6 piezas (96 px). Deja 6 px de margen; -530, 2. No bajar de -540.
- **En horizontal**, el tiempo en el aire baja un poco:
  - con espada, unas 6,2 piezas de salto con carrerilla (antes 6,7);
  - con la Agilidad, unas 10,4 (antes 10,7).

  Los huecos obligatorios son de 3 como mucho.
- **Pendiente:** confirmar jugando, al generar cada zona en la Fase 3, que los escalones de 4 de la ruina, las profundidades y el infierno y los de 6 de la Agilidad se suben bien.

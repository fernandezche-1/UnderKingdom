# P33 - Enemigos por profundidad

- El juego se recorre bajando. Los enemigos lo acompañan:
  - arriba, personas y bichos comunes;
  - en medio, criaturas;
  - al fondo, demonios.
- Antes había cualquier enemigo en cualquier mapa: diablillos y minotauros en las minas, un Vanguardia en el infierno.
- Ahora cada mundo usa solo los enemigos de su profundidad. Los cambios se hicieron en los PNG y se regeneraron las escenas.

## Tabla

| Profundidad | Mundo | Enemigos (letra) | Faltan (sin arte todavía) |
|---|---|---|---|
| 1 | `tiles_cementerio` (superficie) | Vanguardia `v` (el viejito), Aprendis `a` | murciélagos |
| 2 | `tiles_mineria` (bajo tierra) | kolbo `k`, kolbo2 `j`, kolbo3 `q` | murciélagos |
| 3 | `tiles_mazmorra` | mino `M`, kolbo3 `q` | esqueletos |
| 4 | `tiles_ruina` | mino `M`, kolbo3 `q` | esqueletos |
| 5 | `tiles_profundidades` (abismo) | diablillo `d` | |
| 6 | `tiles_jefe` (infierno) | diablillo `d` | demonslime como enemigo común (hoy sin letra) |

- `tiles_casa` está fuera de la ruta y no se tocó (4 diablillos).
- Los jefes no entran en la tabla: van en la escena `_combate` de cada mundo.

## Cambios en los mapas

Coordenadas en piezas (x, fila) del PNG.

- **Minas** (de 13 a 12 enemigos):
  - quitados los 2 diablillos que volaban sobre la veta ardiente, en (80, 79) y (58, 80);
  - kolbo2 nuevo en el suelo de la veta, en (45, 85);
  - los 2 mino, en (78, 43) y (64, 85), pasan a kolbo3.
- **Jefe:** el Vanguardia (96, 32) y el mino (76, 40) pasan a diablillo.
- **Mazmorra:** los 4 kolbo2 pasan a kolbo3, en (39, 12), (48, 12), (73, 48) y (31, 59).
- **Ruina:** el kolbo (8, 12) y el kolbo2 (24, 29) pasan a kolbo3.
- **Cementerio y profundidades:** ya cumplían la tabla y no cambiaron.

## Comprobado sin ventana

- Antes de cambiar los PNG, cada mapa se regeneró aparte y salió idéntico a su escena: no había cambios hechos a mano que perder.
- Después de regenerar, solo cambian los nodos de `Enemigos`.
- Tras 3 segundos de física, cada enemigo nuevo sigue sobre el suelo (`is_on_floor`) y patrulla.
- El menú, el cementerio y las minas arrancan sin errores.

## Notas

- **Plataformas verdes:** los enemigos no las pisan. Son de la capa 2, y los enemigos solo chocan con la capa 1 (`collision_mask = 1`), así que se caen a través. Los enemigos de suelo van siempre sobre bloque sólido.
- **Lava:** no daña a los enemigos (la kill zone solo mira al grupo `player`). Además, `avoid_ledges` no ve un pozo de lava de una pieza como borde. Conviene no poner enemigos de suelo junto a esos pozos.
- **Huecos para murciélagos:** los de los diablillos quitados de las minas, en el aire de la veta ardiente, son buen sitio cuando haya murciélagos.
- **Mundo nuevo:** al montarlo, elegir sus enemigos de esta tabla. Para un enemigo nuevo:
  - crear su escena con `enemy_base.gd`;
  - darle una letra en `COLORS` / `ENEMIES` del constructor;
  - sumarlo a esta tabla.

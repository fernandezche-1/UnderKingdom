# P33 - Enemigos por profundidad

- El juego se recorre bajando. Los enemigos lo acompañan:
  - arriba, personas y bichos comunes;
  - en medio, criaturas;
  - al fondo, demonios.
- Antes había cualquier enemigo en cualquier mapa: diablillos y minotauros en las minas, un Vanguardia en el infierno.
- Ahora cada mundo usa solo los enemigos de su profundidad. Los cambios se hicieron en los PNG y se regeneraron las escenas.
- **Sin repetir (2026-11-12, ficha de las minas en P73):** un enemigo no vuelve a salir en otra zona. Los que ya aparecieron más arriba en la ruta se quitan al vestir cada zona, y su sitio lo toma un enemigo nuevo de esa profundidad. Excepción: el infierno (P46). Pendiente: el cementerio repite la Vanguardia y el murciélago del castillo, y la ruina comparte la lista de la mazmorra (resuelto en su ficha, P73, 2026-11-16: salen los 23 y entran el lobo y el ave; el esqueleto helado se quitó al hacer las piezas, sin arte que sirva). La mazmorra ya tiene su ficha (P73, 2026-11-16): sin kolbo3 y con el esqueleto `e` de arte nuevo, que antes era el mismo que el `u` del cementerio.

## Tabla

| Profundidad | Mundo | Enemigos (letra) | Faltan (sin arte todavía) |
|---|---|---|---|
| 0 | `tiles_calabozo` (antes del castillo) | rata, murciélago grande, slime y esqueleto carcelero (en el nivel de hoy, a mano en la escena `_combate`, ver `P42_CALABOZO_INICIAL.md`; en el calabozo rehecho, con letra: `R` rata, `L` slime y `B` murciélago grande; el carcelero sigue a mano) | |
| 0 | `tiles_castillo` (el castillo, sobre el cementerio) | Guardia `G` (caballero con escudo, ver `P40_CASTILLO_CON_TILES.md`), Vanguardia `v`, murciélago `m` | |
| 1 | `tiles_cementerio` (superficie) | Vanguardia `v` (el viejito), murciélago `m` (cripta y abismo), esqueleto de tumba `u`, cuervo `o` (exterior; `escenas/enemigos/cuervo.tscn`) y ánima `N` (cripta honda; `escenas/enemigos/anima.tscn`), de la ficha del cementerio (P73). Al vestir la zona (2026-11-12) se colocaron 3 cuervos en el exterior y 3 ánimas en lugar de 3 murciélagos (P73, "Vestida") | |
| 2 | `tiles_mineria` (bajo tierra) | kolbo `k`, kolbo2 `j`, kolbo3 `q` (0.5 de daño desde el 2026-11-15), murciélago `m`. Ficha de las minas (P73, 2026-11-12): salen los murciélagos (ya aparecieron arriba) y entran ojo volador `p` (`escenas/enemigos/ojo_volador.tscn`), sapo de la cueva `s` (`escenas/enemigos/sapo.tscn`) y Mimic `i` (`escenas/enemigos/mimic.tscn`), hechos en el paso de piezas (2026-11-15). Al vestir la zona (2026-11-15) se quitaron los 10 murciélagos y se colocaron 6 ojos en sus sitios del aire, 4 sapos en el suelo bajo los otros 4 y 2 Mimics en callejones sin salida (P73, "Vestida") | |
| 3 | `tiles_mazmorra` | Aprendis `a` (esqueleto de fuego), mino `M`, kolbo3 `q`, esqueleto `e`. Ficha de la mazmorra (P73, 2026-11-16): salen los 7 kolbo3 (ya salieron en las minas); el esqueleto `e`, que usaba la misma hoja que el `u` del cementerio, pasa al Skeleton Sprite Pack de Jesse M con `enemy_base.gd`; entran el ogro `W` (criatura; `escenas/enemigos/ogro.tscn`) y la calavera de fuego `X` (esqueleto; `escenas/enemigos/calavera_fuego.tscn`), hechos en el paso de piezas (2026-11-16) con el arte nuevo del esqueleto `e`. Al vestir la zona (2026-11-16) se quitaron los 7 kolbo3 y se colocaron 4 ogros en sus sitios de suelo y 3 calaveras de fuego en el aire, por los otros 3 (P73, "Vestida") | |
| 4 | `tiles_ruina` | Aprendis `a` (esqueleto de fuego), mino `M`, kolbo3 `q`, esqueleto `e`. Ficha de la ruina (P73, 2026-11-16): salen los 23, porque los cuatro ya salieron en la mazmorra y las minas; entran el lobo de la escarcha `J` (criatura, WereWolf de la Legacy; `escenas/enemigos/lobo_escarcha.tscn`) y el ave de las nieves `Z` (criatura, flying-bird blanco de la Legacy; `escenas/enemigos/ave_nieves.tscn`), hechos en el paso de piezas (2026-11-16). El esqueleto helado `Y` de la ficha se quitó en ese paso (se descartó el arte con IA y no queda arte de esqueleto que sirva); sus 8 sitios se reparten: 4 lobos en el suelo de las galerías y 4 aves en el aire. Quedan 13 lobos (los 9 sitios de suelo de los kolbo3 y los mino y 4 de los esqueletos) y 10 aves (los 6 del aire de los Aprendis y 4 sobre los otros sitios de los esqueletos). Al vestir la zona (2026-11-16) se quitaron los 23 y se colocaron así: 13 lobos en el suelo y 10 aves en el aire, las 4 de los esqueletos dos o tres filas sobre su sitio (P73, "Vestida") | |
| 5 | `tiles_profundidades` (abismo) | diablillo `d`. Ficha de las profundidades (P73, 2026-11-17): se quedan 13 diablillos en el aire y entran la bestia infernal `I` (demonio, Hell-Beast de la Legacy; escupe fuego desde el suelo) en 6 sitios de suelo y la pesadilla `Y` (demonio, Nightmare de la Legacy; embiste) en 3 del puente de huesos. Hechos en el paso de piezas (2026-11-17): `escenas/enemigos/bestia_infernal.tscn` (`ranged_demon.gd`, 3 de vida, bola de 0.5) y `escenas/enemigos/pesadilla.tscn` (`lunge_enemy.gd`, 4 de vida, 0.75; se esquiva rodando). Colocados al vestir (2026-11-17): 13 diablillos, 6 bestias y 3 pesadillas | |
| 6 | `tiles_infierno` (en v1, `tiles_jefe`) | diablillo `d`. En el infierno rehecho (la prueba final, P46): los más duros de todas las profundidades, excepción a esta tabla. Ficha del infierno (P73, 2026-11-17): calavera de fuego `X`, ánima `N`, ojo volador `p`, ave de las nieves `Z`, ogro `W`, lobo de la escarcha `J` y Mimic `i` entran en los sitios de los murciélagos, los kolbo, los minos del pasillo del filo y 7 diablillos; nuevo, solo del infierno, el alma condenada `z` (`enemy-ghost` de la Legacy, `lunge_enemy.gd`), en la sima de las ánimas; hecha en el paso de piezas (2026-11-17): `escenas/enemigos/alma_condenada.tscn` (3 de vida, 0.5 de daño y 0.25 de contacto); vestido el 2026-11-17, con las oleadas del coliseo por profundidad (la última, pesadillas `Y` y bestias infernales `I`) y ogros en el salón. El demonslime como enemigo común se descartó: es el arte del Demon Slime | |

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
- **Profundidades:** ya cumplía la tabla y no cambió.

### Segunda tanda: el Aprendis baja

- El Aprendis es un mago pálido con calavera que lanza fuego y se lee como un esqueleto, así que sale del cementerio y pasa a la profundidad de los esqueletos.
- Flota (`use_gravity = false`), así que puede ir en el aire.
- **Cementerio** (13 Vanguardia, 0 Aprendis):
  - (52, 13) y (52, 29) pasan a Vanguardia en el mismo sitio;
  - los dos que flotaban, en (58, 45) y (80, 73), se quitan;
  - en su lugar, Vanguardias sobre el suelo en (58, 47) y (75, 75); el de (75, 75) queda lejos del pozo de lava de x 83-86.
- **Mazmorra:** los kolbo3 de (48, 12) y (73, 48) pasan a Aprendis. Quedan 2 Aprendis, 2 kolbo3 y 1 mino.
- **Ruina:** los kolbo3 de (8, 12) y (24, 29) pasan a Aprendis. Quedan 2 Aprendis, 1 kolbo3 y 1 mino.
- Comprobado igual que la primera tanda:
  - el cementerio, regenerado con su PNG anterior, salía idéntico a su escena;
  - tras regenerar solo cambian los nodos de `Enemigos`;
  - tras 3 segundos de física los enemigos nuevos siguen en su sitio;
  - en el cementerio ya no queda ningún Aprendis.

## Comprobado sin ventana

- Antes de cambiar los PNG, cada mapa se regeneró aparte y salió idéntico a su escena: no había cambios hechos a mano que perder.
- Después de regenerar, solo cambian los nodos de `Enemigos`.
- Tras 3 segundos de física, cada enemigo nuevo sigue sobre el suelo (`is_on_floor`) y patrulla.
- El menú, el cementerio y las minas arrancan sin errores.

## Notas

- **Plataformas verdes:** los enemigos no las pisan. Son de la capa 2, y los enemigos solo chocan con la capa 1 (`collision_mask = 1`), así que se caen a través. Los enemigos de suelo van siempre sobre bloque sólido.
- **Lava:** no daña a los enemigos (la kill zone solo mira al grupo `player`). Además, `avoid_ledges` no ve un pozo de lava de una pieza como borde. Conviene no poner enemigos de suelo junto a esos pozos.
- **Huecos para murciélagos:** los de los diablillos quitados de las minas, en el aire de la veta ardiente, ya tienen murciélago (ver `P34_ENEMIGOS_DE_LOS_PAQUETES.md`).
- **Mundo nuevo:** al montarlo, elegir sus enemigos de esta tabla. Para un enemigo nuevo:
  - crear su escena con `enemy_base.gd`;
  - darle una letra en `COLORS` / `ENEMIES` del constructor;
  - sumarlo a esta tabla.

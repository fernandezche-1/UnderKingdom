# P40 - El castillo: primer mundo con tiles

- La cinemática de "Nueva partida" pasa en la prisión del castillo de la Reina, pero su salida llevaba directo al cementerio. Ahora hay un mundo de castillo entre los dos, hecho con el esquema de los mundos con tiles:
  - PNG + `.txt` → constructor → `tiles_castillo.tscn`;
  - `tiles_castillo_combate.tscn` hereda de ella y añade la sala del jefe, la llave, la puerta con llave y la reliquia.
- **Ruta:** prisión → `tiles_castillo_combate` → `tiles_cementerio_combate` → minas → …
  - El castillo no tiene salida hacia atrás: es la huida.
  - Del cementerio tampoco se vuelve.
- Los mapas hechos a mano del prólogo (`escape_calabozo`, `interior_castillo`, `castillo_oscuro`) no se tocaron y siguen fuera de la ruta.
- **Historia:** la Reina ató el alma del rey muerto a su cadáver para que guarde el castillo. El guerrero, que lo sirvió, lo enfrenta en el salón del trono.

## 1. Tileset `castillo`

- **Atlas:** `assets_prueba/raou_castillo/tileset_castillo.png`, 512x384.
  - **Filas 0-15:** copia sin cambios del de mazmorra, por la antorcha, la escalera, la fogata (checkpoint), el barril, la caja y las rampas.
  - **Filas 16-19:** piezas nuevas. Detalle pieza por pieza en `ORIGEN.txt`.
- **Bloque `castillo`:**
  - es el muro de ladrillo morado de Raou (`prueba/dungeon_sidescroller-Raou/Tilesetv3.png`), con losas claras arriba e interior negro;
  - todas sus piezas son macizas;
  - la fila de plataformas y tiras de una pieza repite la de arriba, como en mazmorra.
- **Rampas:** las de Raou no tienen 3 esquinas opacas y el constructor no les daría colisión, así que el bloque usa las de `violeta`. El mapa no tiene rampas.
- **Fondo `castillo`:** una columna de ladrillo oscuro de Raou que se repite de lado sin costura.
- **Decorados que cambian respecto de mazmorra:**

  | Letra | Pieza | Tamaño |
  |---|---|---|
  | `T` | armadura | 2x2 |
  | `h` | estandarte (cuelga del techo) | 1x2 |
  | `g` | cadena (cuelga del techo) | 1x2 |
  | `r` | ventana en arco | 2x2 |
  | `C` | puerta en arco | 2x3 |
  | `E` | estantería | 2x2 |
  | `f` | rejas de celda | 2x2 |

  - El estandarte y la cadena salen del `dark_castle_tileset.png` de Armando; lo demás, de Raou.
  - Los decorados de los dos paquetes no estaban alineados a 16 px: se recortaron por su borde y se centraron en su hueco.
- **Licencias:**
  - Raou permite el uso comercial y modificarlo, pero no redistribuir el tileset (comentario del autor en https://raou.itch.io/dark-dun).
  - El PNG ya estaba en el repo público por el prólogo.
  - Antes de publicar el juego hay que pedirle la confirmación por escrito.

## 2. Enemigos

- **Guardia** (`escenas/enemigos/guardia.tscn`, letra `G`, color `b0b0d0`):
  - caballero con escudo, arte de `otra vez/Knight 2D Pixel Art/` (uso libre dentro de un juego);
  - `enemy_base.gd`, cuadros de 96x84;
  - 5 de vida, 0.5 de daño;
  - se cubre con el escudo (`defense_enabled`, 30 %).
- **En el castillo:** 6 Guardias, 5 Vanguardias y 5 murciélagos. Es la profundidad 0 de la tabla de `P33_ENEMIGOS_POR_PROFUNDIDAD.md`: personas y bichos comunes.

## 3. Jefe: el Rey Caído

- **Escena:** `escenas/jefes/rey_caido.tscn`, con `simple_boss.gd` y Medieval King Pack 2 (CC0), en cuadros de 160x111 a escala 1. Mide unos 54 px de alto, contra los 40 de la colisión del Player.
- **Vida:** 10 (primer jefe; el Capitán tiene 12).
- **Ataques:**

  | Ataque | Daño | Fase | Qué hace |
  |---|---|---|---|
  | `attack` | 0.5 | 1 | estocada que llega unos 70 px por delante |
  | `attack2` | 0.75 | 1 | giro que barre a los dos lados |
  | `attack3` | 1 | 2 | tajo alto, más una onda en el suelo de 0.5 |

- **Fase 2,** por debajo del 50 %: ataca y persigue más rápido.

## 4. Trazado

- **Mapa:** `mapas_texto/tiles_castillo.png`, de 100x80 piezas (1600x1280 px).
  - Fondo y bloques `castillo`, sin parallax porque es un interior.
  - Se recorre bajando.
- **Zonas** (coordenadas en piezas, x y fila):

  | Zona | Dónde | Qué hay |
  |---|---|---|
  | Galería de las celdas | filas 3-13 | Llegada `P` en (3, 13), checkpoint, celdas con rejas, estandartes, tarima con monedas. Un muro colgante en x 60-62 la separa de la armería (armaduras, cofre). |
  | Gran salón | filas 18-29 | Se baja por la escalera de la columna 57. Inspirado en la imagen de referencia: estrado con cofre y escalones, estructura central con cofre, foso de pinchos en x 70-73, plataformas y tarima con poción. |
  | Biblioteca | filas 40-47 | Escalera de la columna 64. Estanterías, plataforma con monedas y la **reliquia de rodar** en el nicho tras el pilar de la columna 73: (1208, 756) px, como estaba en el cementerio. |
  | Antecámara | filas 52-56 | Escalera de la columna 45. Checkpoint en (41, 56). La puerta de la sala del trono está en la columna 37. |
  | Sala del trono | x 6-36, filas 46-56 | Las mismas coordenadas que la sala del cementerio. Plataformas en la fila 52 y la escalera de la columna 25, que sube por un pozo hasta el gran salón y que tapa la trampilla de la fila 45. |
  | Criptas | filas 62-76 | Escalera de la columna 67. Plataformas, foso de pinchos en x 80-83, checkpoint en (92, 76), **puerta con llave** en la columna 95 (filas 73-76) y la salida `>` en el borde derecho. |

## 5. Escena de combate

- **`SalaJefe`:** `boss_arena.gd`, con `encounter_id` y `key_id` = `castillo_rey` y `boss_message` "EL REY CAÍDO".
  - Copia de la del cementerio: el `Activador`, la puerta de entrada, la trampilla y `PuntoLlave` van en los mismos píxeles.
  - Los puntos del jefe bajan a y=862 para que el Rey aparezca de pie.
  - Las barreras usan las piezas de columna y losa del bloque `castillo`.
  - Sin `ability_reward`: el Rey solo da la llave.
- **`PuertaLlave`:** en (1528, 1200), con el mensaje "NECESITAS LA LLAVE DEL REY".
- **`Ambientacion`:** tono morado, `ambient_color` (0.44, 0.38, 0.56) y viñeta de 0.6.
- **`Reliquias/ReliquiaRodar`:** se quitó de `tiles_cementerio_combate.tscn`. El cementerio sigue dando la Ráfaga con el Capitán.

## 6. Código

- **`GameManager`:**
  - `CASTLE_SCENE_PATH`;
  - `is_autosave_region(path)`: el castillo y el cementerio, en su escena `_combate` o en la base. La usan `autosave_region_entry` y `map_transition.gd`; antes solo autoguardaba al entrar al cementerio;
  - `region_name_for_scene` da "Castillo".
- **Llave `castillo_rey`:** nombre "Rey Caído" en la pestaña de llaves (`pause_menu_overlay.gd`) y en `BOSS_KEY_IDS` del modo desarrollador.
- No cambia el formato del guardado.

## 7. Verificado sin ventana

- **Arranque sin errores:** el menú, la prisión, el castillo, el cementerio y `mundo_1`. Las advertencias de la prisión (sin `MapBounds`) y de `mundo_1` (spawn sin suelo seguro) ya estaban.
- **Escena temporal:**
  - con "Nueva partida", el Player llega de pie a `SpawnInicio`;
  - la reliquia da `roll`;
  - la puerta con llave bloquea;
  - al entrar en la sala se cierra la puerta y aparece el Rey, de pie;
  - al vencerlo se completa el encuentro, se abren la sala y la trampilla, y cae la llave;
  - con la llave se abre la puerta y la salida carga el cementerio con el Player de pie en (104, 417);
  - la salida de la prisión carga el castillo.
- **Simulación de saltos sobre el PNG** (altura de salto ≈ 6,5 piezas):
  - sin llave se llega a todo menos a la salida;
  - tras el jefe, desde la sala del trono, se llega a todo, incluida la galería por la trampilla.

## 8. Pendiente

- **Jugarlo con ventana:**
  - dureza de los Guardias con escudo para un Player que solo tiene el primer tajo;
  - escala y ritmo del Rey;
  - que se vean las cadenas y los estandartes con la ambientación.
- Confirmar con Armando el uso del tileset de Raou y del `dark_castle_tileset.png`.
- Diálogo o cinemática del encuentro con el Rey, como la del Capitán.

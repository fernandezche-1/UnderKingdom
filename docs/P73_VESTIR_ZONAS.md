# P73 - Vestir las zonas: arte y enemigos nuevos en la Fase 3

- Método para meter en cada zona de la Fase 3 de `TASK.md` arte nuevo (tileset, decorados, fondo, luces) y enemigos nuevos que todavía no están en el repo.
- Decidido el 2026-11-10:
  - el arte sale de packs de terceros y de la IA;
  - en cada zona va primero la estructura y después el arte ("vestirla");
  - la lista de cada zona se arma entre los dos: Claude propone y el usuario aprueba.
- No cambia ninguna regla de P46. Un enemigo nuevo sigue la regla de profundidad (P33), y ningún reto obligatorio puede pedir lo que el jugador no tiene al llegar (P46, sección 10).

## 1. Por qué en dos pasadas

El constructor genera la escena base desde el `.txt` de la zona. La base incluye:
- el tileset (`tileset:` y `bloques:`);
- los decorados por letra;
- el fondo (`fondo:` / `parallax:`);
- los enemigos con letra (`ENEMIES` en `herramientas/constructor_mapas/construir_mapa.gd`).

Jefe, puertas, objetos y luces van en la `_combate`, que hereda de la base y no se pierde al regenerar.

Por eso una zona se puede generar y jugar con el arte de hoy y vestirla después. Basta con cambiar la cabecera y las letras de su `.txt` y regenerar la base.

## 2. Los cuatro pasos de cada zona

Cada paso es una sesión con su commit, sin push.

### A. Estructura
- Es el paso de la Fase 3 de `TASK.md`: generar la zona desde su ASCII con el tileset y los enemigos de hoy, montar su `_combate` y jugarla.
- Si la ficha ya pide un enemigo que todavía no existe, su sitio se reserva con una letra de la misma profundidad (tabla de P33) y se apunta en la ficha como provisional.

### B. Ficha de la zona
Claude la propone y el usuario la aprueba. Va en la sección 3 de este documento y tiene estos apartados:
- **Ambientación:**
  - de qué tileset y fondo parte y cuál se propone;
  - los decorados nuevos y qué letra reutiliza cada uno;
  - las luces (`DECOR_LIGHTS` de `scripts/environment/map_ambience.gd`).
- **Enemigos:**
  - los que se quedan y los nuevos;
  - de cada enemigo nuevo:
    - profundidad;
    - script base (`enemy_base.gd`, `lunge_enemy.gd`, `rising_enemy.gd` o `ranged_demon.gd`);
    - vida, daño (múltiplos de 0.25) y letra;
    - dónde va en el ASCII.
- **Origen del arte:**
  - el pack de `assets/terceros/` o el nuevo por bajar, con su licencia;
  - o la receta para la IA.
- **Reto obligatorio:** se revisa contra la fila de la zona en "Desbloqueos por zona" (P46, sección 10).

Arte que ya está en el repo y no se usa: el tileset `mainlev_build` y los props de `pixelfantasy_caves`, el resto de `monster_creatures_2` (Mimic), lo que queda de Gothicvania y de `super_grotto`, y lo apartado en `archivo/sin_uso/assets/`.

### C. Piezas nuevas en la zona de pruebas
Cada pieza se prueba en la zona de pruebas antes de ir a un mapa de la ruta.

**Tileset nuevo** (`mapas_texto/LEYENDA.md`, sección 8):
1. Traer el pack a `assets/terceros/<pack>/` con su `ORIGEN.txt`. Lo que no se use va a `archivo/sin_uso/assets/`.
2. Crear `herramientas/constructor_mapas/tilesets/<tema>.gd`:
   - copia el atlas de la mazmorra en las filas 0-15 y añade lo suyo debajo, como `castillo.gd` y `cementerio.gd`;
   - así las letras de decorado siguen valiendo y cada tileset las reinterpreta.
3. En los bloques, solo piezas macizas: la colisión se deduce de la opacidad de las esquinas de cada pieza.
4. Si alguna pieza da luz, añadir sus coordenadas a `DECOR_LIGHTS`.
5. Probarlo en el piso D de la galería (`herramientas/zona_pruebas/galeria.py`), el de los tilesets:
   - un cuarto con una muestra del tileset que `galeria.py` escribe en `mapas_texto/zona_pruebas_muestra_<tileset>.txt` y el constructor genera con `muestra: si` (solo las capas y las escaleras);
   - la zona de pruebas no tiene MapAmbience, así que las luces se comprueban en la prueba sin ventana;
   - la prueba sin ventana comprueba además que todos los bloques son macizos, que las plataformas son de una vía y que el Player se apoya en ellas.

**Enemigo nuevo** (P34, secciones 1 y 2):
1. Hacer una hoja con una fila por animación, sin cambiar el arte del pack.
2. Crear `escenas/enemigos/<nombre>.tscn`:
   - con el script base que pida la ficha y `collision_layer = 5`;
   - con un script propio solo si su comportamiento no cabe en los métodos que se pueden sobrescribir de `enemy_base.gd`.
3. Darle letra y color en `COLORS` / `ENEMIES` del constructor:
   - regenerar la paleta (`-- --paleta`);
   - ponerlo en la tabla de LEYENDA (sección 5) y en la de P33.
4. Montar su sala en `galeria.py`, con un cartel que diga a qué zona va.
5. Probarlo sin ventana con una escena temporal, que se borra al acabar. Tiene que comprobar que:
   - tras 3 s de física sigue en su sitio;
   - recibe golpes;
   - hace daño en múltiplos de 0.25.

**Arte con IA para enemigos:**
- `herramientas/sprites/tira_ia_a_hoja.py` está pensado para el Player (864x384 por cuadro, escala 1/3).
- Primero se prueba con `--escala` y `--fila-pies`.
- Solo si no basta se le añade un modo para enemigos, sin cambiar lo que hace con el Player.

**Una pieza de C está hecha cuando:**
- funciona en la galería;
- pasó la prueba sin ventana;
- arrancan sin errores el juego y la zona de pruebas (y las zonas ya generadas si se tocó `enemy_base.gd`);
- su ficha y las tablas que la nombran están al día;
- hay un commit.

### D. Vestir la zona
1. En `mapas_texto/tiles_<zona>.txt`:
   - cambiar la cabecera (`tileset`, `bloques`, `fondo` / `parallax`);
   - cambiar las letras provisionales por las nuevas;
   - colocar los decorados.
2. Regenerar la base. La `_combate` solo se toca para las luces o para un enemigo sin letra.
3. Comparar las celdas sólidas de la base antes y después. Con piezas macizas no deberían cambiar, pero la zona ya se jugó, así que se comprueba (regla de las colisiones validadas de CLAUDE.md). Si cambian, preguntar antes de seguir.

**Una zona vestida está hecha cuando:**
- arranca sin errores con `godot --headless res://escenas/mapas/tiles_<zona>_combate.tscn --quit-after 120`;
- `python3 herramientas/macro_mapa/verificar_mundo.py` da 0 errores;
- se jugó a mano;
- se regeneró el Atlas con `herramientas/macro_mapa/datos_atlas.py` y se publicó de nuevo;
- su ficha está marcada como vestida en `TASK.md`;
- hay un commit.

## 3. Fichas por zona

El estado de partida sale de la cabecera de cada ASCII (`mapas_texto/macro/zonas/`) y de la tabla de P33. Lo demás está por armar.

### Calabozo
- Parte de: tileset `castillo`, `bloques: castillo`, `fondo: castillo`. Enemigos de P33, profundidad 0 (rata, slime, murciélago grande, carcelero). Luz ambiente de la `_combate`: (0.44, 0.38, 0.56).
- **Ficha aprobada el 2026-11-11.**
- **Por qué cambia:** el calabozo usaba el mismo tileset y el mismo fondo que el castillo, que está pegado a él en el mundo; al salir por `[L1]` se veía igual. Con su propio tileset se distingue del castillo y sigue a la cinemática de la prisión, que usa el mismo pack.

**Ambientación:**
- **Tileset nuevo `calabozo`** (`herramientas/constructor_mapas/tilesets/calabozo.gd`): el atlas de mazmorra en las filas 0-15, como `castillo.gd`, y piezas de `assets/terceros/dungeon_tile_set/Dungeon Tile Set.png` debajo (el pack de la prisión, `escenas/mapas/prologo_prision/`).
  - **Bloques `calabozo`:** el bloque de piedra gris azulada de 3x3 del pack, piezas (1,1)-(3,3), todas con las cuatro esquinas opacas. La columna y las tiras de una pieza se arman con mitades de piezas, como en `castillo`. El calabozo no tiene rampas.
  - **Fondo `calabozo`:** la pared oscura del pack, piezas (8,1)-(13,7), si tiene un trozo que se repita sin costura. Si no, se queda la pared `castillo`.
  - **Escalera:** la de madera del pack, (5,9)-(5,11).
  - **Plataformas `=`:** la viga de madera del pack, (1,9)-(3,9).
  - **Checkpoint:** la fogata de hoy.
- **Decorados** (mismas letras, reinterpretadas en `calabozo.gd`):

  | Letra | En `castillo` | En `calabozo` |
  |---|---|---|
  | `t` | antorcha de mazmorra | antorcha `spr_torch` de Raou, la de la prisión, si cabe en la pieza; si no, la de hoy |
  | `g` | cadena | cadenas del pack |
  | `h` | estandarte | jaula colgante del pack (cuelga del techo) |
  | `b`, `x` | barril y caja | barril y caja del pack |
  | `f`, `E`, `T` | rejas de celda, estantería, armadura | se quedan |
  | `r` | ventana en arco | rejilla redonda del desagüe. Nueva en el ASCII: junto al conducto (columna 58) y sobre el pozo de `:B:` |
  | `C` | puerta en arco | telarañas que cuelgan del techo. Nuevas en el ASCII: celdas, depósito y secreto |

  Los decorados nuevos siguen la regla de la cabecera del `.txt`: ninguno pisa una escalera, sus columnas vecinas ni las tres filas de encima, un spawn ni otro decorado.
- **Luces:** si la antorcha cambia de coordenadas en el atlas, se añaden a `DECOR_LIGHTS`. La luz ambiente se ajusta al vestir, solo en la `_combate`.

**Enemigos:**
- Se quedan los de profundidad 0: rata `R` (6), slime `L` (1), murciélago grande `B` (3) y el carcelero, a mano en la `_combate`.
- Sin enemigos nuevos: es el tutorial y la profundidad 0 ya está completa en P33.
- Nota de dificultad (no es de esta ficha): los tres hacen 0.75; sin espada, con `unarmed_extra_damage_taken`, es 1 corazón por golpe, y hasta 7 peleas a puño son obligatorias antes de la espada.

**Origen del arte:**
- Todo está ya en el repo: Dungeon Tile Set (bloques, fondo, escalera, viga y decorados), Raou (antorcha, rejas, estantería, armadura), atlas de mazmorra (CC0, RottingPixels) y `monster_creatures_2` (enemigos). Sin pack nuevo ni IA.
- **Licencias:** el Dungeon Tile Set y `monster_creatures_2` están por confirmar, y Raou solo tiene un permiso informal (`ORIGEN.txt` de cada pack y "Otros pendientes" de `TASK.md`). Aprobado usarlos igualmente; se resuelve antes de publicar.

**Reto obligatorio:** coincide con su fila de P46, sección 10. Llega con E0 (salto de unas 3 piezas) y sale con la llave del carcelero (`[L1]`). Ningún reto obligatorio pide E2 o más ni una mejora de la tienda, y vestir no cambia celdas sólidas (se comprueba en el paso D).

**Piezas (hechas el 2026-11-11).** Decisiones aprobadas al pasar la ficha a piezas:
- **Atlas** `assets/terceros/dungeon_tile_set/tileset_calabozo.png`, que arma `herramientas/constructor_mapas/atlas_calabozo.py`:
  - filas 0-19: el atlas del castillo, por `f`, `E`, `T`, la fogata y la pared `castillo`;
  - filas 20-23: las piezas del pack.
- **Bloques `calabozo`** en (0,20): el 3x3 del pack. La columna, las tiras de una pieza y la pieza suelta se arman con mitades y cuartos de sus piezas, todas macizas.
  - El interior (la pieza del centro) es casi negro, como el del castillo. Bajo un escalón de una pieza el suelo se ve oscuro, porque esa celda queda rodeada.
- **Viga:** el constructor dibujaba `=` con la fila de tiras y solo daba colisión a las piezas con 3 esquinas opacas. Se añadió la clave `plataformas` del tileset: la viga (4,20)-(6,20) lleva la colisión de una vía de siempre.
- **Escalera:** solo la pieza (5,9) del pack, en (7,20). El constructor pone la misma pieza en cada `H`, la (5,10) es un tramo roto sin peldaños y la (5,11) deja huecos al repetirse.
- **Fondo `calabozo`:** (6,6)-(12,7) del pack, 7x2, en (8,20). Es el trozo que menos se nota al repetirse; empieza dos columnas antes del rango de la ficha.
- **Decorados:** las mismas letras.
  - `t`: la antorcha de Raou, 4 cuadros de 7x16 a 8 fps, en (15,20). Va en `DECOR_LIGHTS` con la luz de la otra antorcha.
  - `g`: la cadena larga, 1x2.
  - `h`: la jaula, **2x2**, porque mide 19 px de ancho. En sus dos sitios de hoy, (43,5) y (89,5), la columna de la derecha está libre y tiene techo.
  - `C`: la telaraña, **4x1** (64x15).
  - `r`: la rejilla, 2x2, con su cuadro de pared.
  - `b` y `x`: barril y caja, 1x1.
  - Los que cuelgan van pegados arriba de su hueco.
- **Probado** en el piso D de la galería ("TILESET CALABOZO"):
  - captura con el juego abierto;
  - prueba sin ventana: 85 bloques macizos, 4 piezas de viga de una vía, el Player se apoya en la viga y en el suelo, y MapAmbience pone luz a las 2 antorchas.

**Vestida (2026-11-11):**
- `mapas_texto/tiles_calabozo.txt` pasa a `tileset: calabozo`, `bloques: calabozo` y `fondo: calabozo`, y se regeneró la base `escenas/mapas/tiles_calabozo.tscn`. La `_combate` no se tocó.
- Las letras de siempre toman el arte del pack. Las dos jaulas `h` caben a 2x2 en sus sitios de hoy.
- Decorados nuevos en el ASCII, fuera de las escaleras, sus columnas vecinas, sus tres filas de encima y los spawns:
  - rejillas `r`: junto al conducto, en (60, 10) (sala del aviso, a la derecha del hueco), y sobre el pozo de `:B:`, en (65, 42);
  - telarañas `C`, pegadas al techo: celda cerrada (2, 6), celda de inicio (9, 5), depósito (12, 22) y secreto (64, 22).
- **Colisiones:** las mismas antes y después (3377 piezas sólidas y 8 de una vía, con los mismos polígonos), volcadas de las capas de la base con una escena temporal.
- **Orden de dibujo:** al jugarla, la escalera de madera y los decorados se veían delante del Player. La capa `Decorado` del constructor (decorados, escaleras y fogatas de checkpoint) tenía `z_index` 1 desde el primer constructor; pasa a -1, detrás del Player, los enemigos y los objetos (z 0) y delante de la pared de fondo (-10). Se regeneraron el calabozo, la zona de pruebas y la muestra del tileset, con las mismas colisiones. Los niveles de `archivo/tiles_v1/` se quedan como están.
- **Luz ambiente:** se queda la de la `_combate`, (0.44, 0.38, 0.56). Con la pared nueva, más clara que la del castillo, se lee bien en las capturas.
- Arranca sin errores, `verificar_mundo.py` da 0 errores y el Atlas se publicó de nuevo (con los nombres de las letras del tileset `calabozo`). Jugada a mano y vestida el 2026-11-11.

### Castillo
- Parte de: tileset `castillo` (muro de Raou), `bloques: castillo`, `fondo: castillo` (pared lisa de 1x3). Enemigos de P33, profundidad 0: 7 Guardias `G`, 5 Vanguardias `v` y 11 murciélagos `m`; el Rey Caído. Luz ambiente de la `_combate`: (0.5, 0.46, 0.6).
- **Ficha aprobada el 2026-11-11.**
- **Por qué cambia:** con el calabozo en su propio tileset, el castillo ya se distingue de él. Le faltan:
  - salas que se lean como de un castillo habitado (armería, salón real);
  - que las 159 plataformas `=` se vean de una vía: hoy son la misma tira de ladrillo que los bloques;
  - preparar al jugador para el Mimic de más abajo.

**Ambientación** (sin tileset nuevo: cambian `castillo.gd` y su atlas `assets/terceros/raou_castillo/tileset_castillo.png`):
- **Bloques:** se quedan los `castillo`.
- **Plataformas `=`:** el tablón de madera de Raou, piezas (7,8)-(9,8) de `Tilesetv3.png`, con la clave `plataformas` del tileset (como la viga del calabozo). Mantiene la colisión de una vía de siempre.
- **Fondo `castillo`:** la pared con pilastras de Raou (filas 17-19 de `Tilesetv3.png`), con una pilastra cada pocas columnas, si se repite sin costura. Si no, se queda la pared lisa.
- **Cofres:** los 4 cofres `c` toman el aspecto del cofre del Mimic (`Idle_closed` cerrado, `idle_open` abierto), para que el jugador se acostumbre a ese cofre y el Mimic de más abajo lo sorprenda.
  - Escena nueva `escenas/objetos/cofre_madera.tscn`, con el mismo `chest_interactable.gd`.
  - El tileset la elige con una clave nueva, `cofre`; el constructor usa `cofre.tscn` si el tileset no la trae.
  - El calabozo conserva el cofre del pack de la prisión.
  - Mide 31x20 px (casi 2 piezas). En la capilla, el cofre de (58, 18) tapa la mitad de la antorcha de (59, 18): al vestir se mueve el decorado, sin tocar celdas sólidas.
- **Decorados:**

  | Letra | En `castillo` hoy | Propuesta |
  |---|---|---|
  | `h` | estandarte de `dark_castle_tileset.png` (v4 de Armando, origen sin anotar) | estandarte rojo de craftpix (`Other_objects.png`), 1x2 |
  | `t`, `T`, `E`, `f`, `g`, `r`, `C`, `b`, `x` | — | se quedan |
  | `A` (nueva) | — | armero con armas de craftpix (`supplies_objects.png`), 2x2. En la armería |
  | `D` (nueva) | — | trofeo de cráneo de dragón de craftpix (`Other_objects.png`), 2x2. Armería, gran salón y sala del trono |
  | `O` (nueva) | — | estante con provisiones de craftpix (`supplies_objects.png`), 2x2. Armería y sótano (bodegas) |
  | `Q` (nueva) | — | cuadro de Raou (filas 41-44 de `Tilesetv3.png`), 1x1 o 2x2 según la pieza. Gran salón y aposentos de la Reina |

  - Son las piezas de craftpix que la armería del castillo viejo (`archivo/tiles_v1/escenas/tiles_castillo.tscn`) pintaba a mano. Se toma el arte, no la sala: la armería nueva conserva su trazado.
  - Las letras nuevas van en `COLORS` del constructor, en la tabla de LEYENDA (sección 5) y en la paleta. En los tilesets que no las definen no dibujan nada.
  - Los decorados nuevos siguen la regla de la cabecera del `.txt`: ninguno pisa una escalera, sus columnas vecinas ni las tres filas de encima, un spawn ni otro decorado.
  - Los bustos de armadura de craftpix no entran: ya está la armadura `T`.
- **Luces:** ninguna pieza nueva da luz. La luz ambiente se ajusta al vestir, solo en la `_combate`.
- **Parallax:** no. El `fondo` pinta todas las celdas, así que en este constructor un cielo en las almenas taparía o quedaría tapado.

**Enemigos:**
- Se quedan los de profundidad 0, en sus sitios de hoy: Guardia `G`, Vanguardia `v` y murciélago `m`. El Rey Caído sigue en la `_combate`.
- Sin enemigos nuevos.
- **El Mimic** (Monsters Creatures Fantasy 2, cuadros de 146x146) se propuso y se descartó para el castillo, por coherencia con P33: es una criatura. Queda para más adelante, en la profundidad de las criaturas, y se decide en la ficha de esa zona. Lo que ya se sabe:
  - los cofres de verdad de su zona usan también `cofre_madera.tscn`;
  - trae cerrado, apertura, transformación, andar, mordisco, latigazo con la lengua (unas 3 piezas de alcance), daño y muerte;
  - mide 31x20 px cerrado y unos 43x30 despierto, a escala 1.

**Origen del arte:**
- **craftpix dungeon objects:** ya está en el repo, con su `License.txt` (licencia de craftpix para juegos). Lo que se use vuelve de `archivo/sin_uso/` a `assets/terceros/` y se anota en su `ORIGEN.txt`.
- **Raou `Tilesetv3.png`:** tablón, pared con pilastras y cuadro. Con el permiso informal de siempre.
- **Cofre:** `Monsters Creatures Fantasy 2.zip` (Mimic). Va a `assets/terceros/monster_creatures_2/mimic/` y se anota en su `ORIGEN.txt`.
- Sin pack nuevo ni IA.
- **Licencias:** Raou y Monsters Creatures Fantasy 2 están por confirmar antes de publicar (ver "Otros pendientes" de `TASK.md`). Se usan igual, como en el calabozo. El estandarte de origen desconocido sale del castillo.
- **Mirado en Descargas y descartado para el castillo:**
  - el crusher de unTied Games (licencia para juegos con créditos), que pega más con la mazmorra o la ruina;
  - `Monster_Creatures_Fantasy(Version 1.3)`, que solo trae `Attack3` de cada bicho.

**Reto obligatorio:** coincide con su fila de P46, sección 10.
- Llega con E1 (salto de unas 4,3 piezas) y sale por `[H2]` rodando, con Rodar del Rey Caído.
- Ningún reto obligatorio pide E2 ni una mejora de la tienda.
- Vestir no cambia celdas sólidas y las plataformas siguen siendo de una vía; se comprueba en el paso D.

**Piezas (hechas el 2026-11-11).** Decisiones aprobadas al pasar la ficha a piezas:
- **Atlas:** `herramientas/constructor_mapas/atlas_castillo.py` rehace las filas 20-23 de `tileset_castillo.png` y deja las 0-19 como están, así que las escenas ya generadas se ven igual. `atlas_calabozo.py` copia ahora solo las filas 0-19 del castillo; su atlas sale igual píxel a píxel. Coordenadas en `assets/terceros/raou_castillo/ORIGEN.txt`.
- **Tablón:** en `plataformas` (0,20). Lleva la misma colisión de una vía que las tiras de antes.
- **Fondo `castillo`:** 6x3, con cinco columnas de la pared lisa de hoy y la pilastra de Raou (12,17)-(12,19).
  - De lado se repite sin costura.
  - En vertical la pilastra repite capitel y basa cada 3 filas, al mismo paso que la banda oscura que ya tenía la pared lisa.
- **Tamaños** (el arte no cabía en 2x2 sin recortarlo):
  - `A` armero con espadas, **2x3** (32x33 px);
  - `D` cráneo de dragón, **3x3** (34x43);
  - `O` estante estrecho con provisiones, **2x3** (29x45);
  - `Q` el paisaje grande de Raou, **2x2** (25x27);
  - `h` el estandarte rojo pequeño, 1x2 (15x19), pegado arriba.

  `A` y `O` apoyan abajo; `D` y `Q` van centrados en su hueco.
- **Cofre:** `escenas/objetos/cofre_madera.tscn`, con `Idle_closed` e `idle_open` del Mimic (`assets/terceros/monster_creatures_2/mimic/`).
  - Los dos cuadros usan la misma región, 43x20, porque la tapa abierta cae a la izquierda; `offset.x = -6` centra el cuerpo del cofre en su pieza.
  - No usa la animación `opening`: `chest_interactable.gd` pone el cuadro 1 al abrir.
  - El constructor lo toma de la clave `cofre` del tileset, y el calabozo sigue con `cofre.tscn`.
- **Letras** `A`, `D`, `O` y `Q`: en `COLORS`, la paleta y LEYENDA (sección 5). Solo el tileset `castillo` las dibuja.
- **La zona de pruebas** usa el tileset `castillo`, así que ya lleva el tablón, la pared con pilastras y el estandarte nuevo.
  - Las colisiones salen iguales.
  - Solo cambia el cuarto nuevo de la galería: x 78-107, filas 86-98.
- **Probado** en el piso D de la galería ("TILESET CASTILLO"):
  - captura con el juego abierto, con el cofre cerrado y abierto;
  - prueba sin ventana:
    - 96 bloques macizos y 8 piezas de tablón de una vía;
    - el Player se apoya en el tablón y en el suelo;
    - los decorados en su sitio;
    - el cofre abre y suelta 3 monedas y 1 poción.
- **Al vestir:**
  - la cabecera del `.txt` no cambia (`tileset`, `bloques` y `fondo: castillo`);
  - se colocan `A`, `D`, `O` y `Q`, cada uno con su tamaño de arriba;
  - se aparta la antorcha de (59, 18), que tapa el cofre;
  - el estandarte viejo de (10,16) sale del atlas.

**Vestida antes de la revisión (2026-11-11):**
- La cabecera de `mapas_texto/tiles_castillo.txt` no cambia. Se regeneró la base `escenas/mapas/tiles_castillo.tscn` y la `_combate` no se tocó.
  - Con el tileset de hoy salen el tablón en las 159 `=`, la pared con pilastras, los 9 estandartes rojos y los 4 cofres del Mimic.
- Decorados nuevos en el ASCII. Cumplen la regla de la cabecera, y ninguno pisa un cofre, un enemigo ni un objeto de la `_combate`:

  | Letra | Sala | Sitio (abajo a la izquierda) |
  |---|---|---|
  | `A` armero | armería | (79, 19) junto a la armadura y (91, 19) pasado el hueco |
  | `O` provisiones | armería y bodegas del sótano | (97, 19) y el rincón (20, 75) |
  | `D` cráneo de dragón | armería, gran salón y sala del trono | (90, 13); (31, 33), sobre la fogata del checkpoint; (62, 57), sobre el arco del trono |
  | `Q` cuadro | gran salón y aposentos de la Reina | (9, 32), bajo el balcón izquierdo; (40, 32); (61, 33), sobre la armadura; (64, 15), sobre la estantería |

- **Se movieron dos decorados:**
  - la antorcha de la capilla, de (59, 18) a (55, 18), porque el cofre del Mimic la tapaba (abierto, la tapa cae a la izquierda, así que tampoco cabe en la 57);
  - la caja del sótano, de (21, 75) a (22, 75), para dejar sitio al estante.
- **Estandarte viejo:** `atlas_castillo.py` borra (10,16)-(10,17), y `atlas_calabozo.py`, al copiar las filas 0-19, también lo quita de su atlas. Los dos atlas solo cambian en esas piezas.
  - Además de la base del castillo, lo pintaban `archivo/tiles_v1/escenas/tiles_castillo.tscn` y `tiles_calabozo.tscn`, fuera de la ruta: se quedan sin estandartes (aprobado el 2026-11-11).
  - Ninguna otra escena usa esa pieza.
- **Colisiones:** iguales antes y después (4002 piezas sólidas y 159 de una vía, con los mismos polígonos), volcadas de las capas de la base con una escena temporal.
- Capturas sin ventana de la armería, el gran salón, la sala del trono, la capilla con los aposentos y el sótano.
- Arrancan sin errores la `_combate`, el juego, el calabozo y la zona de pruebas, y `verificar_mundo.py` da 0 errores. El Atlas se publicó de nuevo, con los nombres de `A`, `D`, `O` y `Q`.
- La luz ambiente de la `_combate`, (0.5, 0.46, 0.6), se queda hasta jugarla.

**Ficha revisada (aprobada el 2026-11-11): una pared por sala.**
- **Por qué:** vestido así, el castillo se veía igual en todas las salas; la biblioteca, por ejemplo, no parecía una biblioteca. Cada sala tiene que notarse al entrar.
- **Constructor:** opción nueva `fondo_sala: <pared> x0 y0 x1 y1`, que se puede repetir. Pinta otra pared en ese rectángulo de piezas (bordes incluidos); si dos se pisan, gana la de más abajo, y `ninguno` deja la pared vacía para ver el parallax. Sin `fondo_sala` el constructor genera lo mismo que antes.
- **Atlas:** `atlas_castillo.py` lo agranda de 512x384 a 512x512. Las filas 0-23 no cambian y las 24-31 llevan las paredes y los decorados nuevos, todo de `Tilesetv3.png` de Raou (sin pack nuevo ni IA). El atlas del calabozo sigue copiando las filas 0-19 y mide 512x384.
- **Paredes:**

  | Sala | Pared | De `Tilesetv3.png` |
  |---|---|---|
  | Biblioteca | `piedra`, con estanterías altas `l` delante (cambio del 2026-11-11, ver abajo) | (8,20) |
  | Gran salón | `piedra_oscura`, la misma de la galería de las celdas (cambio del 2026-11-11, ver abajo) | (11,20) |
  | Capilla | `piedra_clara` | (5,20) |
  | Aposentos de la Reina | `madera_oscura`: ladrillo con postes y baranda | (14,17) |
  | Antecámara y vestíbulo | `ladrillo`: ladrillo claro | (5,14) |
  | Sala del trono | `columnas`: ladrillo con una columna de piedra | (5,17) |
  | Galería de las celdas | `piedra_oscura` | (11,20) |
  | Sótano y paso bajo el trono | `piedra` | (8,20) |
  | Armería | `castillo`, la de hoy con pilastras | |
  | Almenas | `ninguno`: el cielo de `assets/terceros/gothicvania/pueblo_noche/` (cielo, nubes y montes) como parallax; aprobado aunque su tono es más verdoso | |

  En el atlas quedan además, probadas y sin usar:
  - `madera` (8,17), la versión clara de la de los aposentos: en la biblioteca parecía una cuadrícula, y sus barandas se confunden con los tablones;
  - `marco` (8,14), ladrillo con marco de piedra clara, que cansaba la vista en la antecámara;
  - `libros`, la estantería alta sobre la madera oscura al 60% de brillo, que se confundía con la escalera y los estantes;
  - `arcada` (10,28), dos pisos de arcos de 6x8, que se veía rara en el gran salón.

  La muestra "CASTILLO, SALAS" de la galería las enseña igual.
- **Decorados nuevos** (solo el tileset `castillo` los dibuja):

  | Letra | Pieza | Sala |
  |---|---|---|
  | `w` | ventana de celosía de piedra, 3x3 | capilla (como vidriera) y gran salón |
  | `K` | columna alta, 2x7 | capilla y gran salón |
  | `U` | tapiz, 2x3 | sala del trono y gran salón |
  | `l` | estantería alta, 2x3 | biblioteca y aposentos |
  | `n` | mesa con frascos, 2x1 | biblioteca y aposentos |
  | `y` | lámpara colgante, 1x1 (cuelga del techo) | biblioteca, capilla y aposentos |
  | `V` | mostrador con frascos, 2x2 | bodegas del sótano |

  El armario, los pergaminos y el escudo redondo de Raou se miraron y se dejan fuera.
- Las reglas de siempre: ninguna celda sólida cambia y ningún reto obligatorio cambia.

**Piezas de la revisión (hechas el 2026-11-11):**
- **Constructor:** `fondo_sala` en `construir_mapa.gd`, documentado en LEYENDA (sección 3). Sin esa opción genera lo mismo que antes. Las letras `w`, `K`, `U`, `l`, `n`, `y` y `V` van en `COLORS`, la paleta y LEYENDA (sección 5).
- **Atlas** (`atlas_castillo.py`, 512x512):
  - paredes en (0,24)-(29,26), más `libros` en (0,27) y la `arcada` 6x8 en (21,24);
  - decorados: `w` en (3,27), `U` (6,27), `l` (8,27), `V` (10,27), `n` (12,27), `y` (14,27) y `K` (30,24).

  Los huecos de los arcos de la arcada se rellenan con su negro (6, 6, 6), para que la pared sea opaca.
- **Las escenas que ya usan el atlas** no cambian en sus capas. Al regenerarlas solo cambia el TileSet incrustado, que trae las piezas nuevas (comprobado en las muestras del castillo y del calabozo).
- **Galería:** cuarto "CASTILLO, SALAS" en el piso D (x 41-76, filas 86-98), con la muestra `zona_pruebas_muestra_castillo_salas`:
  - cinco paredes una al lado de la otra (libros, arcada, piedra clara, madera oscura y columnas), con los siete decorados y dos tablones;
  - `galeria.py` aprendió a escribir una segunda muestra del mismo tileset (`sufijo`) con líneas de cabecera (`cabecera`).

  La zona de pruebas se regeneró: sus colisiones solo cambian en el cuarto nuevo.
- **Probado:**
  - captura del cuarto;
  - prueba sin ventana: las 5 paredes con su patrón, los 7 decorados en su pieza del atlas y con arte, el suelo macizo y los 9 tablones de una vía.

**Vestida con la ficha revisada (2026-11-11; jugada a mano y vestida el 2026-11-11):**
- `mapas_texto/tiles_castillo.txt` lleva en la cabecera las paredes de cada sala (`fondo_sala`, con los rectángulos de la tabla de la ficha) y el parallax de `pueblo_noche` (cielo, nubes y montes, a 0.05, 0.1 y 0.2, al doble). Las almenas, x 12-90, filas 1-5, y el tramo derrumbado, x 62-66, filas 6-8, quedan sin pared.
- **Decorados nuevos** (sitio de abajo a la izquierda):

  | Sala | Decorados |
  |---|---|
  | Biblioteca | lámparas `y` (10, 8), (24, 8) y (30, 8); estanterías altas `l` (4, 15), sobre el estante, y (13, 21); mesa `n` (26, 21) |
  | Capilla | vidrieras `w` (45, 12) y (55, 13), que sustituye a la ventana `r` de (55, 12); lámpara `y` (50, 8) |
  | Gran salón | columnas `K` (26, 35) y (35, 35), a los lados del cráneo y de la fogata; tapices `U` (14, 28) y (56, 29); celosía `w` (47, 28) |
  | Sala del trono | tapiz `U` (84, 55); columnas `K` (72, 62) y (98, 62), sin pisar el sitio del Rey (68, 62) |
  | Aposentos | lámpara `y` (69, 11); mesa `n` (70, 18) |
  | Bodegas del sótano | mostrador `V` (37, 75) |

  - La estantería alta se probó primero en (25, 21), pero pisaba las tres filas de encima de la escalera del gran salón (columna 24).
  - Ninguno pisa los objetos de la `_combate` (diario, fragmento, palanca, reliquia, sitio del Rey, E2).
- **Colisiones:** iguales antes y después de la revisión, y también iguales a las de antes de vestir (4002 sólidas y 159 de una vía, mismos polígonos).
- Arrancan sin errores la `_combate`, el juego, el calabozo y la zona de pruebas, y `verificar_mundo.py` da 0 errores. Capturas de todas las salas, y el Atlas publicado con los nombres de las letras nuevas.
- **Corrección tras verla (2026-11-11):**
  - la pared de libros de la biblioteca se confundía con la escalera y los estantes: pasa a `piedra`, y las estanterías van delante como decorado; las `E` de (3, 21) y (19, 21) pasan a estanterías altas `l` y se añade otra en (9, 12), sobre el estante;
  - la arcada del gran salón se veía rara: pasa a `columnas` y, al verlo, a `piedra_oscura`, la de la galería de las celdas;
  - se eligió entre cuatro opciones con capturas de cada sala, y la galería de las celdas, con piedra oscura, se queda.

  Colisiones iguales otra vez. Arrancan el juego y la `_combate`, y el verificador da 0 errores.
- **Al jugarla, mirar:**
  - el cielo de las almenas en movimiento: el parallax solo se vio en capturas (LEYENDA, sección 9);
  - la luz ambiente de la `_combate`, (0.5, 0.46, 0.6), con las paredes nuevas;

### Cementerio
- Parte de: tileset `cementerio`, parallax de `gothicvania_cementerio/fondo` (cielo, montes y cementerio). Vanguardia, murciélago, esqueleto de tumba; el Capitán.
  - Pendiente de P34, sección 5: el cielo se ve también dentro de las cuevas, porque cada mapa tiene un solo parallax.
  - Más detalle: `fondo: ninguno`, `bloques: cementerio` en toda la zona y luz ambiente de la `_combate` (0.42, 0.46, 0.6). En el ASCII, 4 Vanguardias `v`, 13 esqueletos de tumba `u` y 11 murciélagos `m`; en las oleadas de la fosa (`_combate`), 5 `u` y 1 `m`.
- **Ficha aprobada el 2026-11-12.**
- **Por qué cambia** (capturas sin ventana de la zona generada):
  - la luna y el cielo se ven dentro de la fosa, el osario, las catacumbas y la cripta de la primera reina;
  - bajo tierra, todos los suelos, techos y repisas llevan pasto;
  - las "estanterías de huesos" `E` de la cabecera del ASCII son la estantería de libros y frascos de la mazmorra;
  - el exterior solo tiene una lápida, repetida.

**Ambientación** (sin tileset nuevo: cambian `cementerio.gd` y su atlas `assets/terceros/gothicvania_cementerio/tileset_cementerio.png`, que rehará un script `herramientas/constructor_mapas/atlas_cementerio.py`, como el del castillo; pasa de 512x320 a 512x512 y las filas 0-19 no cambian):
- **Paredes**, con `fondo` y `fondo_sala`:

  | Pared | Arte | Dónde |
  |---|---|---|
  | `ninguno` | el parallax de hoy (cielo, montes y cementerio) | el aire libre: x 0-119, filas 0-26, y el foso de pinchos hasta la fila 29 |
  | `tierra` (nueva) | la tierra con calaveras del propio pack, oscurecida (como `libros` del castillo, al 60 %) | lo excavado: fosa, catacumbas alta y baja, pozo del sello, cueva de la estatua y hueco al osario. Pasa a ser el `fondo:` de la zona |
  | `ladrillo` (nueva) | el muro de ladrillo con musgo de Gothic Horror (Legacy), oscurecido | lo construido: casa del sepulturero, antecripta, osario, antesala, cámara de la tumba real, panteón del caballero y cripta de la primera reina |

  Los rectángulos exactos se fijan al vestir.
- **Bloques:** opción nueva del constructor `bloques_sala: <estilo> x0 y0 x1 y1`, como `fondo_sala` (se repite; si dos se pisan, gana la de más abajo; sin ella el constructor genera lo mismo que antes).
  - Estilo nuevo `cripta`: la tierra con calaveras del pack en las 9 piezas del juego de bloques, sin pasto. Todas macizas: las colisiones no cambian.
  - Bajo tierra, las plataformas `=` pasan a la repisa de piedra de Gothic Horror, con la colisión de una vía de siempre.
  - El exterior se queda con `cementerio` (pasto arriba y plataformas de pasto).
- **Decorados** (solo el tileset `cementerio` los dibuja; reutilizan letras del castillo, como el calabozo reinterpretó las de la mazmorra, así que no hay colores nuevos; los tamaños se miden en el paso de piezas):

  | Letra | En `cementerio` hoy | Propuesta | Dónde |
  |---|---|---|---|
  | `T`, `g`, `r`, `t`, `h`, `b`, `x` | lápida, pasto, zarzas, antorcha, hongos, barril y caja | se quedan | |
  | `E` | estantería de la mazmorra, 3x3 | nicho de calaveras de Gothic Horror, 2x3 | sus 4 sitios de hoy: osario, catacumba alta, cueva de la estatua y cripta de la primera reina |
  | `K` | — | cruz de piedra (`stone-2`), 2x3 | exterior |
  | `Q` | — | lápida inclinada (`stone-3`), 2x3 | exterior |
  | `D` | — | árbol muerto (`tree-2`), unas 11x8 | exterior, 2 o 3 |
  | `O` | — | arbusto con cruz (`bush-large`), 5x5 | exterior |
  | `A` | — | gárgola de Gothic Horror, unas 2x3 | casa del sepulturero y mausoleo |
  | `n` | — | montón de huesos de Gothic Horror, 2x2 | osario y catacumbas |
  | `U` | — | calavera en el muro de Gothic Horror, 2x2 | catacumbas y pozo del sello |
  | `V` | — | nicho con llama de Gothic Horror, 2x3 | antesala, cámara de la tumba real, panteón y cripta de la primera reina |

  - La letra `C` (tienda de campaña) sigue sin usarse.
  - Los decorados nuevos siguen la regla de la cabecera del `.txt`: ninguno pisa una escalera, sus columnas vecinas ni las tres filas de encima, un spawn ni otro decorado, ni los objetos de la `_combate`.
- **Luces:** el nicho con llama `V` va en `DECOR_LIGHTS`, con la luz naranja de la antorcha. La luz ambiente se ajusta al vestir, solo en la `_combate`.
- **Parallax:** se queda el de hoy, que ya solo se ve en el exterior. Resuelve el pendiente de P34, sección 5.

**Enemigos:**
- Se quedan, en sus sitios de hoy: Vanguardia `v`, esqueleto de tumba `u` y murciélago `m`. El Capitán y las oleadas de la fosa siguen en la `_combate`.
- Nuevos (los dos de profundidad 1; se suman a la tabla de P33):

  | | Cuervo `o` | Ánima `N` |
  |---|---|---|
  | Qué es | bicho común de la superficie | alma en pena: un muerto de la cripta, como el esqueleto de tumba |
  | Script base | `lunge_enemy.gd`, vuela como el murciélago | `rising_enemy.gd` con `use_gravity = false`: dormida es una brizna (primer cuadro de `appear`), aparece al acercarse el Player, persigue y embiste, y al morir se desvanece (`vanish`) |
  | Vida y daño | 1 de vida, 0.25 de daño | 2.5 de vida, 0.5 de daño |
  | Sitio | 3 nuevos en el exterior: rincón de la colina, sobre el tejado de la casa y junto al mausoleo. Ninguno sobre el foso de pinchos | sustituye a 3 murciélagos: catacumba baja (60, 69), panteón (96, 79) y pozo del sello (8, 80) |
  | Arte | `crow` de la Legacy, 48x48: `idle` 3, `front` 3 y `fly` 2 | `Ghost-Files` de la Legacy, 64x80: `appear` 6, `idle` 7, `chase` 4, `shriek` 4 y `vanish` 7 |

  - Si `rising_enemy.gd` no sirve para un enemigo que vuela sin cambios, se pregunta antes de tocarlo o de hacerle un script propio.
  - Los sitios exactos de los cuervos se fijan al vestir.

**Origen del arte:**
- **Gothicvania Cemetery** (CC0, ya en el repo; el ZIP sigue en Descargas): cruz, lápida inclinada, árbol, arbusto y la tierra con calaveras.
- **Legacy Collection** (CC0, ya en el repo en `assets/terceros/gothicvania/`): de `Gothic-Horror-Files`, el ladrillo, la repisa de piedra, el montón de huesos, el nicho de calaveras, la calavera en el muro, el nicho con llama y la gárgola; `crow` y `Ghost-Files`.
- Lo que se use se copia a `assets/terceros/` y se anota en su `ORIGEN.txt`. Sin pack nuevo ni IA, y sin licencias por confirmar.
- **Mirado y descartado:**
  - el fantasma con farol del Cemetery, porque se confunde con el Barquero;
  - el hell-gato del Cemetery, que es un demonio: queda para las profundidades;
  - la estatua de la Parca del Cemetery, porque se confundiría con la estatua rompible de la Reina;
  - el esqueleto de lanza, que es el carcelero.

**Reto obligatorio:** coincide con su fila de P46, sección 10.
- Llega con E1 o E2 y Rodar, y sale por `[S3]` (tres tumbas sello, la última la del Capitán).
- Vestir no cambia celdas sólidas; se comprueba en el paso D.
- Los cuervos quedan lejos del foso de pinchos de la tumba sello 2, y ninguna ánima va en la sala del Capitán ni en la antesala.
- Ningún reto obligatorio pide E3, la Agilidad ni una mejora de la tienda.
- Antes de dar la zona por vestida falta volver a jugar la fosa agrandada y ajustar sus oleadas (`TASK.md`, estructura del cementerio).

**Piezas (hechas el 2026-11-12).** Decisiones aprobadas al pasar la ficha a piezas:
- **Arte:** la ficha daba la Legacy por "ya en el repo", pero allí solo estaban los fondos, los efectos y el Barquero. Gothic Horror, `crow`, `Ghost-Files` y los `sliced-objects` del Cemetery se trajeron de los ZIP, solo lo que se usa, y quedan anotados en los `ORIGEN.txt` de `assets/terceros/gothicvania/` y `gothicvania_cementerio/`.
- **Atlas** `tileset_cementerio.png`, que arma `herramientas/constructor_mapas/atlas_cementerio.py`. Pasa de 512x320 a 512x512 y las filas 0-19 no cambian (comprobado píxel a píxel). En las filas 20-31:
  - **Estilo `cripta`** en (0,20): la fila de arriba, las tiras y la pieza suelta son la tierra con calaveras sin pasto del pack (`tileset.png`, (4..7,5)); los lados también son de esa tierra; el interior y la fila de abajo son las del juego `cementerio`. Las 16 piezas son macizas.
  - **Repisa de piedra** en (4,20): de Gothic Horror, (2,1), (3,1) y (6,1), con la colisión de una vía de siempre.
  - **Pared `tierra`** en (7,20), 4x2: la tierra del pack sobre la fila de techos del juego `cementerio`, al 60 %.
  - **Pared `ladrillo`** en (11,20), 7x3: la fachada con musgo de Gothic Horror, (34,8)-(40,10), al 60 %. Se repite sin costura de lado y de alto.
- **Decorados** (tamaños medidos; las piezas de `E`, `n` y `U` se eligieron entre las del pack):

  | Letra | Pieza | Tamaño |
  |---|---|---|
  | `E` | calaveras amontonadas | 2x3 |
  | `K` | cruz de piedra (`stone-2`) | 2x3 |
  | `Q` | lápida inclinada (`stone-3`) | 2x3 |
  | `D` | árbol muerto (`tree-2`) | **11x8** |
  | `O` | arbusto con cruz (`bush-large`) | **5x5** |
  | `A` | gárgola, sin el trozo de muro de la casa | 2x3 |
  | `n` | calaveras en la pared | 2x2 |
  | `U` | arco con calavera cornuda: trae su marco y no deja un parche de ladrillo en las paredes de tierra | 2x3 |
  | `V` | nicho con llama | **2x4** |

  La cara en el ladrillo y los huesos tirados de Gothic Horror se miraron y se dejan fuera.
- **Constructor:**
  - opción `bloques_sala: <estilo> x0 y0 x1 y1`, que se repite como `fondo_sala` (gana la de más abajo) y cambia los bloques, las rampas y las plataformas de ese rectángulo;
  - un estilo de `bloques` admite un tercer elemento con sus plataformas (la repisa de `cripta`);
  - sin `bloques_sala` genera lo mismo que antes: las muestras del calabozo y del castillo y la zona de pruebas salen iguales, y el cementerio de hoy da el mismo `Terreno` y las mismas `Plataformas` (solo cambia `Decorado`, por la `E` nueva).
- **Luces:** `DECOR_LIGHTS` buscaba la luz por la coordenada del atlas sin mirar de qué tileset era, así que los dos estantes `O` del castillo tenían la luz de la antorcha del calabozo (15,20). Ahora `DECOR_LIGHTS` solo lleva las piezas del atlas de mazmorra, y `ATLAS_DECOR_LIGHTS` las de cada atlas: la antorcha del calabozo y el nicho `V` del cementerio, en (30,22).
- **Enemigos** (sin script propio):
  - **cuervo** `o` (`escenas/enemigos/cuervo.tscn`, `lunge_enemy.gd`, los valores del murciélago con 1 de vida, 0.25 de daño y 0.25 de contacto): siempre en vuelo. `idle` es el aleteo de frente, `move` el picado, y `attack` aletea durante el aviso (0.25 s) y cae en picado durante la embestida. El cuervo posado no se usa;
  - **ánima** `N` (`escenas/enemigos/anima.tscn`, `rising_enemy.gd` sin cambios y sin gravedad, 2.5 de vida, 0.5 de daño y 0.25 de contacto): dormida es la brizna (cuadro 0 de `appear`) y despierta con el Player a 80 px de lado y 70 de alto. `move` es `chase`, `attack` grita (`shriek`) durante el aviso (0.4 s) y embiste inclinada (`chase`), y `death` es `vanish`.
- **Galería:**
  - piso B: cuarto "CUERVO Y ÁNIMA" tras el del amuleto. Los tres cuartos de las minas se corren 17 columnas a la izquierda y el del Mauler queda en x 8-29, sin tocar el pozo de la columna 4;
  - piso D: cuarto "TILESET CEMENTERIO" (x 2-37), con la muestra `zona_pruebas_muestra_cementerio`. A la izquierda, el exterior sin pared con `Q`, `D`, `K` y `O`; a la derecha, la cripta (`bloques_sala`) con las dos paredes, una columna, una tira y una pieza suelta, la repisa y `U`, `A`, `E`, `V` y `n`. Sin parallax, porque dentro de la galería taparía todo;
  - `galeria.py` acepta la pared de la muestra (`fondo`) para los tilesets sin una pared con su nombre.
- **Probado:**
  - capturas de los dos cuartos;
  - prueba sin ventana con 44 comprobaciones bien:
    - los 42 bloques de la muestra son macizos y los de la cripta usan su juego (columna, tira y pieza suelta incluidas);
    - las 3 piezas de la repisa son de una vía, y el Player se apoya en la repisa y en el suelo;
    - los 9 decorados están en su pieza del atlas, y las paredes salen bien (sin pared, tierra y ladrillo);
    - hay luz en el nicho y en las 21 antorchas del calabozo, y ninguna en los estantes del castillo;
    - el cuervo y el ánima siguen en su sitio a los 3 s; el ánima duerme como brizna, rechaza golpes dormida y mientras aparece, y despierta al acercarse;
    - los dos dañan en múltiplos de 0.25, reciben golpes y mueren (el ánima, con `vanish`);
  - arrancan sin errores el juego, la zona de pruebas y las `_combate` del calabozo, el castillo y el cementerio.
- **Al vestir, mirar:** en la captura la pared `tierra` al 60 % se distingue poco de los bloques de tierra de la cripta. Si al jugar cuesta leer qué es suelo, se baja su brillo (por ejemplo, al 45 %) en `atlas_cementerio.py`.

**Vestida (2026-11-12), falta jugarla a mano:**
- `mapas_texto/tiles_cementerio.txt` pasa a `fondo: tierra`, con `fondo_sala` y `bloques_sala`, y se regeneró la base `escenas/mapas/tiles_cementerio.tscn`. La `_combate` no se tocó.
- **Paredes:**

  | Pared | Rectángulos (x0 y0 x1 y1) |
  |---|---|
  | `ninguno` (el parallax) | aire libre 0 0 119 26 y foso de pinchos 87 27 103 29 |
  | `tierra` (el `fondo:`) | todo el subsuelo, más el túnel de `[H2]` (0 24 9 26) y la cueva de la estatua (111 12 118 17) |
  | `ladrillo` | casa 51 21 63 26; cripta de la primera reina 62 29 74 34 y su nicho 67 35 69 37; antecripta 44 42 61 50; osario 62 38 100 50; antesala 56 80 70 86; cámara de la tumba real 24 76 54 86; panteón 88 76 117 86 |

  - El túnel de `[H2]` y la cueva de la estatua van con tierra, aunque caen en el rectángulo del aire libre de la ficha, porque tienen techo. El rincón de la colina se abre al exterior y se queda con el cielo.
  - Las puertas de la casa (columnas 50 y 64) dejan ver el cielo.
- **Bloques `cripta`:** 0 28 119 89 (todo lo que queda bajo la fila del suelo), el túnel de `[H2]` (0 23 9 27), la cueva de la estatua (112 10 119 18) y el suelo de la casa (51 27 63 27). El foso de pinchos (86 28 104 30) vuelve a `cementerio`, para que los pilares no cambien de pieza a media altura. Las 54 piezas `=` de bajo tierra (de 74) son ahora la repisa de piedra.
- **Pared `tierra` al 35 %:** al 60 % y al 45 %, en las capturas de la fosa y las catacumbas no se veía dónde acababa la pared y empezaban los lados y los techos de la cueva. `atlas_cementerio.py` tiene ahora su propio brillo (`EARTH_WALL_BRIGHTNESS`), y el ladrillo sigue al 60 %. En el atlas solo cambian sus piezas, (7,20)-(10,21).
- **Decorados nuevos** (sitio de abajo a la izquierda):

  | Letra | Sitios |
  |---|---|
  | `Q` lápida inclinada | (10, 26), en la boca del túnel |
  | `K` cruz | (18, 26), junto a la lápida de la fogata |
  | `D` árbol muerto | (24, 26), junto a la fosa |
  | `O` arbusto con cruz | (79, 26), pasado el hueco al osario |
  | `A` gárgola | tejado de la casa (50, 19) y (63, 19); mausoleo (73, 21) |
  | `n` calaveras en la pared | osario (77, 49) y (94, 47); catacumba alta (68, 57); catacumba baja (78, 70), sobre los pinchos |
  | `U` arco con calavera | catacumba alta (50, 60) y (102, 60); catacumba baja (20, 72); pozo del sello (17, 86) |
  | `V` nicho con llama | cripta de la primera reina (70, 34); antesala (61, 86) y (66, 86), a los lados de la escalera; cámara de la tumba real (35, 86) y (42, 86), a los lados de la tumba; panteón (98, 86) |

  - **Un solo árbol**, no 2 o 3: mide 11x8 y en el resto del exterior pisaría plataformas, la fogata, el cofre y el sello del panteón, o las lápidas de antes del foso.
  - **Se quitaron o movieron:** el pasto y la zarza de (29, 26) y (30, 26), bajo el árbol (la zarza pasa a (12, 26)); el pasto de (11, 26), por la lápida inclinada; y las lápidas `T` de (79, 26) y (83, 26), por el arbusto.
  - Cumplen la regla de la cabecera del `.txt`, comprobada con un script sobre el ASCII: ninguno pisa una escalera, sus columnas vecinas ni sus tres filas de encima, un spawn, un cofre, una moneda, una poción, otro decorado ni los objetos de la `_combate`. Solo las Vanguardias de (27, 26) y (82, 26) empiezan delante del árbol y del arbusto; son nodos que patrullan y se dibujan delante.
- **Enemigos nuevos en el ASCII:**
  - cuervos `o`: rincón de la colina (8, 13), sobre el tejado de la casa (57, 14) y junto al mausoleo (66, 19), lejos del foso de pinchos;
  - ánimas `N`, en lugar de los murciélagos: catacumba baja (60, 69), panteón (96, 79) y pozo del sello (8, 80).

  Quedan 4 Vanguardias, 13 esqueletos de tumba, 8 murciélagos, 3 cuervos y 3 ánimas. Prueba sin ventana con el Player en la P: a los 3 s los cuervos siguen en su sitio (se mecen 5,5 px) y las ánimas duermen (capa 0).
- **Al jugarla, mirar:** el ánima del pozo del sello está a 3 piezas sobre el spawn `DesdeMinas`, así que despierta en cuanto se vuelve de las minas (antes, el murciélago estaba en el mismo sitio).
- **Cofres (2026-11-12):** los 4 cofres `c` usan el del castillo, `cofre_madera.tscn` (el del Mimic), con la clave `cofre` del tileset `cementerio.gd`; antes salía `cofre.tscn`. Base regenerada: solo cambian los 4 cofres (escena, `offset` y 1 px más arriba, por su alto de 20 px); capas y colisiones iguales. El de (117, 9) tapa unos 7 px del pasto de (118, 9).
- **Colisiones:** iguales antes y después, 4697 piezas sólidas y 74 de una vía, con los mismos polígonos y la misma marca de una vía, volcadas de las capas de la base con una escena temporal.
- Arrancan sin errores la `_combate`, el juego y la zona de pruebas, y `verificar_mundo.py` da 0 errores. Capturas con el juego abierto de las 21 salas y del túnel. El Atlas se publicó de nuevo, con los nombres de las letras del cementerio, el cuervo y el ánima.
- La luz ambiente de la `_combate`, (0.42, 0.46, 0.6), se queda hasta jugarla.
- **Falta, antes de marcarla vestida en `TASK.md`:** jugarla a mano, con la fosa agrandada y sus oleadas (`TASK.md`, estructura del cementerio).

### Minas
- Parte de: tileset `mazmorra` con `bloques: madera`, `fondo: ninguno` y el parallax de `pixelfantasy_caves` (`fondo1`-`fondo4a`) en toda la zona. Luz ambiente de la `_combate`: (0.3, 0.28, 0.36). En el ASCII, 6 kolbo `k`, 6 kolbo2 `j`, 4 kolbo3 `q` y 10 murciélagos `m`; el Caballero y el Crystal Mauler en la `_combate`.
- **Ficha aprobada el 2026-11-12.**
- **Por qué cambia** (capturas con el juego abierto de 10 salas de la `_combate`):
  - los bloques `madera` son cuadros casi negros con un borde fino: la roca se lee como un hueco;
  - el parallax de cuevas sale igual en todas las salas, y la galería alta, la de las vagonetas y la honda no se distinguen;
  - nada dice "mina": ni vigas, ni entibado, ni bocamina, y las vagonetas son cajas y barriles;
  - las escaleras de mazmorra (161 piezas `H`) apenas se ven.

**Ambientación** (tileset nuevo `minas`, `herramientas/constructor_mapas/tilesets/minas.gd`, como `calabozo`: las filas 0-15 copian el atlas de mazmorra, por la antorcha, la lava, la fogata, los cristales y los hongos, y debajo van piezas de `mainlev_build.png` y `props1.png` de PixelFantasy Caves, el pack del parallax de hoy; un script `herramientas/constructor_mapas/atlas_minas.py` arma el atlas):
- **Escala:** el arte del pack está dibujado con píxeles dobles, como su parallax, sobre una rejilla de 16 px. Se usa tal cual, sin reducirlo: a la mitad, la boca de galería quedaría más baja que el Player. Se comprueba en la galería.
- **Bloques `minas`:** la roca marrón de `mainlev_build`, solo piezas macizas.
- **Plataformas `=`** (29): la viga de madera del pack, con la clave `plataformas`. La colisión de una vía no cambia.
- **Escalera:** la de madera del Dungeon Tile Set, como en el calabozo.
- **Cofres `c`** (5): `cofre_madera.tscn`, con la clave `cofre` del tileset (la ficha del castillo pedía el cofre del Mimic en los cofres de verdad de su zona).
- **Paredes**, con `fondo` y `fondo_sala` (los rectángulos exactos se fijan al vestir):

  | Pared | Arte | Dónde |
  |---|---|---|
  | `galeria` (nueva, el `fondo:` de la zona) | roca oscura con un marco de postes y viga del pack cada pocas columnas, como la pilastra del castillo | lo excavado: galerías alta, de las vagonetas, de los mineros y honda, antecámara, túnel de `[L4]` y pozos |
  | `ladrillo` (nueva) | el muro de ladrillo del pack, oscurecido | lo construido: estación del ascensor y sala del Caballero |
  | `ninguno` | el parallax de hoy | las cuevas naturales: bocamina, secreto de la Agilidad, veta ardiente y gruta de cristal |

- **Decorados** (reutilizan letras, como el cementerio, así que no hay colores nuevos; los tamaños se miden en el paso de piezas):

  | Letra | En `minas` | Dónde |
  |---|---|---|
  | `t`, `f`, `C`, `x`, `b`, `r`, `h` | se quedan: antorchas, fogata, tienda del campamento, cajas y barriles de las vagonetas, cristales y hongos | |
  | `K` | entibado: marco de madera con aspa, unas 3x3 | galerías |
  | `U` | boca de galería: marco de madera, unas 3x4 | bocamina y túnel de `[L4]` |
  | `T` | estalagmita de `props1`, unas 2x3 | veta y gruta |
  | `y` | estalactita que cuelga del techo | veta y gruta (en lugar de las estalactitas de bloque) |

  - **Vagonetas:** no hay arte de vagoneta en ningún pack; se quedan las cajas y los barriles.
  - Los decorados nuevos siguen la regla de la cabecera del `.txt`: ninguno pisa una escalera, sus columnas vecinas ni las tres filas de encima, un spawn ni otro decorado, ni los objetos de la `_combate`.
- **Luces:** ninguna pieza nueva da luz; los cristales y los hongos ya la tienen en `DECOR_LIGHTS`. La luz ambiente se ajusta al vestir, solo en la `_combate`.

**Enemigos.** Regla nueva (2026-11-12): **un enemigo no se repite en otra zona**. Los que ya aparecieron más arriba no vuelven a salir (P33).
- Antes de las minas salen: rata, slime y murciélago grande (calabozo); Guardia, Vanguardia y murciélago `m` (castillo); Vanguardia, murciélago `m`, esqueleto de tumba, cuervo y ánima (cementerio).
- **Salen los 10 murciélagos `m`.**
- **Se quedan** los kolbos, que salen por primera vez: kolbo `k` (6), kolbo2 `j` (6) y kolbo3 `q` (4). El Caballero y el Mauler siguen en la `_combate`.
  - El kolbo3 tiene `attack_damage = 0.60`, que no es múltiplo de 0.25: pasa a **0.5** en el paso de piezas (su escena es compartida).
- **Nuevos** (los tres de profundidad 2, criaturas; letras y colores nuevos en `COLORS`, la paleta, LEYENDA y P33):

  | | Ojo volador `p` | Sapo de la cueva `s` | Mimic `i` |
  |---|---|---|---|
  | Arte | FlyEye de Super Grotto (CC0): 4 cuadros de 48x48, un ojo con alas | mutant-toad de Gothicvania (CC0), 80x64: `idle` 4, `jump` 4 y `attack` 3, con lengua | Mimic de Monsters Creatures Fantasy 2, cuadros de 146x146: cofre cerrado, `transform`, `walk`, `attack_1` (mordisco), `death` |
  | Script base | `lunge_enemy.gd`, vuela y embiste (su arte no trae golpe) | `enemy_base.gd`: avanza a saltos (`jump` como `move`) y golpea con la lengua, de unas 2 piezas de alcance. Muere con el efecto `muerte`, porque no trae muerte | `rising_enemy.gd` sin cambios: dormido es un cofre cerrado (cuadro 0 de `transform`, la misma región que `cofre_madera`); despierta con `transform` con el Player a unas 3 piezas, persigue con `walk`, embiste con el mordisco y muere con `death` |
  | Vida y daño | 2 de vida, 0.5 de daño y 0.25 de contacto | 3 de vida, 0.5 de daño y 0.25 de contacto | 4 de vida, 0.5 de daño y 0.25 de contacto |
  | Sitio | 6 de los sitios de los murciélagos, los del aire: sobre los fosos de lava (75, 53) y (99, 51), veta este (120, 52), junto al pozo de `:D:` (136, 82), vagonetas (112, 36) y galería alta (60, 15) | los otros 4, bajados al suelo: vagonetas (bajo (70, 36)), galería de los mineros (bajo (21, 52)) y galería honda (bajo (80, 82) y (110, 82)) | 2, en callejones sin salida: cochera de la galería de las vagonetas (x 121-130) y galería de los mineros, que ya tiene un cofre de verdad al fondo |

  - Los sitios exactos del sapo y del Mimic se fijan al vestir, con la regla de las escaleras.
  - Dormido, el Mimic no muestra "E Abrir": es la pista para el que se fije.
  - Si `rising_enemy.gd` o `lunge_enemy.gd` no sirven sin cambios, se pregunta antes de tocarlos o de hacer un script propio.
- Quedan 16 kolbos, 6 ojos, 4 sapos y 2 Mimics (28; antes, 26).
- **La regla fuera de las minas** (pendiente, cada una en su sesión):
  - el cementerio, vestido pero sin marcar, repite la Vanguardia `v` (4) y el murciélago `m` (8) del castillo. No se toca hasta que se decida;
  - según P33, el kolbo3 vuelve a salir en la mazmorra y la ruina, y la ruina repite toda la lista de la mazmorra: sus fichas traen enemigos propios;
  - el infierno sigue siendo la excepción de P46: mezcla los más duros de todas las profundidades.

**Origen del arte:**
- **PixelFantasy Caves** (ya en el repo): `mainlev_build.png` y `props1.png` vuelven de `archivo/sin_uso/assets/PixelFantasy_Caves_1.0/` a `assets/terceros/pixelfantasy_caves/` y se anotan en su `ORIGEN.txt`.
- **Mimic:** el resto de sus animaciones se trae de `Monsters Creatures Fantasy 2.zip` (Descargas) a `assets/terceros/monster_creatures_2/mimic/`.
- **FlyEye** (`Super Grotto Escape Files.zip`) y **mutant-toad** (`Legacy Collection.zip`), CC0: a `assets/terceros/super_grotto/` y `assets/terceros/gothicvania/`, con sus `ORIGEN.txt`.
- **Escalera:** la del Dungeon Tile Set, ya en el repo.
- Sin pack nuevo ni IA.
- **Licencias:** PixelFantasy Caves, Monsters Creatures Fantasy 2 y el Dungeon Tile Set están por confirmar antes de publicar (ver "Otros pendientes" de `TASK.md`). Se usan igual, como en el calabozo y el castillo.
- **Mirado y descartado:**
  - el caracol de cristal de Super Grotto: rosa chillón, de estilo tierno;
  - el lagarto y la serpiente de Grotto Escape 2: muy pequeños;
  - el ojo demonio y la calavera de fuego de la Legacy: un demonio y un esqueleto, de más abajo;
  - el Rocky Tileset (playa soleada), las Caverns de Gothicvania (ya son el parallax de la ruina), los Tiles de Anokolisa (pasto y colores de bosque) y las gemas de la Legacy (estilo match-3).

**Reto obligatorio:** coincide con su fila de P46, sección 10.
- Llega con la Ráfaga y Rodar (E1 o E2; la Agilidad solo si encontró E3) y sale por `[L4]` con la llave del Caballero.
- Los dos Mimics van fuera del camino obligatorio.
- Ningún reto obligatorio pide E3, el dash ni una mejora de la tienda.
- Vestir no cambia celdas sólidas y las plataformas siguen siendo de una vía; se comprueba en el paso D.

**Piezas (hechas el 2026-11-15).** Decisiones aprobadas al pasar la ficha a piezas:
- **Lo que no cuadraba con la ficha** (hallado al mirar el arte):
  - **Mimic:** el cuadro 0 de `transform` no es el cofre cerrado, sino el cofre abierto y tumbado (43x11). En el pack van `Idle_closed`, `opening` (6), `transform` (7) e `idle_transformed`. Su `rise` une `opening` y `transform` (13 cuadros), y duerme en el cuadro 0, el cofre cerrado de `cofre_madera`. `rising_enemy.gd` no cambia.
  - **`T` e `y`:** las estalagmitas más pequeñas de `props1.png` miden 48x55, así que van a **3x4**. Son las dos mitades de la misma roca.
  - **Píxeles dobles:** `mainlev_build.png` está dibujado a 1:1 sobre una rejilla de 16 px. Se usa tal cual, como decía la ficha.
  - **Bordes de la roca:** el pack dibuja casi todos los remates sobresaliendo a la celda vecina. Solo se usan celdas macizas:
    - arriba, la franja clara bajo los remates (fila 40);
    - abajo, la de la fila 58;
    - a los lados, la roca con vetas claras, porque el pack no trae otro borde macizo;
    - lo que sobresale se queda fuera.
  - **Galería llena:** los pisos B y D no tenían sitio. Se añadió un **piso E** debajo del D (aprobado el 2026-11-15).
- **Atlas** `assets/terceros/pixelfantasy_caves/tileset_minas.png` (512x320), que arma `herramientas/constructor_mapas/atlas_minas.py`:
  - filas 0-15: el atlas de mazmorra sin cambios. `t`, `f`, `b`, `x`, `h`, `r` y `C` conservan sus piezas, y `DECOR_LIGHTS` les da luz sin entradas nuevas;
  - fila 16:
    - juego `minas` (0,16), con las 16 piezas macizas;
    - viga (4,16);
    - escalera de madera del Dungeon Tile Set (7,16);
    - pared `galeria` (8,16), de 6x4: el relleno de roca, que se repite sin costura, con el marco de postes y viga a la izquierda, al 60 %;
    - pared `ladrillo` (14,16), de 2x2, al 60 %;
    - `K` entibado 3x3 (16,16), `U` boca de galería 3x4 (19,16), `T` estalagmita 3x4 (22,16) e `y` estalactita 3x4 (25,16), que cuelga.

  Coordenadas en `assets/terceros/pixelfantasy_caves/ORIGEN.txt`. `mainlev_build.png` y `props1.png` vuelven a `assets/terceros/pixelfantasy_caves/`.
- **Tileset** `herramientas/constructor_mapas/tilesets/minas.gd`:
  - `bloques_por_defecto: minas` (sin rampas: quedan las de `madera`);
  - `plataformas`, `escalera`, `cofre` (`cofre_madera.tscn`) y `fondos` (`cueva`, `galeria` y `ladrillo`).

  El constructor no cambia.
- **Enemigos** (sin scripts nuevos; todos en la capa 5, con 0.5 de daño y 0.25 de contacto):

  | | Escena | Script | Vida | Detalle |
  |---|---|---|---|---|
  | Ojo volador `p` | `escenas/enemigos/ojo_volador.tscn` | `lunge_enemy.gd`, sin gravedad | 2 | Aleteo en `idle`, `move` y `attack`; avisa 0.3 s y embiste 0.35 s. Muere con el efecto `muerte` |
  | Sapo de la cueva `s` | `escenas/enemigos/sapo.tscn` | `enemy_base.gd` | 3 | `move` es `jump`; el lengüetazo golpea en el cuadro 2 de `attack` (caja de 28x14, 26 px por delante). Sin `hurt` ni `death`: muere con el efecto `muerte` |
  | Mimic `i` | `escenas/enemigos/mimic.tscn` | `rising_enemy.gd` | 4 | Duerme como cofre (capa 0, sin "E Abrir") y despierta a 48 px de lado y 40 de alto. `attack` es `attack_1`: se alza 0.65 s (aviso) y se lanza 0.3 s. Muere con `death` |

  - Hojas: `assets/terceros/super_grotto/ojo_volador.png`, `assets/terceros/gothicvania/personajes/sapo.png` y `assets/terceros/monster_creatures_2/mimic/mimic.png` (cuadros recortados a 84x46, sin cambiar el arte), anotadas en sus `ORIGEN.txt`.
  - Letras `p`, `s` e `i` en `COLORS` y `ENEMIES`, la paleta, LEYENDA (sección 5) y P33.
- **kolbo3:** `attack_damage` pasa de 0.60 a 0.5. La escena la comparten las minas y la mazmorra y la ruina de v1.
- **Galería:**
  - **piso E** (filas 100-118, hacia la izquierda), con el pozo desde el D a la derecha (columna 143) y un checkpoint. La zona de pruebas solo cambia en el piso E y en ese pozo;
  - cuarto "OJO, SAPO Y MIMIC": el ojo en el aire, el sapo en medio y el Mimic al fondo, junto a la pared;
  - cuarto "TILESET MINAS", con la muestra `zona_pruebas_muestra_minas`:
    - a la izquierda, la cueva sin pared, con techo, estalactita y estalagmita;
    - una columna colgada, una tira, una pieza suelta, la viga, cristales, hongos, el entibado y la boca sobre la pared `galeria`;
    - a la derecha, la pared `ladrillo`, con la escalera a una repisa y la antorcha.
- **Probado:**
  - capturas de los dos cuartos con el juego abierto;
  - prueba sin ventana con 45 comprobaciones bien:
    - los 76 bloques de la muestra son macizos y del juego `minas` (columna, tira y pieza suelta incluidas), y las 4 piezas de viga son de una vía;
    - el Player se apoya en la viga y en el suelo;
    - los 7 decorados y la escalera están en su pieza, y las tres paredes salen bien;
    - `MapAmbience` pone 3 luces (antorcha, cristales y hongos);
    - los tres enemigos siguen en su sitio a los 3 s;
    - el Mimic duerme en la capa 0 como cofre cerrado, rechaza golpes, a 60 px sigue dormido, a 40 despierta y se transforma;
    - los tres reciben golpes, dañan en múltiplos de 0.25 (el sapo quitó 1.5 al Player en 4 s) y mueren;
    - el kolbo3 hace 0.5;
  - arrancan sin errores el juego, la zona de pruebas, las `_combate` de las minas, el calabozo, el castillo y el cementerio, y la mazmorra de v1.
- **Al vestir, mirar:**
  - las tiras de una pieza de alto se ven como una fila de barriles, por las vetas verticales de la franja de arriba. En el ASCII de las minas casi no hay; si molestan, se arman con otra celda;
  - las `y` no pueden ir "en lugar de las estalactitas de bloque" de la veta (x 66-67 y 110-111): quitar esos bloques cambia celdas sólidas. Van al lado, o se pregunta antes;
  - una `y` cuelga 4 piezas: su letra va cuatro filas debajo del techo.

**Vestida (2026-11-15), falta jugarla a mano:**
- `mapas_texto/tiles_mineria.txt` pasa a `tileset: minas`, `bloques: minas` y `fondo: galeria`, con `fondo_sala`. El parallax de `pixelfantasy_caves` no cambia. Se regeneró la base `escenas/mapas/tiles_mineria.tscn`; la `_combate` no se tocó.
- **Paredes:**

  | Pared | Rectángulos (x0 y0 x1 y1) |
  |---|---|
  | `galeria` (el `fondo:`) | lo demás: galerías alta, de las vagonetas, de los mineros y honda, antecámara, túnel de `[L4]` y pozos |
  | `ladrillo` | estación del ascensor 8 30 32 40; sala del Caballero 4 74 35 86, con la columna de su puerta |
  | `ninguno` (el parallax) | bocamina 84 10 128 19; secreto de la Agilidad 129 9 141 14; veta 56 48 130 60; gruta de cristal 132 64 147 77, con la boca y el pasillo del fuego (131 52 146 55) y la bajada (144 56 146 63) |

  La boca, el pasillo y la bajada van con la gruta porque la cabecera del ASCII los cuenta como parte de ella.
- **Decorados nuevos** (sitio de abajo a la izquierda):

  | Letra | Sitios |
  |---|---|
  | `K` entibado | galería alta (49, 19) y (65, 19), bajo las vigas de bloque; vagonetas (40, 40), (61, 40) y (78, 40); mineros (22, 56); honda (65, 86) y (106, 86) |
  | `U` boca de galería | (81, 19), entre la bocamina y la galería alta; (36, 68), en la boca del túnel de `[L4]`, del lado de la antecámara |
  | `T` estalagmita | veta (65, 60) y (110, 60), bajo las estalactitas de bloque; gruta (143, 77) |
  | `y` estalactita | veta (68, 51) y (112, 51), al lado de las estalactitas de bloque, que se quedan; gruta (133, 67) y (140, 67) |

  - El túnel de `[L4]` mide 3 de alto y la boca 4: no cabe dentro, así que va en su boca.
  - Cumplen la regla de la cabecera del `.txt`, comprobada con un script sobre el ASCII: ninguno pisa una escalera, sus columnas vecinas ni sus tres filas de encima, un spawn, un cofre, una moneda, una poción, un enemigo, otro decorado ni los objetos de la `_combate`. Los de pie se apoyan en roca y las estalactitas cuelgan de ella.
- **Enemigos en el ASCII:**
  - salen los 10 murciélagos;
  - ojos voladores `p` en 6 de sus sitios: galería alta (60, 15), vagonetas (112, 36), sobre los fosos de lava (75, 53) y (99, 51), veta este (120, 52) y junto al pozo de `:D:` (136, 82);
  - sapos `s` en el suelo, bajo los otros 4: vagonetas (70, 40), mineros (21, 56) y honda (80, 86) y (110, 86);
  - Mimics `i`: al fondo oeste de la galería de los mineros (10, 56), a tres piezas del cofre de verdad de (7, 56), y al fondo de la cochera (129, 40). Los dos, fuera del camino obligatorio.

  Quedan 16 kolbos, 6 ojos, 4 sapos y 2 Mimics (28).
- **Colisiones:** iguales antes y después, 8316 piezas sólidas y 29 de una vía, con los mismos polígonos y la misma marca de una vía (`Terreno`, `Plataformas` y `Liquidos`), volcadas de la base con una escena temporal.
- **Prueba sin ventana** (5388 comprobaciones bien): cada celda sin bloque tiene su pared (2758 de `galeria`, 659 de `ladrillo` y 1767 sin pared); los 17 decorados nuevos están en su pieza del atlas; no queda ningún murciélago; a los 3 s los ojos y los sapos siguen en su sitio (se mecen o patrullan 5,5 px, los sapos en el suelo) y los Mimics duermen en la capa 0 sin moverse. `MapAmbience` pone 94 luces, sin fuentes nuevas.
- Capturas con el juego abierto de 14 salas: bocamina, galería alta, estación, vagonetas, cochera, mineros, veta oeste y este, túnel de `[L4]`, sala del Caballero, galería honda, gruta y secreto.
- Arrancan sin errores la `_combate` y el juego, y `verificar_mundo.py` da 0 errores. El Atlas se publicó de nuevo, con los nombres de `K`, `U`, `T` e `y` del tileset `minas` y de `p`, `s` e `i`.
- La luz ambiente de la `_combate`, (0.3, 0.28, 0.36), se queda hasta jugarla.
- **Al jugarla, mirar:**
  - las estalagmitas y las estalactitas se ven oscuras con esa luz ambiente;
  - el sapo de los mineros está junto al kolbo3 de (16, 56) y el Mimic: la galería tiene ahora tres enemigos y el cofre;
  - el Mimic de los mineros despierta al pasar hacia el cofre de verdad.
- **Falta, antes de marcarla vestida en `TASK.md`:** jugarla a mano.

### Mazmorra
- Parte de: tileset `mazmorra` con `bloques: oliva`, `fondo: ninguno` y el parallax de `gothicvania/castillo_viejo` (el interior del castillo viejo, con su vidriera) en toda la zona. Luz ambiente de la `_combate`: (0.44, 0.38, 0.56). En el ASCII, 5 Aprendis `a`, 2 mino `M`, 7 kolbo3 `q` y 6 esqueletos `e`; la Reina en la `_combate`.
- **Ficha aprobada el 2026-11-16.**
- **Por qué cambia** (capturas con el juego abierto de 12 salas de la `_combate`):
  - los bloques `oliva` son cuadros casi negros con un borde punteado: la roca se lee como un hueco, como la `madera` de las minas;
  - el parallax, con su vidriera en arco, sale igual en todas las salas, también en los desagües, la fosa y los pasillos de 4 de alto: celdas, torre y desagües no se distinguen;
  - las 72 plataformas `=` son tiras moradas del bloque y no se leen de una vía;
  - las 120 escaleras `H` apenas se ven.
- **Lo que no cuadraba** (hallado al armar la ficha):
  - los 7 kolbo3 ya salieron en las minas (4): con la regla de no repetir (P33), salen;
  - el esqueleto `e` y el esqueleto de tumba `u` del cementerio (13) usan la misma hoja (`gothicvania_cementerio/esqueleto.png`) y la misma embestida: para el jugador son el mismo esqueleto. El `e` cambia de arte (abajo). `esqueleto.tscn` la usan también la ruina de v1 y la zona de pruebas, que cambian con ella.

**Ambientación** (tileset nuevo `mazmorra_reina`, `herramientas/constructor_mapas/tilesets/mazmorra_reina.gd`, como `minas`: las filas 0-15 copian el atlas de mazmorra, por la antorcha, la lava, la fogata, la estantería, los hongos y los cristales, y debajo van piezas del tileset Old Dark Castle interior de la Legacy, el pack del parallax de hoy; un script `herramientas/constructor_mapas/atlas_mazmorra_reina.py` arma el atlas):
- **Escala:** el pack ya va en una rejilla de 16 px y se usa tal cual.
- **Bloques `mazmorra_reina`:** la piedra verde del pack, con el remate de musgo arriba. Solo celdas macizas: lo que sobresale a la celda vecina se queda fuera, como en las minas.
- **Plataformas `=`** (72): la pasarela de madera con cuerda del pack, con la clave `plataformas`. La colisión de una vía no cambia.
- **Escalera:** la de madera del Dungeon Tile Set, como en el calabozo y las minas.
- **Cofres `c`** (3): `cofre_madera.tscn` (el del Mimic), con la clave `cofre` del tileset.
- **Paredes**, con `fondo` y `fondo_sala` (los rectángulos exactos se fijan al vestir):

  | Pared | Arte | Dónde |
  |---|---|---|
  | `piedra` (nueva, el `fondo:` de la zona) | el ladrillo verde oscuro del pack, con su pilastra cada pocas columnas, como la del castillo | torre del alcaide, celdas altas y bajas, cuerpo de guardia, llegada, antesala y sala de tortura |
  | `cloaca` (nueva) | la misma piedra, oscurecida (entre el 45 y el 60 %) | desagües, fosa y huida, y los pozos de `:B:` y `:F:` |
  | `ninguno` | el parallax de hoy, con la vidriera | gran sala de guardia y sala de la Reina |

- **Decorados** (reutilizan letras, así que no hay colores nuevos; los tamaños se miden en el paso de piezas):

  | Letra | En `mazmorra_reina` | Dónde |
  |---|---|---|
  | `t`, `E`, `x`, `b`, `f`, `h`, `r` | se quedan: antorchas, estanterías, cajas, barriles, fogata, hongos y cristales | |
  | `g` | cadena del pack, unas 1x4, cuelga del techo | celdas, sala de tortura y antesala |
  | `U` | arco del desagüe del pack, unas 6x3 | desagües y fosa |
  | `w` | reja de celda de Raou, 2x2 (la `f` del calabozo y del castillo) | al fondo de las celdas altas y bajas |

  - Los decorados nuevos siguen la regla de la cabecera del `.txt`: ninguno pisa una escalera, sus columnas vecinas ni las tres filas de encima, un spawn ni otro decorado, ni los objetos de la `_combate`.
  - El agua `%` se queda como está.
- **Luces:** ninguna pieza nueva da luz; las antorchas ya la tienen en `DECOR_LIGHTS`. La luz ambiente se ajusta al vestir, solo en la `_combate`.

**Enemigos** (profundidad 3, criaturas y esqueletos):
- **Se quedan**, porque salen aquí por primera vez: Aprendis `a` (5) y mino `M` (2). La Reina sigue en la `_combate`.
- **Salen** los 7 kolbo3 `q` (ya en las minas).
- **Esqueleto `e`** (6), con arte nuevo: el Skeleton Sprite Pack de Jesse M, de 22x32, con `idle` 11, `walk` 13, `attack` 18 (tajo con espada), `hit` 8, `dead` 15 (se desarma) y `react` 4. Como trae golpe, pasa de `lunge_enemy.gd` a `enemy_base.gd`, con 3 de vida, 0.5 de daño y 0.25 de contacto. Cambia la misma `esqueleto.tscn`, así que el ASCII no cambia.
- **Nuevos** (letras y colores nuevos en `COLORS`, la paleta, LEYENDA y P33):

  | | Ogro `W` (criatura) | Calavera de fuego `X` (esqueleto) |
  |---|---|---|
  | Arte | `Ogre` de la Legacy, cuadros de 144x80 (la figura, unos 55x58): `idle` 4, `walk` 6 y `attack` 7, con la maza | `Fire-Skull` de la Legacy, 8 cuadros de 96x112 (unos 80x90 con las llamas) |
  | Script base | `enemy_base.gd`, golpe de maza hacia los cuadros 4-5. No trae daño ni muerte: muere con el efecto `muerte` | `lunge_enemy.gd`, sin gravedad, como el ojo volador. Muere con el efecto `muerte`. Su escena lleva una luz naranja pequeña |
  | Vida y daño | 4 de vida, 0.75 de daño (golpe lento y fuerte) y 0.25 de contacto | 2 de vida, 0.5 de daño y 0.25 de contacto |
  | Sitio | 4 de los sitios de los kolbo3, los de suelo: sala de tortura (16, 46), de verdugo junto al cofre; cuerpo de guardia (84, 68); celdas bajas (100, 48); celdas altas (92, 37) | los otros 3, en el aire: sobre la repisa alta (por el de (62, 21)), la torre (por el de (104, 21)) y los desagües (por el de (66, 65)) |

  - Los sitios exactos se fijan al vestir, con la regla de las escaleras.
  - Bajo los dinteles de las celdas bajas quedan 64 px de alto y el ogro mide unos 58: se comprueba en la galería.
  - Si la calavera con llamas estorba en los desagües, el pack trae una versión sin fuego, de 40x55.
  - Si `enemy_base.gd` o `lunge_enemy.gd` no sirven sin cambios, se pregunta antes de tocarlos o de hacer un script propio.
- Quedan 5 Aprendis, 2 mino, 6 esqueletos, 4 ogros y 3 calaveras (20, como antes).

**Origen del arte:**
- **Legacy Collection** (CC0, `Legacy Collection.zip` en Descargas): el tileset Old Dark Castle interior (bloques, pasarela, paredes, cadena y arco del desagüe) va a `assets/terceros/gothicvania/castillo_viejo/`, junto a su fondo; `Ogre` y `Fire-Skull`, a `assets/terceros/gothicvania/personajes/`. Se anotan en su `ORIGEN.txt`.
- **Skeleton Sprite Pack** de Jesse M (`Skeleton Sprite Pack.rar` en Descargas): a `assets/terceros/jesse_m_esqueleto/`, con su `ORIGEN.txt`.
- **Reja de celda:** la de Raou, ya en el repo.
- **Escalera:** la del Dungeon Tile Set, ya en el repo.
- Sin pack nuevo ni IA.
- **Licencias:** el RAR del esqueleto no trae licencia, y el Dungeon Tile Set y Raou siguen por confirmar antes de publicar (ver "Otros pendientes" de `TASK.md`). Se usan igual, como en las zonas de arriba.
- **Mirado y descartado:**
  - el tileset grunge de la Legacy: alambrada y puertas modernas;
  - el Gothic Castle de la Legacy: pocas piezas;
  - la puerta de madera del Old Dark Castle: parece que se abre;
  - el `enemy-ghost` de la Legacy: ya está el ánima;
  - el Terrible Knight de la Legacy: es una hoja de personaje jugable;
  - el Skeleton de Monster Creatures Fantasy 1.3: solo trae `Attack3`;
  - Hell-Hound, Hell-Beast, demon y Nightmare de la Legacy: demonios, de más abajo.

**Reto obligatorio:** coincide con su fila de P46, sección 10.
- Llega con el Golpe final, la Ráfaga y Rodar (E1 o E2; la Agilidad solo si encontró E3) y sale por `[!5]`, con el derrumbe tras la Reina.
- Los 3 ogros del camino obligatorio (cuerpo de guardia, celdas bajas y celdas altas) se vencen a espada.
- Ningún enemigo va en la llegada, la antesala, la sala de la Reina ni la huida.
- Ningún reto obligatorio pide E3, el dash ni una mejora de la tienda.
- Vestir no cambia celdas sólidas y las plataformas siguen siendo de una vía; se comprueba en el paso D.

**Piezas (hechas el 2026-11-16).** Decisiones aprobadas al pasar la ficha a piezas:
- **Lo que no cuadraba con la ficha** (hallado al mirar el arte):
  - **La piedra del pack** son losas redondeadas que sobresalen a la celda vecina. Las únicas celdas macizas son el remate de musgo de los pilares, su cuerpo de ladrillo oscuro y la piedra verde (10,6).
    - El ladrillo oscuro es igual de oscuro que la pared, (12,34,29) frente a (12,29,28), y la roca se leería como un hueco, el mismo problema de la `oliva` de hoy.
    - Por eso el juego usa el remate arriba y la piedra verde, el doble de clara, en todo lo demás. Se repite como un aparejo de bloques.
  - **La pasarela** es una sola pieza del puente del pack, con las tablas a 10 px de la fila 5. Se recorta desde el borde de las tablas, con su viga, y se repite. No trae cuerda.
  - **La cadena y el arco** vienen pintados sobre la pared lisa. Al ponerlos en el atlas, ese color plano pasa a transparente, para que sirvan sobre `cloaca`.
  - **El esqueleto** (aprobado el 2026-11-16) va **a escala 1**: mide 32 px de alto, algo menos que el Player, con los píxeles del mismo tamaño que el resto del arte.
  - **El ogro:** en los cuadros 2-4 la maza levantada llega a 72-76 px y asoma sobre un dintel de 64. El cuerpo, de 30x50, sí cabe.
- **Atlas** `assets/terceros/gothicvania/castillo_viejo/tileset_mazmorra_reina.png` (512x320), que arma `herramientas/constructor_mapas/atlas_mazmorra_reina.py`:
  - filas 0-15: el atlas de mazmorra sin cambios. `t`, `f`, `b`, `x`, `h`, `r` y `E` conservan sus piezas, y `DECOR_LIGHTS` les da luz sin entradas nuevas;
  - fila 16:
    - juego `mazmorra_reina` (0,16), con las 16 piezas macizas;
    - pasarela (4,16);
    - escalera de madera del Dungeon Tile Set (7,16);
    - pared `piedra` (8,16), de 6x4: la pilastra, sin cortes de arriba abajo, y cuatro columnas de pared lisa con su hilada de ladrillo;
    - pared `cloaca` (14,16): la misma, al 60 %;
    - `g` cadena 1x4 (20,16), que cuelga; `U` arco del desagüe 6x3 (21,16); `w` reja de celda de Raou 2x2 (27,16), copiada del atlas del castillo.

  El pack va tal cual en `castillo_viejo/tileset.png`. Las coordenadas están en `assets/terceros/gothicvania/ORIGEN.txt`.
- **Tileset** `herramientas/constructor_mapas/tilesets/mazmorra_reina.gd`:
  - `bloques_por_defecto: mazmorra_reina` (sin rampas: quedan las de `oliva`);
  - `plataformas`, `escalera`, `cofre` (`cofre_madera.tscn`) y `fondos` (`cueva`, `piedra` y `cloaca`).

  El constructor no cambia, salvo las letras nuevas.
- **Enemigos** (sin scripts nuevos; todos en la capa 5 y con 0.25 de contacto):

  | | Escena | Script | Vida | Daño | Detalle |
  |---|---|---|---|---|---|
  | Esqueleto `e` | `escenas/enemigos/esqueleto.tscn` (la misma) | `enemy_base.gd` | 3 | 0.5 | `idle`, `walk`, `attack` (18 cuadros a 14 fps; el tajo golpea en los cuadros 7-8), `hurt` y `death`. Se acerca a 24 px para que el hacha, de unos 27 px, alcance |
  | Ogro `W` | `escenas/enemigos/ogro.tscn` | `enemy_base.gd` | 4 | 0.75 | Mira a la izquierda; la maza golpea en los cuadros 4-5 (caja de 52x34, 38 px por delante y abajo), cada 1.8 s. Lento: patrulla a 20 y persigue a 40. Muere con el efecto `muerte` |
  | Calavera de fuego `X` | `escenas/enemigos/calavera_fuego.tscn` | `lunge_enemy.gd`, sin gravedad | 2 | 0.5 | La misma animación para `idle`, `move` y `attack`. Avisa 0.3 s y embiste 0.35 s desde 48 px; la caja (36x28) es más ancha que el cuerpo (24x24), como en los otros voladores, porque si no, el cuerpo choca con el del Player antes de tocarlo. Lleva un `PointLight2D` naranja. Muere con el efecto `muerte` |

  - Hojas: `assets/terceros/jesse_m_esqueleto/esqueleto.png` (las animaciones en un cuadro común de 58x38, alineadas por el centro del cuerpo y los pies, sin cambiar el arte), `assets/terceros/gothicvania/personajes/ogro.png` y `calavera_fuego.png`, anotadas en sus `ORIGEN.txt`.
  - Letras `W` (`507050`) y `X` (`ff5030`) en `COLORS` y `ENEMIES`, la paleta, LEYENDA (sección 5) y P33.
  - `esqueleto.tscn` la usan también la ruina y la mazmorra de v1 y la zona de pruebas. Sus pies quedan 7 px más arriba que los del esqueleto viejo: los esqueletos ya colocados caen al suelo y a los 3 s siguen en su sitio.
- **Galería, piso E**, zona "Mazmorra", a la izquierda de las minas (x 10-72). Quedan 8 columnas libres: la zona siguiente abre un piso F.
  - Cuarto "OGRO, CALAVERA Y ESQUELETO": el esqueleto junto a la escalera, el ogro bajo una losa a 4 piezas del suelo (los 64 px de los dinteles de las celdas bajas) y la calavera en el aire.
  - Cuarto "TILESET MAZMORRA", con la muestra `zona_pruebas_muestra_mazmorra_reina`:
    - a la izquierda, sin pared, con techo, una columna colgada, una tira, una pieza suelta y cristales;
    - en medio, la pared `cloaca`, con la cadena, el arco, una antorcha y hongos;
    - a la derecha, la pared `piedra`, con la reja, la estantería, la pasarela, la escalera a una repisa, otra antorcha, una caja y un barril.

  La zona de pruebas solo cambia en esos dos cuartos (x 10-72, filas 105-117).
- **Probado:**
  - capturas de los dos cuartos con el juego abierto;
  - prueba sin ventana con 727 comprobaciones bien:
    - los 85 bloques de la muestra son macizos y del juego `mazmorra_reina` (columna, tira y pieza suelta incluidas), y las 5 piezas de la pasarela son de una vía;
    - el Player se apoya en la pasarela y en el suelo;
    - los decorados y la escalera están en su pieza del atlas, y las tres paredes salen bien;
    - `MapAmbience` pone 4 luces (2 antorchas, hongos y cristales);
    - los tres enemigos siguen en su sitio a los 3 s y reciben golpes;
    - dañan lo suyo, en múltiplos de 0.25: el esqueleto 0.5, el ogro 0.75 y la calavera 0.5;
    - el ogro persigue al Player bajo la losa sin atascarse;
    - mueren (el esqueleto, con `death`) y se borran;
    - la calavera lleva su luz;
  - en la galería, los tres siguen en su sitio a los 3 s;
  - arrancan sin errores el juego, la zona de pruebas, las `_combate` del calabozo, el castillo, el cementerio, las minas y la mazmorra, y la ruina y la mazmorra de v1.
- **Al vestir, mirar:**
  - los ogros no van bajo un dintel, por la maza;
  - la calavera mide unos 85x88 con las llamas: en los desagües, de 6 de alto, puede estorbar (la ficha deja la versión sin fuego, de 40x55, si hace falta);
  - la reja de Raou es clara y brillante sobre la piedra oscura;
  - el remate de musgo repite su brillo cada pieza a lo largo de los suelos largos;
  - una `g` cuelga 4 piezas: su letra va cuatro filas debajo del techo.

**Vestida (2026-11-16), falta jugarla a mano:**
- `mapas_texto/tiles_mazmorra.txt` pasa a `tileset: mazmorra_reina`, `bloques: mazmorra_reina` y `fondo: piedra`, con `fondo_sala`. El parallax de `castillo_viejo` no cambia. Se regeneró la base `escenas/mapas/tiles_mazmorra.tscn`; la `_combate` no se tocó.
- **Paredes:**

  | Pared | Rectángulos (x0 y0 x1 y1) |
  |---|---|
  | `piedra` (el `fondo:`) | lo demás: torre del alcaide y secreto, celdas altas y bajas, cuerpo de guardia, llegada, antesala, sala de tortura y los huecos de las escaleras |
  | `cloaca` | desagües 36 51 45 56, 46 54 53 59, 54 57 61 62 y 62 60 71 65; pozo de `:B:` 70 0 72 11; hueco del colector 85 69 87 74; todo lo de abajo (fosa, huida, pozo de `:F:` y `[!5]`) 0 75 119 89 |
  | `ninguno` (el parallax) | gran sala de guardia 28 12 71 46; sala de la Reina 4 58 26 74 |

  - La gran sala llega a la columna 71, una más que la sala: así la pared de la torre y de las celdas altas empieza en la pilastra de las columnas 72-73 y no en un corte liso.
  - La fila 75, el suelo que se hunde, va con la fosa.
- **Decorados nuevos** (sitio de abajo a la izquierda):

  | Letra | Sitios |
  |---|---|
  | `w` reja de celda | celdas altas, una por celda: (86, 37), (90, 37), (96, 37), (101, 37), (107, 37) y (111, 37); celdas bajas, en las que no tienen antorcha: (81, 48), (85, 48), (93, 48) y (103, 48) |
  | `g` cadena | sala de tortura (8, 43), (13, 43), (17, 43) y (24, 43); antesala (11, 54) y (19, 54), a los lados de la trampilla de la Reina; celdas altas (82, 35) y (117, 35); celdas bajas (74, 47) y (111, 47) |
  | `U` arco del desagüe | desagües (54, 62), con la boca sobre el agua de x 55-58, y (66, 65), sobre la de x 68-70; fosa (6, 86) y (17, 86) |

  - Las rejas van a ras de suelo, como las `f` del castillo y del calabozo.
  - La huida sigue sin decorados, como pedía la cabecera del ASCII.
  - Cumplen la regla de la cabecera del `.txt`, comprobada con un script sobre el ASCII: ninguno pisa una escalera, sus columnas vecinas ni sus tres filas de encima, un spawn, un cofre, una moneda, una poción, un enemigo, otro decorado ni los objetos de la `_combate`. Los de pie se apoyan en roca y las cadenas cuelgan de ella.
- **Enemigos en el ASCII:**
  - salen los 7 kolbo3;
  - ogros `W` en 4 de sus sitios: sala de tortura (16, 46), cuerpo de guardia (84, 68), celdas altas (92, 37) y celdas bajas (98, 48). El de las celdas bajas pasa de la columna 100 a la 98, al centro de la celda, entre los dinteles de las columnas 96 y 101;
  - calaveras de fuego `X` en el aire, por los otros 3: sobre la repisa alta (62, 18), en la torre (104, 17) y en el último tramo de los desagües (67, 62);
  - los 5 Aprendis, los 2 mino y los 6 esqueletos no se mueven.

  Quedan 5 Aprendis, 2 mino, 6 esqueletos, 4 ogros y 3 calaveras (20, como antes).
- **Colisiones:** iguales antes y después, 5786 piezas sólidas y 72 de una vía, con los mismos polígonos y la misma marca de una vía (`Terreno`, `Plataformas` y `Liquidos`), volcadas de la base con una escena temporal.
- **Comprobado sobre la base** (volcado de sus capas contra el ASCII): las 10800 celdas llevan su pared (1929 sin bloque con `piedra`, 1191 con `cloaca` y 1894 sin pared); los 5786 bloques son del juego `mazmorra_reina` y las 72 piezas de plataforma, de la pasarela; los 24 decorados nuevos y las 120 piezas de escalera están en su pieza del atlas; los 3 cofres son `cofre_madera.tscn`.
- **Prueba sin ventana** de la `_combate` (115 comprobaciones bien): no queda ningún kolbo3; todos los enemigos van en la capa 5 y dañan en múltiplos de 0.25; a los 3 s los 20 siguen en su sitio (los ogros y las calaveras se mueven unos 5 px, y los de suelo siguen sobre el suelo); las 3 calaveras llevan su luz. `MapAmbience` pone 29 luces, sin fuentes nuevas.
- Capturas con el juego abierto de toda la zona, pantalla a pantalla, y de 13 salas con el Player dentro.
- Arrancan sin errores la `_combate`, el juego, las `_combate` de las minas y del calabozo y la zona de pruebas, y `verificar_mundo.py` da 0 errores. El Atlas se publicó de nuevo, con los nombres de `g`, `U` y `w` del tileset `mazmorra_reina` y de `W` y `X`.
- La luz ambiente de la `_combate`, (0.44, 0.38, 0.56), se queda hasta jugarla.
- **Al jugarla, mirar:**
  - **el suelo que se hunde** de la sala de la Reina (`Derrumbe`, en la `_combate`) sigue con su pieza morada por defecto y ahora destaca sobre el remate de musgo. Tiene `piece_texture` para darle la pieza del suelo nuevo; no se tocó porque al vestir la `_combate` solo cambia por las luces;
  - la calavera del último tramo de los desagües, con sus llamas (hasta unos 85x88), va en un túnel de 96 de alto: en la captura cabe sin salirse, pero casi lo tapa. Si estorba, la ficha deja la versión sin fuego del pack;
  - la maza del ogro de las celdas bajas asoma hasta 12 px sobre un dintel cuando golpea debajo de uno. De patrulla y parado, con 58 px de alto, pasa por debajo sin tocarlo;
  - la calavera de la repisa alta ve al Player al llegar del calabozo por `:B:` (está a 7 piezas del spawn, como antes el kolbo3);
  - la fosa y la huida no tienen antorchas y con la pared `cloaca` se ven muy oscuras fuera de la luz del Player; los arcos de la fosa apenas se distinguen hasta acercarse;
  - las cadenas son de un verde oscuro y se ven poco sobre la pared.
- **Falta, antes de marcarla vestida en `TASK.md`:** jugarla a mano.

### Ruina
- Parte de: tileset `mazmorra` con `bloques: ladrillo`, `fondo: ninguno` y el parallax de `gothicvania/cavernas` (`fondo.png` y `paredes.png`) en toda la zona. En el ASCII, 6 Aprendis `a`, 2 mino `M`, 7 kolbo3 `q` y 8 esqueletos `e`; el Guardián de hielo en la `_combate`.
- **Ficha aprobada el 2026-11-16.**
- **Por qué cambia** (leído de la cabecera de `mapas_texto/tiles_ruina.txt`, sin capturas):
  - el parallax de cuevas sale en todas las salas, también en la capilla, las criptas y las galerías de 6 de alto;
  - las 53 plataformas `=` son tiras del bloque `ladrillo` y las 177 escaleras `H` son las de mazmorra, que apenas se ven;
  - lo único que dice "helada" son los 18 cristales `r`.
- **Lo que no cuadraba** (hallado al armar la ficha):
  - los cuatro enemigos de la profundidad 4 de P33 ya salieron más arriba: `a`, `M` y `e` en la mazmorra y `q` en las minas. Con la regla de no repetir (P33) salen los 23;
  - no hay arte de hielo en ningún pack del repo, de `archivo/sin_uso/` ni de Descargas (Legacy, Super Grotto, Monsters Creatures Fantasy 2, PixelFantasy, crusher);
  - no queda arte de esqueleto que sirva: el de Super Grotto ya se descartó (cabezón) y Monster Creatures Fantasy 1.3 solo trae `Attack3`. La ficha pedía el esqueleto a la IA; en el paso de piezas se descartó la IA y el esqueleto salió de la ficha (abajo, "Piezas").

**Ambientación** (tileset nuevo `ruina`, `herramientas/constructor_mapas/tilesets/ruina.gd`, como `minas` y `mazmorra_reina`: las filas 0-15 copian el atlas de mazmorra, por la antorcha, la fogata, el agua, los cristales, los hongos, la estantería, la caja y el barril, y debajo van piezas de `caverns-files-web/layers/tiles.png` de la Legacy, el pack del parallax de hoy (`cavernas/paredes.png` es su `back-walls.png`); un script `herramientas/constructor_mapas/atlas_ruina.py` arma el atlas):
- **Escala:** el pack ya va en una rejilla de 16 px (512x288, 32x18 piezas) y se usa tal cual. Es una escena pintada, no un juego de piezas: se recortan las celdas que sirvan.
- **Bloques `ruina`:** el borde de cantos morados del pack (suelo con piedras, laterales y techo con flecos). Solo celdas macizas: lo que sobresale a la celda vecina se queda fuera, como en las minas.
  - El interior del pack es casi negro, del mismo color que el hueco de la cueva. Si en la galería la roca se lee como un hueco (lo de `oliva` y `madera`), el interior se arma con la textura de cantos de los laterales.
- **Plataformas `=`** (53): una tira del borde de cantos, con la clave `plataformas`. Si no se lee como repisa, la viga de madera del calabozo. La colisión de una vía no cambia.
- **Escalera:** la de madera del Dungeon Tile Set, como en el calabozo, las minas y la mazmorra.
- **Cofres `c`** (4): `cofre_madera.tscn` (el del Mimic), con la clave `cofre` del tileset.
- **Paredes**, con `fondo` y `fondo_sala` (los rectángulos exactos se fijan al vestir):

  | Pared | Arte | Dónde |
  |---|---|---|
  | `ruina` (nueva, el `fondo:` de la zona) | el muro de ladrillo roto de la banda central del pack | lo construido: llegada, torre caída, pasillo, galerías alta y baja, capilla, criptas y refugio, antesala, sala del Guardián, cámaras del deshielo y del hielo negro, secreto del dash y pozos |
  | `ninguno` | el parallax de hoy | lo natural: exterior helado, cumbre del viento, lago helado y pie del pozo `:D:` |

- **Decorados** (reutilizan letras, así que no hay colores nuevos; los tamaños se miden en el paso de piezas):

  | Letra | En `ruina` | Dónde |
  |---|---|---|
  | `t`, `r`, `x`, `b`, `h`, `E` | se quedan: antorchas, cristales (el hielo), cajas, barriles, hongos y estanterías | |
  | `V` | hornacina con llama rosa del pack, unas 2x2, da luz | galerías y capilla |
  | `U` | contrafuerte en arco del muro del pack, unas 3x4 | galerías alta y baja y antesala |
  | `n` | pedruscos caídos del pack | galerías y exterior |

  - El agua `%` del lago se queda como está. Las estalactitas de hielo del exterior son de bloque y se quedan.
  - Los decorados nuevos siguen la regla de la cabecera del `.txt`: ninguno pisa una escalera, sus columnas vecinas ni las tres filas de encima, un spawn ni otro decorado, ni los objetos de la `_combate`.
- **Luces:** la hornacina `V` va en `ATLAS_DECOR_LIGHTS`. La luz ambiente se ajusta al vestir, solo en la `_combate`.
- **Hielo** (aprobado el 2026-11-16: se prueban los dos): sin arte de hielo, el frío sale de:
  - una luz ambiente fría en la `_combate`, por ejemplo (0.40, 0.48, 0.62);
  - un tinte frío de las piezas del pack en `atlas_ruina.py` (un recoloreo, sin dibujar arte nuevo, como el 60 % de las paredes).

  En el paso de piezas la galería enseña las piezas con y sin tinte, y se elige con capturas. **Elegido (2026-11-16): el tinte de las piezas**; la luz ambiente fría se decide al vestir y jugar.

**Enemigos** (profundidad 4, criaturas y esqueletos):
- **Salen los 23:** 6 Aprendis `a`, 2 mino `M`, 7 kolbo3 `q` y 8 esqueletos `e`, porque ya salieron en la mazmorra y las minas. El Guardián sigue en la `_combate`.
- **Nuevos** (letras y colores nuevos en `COLORS`, la paleta, LEYENDA y P33; `J` y `Z` están libres):

  | | Lobo de la escarcha `J` (criatura) | Ave de las nieves `Z` (criatura) |
  |---|---|---|
  | Arte | `WereWolf` de la Legacy, cuadros de 96x76 (la figura, unos 60x40): `idle` 5, `run` 6, `jump` 2 y `fall` 2. No trae golpe, daño ni muerte | `flying-bird` de la Legacy, la versión blanca: 7 cuadros de 32x32 (la figura, unos 25x25) |
  | Script base | `lunge_enemy.gd` en el suelo: corre (`run`), avisa (`idle`) y salta sobre el Player (`jump` y `fall`). Muere con el efecto `muerte` | `lunge_enemy.gd`, sin gravedad, como el cuervo y el ojo volador. Muere con el efecto `muerte` |
  | Vida y daño | 3 de vida, 0.5 de daño y 0.25 de contacto. Rápido | 1.5 de vida, 0.5 de daño y 0.25 de contacto |
  | Sitio | los 9 de suelo de los kolbo3 y los mino: exterior (49, 15) y (72, 15), bajo la repisa de la cumbre (84, 18), lago (64, 23), galería alta (80, 33) y (144, 33), galería baja (14, 47) y su tramo alto (100, 45), cripta oscura (58, 64); y 4 de los esqueletos, en el suelo de las galerías: galería alta (20, 33) y (98, 33), galería baja (52, 47) y (125, 47) | los 6 del aire de los Aprendis: exterior (52, 9), cumbre (70, 6), torre (108, 13), galería alta (46, 30), galería baja (90, 44) y capilla (14, 59); y los otros 4 de los esqueletos, volando sobre su sitio: exterior (97, 21), cumbre (90, 5), pasillo (126, 17) y cripta oscura (36, 64) |

  - Los sitios exactos se fijan al vestir, con la regla de las escaleras. El lobo mide unas 2,5 piezas de alto: cabe en las galerías (6), el pasillo (5) y el lago (6).
  - Si `enemy_base.gd` o `lunge_enemy.gd` no sirven sin cambios, se pregunta antes de tocarlos o de hacer un script propio.
- **Esqueleto helado `Y`: quitado** (2026-11-16, al pasar a piezas). La ficha lo pedía a la IA, con su receta; se descartó la IA y no queda arte de esqueleto que sirva (Super Grotto, descartado; Monster Creatures Fantasy 1.3, solo `Attack3`; el fantasma y la Muerte de la Legacy ya son el ánima y el Barquero). Sus 8 sitios pasan a 4 lobos y 4 aves (en la tabla).
- Quedan 13 lobos y 10 aves (23, como antes).

**Origen del arte:**
- **Legacy Collection** (CC0, `Legacy Collection.zip` en Descargas): `caverns-files-web/layers/tiles.png` va a `assets/terceros/gothicvania/cavernas/`, junto a su fondo; `WereWolf` y `flying-bird`, a `assets/terceros/gothicvania/personajes/`. Se anotan en su `ORIGEN.txt`.
- **Escalera:** la del Dungeon Tile Set, ya en el repo.
- **Licencias:** el Dungeon Tile Set sigue por confirmar antes de publicar (ver "Otros pendientes" de `TASK.md`). Se usa igual, como en las zonas de arriba.
- **Mirado y descartado:**
  - el cangrejo, el slime, el fantasma y el lagarto de Super Grotto: de estilo tierno;
  - el meerman de la Legacy: solo trae 2 cuadros;
  - el crusher de unTied Games: mecánico, y su licencia pide créditos;
  - Rocky Pass y Rocky Tileset de la Legacy: desierto;
  - `cavesofgallet` y `lilspook` (Descargas): piezas de 8 px, de otro estilo;
  - los props de PixelFantasy Caves: árboles y rocas de bosque;
  - Hell-Hound, Nightmare y flying-eye-demon de la Legacy: demonios, de más abajo;
  - Gothicvania Cold Corridors de Ansimuz (gratis en itch.io): su página no dice la licencia ni habla de hielo. Queda como alternativa si se baja.

**Reto obligatorio:** coincide con su fila de P46, sección 10.
- Llega con la Ultimate (más Rodar, la Ráfaga y el Golpe final; la Agilidad solo si encontró E3) y sale por `[P6]`, con el Guardián vencido y la llama eterna.
- Los enemigos nuevos van en los sitios de hoy: ninguno en la llegada, el pie del pozo, la antesala, la sala del Guardián, las cámaras del deshielo y del hielo negro ni los secretos.
- Ningún reto obligatorio pide el dash, E4 ni una mejora de la tienda. Las zonas frías siguen sin mecánica: no son de esta ficha.
- Vestir no cambia celdas sólidas y las plataformas siguen siendo de una vía; se comprueba en el paso D.

**Piezas (hechas el 2026-11-16).** Decisiones aprobadas al pasar la ficha a piezas:
- **Sin IA:** el esqueleto helado `Y` sale de la ficha y sus 8 sitios se reparten entre lobos y aves (arriba, "Enemigos").
- **El salto del lobo es solo visual:** `lunge_enemy.gd` no cambia. Embiste a ras de suelo y su `attack` es el cuadro 0 de `idle` durante el aviso (0.3 s) y después `jump` y `fall`, durante la embestida (0.35 s). Así no se tira a un foso (`avoid_ledges`) ni se queda en una repisa.
- **El tinte:** se probaron en la galería las piezas tal cual y teñidas, con y sin una luz ambiente fría (0.40, 0.48, 0.62). Se eligió el tinte, sin luz; la luz ambiente se decide al vestir y jugar.
- **Lo que no cuadraba con la ficha** (hallado al mirar el arte):
  - **el muro del pack** (filas 6-8) es casi todo el mismo color plano que el interior de la roca, (25,14,27): con el interior del pack, la roca sería igual que la pared. Como preveía la ficha, el interior se arma con los cantos del lateral, al 55 %;
  - **las esquinas** de los cantos sobresalen a la celda vecina: toman el borde de arriba o el de abajo, como en las minas;
  - **el contrafuerte** mide 4x3 (la ficha decía unas 3x4): la banda del muro solo tiene 3 filas;
  - **los pedruscos** son lascas de roca de 1x2 que caen sobre el interior; la `n` junta dos, bajadas al borde de abajo, en 2x2.
- **Atlas** `assets/terceros/gothicvania/cavernas/tileset_ruina.png` (512x320), que arma `herramientas/constructor_mapas/atlas_ruina.py`:
  - filas 0-15: el atlas de mazmorra sin cambios. `t`, `f`, `b`, `x`, `h`, `r` y `E` conservan sus piezas, y `DECOR_LIGHTS` les da luz sin entradas nuevas;
  - fila 16, con las piezas del pack teñidas de frío (la llama de la hornacina conserva su rosa):
    - juego `ruina` (0,16), con las 16 piezas macizas;
    - repisa (4,16): la banda de piedras del suelo del pack, sin el negro de debajo;
    - escalera de madera del Dungeon Tile Set (7,16);
    - pared `ruina` (8,16), de 7x3: el muro de ladrillo roto, sin la hornacina ni los contrafuertes;
    - `V` hornacina con llama 2x2 (15,16), `U` contrafuerte 4x3 (17,16) y `n` pedruscos 2x2 (21,16), sin el color plano del muro.

  El pack va tal cual en `cavernas/tiles.png`. Las coordenadas están en `assets/terceros/gothicvania/ORIGEN.txt`.
- **Tileset** `herramientas/constructor_mapas/tilesets/ruina.gd`:
  - `bloques_por_defecto: ruina` (sin rampas: quedan las de `ladrillo`; la ruina no tiene);
  - `plataformas`, `escalera`, `cofre` (`cofre_madera.tscn`) y `fondos` (`cueva` y `ruina`).

  El constructor no cambia, salvo las letras nuevas.
- **Luz:** la hornacina (15,17) va en `ATLAS_DECOR_LIGHTS` de `scripts/environment/map_ambience.gd`, con una luz rosa que parpadea.
- **Enemigos** (sin scripts nuevos; los dos en la capa 5, con `lunge_enemy.gd` y 0.25 de contacto; miran a la derecha y mueren con el efecto `muerte`):

  | | Escena | Vida | Daño | Detalle |
  |---|---|---|---|---|
  | Lobo `J` | `escenas/enemigos/lobo_escarcha.tscn` | 3 | 0.5 | Patrulla a 45 y persigue a 110; avisa 0.3 s y embiste a 220 durante 0.35 s desde 64 px. Cuerpo de 36x28 con los pies en el borde; el dibujo está 8 px a la izquierda del centro del cuadro y se refleja alrededor del cuerpo (`mirror_sprite_on_flip`) |
  | Ave `Z` | `escenas/enemigos/ave_nieves.tscn` | 1.5 | 0.5 | Sin gravedad, `fly_toward_target`; la misma animación en `idle`, `move` y `attack`. Avisa 0.3 s y embiste a 170 desde 48 px; la caja (32x26) es más ancha que el cuerpo (20x18), como en los otros voladores |

  - Hojas: `assets/terceros/gothicvania/personajes/lobo_escarcha.png` y `ave_nieves.png`, anotadas en su `ORIGEN.txt`.
  - Letras `J` (`587898`) y `Z` (`e8f4f8`) en `COLORS` y `ENEMIES`, la paleta, LEYENDA (sección 5) y P33.
- **Galería, piso F nuevo** (filas 119-138), al que se baja por la izquierda del piso E (escalera de la columna 4), con su checkpoint en (6, 123). Zona "Ruina":
  - cuarto "LOBO Y AVE": el lobo sobre una repisa de 3 de alto y el ave en el aire;
  - cuarto "TILESET RUINA", con la muestra `zona_pruebas_muestra_ruina`: a la izquierda, sin pared, techo, una columna colgada, una tira, una pieza suelta, cristales y pedruscos; a la derecha, la pared `ruina` con la hornacina, el contrafuerte, la repisa, una antorcha, hongos, un barril, la escalera a una repisa y una caja.

  `muestra_tileset` de `galeria.py` admite ahora los pisos que van hacia la derecha (la escalera, a la izquierda del cuarto). La zona de pruebas pasa de 120 a 139 filas.
- **Probado:**
  - capturas de los dos cuartos con el juego abierto, y de las cuatro variantes del tinte;
  - prueba sin ventana con 620 comprobaciones bien:
    - los 85 bloques de la muestra son macizos, del juego `ruina` y con colisión, y las 4 piezas de la repisa son de una vía;
    - el Player se apoya en la repisa y en el suelo;
    - los decorados y la escalera están en su pieza del atlas, y la pared `ruina` cubre la derecha y no la parte sin pared;
    - `MapAmbience` pone 4 luces (antorcha, hongos, cristales y la hornacina rosa);
    - el lobo y el ave siguen en su sitio a los 3 s y reciben golpes;
    - el lobo persigue al Player hasta el borde de una repisa y no se tira;
    - dañan en múltiplos de 0.25 (al Player sin espada, 0.75 por golpe: los 0.5 más su 0.25 de más);
    - mueren y se borran;
    - en la galería, los dos siguen en su sitio a los 3 s, y el lobo sobre su repisa;
  - arrancan sin errores el juego, la zona de pruebas y las `_combate` del calabozo, el castillo, el cementerio, las minas, la mazmorra y la ruina; `verificar_mundo.py` da 0 errores.
- **Al vestir, mirar:**
  - la luz ambiente de la `_combate`: la fría (0.40, 0.48, 0.62) oscurecía mucho con el tinte; se prueba jugando;
  - el muro `ruina` es muy oscuro y casi liso, con pocas grietas: en las salas grandes puede verse plano;
  - la hornacina es pequeña y oscura fuera de su luz;
  - el lobo mide unos 57 px de largo y 39 de alto: en el pasillo (5 de alto) cabe, pero se comprueba con la regla de las escaleras;
  - las 4 aves nuevas van en el exterior, la cumbre, el pasillo y la cripta oscura: la de la cripta, dentro de la `dark_zone`.

**Vestida (2026-11-16), falta jugarla a mano:**
- `mapas_texto/tiles_ruina.txt` pasa a `tileset: ruina`, `bloques: ruina` y `fondo: ruina`, con `fondo_sala`. El parallax de `cavernas` no cambia. Se regeneró la base `escenas/mapas/tiles_ruina.tscn`; la `_combate` no se tocó.
- **Paredes:**

  | Pared | Rectángulos (x0 y0 x1 y1) |
  |---|---|
  | `ruina` (el `fondo:`) | lo demás: llegada, torre caída, pasillo, galerías alta y baja, capilla, criptas, refugio, antesala, sala del Guardián, cámaras del deshielo y del hielo negro, secreto del dash y los pozos de `[!5]`, del atajo, de `:E:` y de `[P6]` |
  | `ninguno` (el parallax) | exterior helado con la cumbre y el lago 24 2 103 24; pie del pozo `:D:` 136 10 152 17, con su pozo 146 0 148 9 y la bajada a la galería alta 150 18 152 27 |

  - El pozo de `:D:` y la bajada van con el pie del pozo porque la cabecera del ASCII los cuenta como parte de él, como la boca de la gruta de las minas.
  - Los pasos de la llegada al exterior (columna 23) y del exterior a la torre (columna 104) quedan con la pared `ruina`: están fuera del rectángulo del exterior de la cabecera.
- **Decorados nuevos** (sitio de abajo a la izquierda, todos apoyados en el suelo):

  | Letra | Sitios |
  |---|---|
  | `V` hornacina con llama | galería alta (14, 33), (52, 33) y (88, 33); galería baja (18, 47) y (64, 47); capilla (8, 64), junto al altar de la llama, y (27, 64) |
  | `U` contrafuerte | galería alta (66, 33), pasados los escombros, (104, 33) y (128, 33); galería baja (40, 47), pasado el foso, y (84, 47); antesala (102, 58) |
  | `n` pedruscos | galería alta (45, 33), pasado el foso, y (114, 33); galería baja (28, 47) y (112, 47); exterior (31, 12), (64, 15) y (95, 21) |

  - El contrafuerte de la antesala se probó primero en (103, 58), pero pisaba la caja de (106, 58).
  - Ninguno en la parte oscura (como las antorchas: la alumbra la llama) ni en el lago, la cumbre, los secretos o la sala del Guardián.
  - Cumplen la regla de la cabecera del `.txt`, comprobada con un script sobre el ASCII: ninguno pisa una escalera, sus columnas vecinas ni sus tres filas de encima, un spawn, un cofre, una moneda, una poción, un enemigo, otro decorado ni los objetos de la `_combate`, y todos se apoyan en roca.
- **Enemigos en el ASCII:**
  - salen los 6 Aprendis, los 2 mino, los 7 kolbo3 y los 8 esqueletos;
  - lobos `J` en el suelo, en los 9 sitios de los kolbo3 y los mino y en 4 de los esqueletos, los de la tabla de la ficha;
  - aves `Z` en el aire: en los 6 sitios de los Aprendis y, volando sobre los otros 4 esqueletos, dos o tres filas más arriba: exterior (97, 18), cumbre (90, 3), pasillo (126, 15) y cripta oscura (36, 61).

  Quedan 13 lobos y 10 aves (23, como antes). Ninguno a menos de 8 piezas de la P, los checkpoints o los spawns.
- **Colisiones:** iguales antes y después, 7157 polígonos sólidos y 53 de una vía, con los mismos polígonos y la misma marca de una vía (`Terreno`, `Plataformas` y `Liquidos`), volcadas de la base con una escena temporal.
- **Prueba sin ventana** (20377 comprobaciones bien):
  - sobre la base, contra el ASCII: cada celda lleva su pared (3961 sin bloque con `ruina` y 1362 sin pared); los bloques son del juego `ruina` y las 53 piezas de plataforma, de la repisa; los 20 decorados nuevos y las 177 piezas de escalera están en su pieza del atlas; los 4 cofres son `cofre_madera.tscn`;
  - en la `_combate`: solo hay lobos y aves (13 y 10), en la capa 5 y con daño y contacto en múltiplos de 0.25; a los 3 s siguen en su sitio (se mueven 1,5 px como mucho) y los lobos, sobre el suelo. `MapAmbience` pone 58 luces, 7 de ellas las rosas de las hornacinas.
- Capturas con el juego abierto de 22 sitios: llegada, exterior (tres), cumbre, lago, torre, pasillo, pie de `:D:`, galería alta (cuatro) y baja (tres), capilla, cripta oscura, antesala, sala del Guardián, cámara del deshielo y secreto del dash.
- Arrancan sin errores la `_combate`, el juego y la `_combate` de la mazmorra, y `verificar_mundo.py` da 0 errores. El Atlas se publicó de nuevo, con los nombres de `V`, `U` y `n` del tileset `ruina` y de `J` y `Z`, y el color de los bloques `ruina`.
- La luz ambiente de la `_combate` no se tocó: se decide jugándola (la fría, (0.40, 0.48, 0.62), oscurecía mucho con el tinte en la galería).
- **Al jugarla, mirar:**
  - la luz ambiente, con el tinte de las piezas;
  - los contrafuertes, oscuros sobre el muro: en las capturas se leen como siluetas;
  - el muro `ruina`, oscuro y casi liso en las salas grandes;
  - las aves del exterior, la cumbre y la torre, que ven al Player desde lejos a cielo abierto;
  - el lobo de (144, 33), en el camino desde `:D:`, junto al foso de pinchos de x 135-137 (antes, el kolbo3).
- **Falta, antes de marcarla vestida en `TASK.md`:** jugarla a mano.

**Nieve y escarcha (aprobado el 2026-11-16, tras vestirla):**
- **Por qué:** para que la ruina se sienta helada además de verse teñida de frío. Ningún pack del repo ni de Descargas trae nieve (solo un fondo de bosque con niebla en la Legacy), así que no hay arte: cada copo es un cuadrado de 1 o 2 px del juego. El usuario aprobó las tres propuestas y dejó elegir la forma que quedara mejor.
- **El exterior helado tiene techo** (filas 0-1 de roca): es una caverna, no un cielo abierto. Por eso no hay nevada general, sino escarcha que flota, nieve que cae de las grietas del techo y ventisca en las zonas frías.
- **Pieza:** `escenas/sistemas/clima_nieve.tscn`, con `scripts/environment/snow_area.gd` (`UnderkingdomSnowArea`). Es un rectángulo de piezas, como `dark_zone.gd`, sin letra en el constructor: va en la `_combate`, en el nodo `Clima`.
  - Tres tipos (`kind`):
    - `MOTES`, escarcha suspendida: nace en cualquier celda abierta, flota, baja unos 3 px/s y se apaga; las motas de 2 px brillan;
    - `FLAKES`, nieve que cae: nace arriba del rectángulo y cae a `fall_speed` (24 px/s), meciéndose;
    - `BLIZZARD`, ventisca: nace en el borde de donde sopla `wind` y cruza de lado; los copos pequeños son trazos de 2x1.
  - **No usa `CPUParticles2D`:** con el stretch `canvas_items` a 3x podrían quedar a medio píxel del juego. Los copos se mueven por script y se dibujan con `draw_rect` en posiciones enteras.
  - **No se pinta sobre la roca:** lee la capa `Terreno` del mapa, y un copo que entra en un bloque desaparece y renace. Así va delante del Player (`z_index` 4), bajo la oscuridad de `dark_zone` (50).
  - **Sin sombreado** (`unshaded`): con la luz ambiente de la `_combate` los copos se perdían en el azul; se eligió con capturas de las dos versiones.
  - **Fuera de pantalla** (`VisibleOnScreenNotifier2D`) no se mueve ni dibuja. El nodo no se oculta: oculto, el aviso de pantalla tampoco funcionaría.
- **En la ruina** (`Clima` de `tiles_ruina_combate.tscn`; rectángulos x, fila, ancho x alto):

  | Nodo | Tipo | Rectángulo | Copos |
  |---|---|---|---|
  | `EscarchaExterior` | escarcha | (24, 2), 80x23: exterior, cumbre y lago | 200 |
  | `EscarchaGaleriaAlta` | escarcha | (4, 28), 150x6 | 150 |
  | `EscarchaGaleriaBaja` | escarcha | (4, 36), 127x12, con el fondo este alto | 130 |
  | `EscarchaAntesala` | escarcha | (76, 53), 37x6 | 40 |
  | `NieveGrieta1`, `2` y `3` | nieve que cae | bajo los huecos del techo del exterior: (41, 2) 3x14, (48, 2) 4x14 y (56, 2) 4x22, que sigue por el hueco hasta el lago | 10, 12 y 16 |
  | `VentiscaCumbre` | ventisca, 85 px/s hacia el este | (66, 2), 38x10 | 110 |
  | `VentiscaLago` | ventisca, 45 px/s hacia el este | (50, 18), 21x6 | 45 |

  - Sin nieve en la parte oscura, la capilla, la sala del Guardián ni las cámaras.
- **Galería:** cuarto "NIEVE Y ESCARCHA" en el piso F, tras el del tileset (x 75-104, filas 124-136). Lleva los tres tipos y un pilar de roca de 3 de alto en la ventisca, para ver que los copos no se pintan sobre él. La zona de pruebas solo cambia en ese cuarto: 360 celdas que se vacían y las 3 del pilar.
- **Probado:**
  - prueba sin ventana, 17 comprobaciones bien en la galería y 47 en la ruina:
    - cada rectángulo empieza en una esquina de pieza y va delante del Player;
    - encuentra la roca de `Terreno`;
    - en 240 cuadros ningún copo queda en una celda de roca ni fuera de su rectángulo;
    - la escarcha baja a unos 3 px/s, la nieve cae a unos 24 y la ventisca cruza a 84 y 46;
    - fuera de pantalla no se mueve ni dibuja;
  - capturas con el juego abierto de la galería, el exterior con las grietas, la cumbre y la galería alta, con y sin sombreado;
  - arrancan sin errores el juego, la zona de pruebas y las `_combate` de la ruina y la mazmorra.
- **Al jugarla, mirar:** la densidad, sobre todo en el exterior (200 motas) y la cumbre (110 copos), y si la nieve delante del Player estorba en las peleas con los lobos y las aves. Si estorba, se baja `amount` o se pasa la pieza detrás (`z_index` -2).
- La pieza vale también para las profundidades (ceniza: otro `color` y `wind` hacia arriba), cuando se haga su ficha.

### Profundidades
- Parte de: tileset `mazmorra` con `bloques: oro`, `fondo: ninguno` y el parallax de `gothicvania/lava` (`fondo.png` y `rocas.png`) en toda la zona. En el ASCII, 22 diablillos `d`, todos en el aire; el Demon Slime en la `_combate`. Los minijefes de los altares se eligieron al montar la `_combate` (2026-11-17, P46 sección 7): la Pesadilla de ceniza, el Diablillo mayor y la Bestia infernal mayor, escenas heredadas de los demonios de la zona.
- **Ficha aprobada el 2026-11-17**, con la base generada y sin la `_combate` (parte 2 de la estructura). TASK.md deja armar la ficha antes; para vestir hace falta la `_combate` montada y jugada.
- **Por qué cambia** (capturas sin ventana de 12 sitios de la base):
  - los bloques `oro` son cuadros azul marino con un borde dorado punteado: la roca se lee como un hueco, como la `oliva` y la `madera`, y el azul no pega con la lava;
  - el parallax de lava, con su cascada, sale igual en la forja, la sala del Demon Slime, la galería y los pasillos;
  - las plataformas `=` son tiras del bloque y las escaleras `H` apenas se ven.
- **Lo que no cuadraba** (hallado al armar la ficha):
  - los minijefes que propone P46 (sección 7) para el coliseo y el santuario son el demonslime común (`demonslime.tscn`), el mismo arte que el Demon Slime, el jefe de la zona: se pelearía tres veces contra el mismo. No es de esta ficha (se eligen en la estructura); abajo, "Para los minijefes", queda el arte que hay;
  - los 22 enemigos son diablillos que vuelan: no hay ninguno de suelo.

**Ambientación** (tileset nuevo `profundidades`, `herramientas/constructor_mapas/tilesets/profundidades.gd`, como `ruina`: las filas 0-15 copian el atlas de mazmorra, por la lava animada, la antorcha, la fogata, los cristales, la caja y el barril, y debajo van piezas de `cavernas/tiles.png` de la Legacy, ya en el repo; un script `herramientas/constructor_mapas/atlas_profundidades.py` arma el atlas):
- **Roca sin tinte:** los cantos de Caverns en su morado original, el mismo de las rocas del parallax de lava (maqueta sobre el parallax, con y sin un tinte de brasa: el tinte quedaba pardo y apagado). La ruina usa las mismas formas teñidas de frío; se distinguen por el color.
  - **Living Tissue** de la Legacy (carne con colmillos) se miró y se guarda para el infierno (Cthulhu); se decide en su ficha.
- **Bloques `profundidades`:** solo celdas macizas, con el interior armado con los cantos del lateral, como en la ruina.
- **Plataformas `=`:** la repisa de piedras del pack, con la clave `plataformas`. La colisión de una vía no cambia.
- **Escalera:** la de madera del Dungeon Tile Set, como en las zonas de arriba.
- **Cofres `c`** (5): `cofre_madera.tscn`, con la clave `cofre` del tileset.
- **Lava `~`:** la animada de hoy. El `lava-tile.png` de la Legacy casa con el parallax pero no está animado.
- **Paredes**, con `fondo` y `fondo_sala` (los rectángulos exactos se fijan al vestir):

  | Pared | Arte | Dónde |
  |---|---|---|
  | `basalto` (nueva, el `fondo:` de la zona) | el interior de los cantos, oscurecido | galería de los condenados, pie de `:E:`, llegada, paso de la chimenea, túnel, encrucijada, antesala y pozos |
  | `ladrillo` (nueva) | el ladrillo de Gothic Horror, teñido de rojo oscuro | lo construido: forja, coliseo de ceniza, sala del Demon Slime y cámara del altar del fuego |
  | `ninguno` | el parallax de lava | lo abierto: gran caverna, lago de magma, chimenea de azufre y puente de ceniza |

- **Decorados** (reutilizan letras, así que no hay colores nuevos; los tamaños se miden en el paso de piezas):

  | Letra | En `profundidades` | Dónde |
  |---|---|---|
  | `t`, `r`, `f`, `x`, `b` | se quedan: antorchas, cristales (las ascuas), fogatas, cajas y barriles | |
  | `V` | horno: el nicho con llama y chimenea de Gothic Horror, teñido de rojo, unas 2x4, da luz | forja |
  | `U` | arco con cara de demonio de Gothic Horror, teñido de rojo, unas 2x3 | coliseo, santuario de las llamas y sala del Demon Slime |
  | `n` | montón de huesos de Gothic Horror, unas 2x2 | galería de los condenados, puente de huesos y coliseo |

  - `V` y `U` ya salen en el cementerio; aquí van teñidos de rojo.
  - Los decorados nuevos siguen la regla de la cabecera del `.txt`: ninguno pisa una escalera, sus columnas vecinas ni las tres filas de encima, un spawn ni otro decorado, ni los objetos de la `_combate` (altares, palancas, E5, restos y página II).
- **Luces:** el horno `V` va en `ATLAS_DECOR_LIGHTS`, con luz naranja. La luz ambiente se ajusta al vestir, solo en la `_combate`.

**Enemigos** (profundidad 5, demonios):
- **Se queda el diablillo `d`**, que no sale en ninguna zona de arriba: 13, en el aire. Puente de ceniza (152, 9) y (163, 9); sobre la cornisa (147, 22); coliseo (16, 34) y (34, 34); forja (20, 71) y (46, 71), que guardan E5; lago (148, 49) y (170, 47); chimenea (208, 33), (216, 47) y (206, 60); pasillo del fuego (184, 76).
- **Nuevos** (letras y colores nuevos en `COLORS`, la paleta, LEYENDA y P33; `I` e `Y` están libres, la `Y` desde que se quitó el esqueleto helado):

  | | Bestia infernal `I` | Pesadilla `Y` |
  |---|---|---|
  | Arte | `Hell-Beast` de la Legacy, cuadros de 80x160 (la figura, unos 44x60): `idle` 6, `breath` 4 (escupe fuego) y `burn` 6 | `Nightmare` de la Legacy, caballo negro con llamas azules, cuadros de 160x96 (la figura, unos 112x71): `idle` 4 y `run` 4 |
  | Script base | `ranged_demon.gd` con gravedad: una torreta en el suelo, casi quieta, que dispara la bola de fuego del diablillo. Muere con `burn` si se lee como muerte; si no, con el efecto `muerte` | `lunge_enemy.gd` en el suelo: patrulla al paso, avisa y embiste lejos y rápido. Es más alta de lo que se salta: se esquiva rodando (se comprueba en el paso de piezas). Muere con el efecto `muerte` |
  | Vida y daño | 3 de vida, 0.5 por bola y 0.25 de contacto | 4 de vida, 0.75 de daño y 0.25 de contacto |
  | Sitio | 6, bajados al suelo desde sitios de diablillos: galería de los condenados (28, 25) y (72, 25); cornisa de la caverna (108, 25) y (178, 25), sobre la roca, que disparan al puente colgante; encrucijada, 2 en el suelo (fila 60), bajo (93, 54) y (118, 54) | 3 en el suelo del puente de huesos (fila 37), por los diablillos de (130, 32), (160, 31) y (186, 33): en medio de los tramos entre las pozas de lava, lejos de las escaleras 100, 194 y 196 |

  - Los sitios exactos se fijan al vestir, con la regla de las escaleras. Ninguno en la llegada, el pie de `:E:`, la antesala, la sala del Demon Slime, el pozo de `[S7]` ni el secreto, ni a menos de 8 piezas de la P, los checkpoints o los spawns.
  - La pesadilla (71 px) no cabe en el pasillo del fuego (4 de alto), que se queda con su diablillo. Los enemigos no pisan plataformas `=`: en la chimenea siguen los diablillos.
  - Si `ranged_demon.gd` o `lunge_enemy.gd` no sirven sin cambios, se pregunta antes de tocarlos o de hacer un script propio.
- Quedan 13 diablillos, 6 bestias y 3 pesadillas (22, como antes).
- **Para los minijefes** (no es de esta ficha; se eligen en la estructura): el demonio alado de la Legacy (`demon`, la figura de unos 134x124, con `idle` 6 y ataque con aliento de fuego) cabría con `simple_boss.gd`, y la bestia infernal a escala 2 podría ir en lugar del diablillo mayor del lago.

**Origen del arte:**
- **Legacy Collection** (CC0, `Legacy Collection.zip` en Descargas): `Hell-Beast` y `Nightmare` van a `assets/terceros/gothicvania/personajes/`; `cavernas/tiles.png` y `gothic_horror/tiles.png` ya están en el repo. Se anotan en su `ORIGEN.txt`.
- **Escalera:** la del Dungeon Tile Set, ya en el repo.
- Sin pack nuevo ni IA, y sin licencias nuevas por confirmar (el Dungeon Tile Set sigue pendiente, como en las zonas de arriba).
- **Mirado y descartado:**
  - Hell-Hound de la Legacy y el hell-gato del Cemetery: embisten a ras de suelo, como el lobo de la ruina;
  - `flying-eye-demon` de la Legacy: es casi el ojo volador de las minas;
  - el `demon` de la Legacy como enemigo común: es del tamaño de un jefe;
  - Rocky Tileset (playa), Modular tileset (casa oriental) y Gothic Castle de la Legacy, y el tileset de Super Grotto (azul, de estilo tierno);
  - el tinte de brasa sobre los cantos de Caverns: pardo y apagado frente al parallax.
- **Fuera de la ficha:** `Red Fire Trap`, en `archivo/sin_uso/assets/`, podría servir de arte al fuego infernal (P61, falta su arte), que va en la `_combate`.

**Reto obligatorio:** coincide con su fila de P46, sección 10.
- Llega con la llama eterna y el dash, más la Ultimate, Rodar, la Ráfaga y el Golpe final (la Agilidad solo si encontró E3; E4 si lo encontró), y sale por `[S7]`, con los tres altares y el Demon Slime.
- La pesadilla se esquiva rodando, que el jugador ya tiene; la bestia se vence a espada.
- Ningún reto obligatorio pide el dash, la Agilidad, E4 ni una mejora de la tienda.
- Vestir no cambia celdas sólidas y las plataformas siguen siendo de una vía; se comprueba en el paso D.

**Piezas (hechas el 2026-11-17).** Decisiones aprobadas al pasar la ficha a piezas:
- **Galería:** con la ruina, al piso F solo le quedaban 36 columnas libres. Las profundidades abren el **piso G** con sus dos cuartos.
- **Horno `V`** con su chimenea, **2x6** (la ficha decía unas 2x4); cabe en la forja, de 13 de alto.
- **Huesos `n`:** el **montón de calaveras 2x3**, sin fondo (la ficha decía unas 2x2; el panel de calaveras 2x2 del cementerio es opaco y sobre el basalto se vería como un cuadro oscuro).
- **Muerte de la bestia:** `burn` del cuadro 1 al 4 (se envuelve en llamas y queda en silueta), sin los cuadros 5-6, una columna de fuego de 160 px que atravesaría techos. Se miró en captura y se lee como muerte.
- **`ranged_demon.gd` no servía sin cambios** (aprobado cambiarlo): apuntaba siempre 8 px sobre el origen del Player, que está 62 px por encima de sus pies, así que la bola pasaba sobre la cabeza de un Player de pie. Desde el aire (el diablillo) da igual; desde el suelo, no. Nuevo export `projectile_target_offset`, con el valor de antes, (0, -8), por defecto, así que el diablillo no cambia; la bestia apunta al torso, (0, 30).
- **Lo que no cuadraba con la ficha** (hallado al mirar el arte):
  - el `run` de la pesadilla tiene 3 cuadros, no 4;
  - la fachada de Gothic Horror tiene musgo en casi todas sus piezas: solo la fila 7 está entera sin él, así que la pared `ladrillo` es de 7x2, con piezas de esa fila en dos órdenes;
  - la llama del horno es amarilla y verdosa en el pack: se recolorea a una rampa naranja, sin repintar.
- **Atlas** `assets/terceros/gothicvania/lava/tileset_profundidades.png` (512x352), que arma `herramientas/constructor_mapas/atlas_profundidades.py`:
  - filas 0-15: el atlas de mazmorra sin cambios (lava animada, antorcha, fogata, cristales, caja y barril, con sus luces de `DECOR_LIGHTS`);
  - filas 16-21:
    - juego `profundidades` (0,16), el mismo armado que el de la ruina, sin el tinte frío, con las 16 piezas macizas;
    - repisa (4,16) y escalera de madera (7,16);
    - pared `basalto` (8,16), 2x4: los cantos de los laterales al 32 %, más oscuros que el interior de la roca (55 %);
    - pared `ladrillo` (10,16), 7x2, teñida de rojo;
    - `V` horno 2x6 (17,16), `U` arco con cara de demonio 2x3 (19,16), los dos teñidos de rojo, y `n` montón de calaveras 2x3 (21,16), tal cual.

  Coordenadas y recortes en `assets/terceros/gothicvania/ORIGEN.txt`.
- **Tileset** `herramientas/constructor_mapas/tilesets/profundidades.gd`:
  - `bloques_por_defecto: profundidades` (sin rampas: quedan las de `ladrillo`; las profundidades no tienen);
  - `plataformas`, `escalera`, `cofre` (`cofre_madera.tscn`) y `fondos` (`cueva`, `basalto` y `ladrillo`);
  - decorados `t`, `f`, `b`, `x` y `r` como en mazmorra, y `V`, `U` y `n` nuevos.

  El constructor no cambia, salvo las letras nuevas.
- **Luz:** la llama del horno (17,20) va en `ATLAS_DECOR_LIGHTS` de `scripts/environment/map_ambience.gd`, con una luz naranja que parpadea.
- **Enemigos** (los dos en la capa 5, con 0.25 de contacto y mirando a la izquierda):

  | | Escena | Vida | Daño | Detalle |
  |---|---|---|---|---|
  | Bestia `I` | `escenas/enemigos/bestia_infernal.tscn` | 3 | bola de 0.5 | `ranged_demon.gd` con gravedad. Casi quieta: patrulla 16 px a 15 y persigue a 20. Desde 170 px escupe (`attack` = `breath`) cada 2 s; la bola sale en el cuadro 3, 24 px por delante (fuera de su cuerpo: el proyectil se destruye contra cualquier cuerpo) y apunta al torso. Cuerpo de 28x52 |
  | Pesadilla `Y` | `escenas/enemigos/pesadilla.tscn` | 4 | 0.75 | `lunge_enemy.gd` con gravedad. Patrulla 80 px a 40 y persigue a 90; desde 110 px avisa 0.45 s y embiste a 260 durante 0.5 s (unas 8 piezas). Cuerpo de 64x52; `ledge_check_forward` 34, para que el borde se mire desde su pecho y no desde el centro |

  - Hojas `assets/terceros/gothicvania/personajes/bestia_infernal.png` (cuadros de 80x72) y `pesadilla.png` (160x96).
  - Letras `I` (`e04020`) y `Y` (`203040`) en `COLORS` y `ENEMIES`, la paleta, LEYENDA (sección 5) y P33.
- **Galería, piso G nuevo** (filas 138-157), al que se baja por la derecha del piso F (escalera de la columna 143), con su checkpoint en (141, 142). La zona de pruebas pasa de 139 a 158 filas; del resto solo cambia el pozo de la bajada (x 142-144, filas 124-137). Zona "Profundidades":
  - cuarto "BESTIA Y PESADILLA": la bestia sobre una repisa de 3 de alto y la pesadilla en el suelo;
  - cuarto "TILESET PROFUNDIDADES", con la muestra `zona_pruebas_muestra_profundidades`:
    - a la izquierda, sin pared (en el mapa, el parallax), techo, una columna colgada, una tira, una pieza suelta y cristales;
    - en medio, el ladrillo, con el horno, el arco y una antorcha;
    - a la derecha, el basalto, con las calaveras, la repisa, un barril, la escalera a una repisa y una caja.
- **Probado:**
  - capturas con el juego abierto de los dos cuartos y de la muerte de la bestia;
  - prueba sin ventana con 668 comprobaciones bien:
    - los 85 bloques de la muestra son macizos, del juego `profundidades` y con colisión, y las 4 piezas de la repisa son de una vía;
    - el Player se apoya en la repisa y en el suelo;
    - los decorados y la escalera están en su pieza del atlas, y cada celda lleva su pared (sin pared, ladrillo o basalto);
    - `MapAmbience` pone la luz naranja del horno;
    - los dos enemigos siguen en su sitio a los 3 s y reciben golpes;
    - la bestia escupe una bola que daña 0.5 al Player de pie, también desde una repisa de 3 con el Player abajo a 80 y a 140 px; muere con `death` y se borra;
    - la pesadilla embiste con 0.75 y no se tira de una repisa: se para con el centro 30 px antes del borde;
    - rodando a través de la embestida al acabar el aviso no recibe daño y acaba al otro lado. Saltando en el sitio la recibe (0.75 más 0.25 de contacto): se esquiva rodando, como pedía la ficha;
    - en la galería, los dos siguen en su sitio a los 3 s, dentro de su patrulla;
  - arrancan sin errores el juego, la zona de pruebas, la base de las profundidades (sus 22 diablillos usan `ranged_demon.gd`) y las `_combate` del calabozo, el castillo, el cementerio, las minas, la mazmorra y la ruina; `verificar_mundo.py` da 0 errores.
- **Al vestir, mirar:**
  - el basalto repite sus dos columnas de cantos: en las salas grandes puede verse a rayas;
  - la bestia de la cornisa dispara al puente colgante, a su altura; y los dos de la encrucijada, a su suelo;
  - la pesadilla mide 64 px de largo: en el puente de huesos, entre pozas de 3, se para en el borde, y el tramo tiene que dejarle sitio para embestir;
  - en la `_combate` (la de la forja), la luz del horno junto a la de la lava.

**Vestida (2026-11-17), falta jugarla a mano:**
- `mapas_texto/tiles_profundidades.txt` pasa a `tileset: profundidades`, `bloques: profundidades` y `fondo: basalto`, con `fondo_sala`. El parallax de lava no cambia. Se regeneró la base `escenas/mapas/tiles_profundidades.tscn`.
- **Paredes:**

  | Pared | Rectángulos (x0 y0 x1 y1) |
  |---|---|
  | `basalto` (el `fondo:`) | lo demás: galería de los condenados, pie de `:E:`, llegada, paso de la chimenea, túnel, antesala, encrucijada, pasillo del fuego y los pozos (`:F:`, `[S7]`, el atajo, las escaleras 100 y 194 y el de la trampilla de la sala) |
  | `ladrillo` | coliseo 4 30 44 44; forja 4 66 55 78; sala del Demon Slime 90 70 111 78; cámara del altar del fuego 160 69 167 78 |
  | `ninguno` (el parallax) | puente de ceniza con su foso 141 6 167 16; gran caverna 95 19 198 37, con su salida este a la chimenea 199 21 200 25; lago de magma 126 46 196 60; chimenea de azufre con su boca 201 14 229 78 |

  - El pasillo del fuego (x 168-200, filas 75-78) no sale en la tabla de la ficha: se queda con el basalto, y solo la cámara del altar lleva ladrillo.
  - El puente de ceniza no tiene pared hacia la llegada ni hacia el pie de `:E:`: el parallax acaba en un corte recto en el aire, en las columnas 141 y 168, como el exterior de la ruina.
- **Enemigos en el ASCII:**
  - salen 9 diablillos y quedan 13, los de la ficha;
  - bestias `I` en el suelo, bajo los diablillos que salen: galería (28, 25) y (72, 25), cornisa (108, 25) y (178, 25), sobre la roca, y encrucijada (93, 60) y (118, 60);
  - pesadillas `Y` en el puente de huesos, en medio de cada tramo entre pozas (de 27, 27 y 15 piezas): (131, 37), (161, 37) y (185, 37).

  - el diablillo del pasillo del fuego pasa de (184, 76) a (172, 76) (aprobado el 2026-11-17): estaba antes que la `_combate`, encima del sitio oeste de la Bestia infernal mayor, `JefePasilloOeste` (184, 76). Ahora queda entre la chimenea y el altar, a 12 piezas de ese sitio y en el aire del pasillo, con 3 piezas libres a cada lado.

  Quedan 13 diablillos, 6 bestias y 3 pesadillas (22, como antes). Ninguno a menos de 8 piezas de la P, los checkpoints o los spawns.
- **Decorados nuevos** (sitio de abajo a la izquierda, todos apoyados en el suelo):

  | Letra | Sitios |
  |---|---|
  | `V` horno | forja (24, 78) y (33, 78), a los lados del yunque de E5 y sin pisar la plataforma de x 26-31 |
  | `U` arco con cara de demonio | coliseo (15, 44) y (31, 44), bajo las plataformas de la fila 41; sala del Demon Slime (96, 78) y (104, 78), a los lados del `PuntoLlave`; cámara del altar del fuego (160, 78) y (166, 78), a los lados del altar |
  | `n` calaveras | galería (33, 25), (58, 25) y (90, 25); puente de huesos (109, 37), (139, 37) y (169, 37); coliseo (5, 44) |

  - Cumplen la regla de la cabecera del `.txt`, comprobada con un script sobre el ASCII: ninguno pisa una escalera, sus columnas vecinas ni sus tres filas de encima, un spawn, un cofre, una moneda, una poción, un enemigo, otro decorado ni los objetos de la `_combate` (altares, palancas, E5, restos, página II, alma, fragmento, puntos de los jefes, oleadas del coliseo y `PuntoLlave`), y todos se apoyan en roca.
  - **Excepción:** el fuego infernal del santuario cubre todo el suelo de la cámara salvo el altar, así que los dos arcos de la cámara quedan detrás de él (el decorado va en z -1 y el fuego, en z 0). Se ve en la captura.
- **Colisiones:** iguales antes y después, 10817 polígonos sólidos y 108 de una vía, con los mismos polígonos y la misma marca de una vía (`Terreno` y `Plataformas`; `Liquidos` no tiene colisión), volcadas de la base con una escena temporal.
- **Luz (la `_combate`):** no tenía `MapAmbience`, así que el horno no daba luz. Se le añade el nodo `Ambientacion` (`map_ambience.gd`), como en la ruina: luz ambiente (0.62, 0.5, 0.5), luz del Player (1, 0.9, 0.85) y viñeta 0.55. Se eligió con capturas frente a una más oscura, (0.5, 0.4, 0.46), con la que el basalto de la galería y la llegada se perdía. `MapAmbience` pone 57 luces, entre ellas las 2 de los hornos y las de la lava.
- **Prueba sin ventana** (20441 comprobaciones bien):
  - sobre la base, contra el ASCII: cada celda lleva su pared (2434 sin bloque con basalto, 1565 con ladrillo y 4819 sin pared); los 10817 bloques son del juego `profundidades`; las 108 piezas de plataforma son de la repisa y de una vía; las 338 piezas de escalera y los 15 decorados nuevos están en su pieza del atlas; los 5 cofres son `cofre_madera.tscn`;
  - en la `_combate`: 13 diablillos, 6 bestias y 3 pesadillas, en la capa 5 y con daño y contacto en múltiplos de 0.25; a los 3 s siguen en su sitio, dentro de su patrulla, y las bestias y las pesadillas, sobre el suelo; las luces de los dos hornos están en su llama.
- Capturas con el juego abierto de 16 sitios: llegada, puente de ceniza, pie de `:E:`, galería (dos), coliseo, forja, caverna, cornisa este, encrucijada, lago, isla, chimenea, santuario, sala del Demon Slime y antesala.
- Arrancan sin errores la `_combate` y el juego, y `verificar_mundo.py` da 0 errores. El Atlas se publicó de nuevo, con los nombres de `r`, `V`, `U` y `n` del tileset `profundidades`, los de `I` e `Y` y el color de los bloques `profundidades`.
- **Al jugarla, mirar:**
  - la luz ambiente, (0.62, 0.5, 0.5);
  - las bestias de la cornisa, que disparan al puente colgante, y las dos de la encrucijada;
  - las pesadillas del puente de huesos: cada tramo les deja sitio para embestir, pero el de (185, 37) es el más corto (15 piezas, entre la poza de x 175-177 y la escalera 194);
  - el corte del parallax en el puente de ceniza;
  - la pared agrietada del secreto, que se lee como roca: la delata solo la franja de techo de encima.
- **Pared agrietada** (P48 y TASK.md la dejaban para este paso; aprobada el 2026-11-17 al acabar de vestir): `escenas/objetos/pared_agrietada_profundidades.tscn`, heredada, con la roca del tileset (la columna del juego de bloques, 1x3, en (23,16) del atlas). La `_combate` la instancia en lugar de la de siempre. Detalle y prueba en P48, sección 7.
- **Colisiones** tras mover el diablillo y añadir la pieza al atlas: las mismas que antes de vestir.

### Infierno
- Parte de: tileset `mazmorra` con `bloques: ladrillo`, `fondo: ninguno` y el parallax de `gothicvania/lava` en toda la zona (el mismo de las profundidades, justo encima). En el ASCII, 36 enemigos: 19 diablillos `d`, 7 murciélagos `m`, 3 mino `M`, 3 Guardias `G`, 2 Aprendis `a`, 1 kolbo2 `j` y 1 kolbo3 `q`; otros 12 en las oleadas del coliseo y del salón (`_combate`) y Cthulhu. Decorados: solo antorchas `t` y fogatas `f`. La `_combate` no tiene `MapAmbience`.
- **Ficha aprobada el 2026-11-17**, con la estructura montada (base y `_combate`), sin jugar a mano todavía.
- **Por qué cambia:**
  - el tileset y el parallax son los de las profundidades de antes de vestirlas, y el parallax de lava ya sale en las profundidades: al bajar por `[S7]` se vería la misma zona;
  - los enemigos son "los que ya existían" (TASK.md): casi todo diablillos, el enemigo de las profundidades, y murciélagos y un kolbo2, de los más flojos del juego;
  - casi no hay decorados.
- **Lo que no cuadraba** (hallado al armar la ficha):
  - **los dos minos del pasillo del filo**, en (38, 75) y (70, 75), están atascados: el cuerpo del mino mide 80 px de alto y el pasillo, 4 piezas (64 px). Prueba sin ventana: a los 3 s no tocan el suelo y no patrullan. El del mirador (5 de alto) sí cabe. La ficha los cambia por ogros;
  - la `_combate` no tiene `MapAmbience`: al vestir se le añade el nodo `Ambientacion`, como en las profundidades.

**Ambientación** (tileset nuevo `infierno`, `herramientas/constructor_mapas/tilesets/infierno.gd`, como `profundidades`: las filas 0-15 copian el atlas de mazmorra, por la lava animada, la antorcha y la fogata, y debajo van piezas de **Living Tissue** de la Legacy, carne con colmillos y ojos, la que las profundidades guardaron para el infierno; un script `herramientas/constructor_mapas/atlas_infierno.py` arma el atlas):
- **Carne en toda la zona**, de la llegada al trono: es lo que más lo separa de las profundidades, y el ojo verde del pack pega con Cthulhu.
- **Bloques `carne`:** el pack trae un suelo de 12x4 piezas, (2,7)-(13,10) de `layers/tileset.png`, y un techo de 5x4, (12,1)-(16,4); **todas sus piezas tienen las cuatro esquinas opacas** (comprobado). El juego de 3x3 se arma con ellas: arriba, el canto del suelo; abajo, el del techo; los lados, sus bordes; el interior, el relleno liso. La cresta de la fila 6, que sobresale del suelo, no entra en los bloques.
- **Plataformas `=`:** el pack no trae repisas. Una tira con la banda de arriba del suelo de carne, con la clave `plataformas`; la colisión de una vía no cambia. La forma exacta, en el paso de piezas.
- **Escalera:** la de madera del Dungeon Tile Set, como en las zonas de arriba.
- **Cofres `c`** (5): `cofre_madera.tscn`, con la clave `cofre` del tileset.
- **Lava `~`:** la animada de hoy.
- **Paredes**, con `fondo` y `fondo_sala` (los rectángulos exactos se fijan al vestir):

  | Pared | Arte | Dónde |
  |---|---|---|
  | `carne` (nueva, el `fondo:` de la zona) | el fondo del pack, `layers/bakground.png`, 9x9 piezas; se repite sin costura (comprobado) | todo lo demás |
  | `ladrillo` | el de las profundidades (Gothic Horror teñido de rojo) | lo construido: coliseo de los condenados y salón de los verdugos |

  - **Sin parallax:** se quita el de lava de la cabecera, porque ya sale en las profundidades.
- **Decorados** (reutilizan letras, así que no hay colores nuevos; los tamaños se miden en el paso de piezas):

  | Letra | En `infierno` | Dónde |
  |---|---|---|
  | `t`, `f` | se quedan: antorchas y fogatas | |
  | `y` | colmillos que cuelgan del techo, unas 3x2 (cuelga: va pegado arriba) | techo del trono, de la sima y de la caverna |
  | `r` | ojo en la carne, 2x2, da luz verde | paredes de la sima, la caverna y el trono |
  | `n` | pústula, 2x2, en el suelo | llegada, mirador, osario y umbral |
  | `U` | herida o vena en la pared, unas 3x2 | pasillos y salón |

  - Los colmillos de suelo del pack no entran: se leen como pinchos.
  - Los decorados nuevos siguen la regla de la cabecera del `.txt`: ninguno pisa una escalera, sus columnas vecinas ni las tres filas de encima, un spawn ni otro decorado, ni los objetos de la `_combate` (rejas, trampillas, rejas bajas, fuego infernal, puntos del jefe y oleadas).
- **Luces:** el ojo `r` va en `ATLAS_DECOR_LIGHTS`, con luz verde. `Ambientacion` nueva en la `_combate` (`map_ambience.gd`); la luz ambiente se elige al vestir, con capturas.

**Enemigos** (excepción a P33, que se mantiene: el infierno reúne las ánimas de lo vencido al bajar):
- Los más duros de cada profundidad, con el arte vestido de hoy; los más flojos (murciélago y kolbo2) y casi la mitad de los diablillos dejan su sitio.
- Cada nuevo va en el sitio de otro, de suelo a suelo y de aire a aire: **no cambia ninguna posición del ASCII**.
- **En el ASCII:**

  | Prueba | Hoy | Queda |
  |---|---|---|
  | 1. Paso de las cadenas | diablillo (38, 9) | se queda |
  | Mirador (opcional) | Aprendis (81, 12), mino (98, 12), diablillos (70, 10) y (94, 10) | el de (70, 10) pasa a calavera de fuego `X`; los demás se quedan |
  | Osario (opcional) | kolbo3 (102, 27), diablillo (88, 24) | el kolbo3 pasa a Mimic `i`, junto al cofre de verdad de (105, 27); el diablillo se queda |
  | 2. Sima de las ánimas | diablillos (14, 12), (24, 19), (6, 23), (28, 31), (12, 35), (24, 39), (5, 47) y (16, 51); murciélagos (20, 27), (14, 43) y (25, 55) | los 3 murciélagos pasan a alma condenada `z` (nueva); (12, 35) y (5, 47) a ánima `N`; (6, 23) y (24, 39) a calavera `X`; se quedan 4 diablillos |
  | 4. Pasillo del filo | Guardias (80, 75), (74, 75) y (30, 75); minos (70, 75) y (38, 75); Aprendis (55, 75); diablillos (48, 68) y (62, 68); kolbo2 (26, 75) | los minos pasan a ogro `W` (50 px de alto: cabe); el kolbo2, a lobo de la escarcha `J` (se lanza a ras de suelo; se pasa rodando); los demás se quedan |
  | 5. Caverna del vuelo | diablillos (28, 80), (38, 84), (25, 92), (12, 96) y (36, 100); murciélagos (10, 86), (30, 90), (18, 99) y (8, 101) | (25, 92) y (12, 96) pasan a ojo volador `p`; murciélagos: (10, 86) y (18, 99) a ave de las nieves `Z`, (30, 90) y (8, 101) a calavera `X` |

  - Salen 18 (7 diablillos, 7 murciélagos, 2 mino, el kolbo2 y el kolbo3) y entran 18. Quedan 36: 12 diablillos, 5 calaveras, 3 almas condenadas, 3 Guardias, 2 ánimas, 2 ojos, 2 aves, 2 ogros, 2 Aprendis, 1 mino, 1 lobo y 1 Mimic.
- **Oleadas** (en la `_combate`; aprobado tocarla al vestir para esto, porque esos enemigos solo existen allí). En el coliseo, una oleada por tramo de la bajada:

  | Arena | Oleada | Hoy | Queda |
  |---|---|---|---|
  | Coliseo | 1 (profundidades 0-2) | esqueleto (52, 60), kolbo3 (75, 60), diablillos (64, 50) y (84, 46), murciélago (73, 44) | Guardia (52, 60), kolbo3 (75, 60), ánimas (64, 50) y (84, 46), ojo (73, 44) |
  | Coliseo | 2 (profundidades 3-4) | mino (60, 60), Guardia (68, 60), Aprendis (86, 60), murciélagos (60, 44) y (86, 44) | mino (60, 60), lobo (68, 60), Aprendis (86, 60), calavera (60, 44), ave (86, 44) |
  | Coliseo | 3 (profundidad 5) | minos (58, 60) y (84, 60), Guardias (64, 60) y (80, 60), Aprendis (72, 52) | pesadillas `Y` (58, 60) y (84, 60), bestias infernales `I` (64, 60) y (80, 60), diablillo (72, 52) |
  | Salón | 1 | Guardias (12, 116) y (22, 116), mino (17, 116), kolbo3 (27, 116) | el kolbo3 pasa a ogro |
  | Salón | 2 | Guardias (8, 116) y (26, 116), mino (17, 116) | los dos Guardias pasan a ogros |

  - El ogro da golpes de maza lentos y fuertes, los del parry. `receive_parry` está en `enemy_base.gd`, así que el parry sirve con todos.
- **Nuevo: alma condenada `z`** (profundidad 6, solo en el infierno: en la sima de las ánimas, por su nombre):

  | | Alma condenada `z` |
  |---|---|
  | Arte | `enemy-ghost` de la Legacy (`Characters/enemy-ghost/Spritesheets/particles.png`): fantasma rosa con capucha y calavera, 6 cuadros de 64x64 (la figura, unos 30x33), una sola animación. Distinto del fantasma del ánima `N` (`Ghost-Files`) |
  | Script base | `lunge_enemy.gd`, volador: avisa y embiste, como el murciélago. Muere con el efecto `muerte` |
  | Vida y daño | 3 de vida, 0.5 de daño y 0.25 de contacto |
  | Letra | `z`, la única letra del alfabeto libre en el constructor; color nuevo en `COLORS`, la paleta, LEYENDA y P33 |
  | Sitio | los 3 murciélagos de la sima: (20, 27), (14, 43) y (25, 55) |

  Si `lunge_enemy.gd` no sirve sin cambios, se pregunta antes de tocarlo.
- **Sin tinte de "ánimas"** para los enemigos de arriba: haría falta un script nuevo y la mezcla ya lo cuenta.
- **Demonslime común:** sale de P33 (lo que faltaba en la profundidad 6). Es el arte del Demon Slime, que ya se venció.

**Origen del arte:**
- **Legacy Collection** (CC0, `Legacy Collection.zip` en Descargas): Living Tissue (`Environments/Living-Tissue-Platform-Files/PNG/layers/tileset.png` y `bakground.png`) y `enemy-ghost` van a `assets/terceros/gothicvania/` y se anotan en su `ORIGEN.txt`. El ladrillo rojo y la escalera ya están en el repo, y los enemigos que se reutilizan, también.
- Sin pack nuevo ni IA, y sin licencias nuevas por confirmar (el Dungeon Tile Set sigue pendiente, como en las zonas de arriba).
- **Mirado y descartado:**
  - Terrible Knight de la Legacy: se lee como un héroe (capa roja, sin muerte);
  - el `demon` de la Legacy: del tamaño de un jefe;
  - Hell-Hound de la Legacy: es casi el lobo de la ruina;
  - el parallax de lava (ya está en las profundidades) y un tileset de roca en la mitad de arriba.

**Reto obligatorio:** coincide con su fila de P46, sección 10.
- Llega con E5, Rodar, la Ráfaga, el Golpe final, la Ultimate, el tajo aéreo, el parry, el dash y la llama eterna (E3 y E4 si los encontró), y no consigue nada; Cthulhu es el final.
- Las pesadillas del coliseo y los ogros y el lobo del pasillo se pasan rodando; el Mimic solo está en el osario, que es opcional.
- Ningún reto obligatorio pide la Agilidad, E4, el dash ni una mejora de la tienda.
- Vestir no cambia celdas sólidas y las plataformas siguen siendo de una vía; se comprueba en el paso D.

**Piezas (hechas el 2026-11-17).** Decisiones aprobadas al pasar la ficha a piezas:
- **Colmillos `y`:** 3x3, no "unas 3x2", para no cortar el colmillo largo, que llega a la tercera fila. Cuelgan: van pegados arriba de su hueco y su letra va tres piezas debajo del techo.
- **Fondo de los decorados:** el ojo, la herida y los colmillos traen un cuadro opaco del color del relleno de la carne, (48, 16, 32), que sobre la pared se veía como un parche. Se quita solo ese color, rellenando desde el borde de la pieza, sin repintar: el ojo queda como una cuenca en la pared y la herida, como una vena. La pústula ya viene sin fondo.
- **Repisa `=`:** el canto del suelo de carne, (2,7), (3,7) y (13,7), sin el relleno liso de debajo. Mide unos 12 px de alto; la colisión de una vía no cambia.
- **Lados de los bloques:** (2,10) y (13,10), que se repiten mejor en vertical que los de la fila 9.
- **Galería:** en el piso G quedaban 48 columnas, justas para los dos cuartos del infierno (14 y 33).
- **El alma condenada mira a la derecha** (la cuenca del ojo delante y la cola detrás), no a la izquierda como los enemigos de las profundidades.
- **Atlas** `assets/terceros/gothicvania/tejido_vivo/tileset_infierno.png` (512x400), que arma `herramientas/constructor_mapas/atlas_infierno.py`:
  - filas 0-15: el atlas de mazmorra sin cambios (lava animada, antorcha y fogata, con sus luces de `DECOR_LIGHTS`);
  - filas 16-24:
    - juego `carne` (0,16): arriba el canto del suelo (con sus esquinas redondas), a los lados los bordes del suelo, abajo el canto del techo y el relleno liso en el interior; la columna y las tiras, con mitades de esas piezas. Las 16 piezas son macizas;
    - repisa (4,16) y escalera de madera (7,16);
    - pared `carne` (8,16), 9x9: el fondo del pack entero;
    - pared `ladrillo` (17,16), 7x2: la de las profundidades, con las mismas funciones de `atlas_profundidades.py` (igual píxel a píxel);
    - `U` herida 3x2 (17,18), `y` colmillos 3x3 (24,16), `r` ojo 2x2 (27,16) y `n` pústula 2x2 (29,16).

  Coordenadas y recortes en `assets/terceros/gothicvania/ORIGEN.txt`.
- **Tileset** `herramientas/constructor_mapas/tilesets/infierno.gd`:
  - `bloques_por_defecto: carne` (sin rampas: quedan las de `ladrillo`; el infierno no tiene);
  - `plataformas`, `escalera`, `cofre` (`cofre_madera.tscn`) y `fondos` (`cueva`, `carne` y `ladrillo`);
  - decorados `t` y `f` como en mazmorra, y `y`, `r`, `n` y `U` nuevos.

  El constructor no cambia, salvo la letra nueva.
- **Luz:** el ojo (27,17) va en `ATLAS_DECOR_LIGHTS` de `scripts/environment/map_ambience.gd`, con una luz verde fija (radio 40, energía 0.7).
- **Alma condenada `z`:** `escenas/enemigos/alma_condenada.tscn`, con `lunge_enemy.gd` volando, como la calavera de fuego, sin scripts nuevos.
  - `idle`, `move` y `attack` son los 6 cuadros de la hoja `assets/terceros/gothicvania/personajes/alma_condenada.png`, el `particles.png` del pack tal cual.
  - 3 de vida, 0.5 de daño y 0.25 de contacto, en la capa 5. Avisa 0.3 s y embiste a 190 durante 0.35 s; detecta a 200 px. Cuerpo de 22x28. Muere con el efecto `muerte`.
  - Letra `z` (`e0407a`) en `COLORS` y `ENEMIES`, la paleta, LEYENDA (sección 5) y P33.
- **Galería, piso G**, zona "Infierno", a la izquierda de las profundidades. La zona de pruebas solo cambia en x 2-49, filas 143-155 (comprobado con las colisiones de las dos escenas: 576 piezas cambian dentro y ninguna fuera):
  - cuarto "ALMA CONDENADA": el alma en el aire;
  - cuarto "TILESET INFIERNO", con la muestra `zona_pruebas_muestra_infierno` (`galeria.py` aprendió a escribir otro estilo de bloques que el nombre del tileset, `bloques`):
    - a la izquierda, la pared `carne`, con techo, una columna colgada, una pieza suelta, dos colmillos, la herida, el ojo, la repisa, la pústula, una antorcha y una fogata;
    - a la derecha, el `ladrillo`, con una antorcha y la escalera a una repisa.
- **Probado:**
  - capturas con el juego abierto de la muestra (con `MapAmbience` y el alma) y del cuarto de la galería;
  - prueba sin ventana con 923 comprobaciones bien:
    - los 78 bloques de la muestra son macizos, del juego `carne` y con colisión, y las 3 piezas de la repisa son de una vía;
    - el Player se apoya en la repisa y en el suelo, 64 px más abajo;
    - los decorados y la escalera están en su pieza del atlas, y cada celda lleva su pared (`carne` o `ladrillo`);
    - `MapAmbience` pone la luz verde del ojo;
    - el alma sigue en su sitio a los 3 s, recibe golpes, toca con 0.25 y embiste con 0.5, y muere con 3 de daño;
    - en la galería, el alma sigue en su sitio a los 3 s;
  - arrancan sin errores el juego, la zona de pruebas y las `_combate` del calabozo, el castillo, el cementerio, las minas, la mazmorra, la ruina, las profundidades y el infierno; `verificar_mundo.py` da 0 errores.
- **Al vestir, mirar:**
  - la carne es clara y llamativa: en las salas grandes, la pared `carne` y la luz ambiente tienen que dejar leer a los enemigos;
  - los colmillos solo donde haya 3 filas libres bajo el techo, y no sobre un enemigo del aire;
  - la luz verde del ojo junto a la de la lava y las antorchas.

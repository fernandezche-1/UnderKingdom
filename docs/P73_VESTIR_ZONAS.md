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

### Minas
- Parte de: tileset `mazmorra` con `bloques: madera`, parallax de `pixelfantasy_caves`. Kolbos y murciélago; el Caballero y el Crystal Mauler.
- Ficha: por armar.

### Mazmorra
- Parte de: tileset `mazmorra` con `bloques: oliva`, parallax de `gothicvania/castillo_viejo`. Aprendis, mino, kolbo3, esqueleto; la Reina.
- Ficha: por armar.

### Ruina
- Parte de: tileset `mazmorra` con `bloques: ladrillo`, parallax de `gothicvania/cavernas`. Los mismos de la profundidad 3-4; el Guardián de hielo.
- Ficha: por armar.

### Profundidades
- Parte de: tileset `mazmorra` con `bloques: oro`, parallax de `gothicvania/lava`. Diablillo; el Demon Slime. Faltan los minijefes de los altares (P46, sección 7).
- Ficha: por armar.

### Infierno
- Parte de: tileset `mazmorra` con `bloques: ladrillo`, parallax de `gothicvania/lava`. La mezcla de los más duros (P46); Cthulhu. Faltan los enemigos definitivos.
- Ficha: por armar.

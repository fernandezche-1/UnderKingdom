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
- Arranca sin errores, `verificar_mundo.py` da 0 errores y el Atlas se publicó de nuevo (con los nombres de las letras del tileset `calabozo`). Falta jugarla a mano.

### Castillo
- Parte de: tileset `castillo`, `fondo: castillo`. Guardia, Vanguardia, murciélago; el Rey Caído.
- Ficha: por armar.

### Cementerio
- Parte de: tileset `cementerio`, parallax de `gothicvania_cementerio/fondo` (cielo, montes y cementerio). Vanguardia, murciélago, esqueleto de tumba; el Capitán.
  - Pendiente de P34, sección 5: el cielo se ve también dentro de las cuevas, porque cada mapa tiene un solo parallax.
- Ficha: por armar.

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

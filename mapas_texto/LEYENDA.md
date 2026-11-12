# Cómo hacer un nivel con tiles

Un nivel se dibuja como una imagen pequeña en la que **cada píxel es una pieza de 16 x 16 px** del juego, y cada color significa una cosa (suelo, plataforma, enemigo, cofre...). El constructor convierte esa imagen en una escena de Godot con tiles, colisiones, enemigos y sistemas listos para jugar.

También se puede escribir el nivel con letras en un `.txt`, como `zona_pruebas.txt` o los ASCII de `macro/zonas/`: cada letra es una pieza. Las letras y los colores significan lo mismo.

Ejemplo completo con PNG: `archivo/mapas_viejos/mapas_texto/ejemplo_nivel.txt` + `ejemplo_nivel.png` (apartado en P72 con `ejemplo_cueva.txt`; su `escena:` ya no está en `escenas/mapas/`, así que el constructor no lo regenera en su sitio).

## 1. Dibujar el nivel
1. Crear una imagen nueva en Aseprite, Piskel, GIMP, Krita o Paint.
   - Cada **pantalla del juego son 30 x 17 píxeles** (480 x 270 px).
   - Un nivel de cuatro pantallas a lo ancho mide unos 120 x 17.
   - El nivel tiene que medir **al menos 30 x 17**; si es más pequeño, se ve fuera del mapa.
2. **Cargar la paleta.** `paleta_niveles.gpl` sirve en Aseprite, GIMP, Krita y Piskel. En Paint hay que escribir los colores a mano con la tabla de abajo.
3. **Dibujar con el lápiz de 1 píxel, sin suavizado ni degradados.** El color tiene que ser exactamente el de la paleta. Si no lo es, el constructor dice en qué coordenadas está el píxel equivocado.
4. Blanco o transparente = vacío.
5. Guardar como PNG en esta carpeta (`mapas_texto/`).

## 2. Reglas al dibujar
- **Bordes del nivel.** Rodear el nivel de bloques negros, salvo donde haya salidas.
- **Qué se apoya en el suelo.** El Player, los enemigos, el cofre, el fuego y el checkpoint se dibujan en el píxel **justo encima del suelo**. Los pinchos también, encima del bloque sobre el que están.
- **Monedas y pociones** pueden ir flotando.
- **Decorados grandes** (árbol, estantería, tienda): el píxel marca su pieza de **abajo a la izquierda**.
- **Escaleras.** El Player mide 20 px y su caja está corrida 7 px a la izquierda de su origen. Para que suba y salga arriba sin atascarse:
  - libres las dos columnas vecinas (izquierda y derecha) en todo el tramo de la escalera;
  - tres filas libres encima de la escalera;
  - si atraviesa un piso, un hueco de tres piezas en ese piso, con la escalera en la del medio.
- **Salidas.** Una columna de 2 o 3 píxeles azules (siguiente) o morados (anterior) en el borde izquierdo o derecho. El Player llega a cada mapa dos piezas hacia dentro de la salida, así que no vuelve a cruzarla sin querer.
- **Inicio del Player.** Tiene que haber exactamente un píxel de inicio (`P`).

## 3. Crear el archivo del nivel
Un `.txt` con el mismo nombre, con las opciones:

```
escena: res://escenas/mapas/mi_nivel.tscn
imagen: mapas_texto/mi_nivel.png
tileset: mazmorra
bloques: ladrillo
fondo: cueva
siguiente: res://escenas/mapas/otro_nivel.tscn
anterior: res://escenas/mapas/nivel_previo.tscn
cofre_monedas: 3
cofre_pociones: 1
```

| Opción | Qué hace |
|---|---|
| `escena` | Dónde se guarda el nivel; siempre en `res://escenas/mapas/`. **Nunca sobrescribe** un mapa hecho a mano. |
| `imagen` | El PNG del nivel. Si en vez de imagen se escribe el mapa con letras después de una línea `---`, se omite. |
| `tileset` | Qué juego de piezas usar: `mazmorra`, `cementerio` (el de mazmorra más piezas de Gothicvania Cemetery; en él `T` es una lápida, `g` puntas de pasto y `r` zarzas) o `castillo` (el de mazmorra más el muro de ladrillo morado de Raou; en él `T` es una armadura 2x2, `h` un estandarte 1x2, `g` una cadena 1x2, `r` una ventana en arco 2x2, `C` una puerta en arco 2x3, `E` una estantería 2x2 y `f` unas rejas de celda 2x2; el estandarte y la cadena cuelgan del techo: su letra va dos piezas debajo de él) o `calabozo` (el de castillo más el Dungeon Tile Set de la prisión, P73; en él `t` es la antorcha de Raou, `g` una cadena 1x2, `h` una jaula 2x2, `b` y `x` barril y caja del pack, `r` la rejilla redonda del desagüe 2x2 y `C` una telaraña 4x1; la cadena, la jaula y la telaraña cuelgan del techo; `f`, `E` y `T` son las del castillo; las plataformas `=` son una viga de madera). Cada tileset es un archivo en `herramientas/constructor_mapas/tilesets/`. |
| `bloques` | Estilo de los bloques. En mazmorra: `verde`, `verde_claro`, `ladrillo`, `violeta`, `oro`, `oliva` o `madera`. En cementerio, además, `cementerio`; en castillo, `castillo`, y en calabozo, `castillo` y `calabozo`. |
| `fondo` | Pared detrás de todo: `cueva`, `castillo` (ladrillo oscuro, con los tilesets castillo y calabozo), `calabozo` (pared oscura del Dungeon Tile Set, solo con el tileset calabozo) o `ninguno`. |
| `parallax` | Imágenes de fondo que se mueven más lento, de la más lejana a la más cercana: `fondos/cielo.png 0.05; fondos/nubes.png 0.2`. El número es la velocidad horizontal (0 = quieta, 1 = como el mapa). Si la imagen es más baja que la pantalla (270 px), se agrega `x2` para dibujarla al doble: `fondos/cielo.png 0.05 x2`. En vertical cada imagen recorre el mapa: se ve su borde de arriba con la cámara arriba del todo y el de abajo con la cámara abajo. Necesita `fondo: ninguno`. |
| `siguiente` / `anterior` | Mapa al que llevan las salidas azules / moradas. Por defecto se llega a su spawn `DesdeAnterior` / `DesdeSiguiente`, que el constructor crea solo. Para llegar a otro spawn: `res://escenas/mapas/tiles_castillo_combate.tscn#SpawnInicio`. |
| `cofre_monedas`, `cofre_pociones` | Botín de cada cofre del nivel (por defecto 3 y 1). |
| `jugador` | Escena del Player que se pone en la `P`. Por defecto `res://escenas/player.tscn`; el calabozo usa `res://escenas/prisn.tscn`, el protagonista sin espada. |
| `depuracion` | `si` activa las teclas de prueba del Player (R reaparecer, H/J daño, K morir) y su panel de depuración. Solo para mapas de prueba como `zona_pruebas`; por defecto `no`. Para probar los niveles de la ruta está el Modo dev (tecla º). |
| `muestra` | `si` genera solo las capas de piezas, las escaleras y las zonas de muerte, sin Player, `MapBounds` ni spawns, y no pide la `P`. Es para las muestras de tileset que la galería de la zona de pruebas instancia en su piso D (P73); las escribe `herramientas/zona_pruebas/galeria.py`. Por defecto `no`. |

## 4. Generar el nivel
Desde la carpeta del proyecto:

```
~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/mi_nivel.txt
```

Después se abre `escenas/mapas/mi_nivel.tscn` en Godot y se juega con F6. Las teclas de prueba (R reaparecer, H/J daño, K morir) están activas en los niveles generados.

Para ajustar el nivel hay dos caminos:
- **Cambiar el PNG y volver a generarlo** (recomendado). Lo que se haya pintado a mano en Godot se pierde.
- **Pintar tiles directamente en Godot.** En ese caso ya no se vuelve a generar desde el PNG.

Otras órdenes:
- `-- --paleta` vuelve a escribir `paleta_niveles.gpl` y `paleta_niveles.png`.
- `-- --a-png mapas_texto/mapa.txt` convierte un mapa de letras en PNG para seguir dibujándolo.
- `-- --desde-mapa res://archivo/mapas_viejos/escenas/ruina.tscn mapas_texto/mi_nivel.png` calca un mapa hecho a mano (ver sección 7).

## 7. Rehacer con tiles un mapa hecho a mano
Los mapas de `fondos/` (casa, cementerio, ruina...) ya tienen sus colisiones probadas jugando. El constructor puede calcarlas como dibujo de piezas para empezar un nivel con tiles con la misma forma:

```
~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- --desde-mapa res://archivo/mapas_viejos/escenas/primer_boss_mundo_1.tscn mapas_texto/mi_nivel.png
```

- Cada pieza de 16 x 16 que las colisiones sólidas cubren a la mitad o más pasa a bloque. Las orillas en diagonal pasan a rampas.
- Las colisiones one-way pasan a plataformas `=`, las zonas de escalera a `H`, y los enemigos que tienen letra a su letra, sobre el suelo.
- La P sale del `SpawnInicio`, del Player del mapa o del inicio de la ruta de prueba.
- Los escalones de una pieza llevan una rampa delante para subirlos caminando.
- El nivel queda cerrado por los lados y por abajo.
- Los jefes y personajes sin letra no se calcan; el constructor dice cuáles quedaron fuera.

El mapa original no se toca. El PNG es un punto de partida: faltan las salidas, el checkpoint, los cofres, las trampas y los decorados, y conviene revisar que cada zona tenga por dónde entrar y salir. Las escaleras del dibujo del fondo no son colisiones, así que no se calcan.

## 5. Colores y letras

| Letra | Color | RGB | Qué es |
|---|---|---|---|
| `.` | #ffffff | 255, 255, 255 | vacío (también transparente) |
| `#` | #000000 | 0, 0, 0 | bloque sólido (esquinas y bordes automáticos) |
| `/` | #404040 | 64, 64, 64 | rampa que sube a la derecha |
| `\` | #808080 | 128, 128, 128 | rampa que sube a la izquierda |
| `=` | #00ff00 | 0, 255, 0 | plataforma de una vía (se baja con S) |
| `~` | #ff0000 | 255, 0, 0 | lava (mata) |
| `^` | #ff80c0 | 255, 128, 192 | pinchos (matan) |
| `F` | #ff8000 | 255, 128, 0 | trampa de fuego (quema ¼ de corazón cada ½ s) |
| `%` | #0080ff | 0, 128, 255 | agua (decorativa) |
| `H` | #8b4513 | 139, 69, 19 | escalera (se trepa con W/S) |
| `P` | #00ffff | 0, 255, 255 | inicio del Player |
| `>` | #0000ff | 0, 0, 255 | salida al mapa siguiente |
| `<` | #8000ff | 128, 0, 255 | salida al mapa anterior |
| `S` | #007000 | 0, 112, 0 | checkpoint (fogata; al morir se reaparece aquí) |
| `c` | #c06000 | 192, 96, 0 | cofre (se abre con E) |
| `$` | #ffd700 | 255, 215, 0 | moneda |
| `!` | #ff00ff | 255, 0, 255 | poción |
| `v` | #800000 | 128, 0, 0 | Vanguardia |
| `a` | #808000 | 128, 128, 0 | Aprendis |
| `k` | #008080 | 0, 128, 128 | kolbo |
| `j` | #000080 | 0, 0, 128 | kolbo2 (rápido) |
| `q` | #800080 | 128, 0, 128 | kolbo3 (resistente) |
| `d` | #c00060 | 192, 0, 96 | diablillo (vuela y lanza fuego) |
| `M` | #503000 | 80, 48, 0 | mino |
| `m` | #402060 | 64, 32, 96 | murciélago (vuela y embiste; se dibuja donde flota) |
| `e` | #d0d0b0 | 208, 208, 176 | esqueleto (camina y embiste) |
| `u` | #706050 | 112, 96, 80 | esqueleto de tumba (enterrado hasta que el Player se acerca) |
| `G` | #b0b0d0 | 176, 176, 208 | Guardia del castillo (se cubre con el escudo) |
| `R` | #b07050 | 176, 112, 80 | rata (calabozo, profundidad 0) |
| `L` | #40c0a0 | 64, 192, 160 | slime (calabozo, profundidad 0; escupe) |
| `B` | #a040a0 | 160, 64, 160 | murciélago grande (calabozo, profundidad 0; embiste; se dibuja donde flota) |
| `t` | #ffc090 | 255, 192, 144 | antorcha |
| `f` | #c03000 | 192, 48, 0 | fogata (decorado) |
| `b` | #a08060 | 160, 128, 96 | barril |
| `x` | #e0b060 | 224, 176, 96 | caja (decorado) |
| `h` | #c0ffc0 | 192, 255, 192 | hongos |
| `g` | #60c060 | 96, 192, 96 | pasto |
| `r` | #c0c0ff | 192, 192, 255 | cristales |
| `T` | #206020 | 32, 96, 32 | árbol (2x3 piezas) |
| `E` | #604080 | 96, 64, 128 | estantería (3x3 piezas) |
| `C` | #e0e0a0 | 224, 224, 160 | tienda de campaña (3x2 piezas) |
| `A` | #7090b0 | 112, 144, 176 | armero (solo tileset `castillo`, 2x3 piezas) |
| `D` | #f0f0f0 | 240, 240, 240 | trofeo de cráneo de dragón (solo `castillo`, 3x3 piezas) |
| `O` | #90a040 | 144, 160, 64 | estante con provisiones (solo `castillo`, 2x3 piezas) |
| `Q` | #d0a070 | 208, 160, 112 | cuadro (solo `castillo`, 2x2 piezas) |

## 6. Si me pasan un boceto en vez del PNG
Una foto de papel cuadriculado o una captura de un juego de referencia también sirve. Conviene que traiga:
- **Tamaño y piezas:** el tamaño aproximado en pantallas y qué es cada cosa (suelo, plataformas, pozos, escaleras).
- **Conexiones:** dónde empieza el Player y dónde están las salidas, y a qué mapas llevan.
- **Contenido:** qué enemigos van y dónde, y dónde hay cofres, monedas, pociones, checkpoints y trampas.
- **Ambiente:** el tileset o estilo de bloques.
- **Historia:** si hay una escena con diálogo, su guion.

Con eso se pasa a PNG, se genera el nivel y se revisa jugando.

## 8. Integrar un paquete de arte
1. El ZIP se descomprime en una carpeta aparte, nunca encima del proyecto.
2. **Revisar la licencia** y anotarla en un `ORIGEN.txt`, como en `assets/terceros/dungeon_platformer/ORIGEN.txt`. El paquete va a `assets/terceros/<paquete>/`, con solo lo que se use; el resto, a `archivo/sin_uso/assets/<paquete>/` (P72).
3. **Medir el tamaño de tile.** Si es de 16 px, entra directo. Si es de otro tamaño, el nivel usa esa cuadrícula sin escalar a medias; el constructor toma el tamaño del archivo del tileset.
4. **Crear `herramientas/constructor_mapas/tilesets/<nombre>.gd`** copiando `mazmorra.gd`, y ubicar en el PNG:
   - el juego de bloques de 4x4 (esquinas, bordes e interior en 3x3, columna a la derecha y plataformas abajo) y las rampas;
   - los decorados y las piezas animadas;
   - los líquidos y la escalera;
   - la pieza del checkpoint y el fondo.

   Si el paquete no trae ese juego de 4x4, se arma un atlas nuevo copiando sus piezas, sin dibujar arte nuevo; mejor con un script que lo rehaga, como `herramientas/constructor_mapas/atlas_calabozo.py`.

   Si las plataformas `=` no deben ser la fila de tiras del juego de bloques (una viga fina, por ejemplo), el tileset añade `"plataformas": Vector2i(x, y)`: sus tres piezas en fila (izquierda, medio, derecha) llevan la colisión de una vía aunque sus esquinas no sean opacas.

   Si el tema pide otro cofre, el tileset añade `"cofre": "res://escenas/objetos/<cofre>.tscn"` (una escena con `chest_interactable.gd`, como `cofre_madera.tscn` del castillo); sin esa clave, `c` pone `cofre.tscn`. Las letras de decorado que un tileset no define no dibujan nada.
5. **Probarlo** en el piso D de la galería de la zona de pruebas: un cuarto en `herramientas/zona_pruebas/galeria.py` con su muestra (`muestra_tileset`), que se genera con la opción `muestra: si`.
6. **Letras y colores nuevos:** si trae decorados o enemigos sin letra, se agregan a `COLORS` / `ENEMIES` del constructor. Después se regenera la paleta (`-- --paleta`) y se actualiza la tabla de la sección 5.
7. **Enemigos:** escena con `enemy_base.gd` y sus valores (cuadros de golpe, hitbox, `collision_layer = 5`), siguiendo el patrón de `kolbo` y `mino`. Se prueban en la zona de pruebas (`zona_pruebas_combate.tscn`).

## 9. Límites del constructor
- **Pinchos:** son estáticos (un recorte de `spike Trap5.png`) y matan al tocarlos. No hay versión animada ni de daño parcial.
- **Salidas:** si un mapa tiene varias salidas en la misma dirección, todas comparten el mismo spawn de llegada.
- **Enemigos:** siempre a la escala de su escena.
- **Parallax:** se vio en capturas a 480 x 270, pero falta verlo en movimiento.
- **Arte:** no se dibuja pixel art nuevo; los niveles se arman con piezas de los paquetes.

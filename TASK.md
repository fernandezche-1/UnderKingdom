# Tarea actual: niveles con tiles calcados de los fondos

**Objetivo:** convertir los siete niveles `tiles_*` en niveles jugables y bonitos. Tienen la forma de los mapas hechos a mano, pero están hechos con tiles. Más adelante el equipo decide si reemplazan a los mapas pintados.

**Estado (2026-10-16):** los siete niveles existen, están unidos en ruta y pasan las pruebas sin ventana. **Nadie los ha jugado todavía.** Rama `edwin/integrar-0.04.047`, sin subir a GitHub.

**Para probar:** abrir `escenas/mapas/tiles_cementerio_combate.tscn` y pulsar F6. Es el cementerio generado más la sala del Capitán, su llave y la puerta que la pide. Las minas se juegan igual desde `tiles_mineria_combate.tscn`. Cada salida azul del borde derecho lleva al siguiente nivel:

`tiles_cementerio` → `tiles_mineria` → `tiles_mazmorra` → `tiles_ruina` → `tiles_profundidades` → `tiles_jefe`

Las teclas de prueba están activas: R reaparecer, H/J daño, K morir.

**Documentación:**
- Guía para dibujar niveles: `mapas_texto/LEYENDA.md`; la sección 7 explica el calco.
- Historial: `docs/CHANGELOG_0.04.047.md`, secciones "Niveles con tiles" y "Niveles con tiles calcados de los fondos".

**Decisiones tomadas:**
- Los mapas hechos a mano no se tocan. Los niveles con tiles se suman a ellos.
- **La fuente de cada nivel es su PNG** (`mapas_texto/tiles_<nivel>.png`, un píxel = una pieza). Se cambia el PNG y se regenera la escena. Si alguien pinta tiles a mano en Godot, ese nivel deja de poder regenerarse.
- El terreno usa el tileset mazmorra, con un estilo de bloque por tema. Los paquetes nuevos solo aportan los fondos de parallax (ver "Tileset propio por tema").

---

## 1. Jugar los niveles (lo primero)

Hasta ahora todo se comprobó sin ventana, con una simulación aproximada. En cada nivel hay que revisar:

- [ ] Se puede ir de la entrada (borde izquierdo) a la salida (borde derecho) sin trucos.
- [ ] Al volver por la salida izquierda se llega bien al nivel anterior, junto a su salida derecha.
- [ ] Se sube bien por las escaleras y se sale arriba de ellas hacia la plataforma.
- [ ] El checkpoint guarda el punto de reaparición. Morir en lava o pinchos devuelve ahí.
- [ ] Los cofres se abren y las monedas y pociones se recogen.
- [ ] Los enemigos quedan sobre el suelo y no se atascan.
- [ ] El parallax se ve bien al moverse en horizontal y en vertical, sin franjas vacías arriba ni abajo.
- [ ] La cámara no muestra fuera del mapa.
- [ ] No hay saltos imposibles ni sitios donde el Player quede encerrado.

Anotar lo que se encuentre en la sección 2 con nivel y coordenadas en piezas (x, fila). Esas coordenadas se ven abriendo el PNG en Aseprite o GIMP.

### Datos de cada nivel

| Nivel | Tamaño (piezas) | Bloques | Enemigos | Escaleras | Además |
|---|---|---|---|---|---|
| `tiles_cementerio` | 120 x 78 | verde | 9 Vanguardia, 4 Aprendis + Capitán | 4 | Primer mundo estilo Hollow Knight, de bajada: superficie, cripta, catacumbas, sala del jefe y abismo con la puerta con llave y la salida en el fondo. Se juega desde `tiles_cementerio_combate.tscn`. Ya no es un calco de `mundo_1`. |
| `tiles_casa` | 104 x 58 | violeta | 4 diablillos | 3 | 3 huecos de 3 piezas en pisos. Las 2 escaleras del mapa original se reemplazaron. **Fuera de la ruta:** el cementerio lleva ahora a las minas. |
| `tiles_mineria` | 104 x 90 | madera | 4 kolbo, 3 kolbo2, 2 kolbo3, 2 mino, 2 diablillos + Caballero de la Reina | 4 | Segundo mundo, con la misma estructura que el cementerio: bocamina, galerías, sala del jefe y veta ardiente con la puerta con llave y la salida en el fondo. Se juega desde `tiles_mineria_combate.tscn`. Ya no es un calco. |
| `tiles_mazmorra` | 78 x 71 | oliva | 4 kolbo2, 1 mino | 13 | 9 huecos, 29 pinchos en pozos sin salida y túnel de 18 piezas hasta la salida derecha. Recortado: lo de abajo era vacío. |
| `tiles_ruina` | 104 x 58 | ladrillo | kolbo, kolbo2, kolbo3, mino | 5 | 3 huecos; túnel de 4 piezas hasta la salida derecha. |
| `tiles_profundidades` | 104 x 58 | oro | 4 diablillos | 2 | 2 huecos, lava en todo el fondo y 3 trampas de fuego. |
| `tiles_jefe` | 104 x 58 | ladrillo | 2 diablillos, 1 Vanguardia, 1 mino | 4 | 4 huecos, lava en el fondo, 2 trampas de fuego y 1 pinchos. Es el último: no tiene salida derecha. **No tiene jefe** (ver sección 3). |

Todos tienen un checkpoint, dos cofres (jefe uno), 12 monedas, una o dos pociones, antorchas y decorados del tema.

---

## 2. Bugs y cosas a revisar

### En los niveles nuevos
- [x] **`tiles_jefe`: hueco junto a la llegada.** El Player aparecía en (2, fila 31) y caía por el hueco con escalera de x=3-5, fila 32, al dar un paso a la derecha. La llegada no se puede mover, porque el constructor la pone dos piezas dentro de la salida. Se tapó el hueco y la escalera pasó al valle de la bajada: hueco en x=14-16 de la fila 36, escalera en x=15 de las filas 36 a 43 y suelo nuevo en (15-16, fila 44). Lleva a la misma cueva de abajo a la izquierda. Comprobado sin ventana: llegar y caminar, subir y salir por los dos lados, caer por el hueco y volver a subir, y saltarlo con carrerilla.
- [ ] **`tiles_mazmorra`: 3 piezas sin salida** en la orilla de un pozo con pinchos: (26, 58), (31, 59) y (34, 63). No dejan al Player encerrado, porque puede caer a los pinchos y reaparecer, pero queda feo. Revisar al jugar.
- [ ] **`tiles_mazmorra`: un enemigo en una cámara cerrada.** No se puede llegar a él. Quitarlo del PNG o abrir la cámara.
- [ ] **`tiles_mazmorra`: demasiadas escaleras y huecos** (13 y 9). Es el nivel que más se alejó del original. Ver si conviene simplificarlo.
- [ ] **Túneles hacia las salidas.** El de mazmorra mide 18 piezas y atraviesa la cámara de arriba a la derecha. Revisar que se vea bien o mover la salida.
- [ ] **Zonas sin acceso**, cerradas por roca en el mapa original: unas 21 piezas en mineria, 27 en mazmorra, 12 en ruina y 4 en profundidades. Quedan como decorado. Abrirlas solo si se quieren usar.
- [ ] **Escaleras sin apoyo visual.** Algunas suben por el aire hasta una plataforma; el dibujo de la escalera queda flotando. Valorar al jugar.
- [ ] **Antorchas y decorados** se repartieron al azar sobre el suelo alcanzable. Puede haber antorchas en medio de un pasillo o decorados amontonados. Moverlos en el PNG.
- [ ] **Escala de los enemigos.** El constructor los pone a escala 1, y el diablillo se ve bastante más grande que el Player. En los mapas pintados está entre 0.34 y 0.66, pero esa escala no es entera y no cumple la regla de pixel art. Decidir si hace falta un sprite más pequeño.
- [ ] **Lava y pinchos** en profundidades, jefe y mazmorra son decisión de diseño, no vienen de los mapas originales. Confirmar que se quieren.
- [ ] **Las teclas y el panel de depuración** están activos en todos los niveles generados. Apagarlos (`enable_debug_keys`, `show_debug_hud` del Player) cuando dejen de ser de prueba.

### En el resto del proyecto (encontrados durante esta tarea)
- [ ] **`primer_boss_mundo_1.tscn`:** la ruta de prueba tiene dos líneas `# W2: ...` entre sus propiedades. Godot pierde la propiedad siguiente, `spawn_position = Vector2(1535, 650)`, y el `SpawnInicio` de ese mapa queda en (160, 160), arriba a la izquierda. Arreglo: borrar esas dos líneas del `.tscn`. Es un mapa hecho a mano: confirmar con Armando antes.
- [ ] **`arena_enemigos.tscn` está desactualizada:** se generó antes del último cambio del diablillo. Al regenerarla cambian sus valores de IA. Regenerarla con `-- mapas_texto/arena_enemigos.txt` y revisar que siga bien.
- [ ] **`LEYENDA.md`, regla de escaleras:** hoy dice solo "dejar una pieza libre entre la escalera y el bloque". La regla probada es más estricta:
  - libres las dos columnas vecinas en todo el tramo de la escalera;
  - tres filas libres encima;
  - si atraviesa un piso, un hueco de tres piezas.

  El Player mide 20 px y su caja está corrida 7 px a la izquierda del origen. Actualizar la guía.

---

## 3. Cosas a agregar

### Jugabilidad
- [ ] **Jefes y personajes.** El calco dejó fuera lo que no tiene letra en el constructor:
  - ~~Capitán (cementerio)~~: hecho en `tiles_cementerio_combate.tscn`, una escena que hereda del nivel generado (ver changelog, "Cementerio con tiles: primer mundo estilo Hollow Knight");
  - Caballero de la Reina, Reina y Cthulhu (casa);
  - ~~jefe de las minas~~: el Caballero de la Reina, en `tiles_mineria_combate.tscn` (ver changelog, "Minas con tiles: segundo mundo");
  - Reina (mazmorra);
  - demonslime (profundidades);
  - jefe final (jefe).

  Opciones: añadir letras para jefes al constructor, o colocarlos a mano en una escena que herede del nivel generado. `tiles_jefe` necesita al menos su jefe para tener sentido.
- [ ] **Conectar con los mapas hechos a mano.** Hoy la ruta de tiles es independiente. Con `siguiente: res://escenas/mapas/<mapa>.tscn#<Spawn>` se puede enlazar con un spawn existente.
- [ ] **Agua decorativa (`%`)** donde el fondo original tiene agua: los estanques de ruina y mazmorra, y el río de mineria.
- [ ] **Objetos rompibles:** no tienen letra. Primero hace falta un sprite pequeño, porque `caja_rompible` y `estatua_rompible` son arte en alta resolución.

### Arte con los paquetes nuevos
- [ ] **Tileset propio por tema**, en lugar de los estilos de mazmorra. Los paquetes recibidos no traen un juego de bloques de 16 px listo: hay que armar un atlas con la forma que espera el constructor a partir de sus piezas. Candidatos:
  - cementerio: `Final.zip` (tumbas, verja, columnas, tierra con pasto) o Gothicvania `Gothic-Horror-Files`;
  - casa y mazmorra: Gothicvania `Gothic-Castle-Files` u `Old-dark-Castle-tileset-Files`;
  - mineria: `PixelFantasy_Caves` (`mainlev_build.png`, `props1/2.png`);
  - profundidades y jefe: Gothicvania `Living-Tissue-Platform-Files` o rocas con lava.

  Pasos en "Receta: integrar un paquete" (abajo).
- [ ] **Enemigos de Gothicvania** (`Legacy Collection/Assets/Gothicvania/Characters/`): Ghost, Hell-Hound, Hell-Beast, Fire-Skull, flying-eye-demon, Ogre, Nightmare, crow, entre otros. Cada uno necesita una escena con `enemy_base.gd`, una letra en el constructor y una prueba en `arena_enemigos`.
- [ ] **Decorados de los paquetes:** velas, jaulas, cadenas, estandartes, vagonetas. Necesitan estar en el atlas del tileset y tener letra.

### Herramientas
- [ ] **Decidir si los scripts de diseño entran al repo.** Las salidas, escaleras, objetos y decorados se pusieron con un script de Python (`disenar.py`). Un verificador (`recorrido.py`) simula los saltos del Player para comprobar que todo se alcanza. Los dos están fuera del repo y necesitan Python con Pillow. Si entran, irían en `herramientas/constructor_mapas/`, con instrucciones en `LEYENDA.md`.
- [ ] **Prueba de escaleras en Godot** (sin ventana: sube por cada escalera y comprueba que el Player queda arriba). Se usó y se borró. Si se quiere repetir tras cambiar los PNG, guardarla como herramienta.

### Licencias
- [ ] **Pixel Fantasy Caves:** el ZIP no trae licencia. Confirmar de dónde se bajó y sus condiciones antes de usarlo fuera de pruebas (ver `assets_prueba/pixelfantasy_caves/ORIGEN.txt`).
- [ ] **`Final.zip`** (Anokolisa): su nota pide no dar crédito si se cambia el arte. Anotarlo en un `ORIGEN.txt` cuando se use.

---

## 4. Cómo ajustar un nivel

1. Abrir `mapas_texto/tiles_<nivel>.png` en Aseprite, GIMP o Krita con la paleta `mapas_texto/paleta_niveles.gpl`.
   - Lápiz de 1 píxel y sin suavizado.
   - Los colores y letras están en `LEYENDA.md`, sección 5.
2. Regenerar desde la carpeta del proyecto:
   ```
   ~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/tiles_<nivel>.txt
   ```
3. Si el nivel estaba abierto en el editor, recargarlo sin guardar encima.
4. Comprobar que arranca sin errores:
   ```
   ~/.local/bin/godot --headless res://escenas/mapas/tiles_<nivel>.tscn --quit-after 120
   ```
5. Jugarlo con F6.

Para empezar de cero desde un mapa hecho a mano, se usa `-- --desde-mapa` (sección 7 de `LEYENDA.md`). El calco no pone salidas, objetos ni escaleras nuevas.

### Archivos de cada nivel
| Qué | Dónde |
|---|---|
| Dibujo (fuente) | `mapas_texto/tiles_<nivel>.png` |
| Opciones: tileset, bloques, parallax, salidas | `mapas_texto/tiles_<nivel>.txt` |
| Escena generada (no editar a mano) | `escenas/mapas/tiles_<nivel>.tscn` |
| Fondos de parallax | `assets_prueba/gothicvania/`, `assets_prueba/pixelfantasy_caves/` |

---

## Receta: integrar un paquete
1. El ZIP se descomprime en una carpeta aparte, nunca encima del proyecto.
2. **Revisar la licencia** y anotarla en un `ORIGEN.txt`, como en `assets_prueba/dungeon_platformer/ORIGEN.txt`.
3. **Medir el tamaño de tile.** Si es de 16 px, entra directo. Si es de otro tamaño, el nivel usa esa cuadrícula sin escalar a medias; el constructor toma el tamaño del archivo del tileset.
4. **Crear `herramientas/constructor_mapas/tilesets/<nombre>.gd`** copiando `mazmorra.gd`, y ubicar en el PNG:
   - el juego de bloques de 4x4 (esquinas, bordes e interior en 3x3, columna a la derecha y plataformas abajo) y las rampas;
   - los decorados y las piezas animadas;
   - los líquidos y la escalera;
   - la pieza del checkpoint y el fondo.

   Si el paquete no trae ese juego de 4x4, se arma un atlas nuevo copiando sus piezas, sin dibujar arte nuevo.
5. **Probarlo** con un mapa de muestra.
6. **Letras y colores nuevos:** si trae decorados o enemigos sin letra, se agregan a `COLORS` / `ENEMIES` del constructor. Después se regenera la paleta (`-- --paleta`) y se actualiza la tabla de `LEYENDA.md`.
7. **Enemigos:** escena con `enemy_base.gd` y sus valores (cuadros de golpe, hitbox, `collision_layer = 5`), siguiendo el patrón de `kolbo` y `mino`. Se prueban en `arena_enemigos`.

## Límites conocidos del constructor
- **Pinchos:** son estáticos (un recorte de `spike Trap5.png`) y matan al tocarlos. No hay versión animada ni de daño parcial.
- **Salidas:** si un mapa tiene varias salidas en la misma dirección, todas comparten el mismo spawn de llegada.
- **Enemigos:** siempre a la escala de su escena.
- **Parallax:** se vio en capturas a 480 x 270, pero falta verlo en movimiento.
- **Arte:** no se dibuja pixel art nuevo; los niveles se arman con piezas de los paquetes.

## Hecho
- **Fase 1, el constructor:**
  - tilesets como datos;
  - nivel dibujado como PNG con paleta;
  - pinchos, fuego, checkpoint, cofre, monedas, pociones y salidas;
  - parallax;
  - guía y nivel de muestra.

  Detalle en el changelog, sección "Niveles con tiles".
- **Fase 2, en parte:** fondos de parallax de Gothicvania (CC0) y Pixel Fantasy Caves, con su `ORIGEN.txt`.
- **Fase 3, primera tanda:**
  - `-- --desde-mapa` y `parallax` con `x2`;
  - los siete niveles `tiles_*`.

  Comprobado sin ventana:
  - todos arrancan sin errores;
  - las 12 salidas llevan a mapas y spawns que existen;
  - el Player sube por las 32 escaleras y queda arriba;
  - según la simulación, desde la P se alcanzan las salidas, el checkpoint y los objetos.

  Commits `0ab5a4c`, `a5cc8f7`, `0a45be4` y `9b6f24c`.

## Otros pendientes del proyecto (fuera de esta tarea)
Ver "Pendientes" en `docs/CHANGELOG_0.04.047.md`:
- probar jugando la 0.04.047;
- pausa, menú y guardado;
- jefes de Mundo 2 y final;
- transiciones definitivas;
- audio;
- arte a escala entera.

Además:
- fusionar esta rama en `main` y subirla cuando el equipo lo apruebe;
- decidir qué hacer con la rama `v5`, que apunta a la versión vieja;
- confirmar si fue intencional rellenar el hueco de `ColisionPoligono_04` en Mundo 1.

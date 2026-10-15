# Tarea actual: niveles hechos con tiles

**Objetivo:** que el equipo pueda crear niveles nuevos con tiles, a partir de un dibujo de píxeles o un boceto, en lugar de fondos pintados con colisiones a mano.

**Decisiones tomadas:**
- Los mapas actuales se quedan como están y los niveles nuevos se suman. Más adelante se decide cuáles reemplazan a cuáles.
- El diseño de cada nivel llega como dibujo de píxeles (PNG con la paleta) o como boceto en papel o foto.

**Guía para el equipo:** `mapas_texto/LEYENDA.md`. **Historial:** `docs/CHANGELOG_0.04.047.md`, sección "Niveles con tiles".

Estado: **fase 1 terminada.** Las fases 2 y 3 esperan material del equipo.

## Fase 1: ampliar el constructor (hecha)
Rama `edwin/integrar-0.04.047`, 7 commits por encima de `main`, sin subir a GitHub.

| Qué | Dónde | Commit |
|---|---|---|
| Tilesets como datos: cada uno en un archivo y se elige con `tileset:` | `herramientas/constructor_mapas/tilesets/mazmorra.gd` | `8bdd2c3` |
| Nivel dibujado como PNG (un píxel = una pieza), paleta `.gpl` y conversión de texto a PNG | `construir_mapa.gd`, `mapas_texto/paleta_niveles.gpl` | `a40f9cc` |
| Elementos de juego: pinchos `^`, fuego `F`, checkpoint `S`, cofre `c`, moneda `$`, poción `!` y salidas `>` / `<` con su spawn de llegada | `construir_mapa.gd` | `8403951` |
| Escenas nuevas: checkpoint genérico, trampa de fuego y cofre a escala 1. Arte derivado a escala entera en `sprites/trampas/` | `escenas/sistemas/`, `escenas/objetos/cofre.tscn` | `6459cf7` |
| Fondo con parallax (`parallax:`) | `construir_mapa.gd` | `45bc1f9` |
| Guía para el equipo y nivel de muestra de 46 x 17 | `mapas_texto/LEYENDA.md`, `ejemplo_nivel.txt` / `.png` | `d23392c` |

Correcciones hechas por el camino:
- Las zonas generadas (lava, escaleras) ya tienen su tamaño real (`8403951`).
- Las transiciones cambian de escena en diferido (`3806f3e`).
- Las monedas y pociones colocadas en un mapa no reaparecen al morir (`6459cf7`).

**Verificado:**
- `ejemplo_cueva` y `arena_enemigos` salen idénticos al regenerarlos, salvo el arreglo de las zonas.
- `ejemplo_cueva` reconstruido desde PNG es idéntico al de texto.
- Recorrido completo del nivel de muestra sin ventana: recoger objetos, abrir el cofre, checkpoint, quemarse, morir en los pinchos y reaparecer con lo recogido conservado, y cruzar la salida.
- El juego y todos los mapas arrancan sin errores.

## Fase 2: integrar los paquetes nuevos (pendiente; espera los ZIP)
1. El equipo deja los ZIP en Descargas. Cada uno se descomprime en una carpeta aparte, nunca encima del proyecto.
2. Por cada paquete:
   - **Revisar la licencia** y anotarla en un `ORIGEN.txt`, como `assets_prueba/dungeon_platformer/ORIGEN.txt`.
   - **Medir el tamaño de tile.** Si es de 16 px, entra directo. Si es de otro tamaño, el nivel usa esa cuadrícula sin escalar a medias; el constructor ya toma el tamaño del archivo del tileset.
   - **Crear `tilesets/<nombre>.gd`** copiando `mazmorra.gd` y ubicando en el PNG:
     - el juego de bloques de 4x4 y las rampas;
     - los decorados y las piezas animadas;
     - los líquidos y la escalera;
     - la pieza del checkpoint y el fondo.
   - **Probarlo** con un mapa de muestra.
3. **Enemigos nuevos de los paquetes:** escena con `enemy_base.gd` y sus valores (cuadros de golpe, hitbox, `collision_layer = 5`), con el mismo patrón que `kolbo` y `mino`. Se prueban en `arena_enemigos`.
4. **Letras y colores nuevos:** si un tileset trae decorados o enemigos sin letra, se agregan a `COLORS` / `ENEMIES` del constructor, se regenera la paleta (`-- --paleta`) y se actualiza la tabla de `LEYENDA.md`.

## Fase 3: hacer cada nivel (pendiente; espera los bocetos)
1. **Recibir el diseño:** PNG con la paleta o boceto, con lo que pide `LEYENDA.md` sección 6.
2. **Pasar el boceto a PNG** si hace falta. Ese PNG en `mapas_texto/` es la fuente del nivel.
3. **Generar el nivel y validarlo sin ventana:**
   - el Player y los enemigos quedan sobre el suelo;
   - cada salida lleva a su mapa y spawn;
   - el checkpoint guarda el punto de reaparición.
4. **Conectarlo a la ruta:** con `siguiente:` / `anterior:` entre niveles nuevos, y con los mapas hechos a mano a través de un `#Spawn` existente. Los mapas actuales todavía usan los portales provisionales de `world_test_route.gd`.
5. **Que el equipo lo juegue y ajuste.** Si alguien pinta tiles a mano en Godot, ese nivel deja de regenerarse desde el PNG.

## Límites conocidos
- **Objetos rompibles:** todavía no hay letra para ellos. `caja_rompible` y `estatua_rompible` usan arte en alta resolución que no cumple la regla de pixel art, así que primero hace falta un sprite pequeño.
- **Pinchos:** son estáticos (un recorte de `spike Trap5.png`) y matan al tocarlos. No hay versión animada ni de daño parcial.
- **Parallax:** solo se comprobó sin ventana. Falta ver en pantalla que la velocidad de cada capa se vea bien.
- **Salidas:** si un mapa tiene varias salidas en la misma dirección, todas comparten el mismo spawn de llegada.
- **Arte nuevo:** no se dibuja pixel art nuevo; los niveles se arman con las piezas de los paquetes.

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

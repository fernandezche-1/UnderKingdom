# UnderKingdom 0.04.047 — integración de la rama de Edwin con la 0.04.047

Esta etapa junta en una sola versión dos líneas de trabajo que salieron de la 0.04.030:

- El trabajo de Edwin en el repo, rama `edwin/hud-jefe-y-reorganizacion`, ya fusionada en `main`.
- La 0.04.047 de un compañero, que llegó en ZIP. Sus notas están en `CAMBIOS_0.04.045.txt` y `CAMBIOS_0.04.047.txt`, en la raíz del proyecto.

## HUD y jefes
- HUD del Player: vida en cuartos de corazón, carga de la Ultimate y llave.
- Barra de vida de jefe reutilizable, conectada a Capitán.
- Capitán: elige sus ataques al azar en vez de seguir un ciclo fijo y avisa visualmente antes de la Ultimate.
- Barra de vida pequeña de pixel art (24 x 4 px) sobre los enemigos normales. Aparece al recibir un golpe y se desvanece a los 3 s.

## Imagen y cámara
- Escenas y fondos reorganizados en carpetas. Filtro nearest en todo el proyecto.
- Resolución base fija de 480x270 con escalado entero y aspecto en keep.
- Cámara con zoom 2. El HUD y la barra de jefe usan la misma escala de píxel.
- Límites de cámara ajustados al borde real de cada fondo. El Player tiene un límite de caída según el borde inferior de cada mapa.
- El temblor al caminar quedó corregido con cuatro cambios:
  - pixel snapping 2D activado;
  - Camera2D sin smoothing y procesada en física;
  - `floor_snap_length` 4;
  - `safe_margin` 0.02.
- Escalas enteras para el Player (1), Cthulhu (2), los kolbo y el diablillo (1), y los decorados donde fue posible.

## Combate del Player
- Combo con varios golpes por animación (tabla `ATTACK_PROFILES`). Dura unos 2.3 s en vez de 5 s y se cancela al moverse, saltar o rodar.
- Roll más corto (unos 92 px) y ataque aéreo más rápido.
- Efectos de bloqueo, Guard Break y curación por robo de vida.
- Parry: cubrirse como mucho 0.15 s antes del golpe aturde al enemigo 0.8 s y no gasta guardia. El bloqueo normal empuja al Player unos 14 px sin quitarle vida.

## Enemigos
- IA con `enemy_base.gd` para kolbo, kolbo2, kolbo3, diablillo y mino. Opciones nuevas, todas apagadas por defecto:
  - `mirror_sprite_on_flip`: refleja el sprite alrededor del cuerpo.
  - `fly_toward_target`: el enemigo vuela hacia la altura del Player.
  - `attack_hit_windows`: varios golpes en un mismo ataque.

## Herramientas
- Constructor de mapas desde texto: `herramientas/constructor_mapas/` y `mapas_texto/`, con el tileset CC0 de `assets_prueba/dungeon_platformer/`.
- Arena de enemigos: `escenas/mapas/arena_enemigos.tscn`.
- `CLAUDE.md` con las reglas del proyecto, la estructura y cómo validar cambios.

## Lo que trae la 0.04.047 del compañero
- Cinemáticas (`scripts/cinematics/cinematic_controller.gd`) y diálogos guardados en JSON (`dialogues/`, `escenas/ui/dialogue_ui.tscn`).
- Mundo 1:
  - intro del recuerdo y reencuentro con el Capitán;
  - checkpoint con barrera antes del jefe;
  - cofre, caja y estatuas rompibles.
- Monedas y pociones en el HUD.
- Proyectiles enemigos: flechas y fuego del diablillo (`ranged_demon.gd`).
- Caballero de la Reina como jefe de 3 fases (`w2_archer_boss.gd`).

## Integración (rama `edwin/integrar-0.04.047`)
- El ZIP partía de `eabb14b`. Se guardó como el commit `zip/0.04.047` y se fusionó con `main`.
- El ícono de corazón de `imagem vidas/` mantiene su nombre original; el ZIP lo había alterado.
- Conflictos resueltos:
  - **Diablillo**: lanza fuego (la versión del compañero) y además vuela hacia la altura del Player (la versión de Edwin).
  - **Kolbo x3 y mino**: cuadros de golpe, hitbox y volteo de Edwin; vida, velocidades, daño y cooldown del compañero.
  - **Capitán**: se conservan `receive_parry` (Edwin) y `_cancel_attack` (compañero).
  - **Mundo 1**: queda como en la 0.04.047.
- Correcciones después de la integración:
  - `dialogue_ui.gd` ya no crea un tween vacío en las líneas de narración.
  - `enemy_projectile.gd` desactiva `monitoring` con `set_deferred`.
  - Ruina: se quitó una instancia del Capitán que colgaba de un kolbo. Si se le derrotaba ahí, marcaba como vencido al jefe de Mundo 1.
  - Las teclas de depuración (R/H/J/K) y el panel de depuración están apagados por defecto. Siguen activos en la arena y en los mapas que genera el constructor.

## A confirmar
- `ColisionPoligono_04` de Mundo 1: P30 dice que tenía un hueco local para atravesar el arco negro. El commit `ecad67a` ("Corregir colision de pared") y la 0.04.047 rellenaron ese hueco (x 380–437, y 440–508), y ahora la pared es recta en x 437. No se tocó; hay que confirmar con quien hizo el cambio que fue intencional.

## Pociones y muerte
- **Pociones**: se toman con **C** y cada una cura un corazón (`potion_heal_amount` en `player.gd`). No se gastan con la vida llena. El HUD muestra la tecla.
- **Muerte**: al terminar la animación, la pantalla se funde a negro con "HAS CAÍDO" y el mapa se recarga.
  - Enemigos y jefes no derrotados vuelven a su estado inicial.
  - El Player reaparece con la vida llena en el último checkpoint, o en la entrada por la que llegó al mapa.
  - Si reaparece en el checkpoint del Capitán, la barrera de la sala se vuelve a cerrar.
  - No hay vidas ni game over.
- **Qué se conserva al morir**: la llave, los jefes vencidos, las cinemáticas vistas, las monedas y las pociones.
  - Los cofres abiertos y los objetos rotos siguen así después de la recarga (`GameManager.consumed_objects`), para que no vuelvan a soltar botín.
  - Las monedas o pociones que estaban en el suelo sin recoger se pierden.
- **Opción de prueba**: `reload_map_on_death` (en `player.gd`) desactivado vuelve al comportamiento anterior, en el que el Player reaparece en el sitio sin reiniciar nada.
- **Errores corregidos**: el checkpoint del Capitán y la llave del jefe desactivaban `monitoring` dentro de `body_entered`. Ahora lo hacen con `set_deferred`.

## Diálogo del Capitán y enemigos que bloqueaban
- **Reencuentro con el Capitán** (`dialogues/w1_reencuentro_capitan.json`): usa el guion de "Cinemática 2" y pasa de 36 a 18 líneas.
  - La frase larga del Capitán se parte en dos cuadros.
  - El paneo al reino destruido va en la segunda parte.
  - Hay pausas breves antes de "Después encontramos los cuerpos..." y de "Eso haré, viejo amigo.".
- **Enemigos acorralados** (`enemy_base.gd`): si el Player está demasiado cerca y el enemigo no puede retroceder, ataca. Antes se quedaba quieto para siempre, bloqueando el paso.
- **Cuerpos sin IA**: `boss_mina` y `CharacterBody2D4` de Mundo 2, y Cthulhu del jefe final, pasan a `collision_layer = 0`. Siguen viéndose, pero ya no son paredes invisibles. Al darles IA hay que volver a ponerlos en `collision_layer = 5`.

## Niveles con tiles (constructor de mapas)
Los niveles nuevos se hacen con tiles en vez de fondos pintados. Los mapas actuales se quedan como están. La guía para el equipo está en `mapas_texto/LEYENDA.md`.

- **Nivel dibujado como imagen.** Con `imagen:` en el `.txt`, cada píxel es una pieza y cada color una letra.
  - La paleta está en `mapas_texto/paleta_niveles.gpl`, para Aseprite, GIMP, Krita y Piskel.
  - `-- --a-png` convierte un mapa de letras en PNG.
- **Tilesets como datos.** Cada tileset es un archivo en `herramientas/constructor_mapas/tilesets/` (hoy `mazmorra.gd`) y se elige con `tileset:`. Integrar un paquete nuevo es copiar ese archivo y cambiar las coordenadas de sus piezas.
- **Elementos de juego:**
  - pinchos `^` (KillZone), trampa de fuego `F` (BurnZone) y checkpoint `S`;
  - cofre `c`, moneda `$` y poción `!`;
  - salidas `>` / `<`, con su spawn de llegada.
- **Fondo con parallax:** opción `parallax:`.
- **Escenas nuevas:**
  - `escenas/sistemas/checkpoint.tscn` (`checkpoint.gd`);
  - `escenas/sistemas/trampa_fuego.tscn`;
  - `escenas/objetos/cofre.tscn`.
- **Arte derivado,** sin tocar los originales:
  - `sprites/trampas/fuego_rojo.png` es la hoja de "Red Fire Trap" reducida a 1/3. El original estaba ampliado x3, y reducido coincide píxel a píxel, así que se usa a escala 1.
  - `sprites/trampas/pinchos.png` es el recorte de `spike Trap5.png`.
- **Correcciones:**
  - Las zonas que genera el constructor (lava, escaleras) quedaban con el tamaño por defecto de su escena. Ahora tienen el de su tramo; se regeneró `ejemplo_cueva`.
  - `map_transition.gd` cambia de escena en diferido; antes daba error al cruzar una salida automática.
  - Las monedas y pociones colocadas en un mapa no reaparecen al morir.
- **Muestra:** `mapas_texto/ejemplo_nivel.txt` + `.png`. Se probó sin ventana con todos los elementos: recoger, abrir el cofre, el checkpoint, quemarse, morir en los pinchos y reaparecer con lo recogido conservado, y cruzar la salida.

## Niveles con tiles calcados de los fondos
Siete niveles nuevos con tiles, uno por cada fondo pintado, con la misma forma que su mapa hecho a mano. Los mapas originales no se tocaron.

| Nivel | Fondo | Mapa calcado | Bloques | Parallax |
|---|---|---|---|---|
| `tiles_cementerio` | `cementerio.png` | `mundo_1` | verde | pueblo de noche (Gothicvania) |
| `tiles_casa` | `casa.png` | `primer_boss_mundo_1` | violeta | interior de castillo viejo (Gothicvania) |
| `tiles_mineria` | `mineria.png` | `mundo_2` | madera | cuevas (Pixel Fantasy Caves) |
| `tiles_mazmorra` | `mazmorra.png` | `mundo_3` | oliva | interior de castillo viejo |
| `tiles_ruina` | `ruina.png` | `ruina` | ladrillo | cavernas (Gothicvania) |
| `tiles_profundidades` | `profundidades.png` | `profundidades` | oro | lava (Gothicvania) |
| `tiles_jefe` | `jefe.png` | `jefe_final` | ladrillo | lava |

- **Ruta:** cada nivel lleva al siguiente por las salidas de los bordes, en el orden de la ruta de prueba (cementerio → casa → mineria → mazmorra → ruina → profundidades → jefe). No están conectados con los mapas hechos a mano.
- **Constructor:**
  - `-- --desde-mapa <escena> <png>` calca las colisiones de un mapa hecho a mano como PNG de piezas (ver `LEYENDA.md`, sección 7).
  - `parallax:` admite `x2` para imágenes más bajas que la pantalla, y cada capa recorre el mapa en vertical en vez de quedarse fija arriba.
- **Lo que se agregó encima del calco.** Son decisiones de diseño, no vienen de los mapas originales; se cambian en el PNG:
  - salidas en los bordes, con túnel si había pared en medio;
  - escaleras donde hacían falta para unir zonas;
  - las escaleras del dibujo del fondo no son colisiones y no se calcan;
  - un checkpoint a mitad del recorrido, cofres, monedas, pociones, antorchas y decorados del tema;
  - lava en el fondo de profundidades y jefe;
  - pinchos en los pozos de mazmorra y jefe de los que no se podía salir;
  - mazmorra recortada a 71 filas, porque lo de abajo es vacío en el fondo.
- **Fuera del calco:**
  - Los jefes y personajes sin letra en el constructor: Capitán, Caballero de la Reina, Reina, Cthulhu, jefe de la mina, demonslime y jefe final.
  - Algunas cámaras cerradas por roca en mineria, mazmorra y ruina. Quedan como parte del decorado, sin acceso.
- **Arte nuevo:** solo fondos de parallax, en `assets_prueba/gothicvania/` (CC0) y `assets_prueba/pixelfantasy_caves/` (el ZIP no trae licencia; ver su `ORIGEN.txt`). Los tilesets de esos paquetes no se usan: son piezas para componer a mano, no juegos de bloques de 16 px. El terreno sigue siendo el tileset mazmorra.
- **Escaleras:** el Player mide 20 px y su caja está corrida 7 px a la izquierda del origen, así que roza una pieza a cada lado de la columna.
  - Cada escalera lleva libres las dos columnas vecinas en todo su tramo y tres filas libres arriba.
  - Cuando atraviesa un piso, el hueco es de tres piezas.
  - Las dos escaleras calcadas de `primer_boss_mundo_1` no cumplían esto en la cuadrícula de 16 px y se reemplazaron.
- **Verificado:**
  - Los siete niveles arrancan sin errores.
  - Las 12 salidas apuntan a un nivel y un spawn que existen.
  - Prueba sin ventana: el Player sube por las 32 escaleras y queda parado arriba.
  - Simulación de saltos y caídas con la física del Player:
    - desde la P se alcanzan las dos salidas, el checkpoint, los cofres, las monedas y las pociones de cada nivel;
    - no queda ninguna zona de la que no se pueda volver, salvo 3 piezas de mazmorra en la orilla de un pozo con pinchos, que se resuelven cayendo a los pinchos;
    - un enemigo de mazmorra queda en una cámara cerrada.
  - Falta jugarlos con ventana: la simulación es aproximada.
- **Corregido después:** en `tiles_jefe`, el Player llegaba junto a un hueco con escalera (x=3-5, fila 32) y caía al dar un paso. Se tapó y la escalera pasó a x=15 (hueco en x=14-16, fila 36), con suelo bajo su pie. Une la bajada con la misma cueva.
- **A confirmar:** la ruta de prueba de `primer_boss_mundo_1.tscn` tiene dos líneas de comentario (`# W2: ...`) entre sus propiedades. Godot pierde la propiedad que sigue, `spawn_position = Vector2(1535, 650)`, y queda en su valor por defecto, (160, 160): el `SpawnInicio` de ese mapa cae arriba a la izquierda. Las demás propiedades se leen bien. No se tocó.

## Encuentro del cementerio: oleadas y Capitán
El primer nivel con tiles tiene ahora un combate obligatorio. En el pasillo del suelo se enfrentan dos oleadas de esbirros y después al Capitán, y hasta derrotarlo no se puede seguir.

- **Escena:** `escenas/mapas/tiles_cementerio_combate.tscn` hereda de `tiles_cementerio.tscn` y solo añade `SistemasMapa/EncuentroCementerio`. La generada sigue saliendo del PNG y se puede regenerar sin perder el encuentro. Para jugar el nivel se abre la heredada; la salida izquierda de `tiles_casa` ya lleva a ella.
- **Flujo:**
  1. El Player entra en `Activador` (x 480–704, y 560–864).
  2. Se cierran `BarreraIzquierda` (columna 21) y `BarreraDerecha` (columna 54).
  3. Sale la oleada 1 (2 Vanguardia) y, al caer, la 2 (2 Aprendis y 1 Vanguardia).
  4. Aparece el Capitán en el `PuntosJefe` más lejano al Player.
  5. Al terminar su animación de muerte se abren las barreras y aparece el aviso "ZONA DESPEJADA".
- **Arena:** usa el techo que ya tiene el pasillo (filas 34 y 43), así que no se tocó ninguna colisión. El salto del Player (unos 104 px) no alcanza el bloque flotante de arriba. Las barreras se dibujan con la columna del juego de bloques verde del tileset mazmorra, sin arte nuevo.
- **Scripts nuevos:**
  - `scripts/combat/arena_encounter.gd` (`UnderkingdomArenaEncounter`):
    - estados: inactivo → oleadas → entre oleadas → presentación del jefe → jefe → completado;
    - señales: `combat_started`, `wave_started`, `wave_cleared`, `boss_spawned`, `boss_defeated` y `encounter_completed`;
    - cada enemigo se sigue por su señal `died`, o por `tree_exiting` si desaparece sin morir;
    - los enemigos y el jefe se agregan al nodo `Enemigos` del mapa.
  - `scripts/combat/arena_spawn_point.gd`: un `Marker2D` por enemigo, con su `enemy_scene`. Cada hijo de `Oleadas` es una oleada.
  - `scripts/environment/arena_barrier.gd`: muro que se abre y se cierra con un fundido.
- **Capitán reutilizado:** se instancia `escenas/jefes/capitan.tscn` sin cambios en stats, IA, fases ni barra de vida. El `@export` nuevo `counts_as_world1_boss` (activo por defecto, así Mundo 1 no cambia) se apaga en el cementerio con `boss_overrides`: ese Capitán no lee ni marca el progreso de Mundo 1 y no suelta la llave de la reja.
- **Progreso:** `GameManager.completed_encounters` guarda los encuentros superados; métodos `mark_encounter_completed()` e `is_encounter_completed()` y señal `encounter_completed`. Si el Player muere durante el combate, el mapa se recarga y el encuentro empieza de cero. Una vez superado no se repite, ni al morir ni al volver desde `tiles_casa`.
- **Sin audio:** el proyecto no tiene sistema de sonido ni música. Cuando exista, la música de jefe puede colgarse de `boss_spawned` y `encounter_completed`.
- **Verificado sin ventana:**
  - arranque de la escena nueva, de la generada, de `tiles_casa` y de Mundo 1 sin errores;
  - el flujo completo con sus señales en orden y cada oleada una sola vez;
  - las barreras detienen al Player a los dos lados y no se pueden saltar; abiertas dejan pasar;
  - tras la victoria `world1_boss_defeated` sigue en falso y no aparece la llave;
  - al recargar el mapa, el encuentro sigue completado;
  - el Capitán de Mundo 1 conserva `counts_as_world1_boss` y el grupo `world1_boss`.
- **Falta jugarlo con ventana:**
  - si el Capitán (sprite de 288 px) se ve bien en una arena de 512 px;
  - la dificultad de las oleadas;
  - que los Aprendis, que vuelan, no se queden fuera del alcance del Player.

## Pendientes, en orden de prioridad
1. Probar jugando: la intro, el reencuentro con el Capitán, el combate y la muerte con reaparición en el checkpoint. Ninguna de las dos versiones del compañero se había ejecutado en Godot.
2. Pausa, menú principal y guardado persistente. Hoy todo se pierde al cerrar el juego.
3. Jefe de Mundo 2 (`escenas/jefes/boss_mina.tscn`) y jefe final (Cthulhu, `escenas/jefes/boss.tscn`): los dos son sprites sin script. Nadie llama a `GameManager.reveal_cthulhu()`.
4. Transiciones definitivas para reemplazar los portales de `world_test_route.gd`, y zonas Kill, Burn y One Way en los mapas. `pinchos` y `trampa de fuego` de Mundo 1 no hacen daño. Las marcas las coloca una persona en el editor o las pasa como coordenadas.
5. Audio: no hay ningún sonido ni música.
6. Arte a escala entera:
   - la caja y las estatuas rompibles son arte en alta resolución reducido a 0.08–0.13 y necesitan sprites nuevos;
   - los diablillos del castillo están entre 0.34 y 0.66;
   - `trampa de fuego` está a 0.352.

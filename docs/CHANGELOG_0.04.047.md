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

## Cementerio con tiles: primer mundo estilo Hollow Knight
`tiles_cementerio` pasa a ser un mundo para explorar. Hay un hub con caminos, una cripta opcional, catacumbas, una sala del jefe que se cierra al entrar, una llave y una puerta que la pide para llegar a la salida. Reemplaza al primer intento con oleadas, que se descartó.

**Trazado** (`mapas_texto/tiles_cementerio.png`, 120 x 78 piezas; coordenadas en piezas). Siguiendo el lore, el mundo se recorre bajando: se empieza en la superficie y la puerta al siguiente mundo está en el fondo del mapa.
```
 fila 7-14                 [CRIPTA: cofre, poción, Aprendis]
                            ↑ plataformas one-way desde el mausoleo
 fila 29  P ENTRADA ── HUB (mausoleo, S) ── SUPERFICIE ESTE
          ════════╤══════════════════════╤════════════════
                  │ atajo (x 25)          │ pozo (x 64)
 fila 40-47       │        CATACUMBAS 1 (enemigos, cofre)
                  │          │ escalera (x 45)
 fila 46-56  [SALA DEL JEFE]┃ S  CATACUMBAS 2 ──┐
             x 6-36  puerta (columna 37)        │ pozo del abismo (x 67)
 fila 62-75                 ABISMO: plataformas, foso de lava, S ┃PUERTA CON LLAVE┃──> siguiente mundo
                                                         (columna 109, filas 72-75)
```
- **Recorrido:**
  1. Se explora la superficie y la cripta, y se baja por el pozo a las catacumbas.
  2. En las catacumbas 2 hay un checkpoint justo antes de la sala del jefe.
  3. Al entrar en la sala se cierra la puerta y aparece el Capitán.
  4. Al vencerlo se abre la puerta, cae la llave y se abre la trampilla del atajo, que sube directo al hub.
  5. Desde el este de las catacumbas 2 se baja por el pozo del abismo hasta la caverna del fondo. Tiene plataformas, un foso de lava y un checkpoint junto a la puerta.
  6. Con la llave se abre la puerta y se llega a la salida, en el borde derecho del fondo del mapa, hacia `tiles_casa`.

  Al abismo se puede bajar antes de vencer al jefe: se ve la puerta cerrada y se puede volver a subir.
- **Contenido:** 13 enemigos (Vanguardia y Aprendis), 3 checkpoints (hub, antesala del jefe y fondo del abismo), 2 cofres, 13 monedas y 3 pociones.
- **Por qué la salida es lateral:** el constructor solo crea salidas en los bordes izquierdo y derecho. La salida está en el borde derecho, pero en el punto más profundo del mapa. Una salida en el suelo necesitaría cambiar el constructor y decidir cómo se vuelve hacia arriba desde el mapa siguiente.
- **Comprobado con una simulación aproximada de saltos sobre el PNG** (escalones de 4 piezas como máximo, huecos de 5 y lava mortal):
  - sin la llave se alcanza todo menos la salida;
  - desde la sala del jefe se llega a la puerta del abismo y, con la llave, a la salida;
  - desde la puerta del abismo, o al llegar desde `tiles_casa`, se vuelve a la superficie;
  - quien baja por el atajo antes del jefe puede volver a subir;
  - con la sala cerrada no se sale de ella.
  El script de diseño y el verificador están fuera del repo, igual que los anteriores (ver TASK.md).

**Escena:** `escenas/mapas/tiles_cementerio_combate.tscn` hereda de la generada y añade:
- `SistemasMapa/SalaJefe`, con `scripts/combat/boss_arena.gd` (`UnderkingdomBossArena`):
  - `Activador`;
  - `Puertas/PuertaEntrada`: se cierra durante el combate;
  - `Atajos/Trampilla`: cerrada hasta vencer al jefe;
  - `PuntosJefe`: el jefe sale en el más lejano al Player;
  - `PuntoLlave`;
  - el aviso en pantalla;
  - señales `combat_started`, `boss_spawned`, `boss_defeated`, `encounter_completed` y `key_dropped`.
- `SistemasMapa/PuertaLlave` (fondo del abismo), con `scripts/environment/locked_door.gd`:
  - se abre al llegar con la llave `cementerio_capitan`;
  - sin ella muestra "NECESITAS LA LLAVE DEL CAPITÁN";
  - una vez abierta queda abierta, guardada como objeto consumido igual que los cofres.

Las puertas y la trampilla (`scripts/environment/arena_barrier.gd`) se dibujan con piezas del bloque verde del tileset: la columna para las verticales y la losa para la horizontal.

**Capitán y llave:**
- **Capitán:** se instancia `escenas/jefes/capitan.tscn` sin cambios. El `@export` `counts_as_world1_boss` (activo por defecto) se apaga con `boss_overrides`, así que este Capitán no toca el progreso de Mundo 1.
- **Llaves genéricas en `GameManager`:**
  - `collected_keys`, `grant_key()`, `has_key()`, `has_any_key()` y la señal `key_changed`;
  - la llave de Mundo 1 sigue con sus funciones propias;
  - `boss_key_pickup.gd` tiene un `key_id`: vacío se comporta como antes; con valor da esa llave;
  - el HUD muestra el icono con cualquier llave.
- **Persistencia:**
  - `GameManager.completed_encounters` guarda la sala superada;
  - si se muere antes de recoger la llave, al recargar la llave vuelve a estar en la sala;
  - si se muere durante el combate, la sala se reinicia y se reaparece en el checkpoint de la antesala.

**Verificado sin ventana:**
- arranque de Mundo 1, `primer_boss_mundo_1`, `tiles_casa`, la escena generada y la heredada sin errores;
- la puerta del fondo bloquea sin llave y se abre con ella;
- el flujo completo, con las señales en orden;
- la puerta con llave y la trampilla bloquean al Player y, abiertas, dejan pasar;
- la puerta de la sala lo encierra durante el combate;
- la llave reaparece tras recargar si no se recogió;
- la puerta sigue abierta tras recargar;
- `world1_boss_defeated` y la llave de Mundo 1 no cambian.

**Falta jugarlo con ventana:**
- la dificultad y el reparto de enemigos;
- si el Capitán se ve bien en una sala de 496 x 176 px con dos plataformas;
- que la escalera del atajo dentro de la sala no estorbe el combate;
- el parallax de cielo se ve también en las catacumbas y el abismo, porque el constructor no tiene fondo por zonas;
- el foso de lava del abismo es decisión de diseño: avisa de que se baja hacia el infierno;
- los mapas siguientes de la ruta (`tiles_casa`...) no siguen todavía la idea de bajar;
- la llave (`llave_jefe_m1.tscn`) tiene el sprite a escala 1,5, que no es entera.

## Minas con tiles: segundo mundo
`tiles_mineria` deja de ser un calco y pasa a ser el segundo mundo, con la misma estructura que el cementerio: bocamina, galerías, sala del jefe que se cierra al entrar, llave y puerta en el fondo del mapa. La salida del abismo del cementerio lleva ahora aquí, así que la ruta sigue bajando. `tiles_casa` queda fuera de la ruta por ahora: es una casa y no encaja bajo tierra. El archivo se conserva.

**Trazado** (`mapas_texto/tiles_mineria.png`, 104 x 90 piezas; coordenadas en piezas):
```
 fila 3-11  < BOCAMINA: campamento minero, S ─────────────┐
                                                          │ pozo principal (x 49)
 fila 21-27      GALERÍA 1: taller, S ── gruta de cristales, cofre
                 │ atajo (x 25)          │
 fila 36-43      │                       GALERÍA 2: mino ──┐
                 │                       │                 │ pozo este (x 85)
 fila 48-60 [SALA DEL JEFE]┃ ANTECÁMARA, S ──┐             │
            x 6-36  puerta (columna 37)      │ pozo (x 67)  │
 fila 72-85                 VETA ARDIENTE: lava, fuego, diablillos, S ┃PUERTA CON LLAVE┃──> tiles_mazmorra
                                                              (columna 92, filas 82-85)
```
- **Recorrido:**
  1. Se llega desde el fondo del cementerio a la bocamina, por el borde izquierdo de arriba. La salida morada lleva de vuelta.
  2. El pozo principal baja por la galería 1 y la galería 2 hasta la antecámara, que tiene un checkpoint junto a la sala del jefe.
  3. Al entrar en la sala se cierra la puerta y aparece el Caballero de la Reina.
  4. Al vencerlo se abre la puerta, cae la llave y se abre la trampilla del atajo, que sube al checkpoint de la galería 1.
  5. A la veta ardiente se baja por el pozo de la antecámara o por el pozo este de la galería 2. Tiene dos fosos de lava con plataformas, trampas de fuego, diablillos y un checkpoint junto a la puerta: el calor anuncia que se baja hacia el infierno.
  6. Con la llave se abre la puerta y se llega a la salida, en el borde derecho del fondo, hacia `tiles_mazmorra`.
- **Contenido:**
  - 13 enemigos: 4 kolbo, 3 kolbo2, 2 kolbo3, 2 mino y 2 diablillos;
  - 4 checkpoints: bocamina, galería 1, antecámara y veta ardiente;
  - 1 cofre, 12 monedas, 3 pociones y 2 trampas de fuego;
  - 4 escaleras;
  - bloques `madera` y el parallax de cuevas que ya tenía el nivel.
- **Comprobado con la simulación de saltos sobre el PNG:**
  - sin la llave se alcanza todo menos la salida;
  - con la trampilla abierta se sube de la sala del jefe a la galería 1;
  - desde la llegada del mapa siguiente se vuelve a la bocamina.

**Escena:** `escenas/mapas/tiles_mineria_combate.tscn` hereda de la generada y tiene las mismas piezas que la del cementerio:
- `SistemasMapa/SalaJefe` (`encounter_id` y `key_id` `minas_caballero`);
- `SistemasMapa/PuertaLlave`, que pide esa llave y muestra "NECESITAS LA LLAVE DEL CABALLERO".

No hizo falta código nuevo.

**Jefe:** `escenas/jefes/caballero_reina.tscn` hereda del elfo arquero (`escenas/enemigos/enemis.tscn`, `w2_archer_boss.gd`, tres fases).
- Lleva los valores que tenía en `primer_boss_mundo_1` (12 de vida, alcance de detección...) y su `BossHealthBar`.
- No se le conecta `w2_queen_knight_progress.gd`, así que no toca el progreso del mapa viejo.
- **IA rehecha** (`scripts/bosses/w2_archer_boss.gd`), tras probarlo: no hacía daño y apenas se movía.
  - **No hacía daño:** la flecha salía 60 px por encima del arco y apuntaba al origen del Player, que también queda por encima de su colisión, así que siempre pasaba por arriba. Ahora sale del arco y apunta al centro del cuerpo del Player.
  - **El disparo duraba 2,7 s:** "attack inicial" junta dos ataques, y la flecha salía al final del primero. El disparo termina ahora en el cuadro 12 y suelta la flecha en el 8. La segunda mitad es la lluvia de flechas: desde la fase 2 caen 3 flechas sobre el Player, y 4 en la fase 3.
  - **Se movía mal:** huía corriendo de espaldas y, contra la pared, se quedaba quieto disparando. Ahora corre de frente, se gira para disparar y rueda cuando el Player se le pega: si tiene espacio, alejándose; si está arrinconado, a través del Player, con invulnerabilidad al principio del roll.
  - Cada golpe lo dejaba quieto 1,2 s (la animación de daño); ahora 0,3 s.
  - Daño: 0,5 de cerca a 0,75 de lejos; la lluvia, 0,5 por flecha.

**Ruta:** `tiles_cementerio` → `tiles_mineria` → `tiles_mazmorra` → ...
- Para no regenerar con cambios de unique_id, se editó solo la línea `target_scene_path` en `tiles_cementerio.tscn` (salida siguiente) y en `tiles_mazmorra.tscn` (salida anterior). Ahora apuntan a `tiles_mineria_combate.tscn`.
- También se actualizaron sus `.txt`.

**Verificado sin ventana:**
- el arranque de la escena sin errores;
- el Player queda de pie en las dos llegadas;
- los enemigos se asientan en el suelo;
- la puerta del fondo bloquea sin llave;
- al entrar en la sala se cierra la puerta y no deja salir al Player;
- el Caballero aparece en el punto más lejano, con barra de vida, y queda en el suelo;
- al vencerlo se abren la puerta y la trampilla, se guarda la sala y cae la llave;
- al recargar, la llave vuelve si no se recogió y el jefe no reaparece;
- con la llave la puerta se abre y sigue abierta tras recargar;
- la llave de Mundo 1 no cambia.

**Falta jugarlo con ventana:**
- el combate contra el arquero en una sala de 496 x 208 px con tres plataformas, y si la escalera del atajo dentro de la sala estorba;
- la dificultad de la veta ardiente: fuego, diablillos y mino juntos;
- el icono de llave del HUD sigue encendido con la llave del cementerio, porque las puertas no gastan la llave. No avisa de que se ha conseguido la nueva.

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

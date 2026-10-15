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

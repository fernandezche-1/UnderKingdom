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

## Pendientes, en orden de prioridad
1. Probar jugando la 0.04.047: la intro, el reencuentro con el Capitán, el combate y la muerte con reintento. Ninguna de las dos versiones del compañero se había ejecutado en Godot.
2. Pociones usables: se recogen, pero no hay forma de tomarlas.
3. Muerte y reintento reales. Hoy el Player reaparece con la vida llena, sin reiniciar enemigos ni jefes, y no hay game over.
4. Pausa, menú principal y guardado persistente. Hoy todo se pierde al cerrar el juego.
5. Jefe de Mundo 2 (`escenas/jefes/boss_mina.tscn`) y jefe final (Cthulhu, `escenas/jefes/boss.tscn`): los dos son sprites sin script. Nadie llama a `GameManager.reveal_cthulhu()`.
6. Transiciones definitivas para reemplazar los portales de `world_test_route.gd`, y zonas Kill, Burn y One Way en los mapas. `pinchos` y `trampa de fuego` de Mundo 1 no hacen daño. Las marcas las coloca una persona en el editor o las pasa como coordenadas.
7. Audio: no hay ningún sonido ni música.
8. Arte a escala entera:
   - la caja y las estatuas rompibles son arte en alta resolución reducido a 0.08–0.13 y necesitan sprites nuevos;
   - los diablillos del castillo están entre 0.34 y 0.66;
   - `trampa de fuego` está a 0.352.

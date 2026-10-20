# UnderKingdom

Plataformero de acción 2D en Godot 4.7 (GDScript), pixel art. Repo de Armando Che; colaboradores trabajan en ramas propias. Responder en español.

## Mapas en uso (leer primero)

- **La estructura del juego a partir de ahora son los niveles con tiles (`escenas/mapas/tiles_*`).** Todo trabajo nuevo de mapas, progresión, jefes y ruta va ahí.
- **Mapas aparte, por el momento sin uso:** `mundo_1.tscn` y los demás mapas hechos a mano (`primer_boss_mundo_1`, `mundo_2`, `mundo_3`, `ruina`, `profundidades`, `jefe_final`, ejemplos y arenas de prueba).
  - No se borran ni se modifican salvo que se pida.
  - No se toman como referencia de diseño.
  - No se conectan con la ruta de tiles.
- **Lore y diseño: el juego se recorre bajando**, de la tierra a los abismos y al infierno, al estilo de Terraria.
  - Cada mundo es un mapa para explorar al estilo Hollow Knight: zonas, atajos, checkpoints, enemigos repartidos y una sala de jefe.
  - La sala del jefe se cierra al entrar. Al vencerlo cae una llave, y esa llave abre la puerta al mundo siguiente, que está en la parte más profunda del mapa.
  - Los enemigos cambian conforme se baja: personas y bichos comunes arriba, criaturas en medio, demonios al fondo. Cada mundo usa solo los de su profundidad (tabla en `docs/P33_ENEMIGOS_POR_PROFUNDIDAD.md`); no mezclar enemigos de otro nivel.
- **Primer mundo, el cementerio:** se juega desde `tiles_cementerio_combate.tscn`, que hereda de la escena generada `tiles_cementerio.tscn`.
  - Trazado y coordenadas: `mapas_texto/tiles_cementerio.txt` y `docs/CHANGELOG_0.04.047.md`, sección "Cementerio con tiles".
  - Es el modelo para los mundos siguientes.
- **Segundo mundo, las minas:** se juega desde `tiles_mineria_combate.tscn`, que hereda de `tiles_mineria.tscn`. Su jefe es el Caballero de la Reina (`escenas/jefes/caballero_reina.tscn`). Trazado en `mapas_texto/tiles_mineria.txt` y en el changelog, sección "Minas con tiles".
- **Ruta actual:** `tiles_cementerio` → `tiles_mineria` → `tiles_mazmorra` → `tiles_ruina` → `tiles_profundidades` → `tiles_jefe`. Desde la mazmorra, los mapas todavía no siguen la idea de bajar ni tienen sala de jefe (ver `TASK.md`). `tiles_casa` quedó fuera de la ruta.
- **Cómo se monta un mundo:**
  - El trazado se dibuja en el PNG y la escena base la genera el constructor; no se edita a mano.
  - Jefe, puertas y llave van en una escena que hereda de la base. Así se puede regenerar sin perderlos.
  - Piezas a reutilizar:
    - `scripts/combat/boss_arena.gd`: sala de jefe, con `Puertas`, `Atajos`, `PuntosJefe` y `PuntoLlave`;
    - `scripts/environment/locked_door.gd`: puerta con llave;
    - `scripts/environment/arena_barrier.gd`: puertas y trampillas;
    - en `GameManager`, las llaves genéricas (`grant_key` / `has_key`) y `completed_encounters`.
  - Los jefes se reutilizan por su `.tscn`. El Capitán va con `counts_as_world1_boss = false`. Si un jefe necesita otros valores o su `BossHealthBar`, se le hace una escena heredada en `escenas/jefes/`, como `caballero_reina.tscn`.
  - Las salidas se cambian en el `.txt` del mapa y, para no regenerar, solo en la línea `target_scene_path` del `.tscn`. Apuntan a la escena `_combate` cuando el mapa la tiene.
  - La llave y el progreso de Mundo 1 (`world1_*`) son del mapa viejo: no usarlos en los mapas nuevos.

## Reglas del proyecto

- Las colisiones sólidas de los mapas que ya se validaron jugando no se redibujan ni se eliminan. Si un cambio las afecta, preguntar antes.
- No tocar los ajustes que quitaron el temblor al caminar salvo que se pida: smoothing de la Camera2D (desactivado, proceso en física), pixel snapping 2D, `floor_snap_length` (4) y `safe_margin` (0.02) del Player.
- La vida se mide en cuartos de corazón: 4 corazones al empezar y hasta 6 con la mejora de vida máxima; 0.25 es el daño mínimo. Toda curación y todo daño van en múltiplos de 0.25.
- Colores de las marcas en los mapas: verde = plataforma one-way, rojo/rosado = kill zone, blanco = burn zone, azul = transición al mapa siguiente, morado = transición al mapa anterior, amarillo = puerta interna.
- Las zonas que dependen de marcas visuales las coloca una persona en el editor o pasa coordenadas; no inferir su posición por la forma o el color de una colisión.
- (Mapa viejo) `PuertaJefeM1Bloqueo`, `PasoPuertaWS` y `OneWayPasoPuertaWS` de Mundo 1 no se mueven ni se modifican (secuencia Capitán → llave → reja).
- Pixel art: filtro nearest, resolución base 480x270 con escalado entero, sprites a escala entera (1 o 2). No usar escalas no enteras ni estirar sprites.

## Estructura

- `escenas/mapas/tiles_*`: los mapas en uso. Cada uno se genera con el constructor y tiene un nodo `SistemasMapa` (MapBounds, spawns, escaleras, checkpoints, transiciones). Los que llevan jefe o puertas tienen además una escena heredada, como `tiles_cementerio_combate.tscn`.
- `escenas/mapas/` (mapas viejos, sin uso por ahora): mundo_1, primer_boss_mundo_1, mundo_2, mundo_3, ruina, profundidades, jefe_final. Cada uno es un PNG de `fondos/` cortado en tiles de 16 px más colisiones dibujadas a mano.
- `escenas/menu/`: menú principal y menú de pausa (autoload `PauseMenu`, `scripts/ui/pause_menu_*.gd`; pestañas de estadísticas, llaves y mejoras compradas con monedas, definidas en `GameManager.UPGRADE_DEFINITIONS`). "Nueva partida" llama a `GameManager.reset_for_new_game()`: toda variable de progreso nueva se reinicia ahí.
- `escenas/enemigos/`, `escenas/jefes/`, `escenas/player.tscn`, `escenas/sistemas/` (one-way, kill zone, burn zone, climb zone, transición, spawn point), `escenas/items/`, `escenas/ui/`.
- `scripts/`: `player/player.gd`, `combat/enemy_base.gd` (base de todo enemigo con IA), `bosses/captain_boss.gd`, `core/game_manager.gd` (autoload `GameManager`), `ui/` (HUD, barra de jefe, barra de enemigo), `fx/combat_fx.gd`, `transitions/`, `environment/`, `camera/`.
- `docs/`: historial de cada etapa (P1…P30). Es la fuente de verdad de lo decidido y lo pendiente; documentar etapas nuevas con el mismo formato.
- Niveles con tiles: `mapas_texto/<nivel>.txt` (opciones) + `<nivel>.png` (un píxel = una pieza) o mapa de letras, y `herramientas/constructor_mapas/construir_mapa.tscn` genera la escena; guía, colores y letras en `mapas_texto/LEYENDA.md`; cada tileset se define en `herramientas/constructor_mapas/tilesets/<nombre>.gd` (hoy `mazmorra`, CC0 en `assets_prueba/dungeon_platformer/`). Nunca sobrescribe mapas hechos a mano.

## Combate (resumen)

- Las animaciones del combo del Player son acumulativas: "attack 2" repite el tajo de "attack" y "attack 3" repite todo "attack 2". `ATTACK_PROFILES` en `player.gd` define en qué cuadro arranca cada etapa y sus ventanas de golpe.
- Golpes intermedios de una ráfaga usan `take_continuous_damage_from` (sin empuje ni invulnerabilidad); el último usa `take_damage_from` (empuja).
- Los enemigos deben estar en la capa de colisión 3 (valor 4, `collision_layer = 5`): la AttackHitbox del Player solo detecta esa capa.

## Validar cambios

- Arranque sin errores: `godot --headless --quit-after 120` desde la raíz del proyecto. Abre el menú principal (`escenas/menu/menu_principal.tscn`), que es la escena principal.
- El cementerio, donde arranca "Nueva partida": `godot --headless res://escenas/mapas/tiles_cementerio_combate.tscn --quit-after 120`.
- Mundo 1, el mapa viejo: `godot --headless res://escenas/mapas/mundo_1.tscn --quit-after 120`. Comprobarlo cuando se toquen scripts compartidos (Player, enemigos, GameManager, Capitán).
- Un mapa concreto: `godot --headless res://escenas/mapas/<mapa>.tscn --quit-after 60`.
- Tras crear un script con `class_name` nuevo, correr `godot --headless --import` para actualizar la caché de clases.
- `godot --check-only --script <archivo>` da un falso "Identifier not found: GameManager" en scripts que usan el autoload; no usarlo como prueba.
- Para probar lógica sin ventana: una escena temporal con un script que instancia lo necesario, simula entradas con `Input.parse_input_event` y hace `print`; borrarla al terminar.

## Forma de trabajo

- Un commit por cambio que funcione. No hacer push sin que se pida.
- Al editar un `.tscn`, avisar cuál para que se recargue en el editor sin guardar encima.
- Armando ha pasado versiones en ZIP: nunca extraer una versión encima de la carpeta de trabajo; traerla a una rama aparte y fusionar.
- Aplica siempre Static Typing (var speed: float = 200.0, func take_damage(amount: int) -> void:)

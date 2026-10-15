# UnderKingdom

Plataformero de acción 2D en Godot 4.7 (GDScript), pixel art. Repo de Armando Che; colaboradores trabajan en ramas propias. Responder en español.

## Reglas del proyecto

- Las colisiones sólidas de los mapas que ya se validaron jugando no se redibujan ni se eliminan. Si un cambio las afecta, preguntar antes.
- No tocar los ajustes que quitaron el temblor al caminar salvo que se pida: smoothing de la Camera2D (desactivado, proceso en física), pixel snapping 2D, `floor_snap_length` (4) y `safe_margin` (0.02) del Player.
- La vida se mide en cuartos de corazón: 4 corazones máximo, 0.25 es el daño mínimo.
- Colores de las marcas en los mapas: verde = plataforma one-way, rojo/rosado = kill zone, blanco = burn zone, azul = transición al mapa siguiente, morado = transición al mapa anterior, amarillo = puerta interna.
- Las zonas que dependen de marcas visuales las coloca una persona en el editor o pasa coordenadas; no inferir su posición por la forma o el color de una colisión.
- `PuertaJefeM1Bloqueo`, `PasoPuertaWS` y `OneWayPasoPuertaWS` de Mundo 1 no se mueven ni se modifican (secuencia Capitán → llave → reja).
- Pixel art: filtro nearest, resolución base 480x270 con escalado entero, sprites a escala entera (1 o 2). No usar escalas no enteras ni estirar sprites.

## Estructura

- `escenas/mapas/`: mundo_1 (escena principal), primer_boss_mundo_1, mundo_2, mundo_3, ruina, profundidades, jefe_final. Cada mapa es un PNG de `fondos/` cortado en tiles de 16 px más colisiones dibujadas a mano, y un nodo `SistemasMapa` (MapBounds, spawns, zonas, ruta de prueba).
- `escenas/enemigos/`, `escenas/jefes/`, `escenas/player.tscn`, `escenas/sistemas/` (one-way, kill zone, burn zone, climb zone, transición, spawn point), `escenas/items/`, `escenas/ui/`.
- `scripts/`: `player/player.gd`, `combat/enemy_base.gd` (base de todo enemigo con IA), `bosses/captain_boss.gd`, `core/game_manager.gd` (autoload `GameManager`), `ui/` (HUD, barra de jefe, barra de enemigo), `fx/combat_fx.gd`, `transitions/`, `environment/`, `camera/`.
- `docs/`: historial de cada etapa (P1…P30). Es la fuente de verdad de lo decidido y lo pendiente; documentar etapas nuevas con el mismo formato.
- Niveles con tiles: `mapas_texto/<nivel>.txt` (opciones) + `<nivel>.png` (un píxel = una pieza) o mapa de letras, y `herramientas/constructor_mapas/construir_mapa.tscn` genera la escena; guía, colores y letras en `mapas_texto/LEYENDA.md`; cada tileset se define en `herramientas/constructor_mapas/tilesets/<nombre>.gd` (hoy `mazmorra`, CC0 en `assets_prueba/dungeon_platformer/`). Nunca sobrescribe mapas hechos a mano.

## Combate (resumen)

- Las animaciones del combo del Player son acumulativas: "attack 2" repite el tajo de "attack" y "attack 3" repite todo "attack 2". `ATTACK_PROFILES` en `player.gd` define en qué cuadro arranca cada etapa y sus ventanas de golpe.
- Golpes intermedios de una ráfaga usan `take_continuous_damage_from` (sin empuje ni invulnerabilidad); el último usa `take_damage_from` (empuja).
- Los enemigos deben estar en la capa de colisión 3 (valor 4, `collision_layer = 5`): la AttackHitbox del Player solo detecta esa capa.

## Validar cambios

- Arranque sin errores: `godot --headless --quit-after 120` desde la raíz del proyecto (ejecuta Mundo 1).
- Un mapa concreto: `godot --headless res://escenas/mapas/<mapa>.tscn --quit-after 60`.
- Tras crear un script con `class_name` nuevo, correr `godot --headless --import` para actualizar la caché de clases.
- `godot --check-only --script <archivo>` da un falso "Identifier not found: GameManager" en scripts que usan el autoload; no usarlo como prueba.
- Para probar lógica sin ventana: una escena temporal con un script que instancia lo necesario, simula entradas con `Input.parse_input_event` y hace `print`; borrarla al terminar.

## Forma de trabajo

- Un commit por cambio que funcione. No hacer push sin que se pida.
- Al editar un `.tscn`, avisar cuál para que se recargue en el editor sin guardar encima.
- Armando ha pasado versiones en ZIP: nunca extraer una versión encima de la carpeta de trabajo; traerla a una rama aparte y fusionar.

# Underkingdom — P1: sistemas base del mapa

Esta versión parte del P0 que ya fue validado por el usuario.

## Implementado

### One Way
`res://escenas/sistemas/one_way_platform.tscn`

- `StaticBody2D`
- `CollisionShape2D`
- `one_way_collision = true`
- margen inicial de 6 px
- permite atravesar desde abajo y aterrizar arriba

La acción de bajar voluntariamente con S/abajo se implementará junto con el Player,
porque requiere controlar temporalmente cómo el jugador interactúa con la plataforma.

### KillZone
`res://escenas/sistemas/kill_zone.tscn`

Script:
`res://scripts/environment/kill_zone.gd`

Busca un cuerpo del grupo `player`.
Al entrar intenta, en este orden:
1. `die()`
2. `kill()`
3. `take_damage(9999)`

### BurnZone
`res://escenas/sistemas/burn_zone.tscn`

Script:
`res://scripts/environment/burn_zone.gd`

Parámetros editables en el Inspector:
- `damage_per_tick = 0.25`
- `tick_interval = 0.50`
- `damage_immediately = false`
- `player_group = "player"`

Con la escala de vida acordada:
- 1 tic = 1/4 de corazón
- 4 tics = 1 corazón

## Organización agregada a los mapas

Cada mapa principal incluye ahora:

```
SistemasMapa
├── PlataformasOneWay
├── KillZones
├── BurnZones
├── Transiciones
├── PuertasLaberinto
└── Cinematicas
```

No se movieron ni eliminaron las colisiones P0 ya validadas.

## Importante

En esta etapa se crearon los sistemas reutilizables y los contenedores,
pero NO se reasignaron automáticamente las colisiones existentes a verde/rojo/blanco.
Esas intenciones están documentadas principalmente mediante capturas y no como
metadatos dentro de los `.tscn`; reasignarlas por forma o color inferido podría
convertir una pared sólida en One Way o una plataforma segura en una zona letal.

El siguiente paso es colocar/convertir cada zona usando las referencias visuales
de cada mapa, sin alterar las colisiones sólidas ya confirmadas.

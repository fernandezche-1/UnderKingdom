# Underkingdom — P4: escaleras/rampas y base de transiciones

## Escaleras y rampas

El Player ahora admite dos comportamientos:

### Rampas/escaleras diagonales del escenario
Se aumentó el ángulo máximo de piso a 60° y se añadió `floor_snap_length`.
Esto permite recorrer las escaleras diagonales existentes usando A/D de forma natural,
siempre que su CollisionPolygon2D siga la pendiente visual.

### ClimbZone
Para escaleras verticales o zonas donde se necesite trepar:

- W / ↑ = subir
- S / ↓ = bajar
- A / D = moverse lateralmente
- al salir del Area2D vuelve la gravedad normal

Escena reutilizable:
`res://escenas/sistemas/climb_zone.tscn`

## Transiciones

Se añadió infraestructura reutilizable:

- `GameManager` como Autoload.
- `map_transition.tscn`
- `spawn_point.tscn`
- `map_spawn_controller.gd`

Las transiciones guardan un `target_spawn_id`, cambian de escena y, en el mapa
destino, el Player puede colocarse en el SpawnPoint correspondiente.

### Convención pendiente de colocar

- Azul = siguiente mapa
- Morado = mapa anterior

No se colocaron todavía los Area2D azul/morado exactos porque sus coordenadas
provienen de las marcas visuales de cada mapa. La lógica ya está lista para usarse
cuando se coloquen esas zonas.

## Mundo 1

Se añadió `SpawnInicio` utilizando la posición actual del Player para que el nuevo
sistema no cambie el punto de inicio que ya funcionaba.

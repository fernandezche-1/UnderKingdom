extends Marker2D
class_name UnderkingdomArenaSpawnPoint

## Punto de aparición de un enemigo de oleada. Cada oleada de un
## UnderkingdomArenaEncounter es un nodo (Oleada1, Oleada2...) cuyos hijos son
## estos puntos; al empezar la oleada se instancia enemy_scene aquí.
## Se coloca donde debe quedar el origen del enemigo (los que tienen gravedad
## pueden ir un poco por encima del suelo y caen solos).

@export var enemy_scene: PackedScene

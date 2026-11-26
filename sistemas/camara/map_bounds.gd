extends Node2D
class_name UnderkingdomMapBounds

## Límites reales del arte/mapa. La Camera2D nunca debe mostrar fuera de aquí.
@export var left: int = 0
@export var top: int = 0
@export var right: int = 1672
@export var bottom: int = 941

func _ready() -> void:
    add_to_group("map_bounds")


func apply_to(camera: Camera2D) -> void:
    camera.limit_left = left
    camera.limit_top = top
    camera.limit_right = right
    camera.limit_bottom = bottom
    camera.limit_smoothed = false

extends Camera2D
class_name UnderkingdomBoundedCamera

## Cámara reutilizable para todos los mapas.
## Lee automáticamente el nodo del grupo `map_bounds`.

@export var enable_position_smoothing: bool = false
@export_range(0.1, 20.0, 0.1) var smoothing_speed: float = 7.0

func _ready() -> void:
    process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
    position_smoothing_enabled = false
    position_smoothing_speed = smoothing_speed
    limit_smoothed = false

    # Esperar un frame garantiza que el MapBounds de la escena ya entró al árbol.
    call_deferred("_apply_current_map_bounds")


func _apply_current_map_bounds() -> void:
    var bounds := get_tree().get_first_node_in_group("map_bounds")

    if bounds == null:
        push_warning("No se encontró MapBounds en el mapa actual.")
        return

    if bounds.has_method("apply_to"):
        bounds.call("apply_to", self)

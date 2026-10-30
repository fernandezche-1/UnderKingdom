extends Camera2D
class_name UnderkingdomBoundedCamera

## Cámara reutilizable para todos los mapas.
## Lee automáticamente el nodo del grupo `map_bounds`.

@export var enable_position_smoothing: bool = false
@export_range(0.1, 20.0, 0.1) var smoothing_speed: float = 7.0

## Temblor de impacto (shake): solo mueve `offset`, en píxeles enteros, para no
## tocar el seguimiento ni el pixel snapping que quitaron el temblor al caminar.
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0
var _shake_time_left: float = 0.0
var _last_process_usec: int = 0

func _ready() -> void:
    process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
    position_smoothing_enabled = false
    position_smoothing_speed = smoothing_speed
    limit_smoothed = false
    _last_process_usec = Time.get_ticks_usec()

    # Esperar un frame garantiza que el MapBounds de la escena ya entró al árbol.
    call_deferred("_apply_current_map_bounds")


## Sacude la cámara strength píxeles como máximo, apagándose en duration
## segundos reales (sigue durante un hitstop). Un temblor más débil no pisa
## a uno más fuerte que siga en curso.
func shake(strength: float, duration: float) -> void:
    if strength <= 0.0 or duration <= 0.0:
        return
    if strength < _current_shake_amount():
        return
    _shake_strength = strength
    _shake_duration = duration
    _shake_time_left = duration


func _process(_delta: float) -> void:
    var now := Time.get_ticks_usec()
    var real_delta := float(now - _last_process_usec) / 1000000.0
    _last_process_usec = now

    if _shake_time_left <= 0.0:
        return
    _shake_time_left = maxf(_shake_time_left - real_delta, 0.0)
    var amount := _current_shake_amount()
    if _shake_time_left <= 0.0 or amount < 0.5:
        _shake_time_left = 0.0
        offset = Vector2.ZERO
        return
    offset = Vector2(
        roundf(randf_range(-amount, amount)),
        roundf(randf_range(-amount, amount))
    )


func _current_shake_amount() -> float:
    if _shake_time_left <= 0.0 or _shake_duration <= 0.0:
        return 0.0
    return _shake_strength * (_shake_time_left / _shake_duration)


func _apply_current_map_bounds() -> void:
    var bounds := get_tree().get_first_node_in_group("map_bounds")

    if bounds == null:
        push_warning("No se encontró MapBounds en el mapa actual.")
        return

    if bounds.has_method("apply_to"):
        bounds.call("apply_to", self)

extends "res://scripts/combat/lunge_enemy.gd"
class_name UnderkingdomRisingEnemy

## Enemigo que espera enterrado (esqueleto de tumba). Mientras duerme se ve
## solo un montículo: no se mueve, no choca con el Player y no recibe daño.
## Al acercarse el Player sale de la tierra con su animación y pelea como un
## enemigo de embestida normal.

@export_category("Despertar")
@export var starts_dormant: bool = true
@export var rise_animation: StringName = &"rise"
## Cuadro de rise que se ve mientras duerme (el montículo de tierra).
@export_range(0, 20, 1) var dormant_frame: int = 1
@export_range(0.0, 600.0, 5.0) var wake_range: float = 85.0
@export_range(0.0, 600.0, 5.0) var wake_vertical_range: float = 60.0

var _dormant: bool = false
var _rise_time_left: float = 0.0
var _awake_collision_layer: int = 0


func _ready() -> void:
    super._ready()
    _awake_collision_layer = collision_layer
    if not starts_dormant or not sprite.sprite_frames.has_animation(rise_animation):
        return
    _dormant = true
    # Capa 0: el Player lo atraviesa y su ataque no lo detecta. La máscara se
    # mantiene para que siga apoyado en el suelo.
    collision_layer = 0
    sprite.play(rise_animation)
    sprite.pause()
    sprite.frame = mini(dormant_frame, sprite.sprite_frames.get_frame_count(rise_animation) - 1)


func _process_special_state(delta: float) -> bool:
    if _rise_time_left > 0.0:
        _rise_time_left = maxf(_rise_time_left - delta, 0.0)
        velocity.x = 0.0
        if _rise_time_left <= 0.0:
            _play_if_exists(&"idle")
        return true

    if not _dormant:
        return false

    velocity.x = 0.0
    if not is_instance_valid(_target):
        _find_target()
    if is_instance_valid(_target):
        var offset := _target.global_position - global_position
        if absf(offset.x) <= wake_range and absf(offset.y) <= wake_vertical_range:
            _wake(offset.x)
    return true


func _wake(direction_to_target: float) -> void:
    _dormant = false
    collision_layer = _awake_collision_layer
    _face_direction(_normalized_direction(direction_to_target))
    # Sigue desde el montículo que ya se veía, sin volver al primer cuadro.
    var frame_count := sprite.sprite_frames.get_frame_count(rise_animation)
    var first := mini(dormant_frame, frame_count - 1)
    _rise_time_left = _animation_duration(rise_animation) * float(frame_count - first) / float(frame_count)
    _restart_if_exists(rise_animation)
    sprite.frame = first


func _is_special_invulnerable() -> bool:
    return _dormant or _rise_time_left > 0.0


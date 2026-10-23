extends "res://scripts/combat/enemy_base.gd"
class_name UnderkingdomLungeEnemy

## Enemigo que ataca embistiendo con el cuerpo, para criaturas cuyo arte no
## trae animación de golpe (murciélago, esqueleto). Al empezar el ataque se
## queda quieto un momento (aviso), luego se lanza hacia el Player y solo hace
## daño durante el impulso. Los voladores se lanzan también en vertical.

@export_category("Embestida")
## Pausa antes de lanzarse, para que el Player pueda leer el ataque.
@export_range(0.0, 2.0, 0.05) var lunge_windup: float = 0.25
@export_range(0.05, 2.0, 0.05) var lunge_duration: float = 0.35
@export_range(0.0, 600.0, 5.0) var lunge_speed: float = 170.0
## Altura a la que apunta respecto al origen del Player (43 = su torso).
@export var lunge_target_offset_y: float = 43.0

var _lunge_velocity: Vector2 = Vector2.ZERO


func _start_enemy_attack(animation_name: StringName) -> void:
    super._start_enemy_attack(animation_name)
    if _current_attack_animation == &"":
        return
    _lunge_velocity = Vector2.ZERO
    if not is_instance_valid(_target):
        return
    var origin := Vector2(_body_global_x(), global_position.y)
    var aim := _target.global_position + Vector2(0.0, lunge_target_offset_y)
    if not use_gravity:
        var body_offset_y := body_collision.position.y if body_collision != null else 0.0
        _lunge_velocity = (aim - (origin + Vector2(0.0, body_offset_y))).normalized() * lunge_speed
    else:
        _lunge_velocity = Vector2(_normalized_direction(aim.x - origin.x) * lunge_speed, 0.0)


func _update_attack_damage_window() -> void:
    if _attack_time_left <= 0.0 or _current_attack_animation == &"":
        return
    var elapsed := _attack_total_time - _attack_time_left
    if elapsed < lunge_windup:
        velocity.x = 0.0
        if not use_gravity:
            velocity.y = 0.0
        return
    if elapsed < lunge_windup + lunge_duration:
        velocity.x = _lunge_velocity.x
        if not use_gravity:
            velocity.y = _lunge_velocity.y
        # El ledge check de la patrulla no corre durante el ataque: frena al
        # borde para no tirarse a un pozo.
        if use_gravity and avoid_ledges and is_on_floor() and not _has_floor_ahead(signf(velocity.x)):
            velocity.x = 0.0
        super._update_attack_damage_window()
        return
    var stop := horizontal_deceleration * get_physics_process_delta_time()
    velocity = velocity.move_toward(Vector2.ZERO, stop) if not use_gravity else Vector2(move_toward(velocity.x, 0.0, stop), velocity.y)


## Todo el impulso es ventana de golpe: el daño se limita por tiempo, no por
## cuadro de animación.
func _active_frame_range_for_attack(animation_name: StringName) -> Vector2i:
    return Vector2i(0, maxi(sprite.sprite_frames.get_frame_count(animation_name) - 1, 0))


func _cancel_special_state_on_hit() -> void:
    if not use_gravity:
        velocity.y = 0.0

extends UnderkingdomEnemyBase
class_name UnderkingdomCaptainBoss

## Primer jefe oficial de Underkingdom.
## Usa exclusivamente las animaciones que ya existen en capitan.tscn.

signal phase_changed(new_phase: int)

const BOSS_KEY_SCENE := preload("res://escenas/items/llave_jefe_m1.tscn")

@export_category("Capitán - Fases")
@export_range(0.1, 0.95, 0.05) var phase_2_health_ratio: float = 0.66
@export_range(0.05, 0.90, 0.05) var phase_3_health_ratio: float = 0.33
@export_range(0.0, 600.0, 10.0) var boss_roll_speed: float = 170.0
@export_range(1, 10, 1) var attacks_before_roll: int = 3
@export_range(0.1, 1.0, 0.05) var roll_invulnerability_ratio: float = 0.82

var boss_phase: int = 1
var _attack_cycle_index: int = 0
var _attacks_since_roll: int = 0
var _roll_pending: bool = false
var _roll_time_left: float = 0.0
var _roll_direction: float = 1.0
var _key_spawned: bool = false
var _roll_collision_exception_active: bool = false


func _ready() -> void:
    # Si el jefe ya fue derrotado en esta ejecución, no reaparece. Si murió
    # antes de que se recogiera la llave, la llave vuelve a quedar disponible.
    if GameManager.world1_boss_defeated:
        if not GameManager.world1_boss_key_collected:
            _spawn_boss_key()
        queue_free()
        return

    super._ready()
    add_to_group("boss")
    add_to_group("world1_boss")
    health_changed.connect(_on_boss_health_changed)
    _update_boss_phase()


func _on_boss_health_changed(_current: float, _maximum: float) -> void:
    _update_boss_phase()


func _update_boss_phase() -> void:
    if max_health <= 0.0:
        return

    var ratio := current_health / max_health
    var next_phase := 1
    if ratio <= phase_3_health_ratio:
        next_phase = 3
    elif ratio <= phase_2_health_ratio:
        next_phase = 2

    if next_phase != boss_phase:
        boss_phase = next_phase
        phase_changed.emit(boss_phase)


func _select_attack_animation() -> StringName:
    _update_boss_phase()

    var sequence: Array[StringName]
    match boss_phase:
        1:
            sequence = [&"attack", &"attack2"]
        2:
            sequence = [&"attack rapido", &"attack2", &"attack"]
        _:
            # Ultimate solo entra en fase 3.
            sequence = [&"attack rapido", &"attack2", &"ultimate", &"attack"]

    var chosen := sequence[_attack_cycle_index % sequence.size()]
    _attack_cycle_index += 1
    return chosen


func _damage_for_attack(animation_name: StringName) -> float:
    match animation_name:
        &"attack":
            return 0.75
        &"attack2":
            return 1.00
        &"attack rapido":
            return 0.75
        &"ultimate":
            return 1.50
        _:
            return attack_damage


func _active_frame_range_for_attack(animation_name: StringName) -> Vector2i:
    match animation_name:
        &"attack":
            return Vector2i(2, 5)
        &"attack2":
            return Vector2i(3, 6)
        &"attack rapido":
            return Vector2i(4, 14)
        &"ultimate":
            return Vector2i(14, 47)
        _:
            return super._active_frame_range_for_attack(animation_name)


func _hitbox_size_for_attack(animation_name: StringName) -> Vector2:
    match animation_name:
        &"attack":
            return Vector2(72.0, 52.0)
        &"attack2":
            return Vector2(82.0, 56.0)
        &"attack rapido":
            return Vector2(92.0, 58.0)
        &"ultimate":
            return Vector2(170.0, 90.0)
        _:
            return attack_hitbox_size


func _hitbox_offset_for_attack(animation_name: StringName) -> Vector2:
    match animation_name:
        &"ultimate":
            return Vector2(80.0, 38.0)
        &"attack rapido":
            return Vector2(48.0, 38.0)
        &"attack2":
            return Vector2(44.0, 38.0)
        _:
            return Vector2(40.0, 38.0)


func _cooldown_for_attack(animation_name: StringName) -> float:
    match animation_name:
        &"ultimate":
            return 2.20
        &"attack rapido":
            return 0.85
        _:
            return 0.75


func _on_enemy_attack_finished(_animation_name: StringName) -> void:
    _attacks_since_roll += 1
    if boss_phase >= 2 and _attacks_since_roll >= attacks_before_roll:
        _attacks_since_roll = 0
        _roll_pending = true


func _process_special_state(delta: float) -> bool:
    if _roll_time_left > 0.0:
        _roll_time_left = maxf(_roll_time_left - delta, 0.0)
        if _can_move_horizontally(_roll_direction):
            velocity.x = _roll_direction * boss_roll_speed
        else:
            velocity.x = 0.0

        if _roll_time_left <= 0.0:
            velocity.x = 0.0
            _disable_roll_player_passthrough()
            _attack_cooldown_left = maxf(_attack_cooldown_left, 0.35)
            _play_if_exists(&"idle")
        return true

    if not _roll_pending or not sprite.sprite_frames.has_animation(&"roll"):
        return false

    _roll_pending = false
    _roll_time_left = _animation_duration(&"roll")

    # Si está cerca, rueda hacia el Player para atravesarlo y terminar a su
    # espalda. Si está lejos, usa el roll para reposicionarse.
    if is_instance_valid(_target):
        var offset_x := _target.global_position.x - global_position.x
        if absf(offset_x) <= 110.0:
            _roll_direction = signf(offset_x)
        else:
            _roll_direction = signf(global_position.x - _target.global_position.x)
        if is_zero_approx(_roll_direction):
            _roll_direction = _facing_direction()
        _enable_roll_player_passthrough()
    else:
        _roll_direction = _facing_direction()

    _face_direction(_roll_direction)
    sprite.play(&"roll")
    return true


func _cancel_special_state_on_hit() -> void:
    _roll_pending = false
    _roll_time_left = 0.0
    _disable_roll_player_passthrough()


func _is_special_invulnerable() -> bool:
    # Ultimate del jefe es ininterrumpible/invulnerable durante toda su ejecución.
    if _current_attack_animation == &"ultimate" and _attack_time_left > 0.0:
        return true

    # El roll solo protege durante la parte activa inicial, igual que el Player.
    if _roll_time_left > 0.0:
        var total := maxf(_animation_duration(&"roll"), 0.01)
        var elapsed := total - _roll_time_left
        return elapsed <= total * roll_invulnerability_ratio

    return false


func _enable_roll_player_passthrough() -> void:
    _disable_roll_player_passthrough()
    if not is_instance_valid(_target) or not (_target is PhysicsBody2D):
        return

    var player_body := _target as PhysicsBody2D
    add_collision_exception_with(player_body)
    player_body.add_collision_exception_with(self)
    _roll_collision_exception_active = true


func _disable_roll_player_passthrough() -> void:
    if not _roll_collision_exception_active:
        return
    if is_instance_valid(_target) and _target is PhysicsBody2D:
        var player_body := _target as PhysicsBody2D
        remove_collision_exception_with(player_body)
        player_body.remove_collision_exception_with(self)
    _roll_collision_exception_active = false


func _on_enemy_death_finished() -> void:
    GameManager.mark_world1_boss_defeated()
    _spawn_boss_key()


func _spawn_boss_key() -> void:
    if _key_spawned or GameManager.world1_boss_key_collected:
        return
    if not is_inside_tree() or get_parent() == null:
        return

    # En Mundo 1 la llave funcional ya está colocada en la posición elegida
    # por el diseñador, oculta hasta derrotar a Capitán. Activarla es más
    # fiable que crearla durante el mismo frame en que el boss va a eliminarse.
    var preplaced_key := get_tree().get_first_node_in_group(&"world1_boss_key")
    if is_instance_valid(preplaced_key):
        _key_spawned = true
        if preplaced_key.has_method("activate_pickup"):
            preplaced_key.call("activate_pickup")
        return

    # Fallback reutilizable si el boss se usa en una escena sin llave previa.
    _key_spawned = true
    var key := BOSS_KEY_SCENE.instantiate() as Area2D
    get_parent().add_child(key)

    var key_spawn := get_tree().get_first_node_in_group(&"world1_boss_key_spawn") as Node2D
    if is_instance_valid(key_spawn):
        key.global_position = key_spawn.global_position
    else:
        key.global_position = global_position + Vector2(0.0, -34.0)

    if key.has_method("activate_pickup"):
        key.call_deferred("activate_pickup")

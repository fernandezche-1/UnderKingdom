extends "res://scripts/combat/enemy_base.gd"
class_name UnderkingdomW2ArcherBoss

## Caballero de la Reina (elfo). Jefe de tres fases centrado en mantener
## distancia y castigar más cuanto más lejos viaje la flecha.

signal phase_changed(new_phase: int)

const ARROW_SCENE := preload("res://escenas/proyectiles/flecha_enemiga.tscn")

@export_category("Caballero - Fases")
@export_range(0.1, 0.95, 0.05) var phase_2_health_ratio: float = 0.66
@export_range(0.05, 0.90, 0.05) var phase_3_health_ratio: float = 0.33
@export_range(40.0, 400.0, 5.0) var preferred_min_distance: float = 155.0
@export_range(80.0, 600.0, 5.0) var preferred_max_distance: float = 310.0
@export_range(20.0, 400.0, 5.0) var phase_1_move_speed: float = 90.0
@export_range(20.0, 500.0, 5.0) var phase_2_move_speed: float = 155.0
@export_range(20.0, 600.0, 5.0) var phase_3_move_speed: float = 180.0
@export_range(0.5, 2.5, 0.05) var phase_2_animation_speed: float = 1.35
@export_range(0.5, 3.0, 0.05) var phase_3_animation_speed: float = 1.55
@export_range(0.1, 3.0, 0.05) var phase_1_attack_cooldown: float = 1.10
@export_range(0.1, 3.0, 0.05) var phase_2_attack_cooldown: float = 0.68
@export_range(0.1, 3.0, 0.05) var phase_3_attack_cooldown: float = 0.48

@export_category("Caballero - Flechas")
@export var normal_attack_animation: StringName = &"attack inicial"
@export var ultimate_animation: StringName = &"ultimate"
@export_range(1, 80, 1) var arrow_release_frame: int = 14
@export_range(1, 80, 1) var ultimate_release_frame: int = 8
@export_range(60.0, 900.0, 10.0) var arrow_speed: float = 330.0
@export_range(0.05, 4.0, 0.05) var arrow_near_damage: float = 0.50
@export_range(0.05, 4.0, 0.05) var arrow_far_damage: float = 1.25
@export_range(0.0, 600.0, 10.0) var arrow_damage_min_distance: float = 80.0
@export_range(50.0, 1000.0, 10.0) var arrow_damage_max_distance: float = 380.0
@export var arrow_spawn_offset: Vector2 = Vector2(30.0, -12.0)

@export_category("Caballero - Ultimate")
## No existe cooldown de Ultimate para los enemigos. En fase 3 puede elegirla
## cada vez que termina una acción; la probabilidad evita un bucle obligatorio.
@export_range(0.0, 1.0, 0.05) var ultimate_chance: float = 0.38
@export_range(1, 7, 1) var ultimate_arrow_count: int = 3
@export_range(0.0, 120.0, 5.0) var ultimate_spread_y: float = 34.0

var boss_phase: int = 1
var _projectile_spawned: bool = false


func _ready() -> void:
    super._ready()
    add_to_group("boss")
    add_to_group("w2_boss")
    show_health_bar = false
    _update_boss_phase()


func _update_ai(delta: float) -> void:
    _update_boss_phase()

    if not is_instance_valid(_target):
        _find_target()
    _update_aggro()

    if not _has_aggro or not is_instance_valid(_target):
        if return_to_origin and absf(global_position.x - _spawn_global_position.x) > return_tolerance:
            _return_to_origin(delta)
        elif patrol_enabled and patrol_distance > 0.0 and patrol_speed > 0.0:
            _patrol(delta)
        else:
            ai_state = AIState.PATROL
            velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
            sprite.speed_scale = 1.0
            _play_if_exists(&"idle")
        return

    var offset_x := _target.global_position.x - global_position.x
    var distance := absf(offset_x)
    var direction := _normalized_direction(offset_x)
    _face_direction(direction)

    # Si el Player se acerca demasiado, la prioridad del arquero es abrir
    # distancia. En fase 2 y 3 esta retirada es mucho más veloz.
    if distance < preferred_min_distance:
        var retreat_direction := -direction
        ai_state = AIState.CHASE
        if _can_move_horizontally(retreat_direction):
            velocity.x = retreat_direction * _move_speed_for_phase()
            sprite.speed_scale = _movement_animation_speed_for_phase()
            _play_movement_animation()
        else:
            velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
            sprite.speed_scale = 1.0
            _play_if_exists(&"idle")
            if attacks_enabled and _attack_cooldown_left <= 0.0:
                _start_enemy_attack(_choose_attack())
        return

    # A distancia adecuada o larga dispara. Alejarse de él es peligroso porque
    # la flecha incrementa su daño según lo que viaje antes de impactar.
    if attacks_enabled and _attack_cooldown_left <= 0.0:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * 2.0 * delta)
        _start_enemy_attack(_choose_attack())
        return

    # Entre disparos sigue intentando conservar una separación amplia.
    if distance < preferred_max_distance:
        var drift_direction := -direction
        if _can_move_horizontally(drift_direction):
            velocity.x = drift_direction * (_move_speed_for_phase() * 0.72)
            sprite.speed_scale = _movement_animation_speed_for_phase()
            _play_movement_animation()
        else:
            velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
            sprite.speed_scale = 1.0
            _play_if_exists(&"idle")
    else:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
        sprite.speed_scale = 1.0
        _play_if_exists(&"idle")


func _choose_attack() -> StringName:
    if boss_phase >= 3 and sprite.sprite_frames.has_animation(ultimate_animation):
        if randf() <= ultimate_chance:
            return ultimate_animation
    return normal_attack_animation


func _start_enemy_attack(animation_name: StringName) -> void:
    if dead or _attack_time_left > 0.0 or _defense_time_left > 0.0:
        return
    if not sprite.sprite_frames.has_animation(animation_name):
        return

    _projectile_spawned = false
    _current_attack_animation = animation_name
    _current_attack_damage = 0.0 # El daño lo aplica la flecha, nunca el hitbox melee.
    var speed_multiplier := _attack_animation_speed_for_phase()
    _attack_total_time = _animation_duration(animation_name) / speed_multiplier
    _attack_time_left = _attack_total_time
    _attack_hit_targets.clear()
    ai_state = AIState.ATTACK
    velocity.x = 0.0
    sprite.speed_scale = speed_multiplier
    sprite.play(animation_name)
    attack_started.emit(animation_name, 0.0)


func _update_attack_damage_window() -> void:
    if _attack_time_left <= 0.0 or _current_attack_animation == &"":
        return
    if sprite.animation != _current_attack_animation or _projectile_spawned:
        return

    var release_frame := arrow_release_frame
    if _current_attack_animation == ultimate_animation:
        release_frame = ultimate_release_frame

    var frame_count := sprite.sprite_frames.get_frame_count(_current_attack_animation)
    release_frame = clampi(release_frame, 0, maxi(frame_count - 1, 0))
    if sprite.frame < release_frame:
        return

    _projectile_spawned = true
    if _current_attack_animation == ultimate_animation:
        _fire_ultimate_volley()
    else:
        _fire_arrow(Vector2.ZERO)


func _fire_arrow(target_offset: Vector2) -> void:
    if not is_instance_valid(_target):
        _find_target()
    if not is_instance_valid(_target):
        return

    var projectile := ARROW_SCENE.instantiate()
    var scene_root := get_tree().current_scene
    if scene_root == null:
        scene_root = get_tree().root
    scene_root.add_child(projectile)

    var facing := _facing_direction()
    var origin := global_position + Vector2(arrow_spawn_offset.x * facing, arrow_spawn_offset.y)
    var target_position := _target.global_position + Vector2(0.0, -10.0) + target_offset
    projectile.call(
        "setup",
        origin,
        target_position,
        arrow_speed,
        arrow_near_damage,
        arrow_far_damage,
        arrow_damage_min_distance,
        arrow_damage_max_distance
    )


func _fire_ultimate_volley() -> void:
    var count := maxi(ultimate_arrow_count, 1)
    if count == 1:
        _fire_arrow(Vector2.ZERO)
        return

    for i in range(count):
        var ratio := float(i) / float(count - 1)
        var offset_y := lerpf(-ultimate_spread_y, ultimate_spread_y, ratio)
        _fire_arrow(Vector2(0.0, offset_y))


func _cooldown_for_attack(animation_name: StringName) -> float:
    if animation_name == ultimate_animation:
        return 0.0
    if boss_phase >= 3:
        return phase_3_attack_cooldown
    if boss_phase >= 2:
        return phase_2_attack_cooldown
    return phase_1_attack_cooldown


func _on_enemy_attack_finished(_animation_name: StringName) -> void:
    sprite.speed_scale = 1.0


func _move_speed_for_phase() -> float:
    if boss_phase >= 3:
        return phase_3_move_speed
    if boss_phase >= 2:
        return phase_2_move_speed
    return phase_1_move_speed


func _movement_animation_speed_for_phase() -> float:
    if boss_phase >= 3:
        return 1.40
    if boss_phase >= 2:
        return 1.25
    return 1.0


func _attack_animation_speed_for_phase() -> float:
    if boss_phase >= 3:
        return phase_3_animation_speed
    if boss_phase >= 2:
        return phase_2_animation_speed
    return 1.0


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

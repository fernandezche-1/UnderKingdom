extends "res://scripts/combat/enemy_base.gd"
class_name UnderkingdomW2ArcherBoss

## Caballero de la Reina (elfo). Jefe de tres fases centrado en mantener
## distancia y castigar más cuanto más lejos viaje la flecha.
##   Fase 1: dispara y se aleja corriendo; si el Player se le pega, rueda.
##   Fase 2: más rápido y añade la lluvia de flechas sobre el Player.
##   Fase 3: aún más rápido y puede usar el rayo (Ultimate).
## La animación "attack inicial" trae dos ataques seguidos: el disparo
## (cuadros 0 a shot_end_frame) y la lluvia (desde rain_start_frame).

signal phase_changed(new_phase: int)

const ARROW_SCENE := preload("res://escenas/proyectiles/flecha_enemiga.tscn")

enum AttackKind { SHOT, RAIN, ULTIMATE }

@export_category("Caballero - Fases")
@export_range(0.1, 0.95, 0.05) var phase_2_health_ratio: float = 0.66
@export_range(0.05, 0.90, 0.05) var phase_3_health_ratio: float = 0.33
@export_range(40.0, 400.0, 5.0) var preferred_min_distance: float = 120.0
@export_range(80.0, 600.0, 5.0) var preferred_max_distance: float = 260.0
@export_range(20.0, 400.0, 5.0) var phase_1_move_speed: float = 110.0
@export_range(20.0, 500.0, 5.0) var phase_2_move_speed: float = 150.0
@export_range(20.0, 600.0, 5.0) var phase_3_move_speed: float = 180.0
@export_range(0.5, 2.5, 0.05) var phase_1_animation_speed: float = 1.3
@export_range(0.5, 2.5, 0.05) var phase_2_animation_speed: float = 1.55
@export_range(0.5, 3.0, 0.05) var phase_3_animation_speed: float = 1.8
@export_range(0.1, 3.0, 0.05) var phase_1_attack_cooldown: float = 0.9
@export_range(0.1, 3.0, 0.05) var phase_2_attack_cooldown: float = 0.6
@export_range(0.1, 3.0, 0.05) var phase_3_attack_cooldown: float = 0.4
## Tiempo que queda aturdido al recibir un golpe (la animación de daño dura 1,2 s).
@export_range(0.05, 1.5, 0.05) var hurt_stun_time: float = 0.3

@export_category("Caballero - Flechas")
@export var normal_attack_animation: StringName = &"attack inicial"
@export var ultimate_animation: StringName = &"ultimate"
## Cuadro en que la flecha sale del arco.
@export_range(0, 80, 1) var arrow_release_frame: int = 8
## Último cuadro del disparo; los siguientes son la lluvia de flechas.
@export_range(0, 80, 1) var shot_end_frame: int = 12
@export_range(0, 80, 1) var ultimate_release_frame: int = 9
@export_range(60.0, 900.0, 10.0) var arrow_speed: float = 300.0
@export_range(0.05, 4.0, 0.05) var arrow_near_damage: float = 0.50
@export_range(0.05, 4.0, 0.05) var arrow_far_damage: float = 0.75
@export_range(0.0, 600.0, 10.0) var arrow_damage_min_distance: float = 80.0
@export_range(50.0, 1000.0, 10.0) var arrow_damage_max_distance: float = 380.0
## Salida de la flecha respecto al origen del jefe: el arco, a media altura del cuerpo.
@export var arrow_spawn_offset: Vector2 = Vector2(24.0, 34.0)

@export_category("Caballero - Lluvia de flechas")
## Probabilidad de elegir la lluvia en lugar del disparo, desde la fase 2.
@export_range(0.0, 1.0, 0.05) var rain_chance: float = 0.35
@export_range(0, 80, 1) var rain_start_frame: int = 13
@export_range(0, 80, 1) var rain_release_frame: int = 22
@export_range(1, 9, 1) var phase_2_rain_arrows: int = 3
@export_range(1, 9, 1) var phase_3_rain_arrows: int = 4
@export_range(8.0, 120.0, 2.0) var rain_spacing: float = 44.0
## Altura sobre el Player desde la que caen (menos si el techo está más cerca).
@export_range(40.0, 400.0, 5.0) var rain_height: float = 150.0
@export_range(60.0, 900.0, 10.0) var rain_speed: float = 240.0
@export_range(0.05, 4.0, 0.05) var rain_damage: float = 0.5

@export_category("Caballero - Ultimate")
## En fase 3 puede elegirla cada vez que termina una acción; la probabilidad
## evita un bucle obligatorio.
@export_range(0.0, 1.0, 0.05) var ultimate_chance: float = 0.3
@export_range(1, 7, 1) var ultimate_arrow_count: int = 3
@export_range(0.0, 120.0, 5.0) var ultimate_spread_y: float = 34.0

@export_category("Caballero - Roll")
## Si el Player se acerca rueda para alejarse; arrinconado, rueda a través de él.
@export_range(60.0, 600.0, 10.0) var roll_speed: float = 240.0
@export_range(0.0, 1.0, 0.05) var roll_invulnerability_ratio: float = 0.7
@export_range(0.1, 10.0, 0.1) var phase_1_roll_cooldown: float = 2.4
@export_range(0.1, 10.0, 0.1) var phase_2_roll_cooldown: float = 1.6
@export_range(0.1, 10.0, 0.1) var phase_3_roll_cooldown: float = 1.0
## Espacio libre que necesita a su espalda para rodar alejándose.
@export_range(16.0, 300.0, 4.0) var roll_escape_space: float = 96.0

var boss_phase: int = 1
var _projectile_spawned: bool = false
var _attack_kind: AttackKind = AttackKind.SHOT
var _roll_time_left: float = 0.0
var _roll_cooldown_left: float = 0.0
var _roll_direction: float = 1.0
var _roll_passthrough: bool = false


func _ready() -> void:
    super._ready()
    add_to_group("boss")
    add_to_group("w2_boss")
    show_health_bar = false
    _update_boss_phase()


func _update_ai(delta: float) -> void:
    _update_boss_phase()
    if _roll_cooldown_left > 0.0:
        _roll_cooldown_left = maxf(_roll_cooldown_left - delta, 0.0)

    if not is_instance_valid(_target):
        _find_target()
    _update_aggro()

    if not _has_aggro or not is_instance_valid(_target):
        sprite.speed_scale = 1.0
        if return_to_origin and absf(global_position.x - _spawn_global_position.x) > return_tolerance:
            _return_to_origin(delta)
        elif patrol_enabled and patrol_distance > 0.0 and patrol_speed > 0.0:
            _patrol(delta)
        else:
            ai_state = AIState.PATROL
            velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
            _play_if_exists(&"idle")
        return

    var offset_x := _target.global_position.x - _body_global_x()
    var distance := absf(offset_x)
    var direction := _normalized_direction(offset_x)

    # Pegado al Player: rueda para recuperar distancia.
    if distance < preferred_min_distance and _roll_cooldown_left <= 0.0 and is_on_floor():
        _start_roll(direction)
        return

    if attacks_enabled and _attack_cooldown_left <= 0.0:
        _face_direction(direction)
        velocity.x = 0.0
        _start_enemy_attack(_choose_attack())
        return

    # Entre disparos se aleja corriendo de frente, no de espaldas.
    if distance < preferred_max_distance and _can_move_horizontally(-direction):
        ai_state = AIState.CHASE
        _face_direction(-direction)
        velocity.x = -direction * _move_speed_for_phase()
        sprite.speed_scale = _movement_animation_speed_for_phase()
        _play_movement_animation()
        return

    ai_state = AIState.CHASE
    _face_direction(direction)
    velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
    sprite.speed_scale = 1.0
    _play_if_exists(&"idle")


func _choose_attack() -> StringName:
    _attack_kind = AttackKind.SHOT
    if boss_phase >= 3 and sprite.sprite_frames.has_animation(ultimate_animation) and randf() <= ultimate_chance:
        _attack_kind = AttackKind.ULTIMATE
        return ultimate_animation
    if boss_phase >= 2 and randf() <= rain_chance:
        _attack_kind = AttackKind.RAIN
    return normal_attack_animation


func _start_enemy_attack(animation_name: StringName) -> void:
    if dead or _attack_time_left > 0.0 or _defense_time_left > 0.0:
        return
    if not sprite.sprite_frames.has_animation(animation_name):
        return

    var frame_count := sprite.sprite_frames.get_frame_count(animation_name)
    var first_frame := 0
    var last_frame := frame_count - 1
    match _attack_kind:
        AttackKind.SHOT:
            last_frame = mini(shot_end_frame, last_frame)
        AttackKind.RAIN:
            first_frame = clampi(rain_start_frame, 0, last_frame)

    _projectile_spawned = false
    _current_attack_animation = animation_name
    _current_attack_damage = 0.0 # El daño lo aplican las flechas, nunca el hitbox melee.
    var speed_multiplier := _attack_animation_speed_for_phase()
    var fps := maxf(sprite.sprite_frames.get_animation_speed(animation_name), 1.0)
    _attack_total_time = float(last_frame - first_frame + 1) / fps / speed_multiplier
    _attack_time_left = _attack_total_time
    _attack_hit_targets.clear()
    ai_state = AIState.ATTACK
    velocity.x = 0.0
    sprite.speed_scale = speed_multiplier
    sprite.play(animation_name)
    sprite.frame = first_frame
    attack_started.emit(animation_name, 0.0)


func _update_attack_damage_window() -> void:
    if _attack_time_left <= 0.0 or _current_attack_animation == &"":
        return
    if sprite.animation != _current_attack_animation or _projectile_spawned:
        return

    var release_frame := arrow_release_frame
    match _attack_kind:
        AttackKind.RAIN:
            release_frame = rain_release_frame
        AttackKind.ULTIMATE:
            release_frame = ultimate_release_frame
    var frame_count := sprite.sprite_frames.get_frame_count(_current_attack_animation)
    if sprite.frame < clampi(release_frame, 0, maxi(frame_count - 1, 0)):
        return

    _projectile_spawned = true
    match _attack_kind:
        AttackKind.RAIN:
            _fire_rain()
        AttackKind.ULTIMATE:
            _fire_ultimate_volley()
        _:
            _fire_arrow(Vector2.ZERO)


func _fire_arrow(target_offset: Vector2) -> void:
    if not is_instance_valid(_target):
        _find_target()
    if not is_instance_valid(_target):
        return

    var facing := _facing_direction()
    var origin := Vector2(_body_global_x(), global_position.y) + Vector2(arrow_spawn_offset.x * facing, arrow_spawn_offset.y)
    _spawn_arrow(origin, _aim_point() + target_offset, arrow_speed, arrow_near_damage, arrow_far_damage)


func _fire_ultimate_volley() -> void:
    var count := maxi(ultimate_arrow_count, 1)
    if count == 1:
        _fire_arrow(Vector2.ZERO)
        return

    for i in range(count):
        var ratio := float(i) / float(count - 1)
        var offset_y := lerpf(-ultimate_spread_y, ultimate_spread_y, ratio)
        _fire_arrow(Vector2(0.0, offset_y))


## Flechas que caen en vertical alrededor de donde está el Player.
func _fire_rain() -> void:
    if not is_instance_valid(_target):
        return
    var aim := _aim_point()
    var count := phase_3_rain_arrows if boss_phase >= 3 else phase_2_rain_arrows
    var space := get_world_2d().direct_space_state
    for i in range(count):
        var x := aim.x + (float(i) - float(count - 1) * 0.5) * rain_spacing
        var bottom := Vector2(x, aim.y)
        var top := bottom - Vector2(0.0, rain_height)
        # Que no nazcan dentro del techo.
        var query := PhysicsRayQueryParameters2D.create(bottom, top, 1)
        query.exclude = [get_rid(), (_target as CollisionObject2D).get_rid()] if _target is CollisionObject2D else [get_rid()]
        var hit := space.intersect_ray(query)
        if not hit.is_empty():
            top.y = (hit["position"] as Vector2).y + 10.0
        if bottom.y - top.y < 24.0:
            continue
        _spawn_arrow(top, bottom + Vector2(0.0, 40.0), rain_speed, rain_damage, rain_damage)


func _spawn_arrow(origin: Vector2, target_position: Vector2, speed: float, near_damage: float, far_damage: float) -> void:
    var projectile := ARROW_SCENE.instantiate()
    var scene_root := get_tree().current_scene
    if scene_root == null:
        scene_root = get_tree().root
    scene_root.add_child(projectile)
    projectile.call(
        "setup",
        origin,
        target_position,
        speed,
        near_damage,
        far_damage,
        arrow_damage_min_distance,
        arrow_damage_max_distance
    )


## Centro del cuerpo del Player (su origen queda por encima de la colisión).
func _aim_point() -> Vector2:
    var shape := _target.get_node_or_null("CollisionShape2D") as CollisionShape2D
    if shape != null:
        return shape.global_position
    return _target.global_position


func _start_roll(direction_to_target: float) -> void:
    if not sprite.sprite_frames.has_animation(&"roll"):
        _roll_cooldown_left = _roll_cooldown_for_phase()
        return
    _cancel_attack()
    # Con espacio a la espalda rueda alejándose; arrinconado, a través del Player.
    var away := -direction_to_target
    if test_move(global_transform, Vector2(away * roll_escape_space, 0.0)):
        _roll_direction = direction_to_target
        _set_roll_passthrough(true)
    else:
        _roll_direction = away
    _roll_time_left = _animation_duration(&"roll")
    _roll_cooldown_left = _roll_cooldown_for_phase()
    _face_direction(_roll_direction)
    sprite.speed_scale = 1.0
    sprite.play(&"roll")


func _process_special_state(delta: float) -> bool:
    if _roll_time_left <= 0.0:
        return false
    _roll_time_left = maxf(_roll_time_left - delta, 0.0)
    velocity.x = _roll_direction * roll_speed if _can_move_horizontally(_roll_direction) else 0.0
    if _roll_time_left <= 0.0:
        velocity.x = 0.0
        _set_roll_passthrough(false)
        # Al levantarse dispara enseguida, pero no en el mismo cuadro.
        _attack_cooldown_left = minf(_attack_cooldown_left, 0.2)
        _play_if_exists(&"idle")
    return true


func _is_special_invulnerable() -> bool:
    if _roll_time_left <= 0.0:
        return false
    var total := maxf(_animation_duration(&"roll"), 0.01)
    return total - _roll_time_left <= total * roll_invulnerability_ratio


func _cancel_special_state_on_hit() -> void:
    _roll_time_left = 0.0
    _set_roll_passthrough(false)


func _set_roll_passthrough(active: bool) -> void:
    if active == _roll_passthrough:
        return
    if is_instance_valid(_target) and _target is PhysicsBody2D:
        var player_body := _target as PhysicsBody2D
        if active:
            add_collision_exception_with(player_body)
            player_body.add_collision_exception_with(self)
        else:
            remove_collision_exception_with(player_body)
            player_body.remove_collision_exception_with(self)
    _roll_passthrough = active


func take_damage(
    amount: float,
    source_global_position: Vector2 = Vector2.ZERO,
    apply_knockback: bool = false
) -> bool:
    var result := super.take_damage(amount, source_global_position, apply_knockback)
    # La animación de daño completa lo dejaría quieto 1,2 s por golpe.
    if _hurt_time_left > hurt_stun_time:
        _hurt_time_left = hurt_stun_time
    return result


func die() -> void:
    _set_roll_passthrough(false)
    super.die()


func _cooldown_for_attack(_animation_name: StringName) -> float:
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


func _roll_cooldown_for_phase() -> float:
    if boss_phase >= 3:
        return phase_3_roll_cooldown
    if boss_phase >= 2:
        return phase_2_roll_cooldown
    return phase_1_roll_cooldown


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
    return phase_1_animation_speed


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

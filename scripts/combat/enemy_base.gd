extends CharacterBody2D
class_name UnderkingdomEnemyBase

## Base reutilizable para enemigos terrestres o flotantes.
## P1: patrulla, detección, persecución, pérdida de aggro y regreso.
## P2: ataque ofensivo reutilizable, daño al Player y defensa opcional.

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float)
signal died
signal death_finished
signal aggro_changed(active: bool)
signal attack_started(animation_name: StringName, damage: float)
signal blocked
signal guard_broken

enum AIState {
    PATROL,
    CHASE,
    HOLD,
    RETURN,
    ATTACK,
    DEFEND,
}

@export_category("Vida")
@export_range(0.25, 100.0, 0.25) var max_health: float = 3.0
@export_range(0.0, 2.0, 0.05) var invulnerability_time: float = 0.18

@export_category("Física")
@export var use_gravity: bool = true
@export_range(100.0, 5000.0, 50.0) var gravity: float = 1500.0
@export_range(100.0, 3000.0, 50.0) var max_fall_speed: float = 1000.0
@export_range(0.0, 1000.0, 10.0) var knockback_horizontal: float = 180.0
@export_range(-800.0, 0.0, 10.0) var knockback_vertical: float = -120.0
@export_range(0.0, 5000.0, 50.0) var horizontal_deceleration: float = 900.0

@export_category("IA base")
@export var ai_enabled: bool = true
@export var target_group: StringName = &"player"
@export var patrol_enabled: bool = true
@export_range(0.0, 1000.0, 5.0) var patrol_distance: float = 70.0
@export_range(0.0, 500.0, 5.0) var patrol_speed: float = 35.0
@export_range(0.0, 800.0, 5.0) var chase_speed: float = 70.0
@export_range(0.0, 1200.0, 5.0) var detection_range: float = 200.0
@export_range(0.0, 1200.0, 5.0) var detection_vertical_range: float = 100.0
@export_range(0.0, 1800.0, 5.0) var lose_aggro_range: float = 300.0
@export_range(0.0, 1800.0, 5.0) var lose_aggro_vertical_range: float = 160.0
@export_range(0.0, 500.0, 1.0) var attack_range: float = 34.0
@export_range(0.0, 100.0, 1.0) var attack_stop_margin: float = 6.0
@export_range(0.0, 100.0, 1.0) var minimum_player_distance: float = 28.0
@export_range(0.0, 300.0, 5.0) var separation_speed: float = 80.0
@export var return_to_origin: bool = true
@export_range(0.0, 100.0, 1.0) var return_tolerance: float = 5.0

@export_category("Ataque")
@export var attacks_enabled: bool = true
@export var attack_animation: StringName = &"attack"
@export_range(0.05, 20.0, 0.05) var attack_damage: float = 0.50
@export_range(0.1, 10.0, 0.05) var attack_cooldown: float = 1.10
@export_range(-1, 120, 1) var attack_active_start_frame: int = -1
@export_range(-1, 120, 1) var attack_active_end_frame: int = -1
@export var attack_hitbox_size: Vector2 = Vector2(48.0, 36.0)
@export var attack_hitbox_offset: Vector2 = Vector2(30.0, 12.0)
## Varias ventanas de golpe dentro de una misma animación de ataque
## (por ejemplo dos hachazos). Vacío = una sola ventana (attack_active_*).
@export var attack_hit_windows: Array[Vector2i] = []

@export_category("Defensa")
@export var defense_enabled: bool = false
@export var defense_animation: StringName = &"defense"
@export_range(0.0, 1.0, 0.05) var defense_chance: float = 0.25
@export_range(0.0, 1.0, 0.05) var defense_damage_reduction: float = 1.0
@export_range(0.1, 3.0, 0.05) var defense_duration: float = 0.45
@export_range(0.1, 10.0, 0.05) var defense_cooldown: float = 2.5
@export_range(1, 10, 1) var defense_max_hits: int = 3
@export_range(0.1, 3.0, 0.05) var guard_break_stun_time: float = 0.65
@export_range(0.1, 10.0, 0.05) var guard_break_recovery: float = 2.0

@export_category("IA - Vuelo")
## Solo para enemigos sin gravedad: al perseguir también se acercan en
## vertical; sin aggro vuelven a la altura donde aparecieron.
@export var fly_toward_target: bool = false
## Altura objetivo respecto al origen del Player (positivo = más abajo).
@export var fly_target_offset_y: float = 30.0

@export_category("IA - Seguridad de movimiento")
@export var avoid_ledges: bool = true
@export_range(2.0, 80.0, 1.0) var ledge_check_forward: float = 14.0
@export_range(4.0, 100.0, 1.0) var ledge_check_depth: float = 24.0

@export_category("Orientación")
@export var sprite_faces_right: bool = true
## Para escenas cuyo dibujo no está centrado en el nodo: al darse vuelta el
## sprite se refleja alrededor del centro de la colisión (el cuerpo), y las
## distancias, el ataque y el borde se miden desde ahí.
@export var mirror_sprite_on_flip: bool = false
@export_range(-1.0, 1.0, 2.0) var initial_patrol_direction: float = 1.0

@export_category("Barra de vida")
## Barra pequeña sobre la cabeza. Los jefes con BossHealthBar no la llevan.
@export var show_health_bar: bool = true
## Ajuste fino de la altura de la barra (negativo = más arriba).
@export var health_bar_offset_y: float = 0.0

@export_category("Prueba")
@export var remove_on_death: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D

var current_health: float
var dead: bool = false
var ai_state: AIState = AIState.PATROL

var _invulnerability_left: float = 0.0
var _hurt_time_left: float = 0.0
var _spawn_global_position: Vector2
var _patrol_direction: float = 1.0
var _has_aggro: bool = false
var _target: Node2D = null

var _attack_time_left: float = 0.0
var _attack_total_time: float = 0.0
var _attack_cooldown_left: float = 0.0
var _current_attack_animation: StringName = &""
var _current_attack_damage: float = 0.0
var _attack_hit_targets: Array[int] = []
var _attack_hitbox: Area2D = null
var _attack_shape: RectangleShape2D = null

var _defense_time_left: float = 0.0
var _defense_cooldown_left: float = 0.0
var _defense_hits_remaining: int = 3
var _attack_window_index: int = -1
var _sprite_base_x: float = 0.0


func _ready() -> void:
    _sprite_base_x = sprite.position.x
    add_to_group("enemy")
    add_to_group("damageable")
    current_health = max_health
    _spawn_global_position = global_position
    _patrol_direction = _normalized_direction(initial_patrol_direction)
    _find_target()
    _ensure_attack_hitbox()
    _defense_hits_remaining = defense_max_hits
    _face_direction(_patrol_direction)
    _play_if_exists(&"idle")
    _ensure_health_bar()


func _physics_process(delta: float) -> void:
    if dead:
        return

    _update_damage_timers(delta)
    _update_combat_timers(delta)
    _apply_gravity(delta)

    # Recibir daño siempre tiene prioridad sobre IA y ataque.
    if _hurt_time_left > 0.0:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
        move_and_slide()
        return

    # Estado especial opcional para subclases (por ejemplo, roll de un boss).
    if _process_special_state(delta):
        move_and_slide()
        return

    if _defense_time_left > 0.0:
        ai_state = AIState.DEFEND
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * 1.5 * delta)
        _play_if_exists(defense_animation)
        move_and_slide()
        return

    if _attack_time_left > 0.0:
        ai_state = AIState.ATTACK
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * 1.6 * delta)
        _update_attack_damage_window()
        move_and_slide()
        return

    if ai_enabled:
        _update_ai(delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
        _play_if_exists(&"idle")

    move_and_slide()


func _ensure_health_bar() -> void:
    if not show_health_bar or has_node("BossHealthBar") or has_node("BarraVida"):
        return
    var bar := UnderkingdomEnemyHealthBar.new()
    bar.name = "BarraVida"
    var center_x := body_collision.position.x if body_collision != null else 0.0
    bar.position = Vector2(roundf(center_x), roundf(_sprite_top_y() - 7.0 + health_bar_offset_y))
    add_child(bar)


## Borde superior del dibujo (cuadro 0 de idle), relativo al enemigo.
func _sprite_top_y() -> float:
    var anim: StringName = &"idle" if sprite.sprite_frames.has_animation(&"idle") else sprite.animation
    var tex := sprite.sprite_frames.get_frame_texture(anim, 0)
    if tex == null:
        return -_collision_foot_y()
    var used := tex.get_image().get_used_rect()
    var top := float(used.position.y) - (tex.get_size().y * 0.5 if sprite.centered else 0.0)
    return sprite.position.y + (top + sprite.offset.y) * sprite.scale.y


func _update_damage_timers(delta: float) -> void:
    if _invulnerability_left > 0.0:
        _invulnerability_left = maxf(_invulnerability_left - delta, 0.0)

    if _hurt_time_left > 0.0:
        _hurt_time_left = maxf(_hurt_time_left - delta, 0.0)


func _update_combat_timers(delta: float) -> void:
    if _attack_cooldown_left > 0.0:
        _attack_cooldown_left = maxf(_attack_cooldown_left - delta, 0.0)

    if _defense_cooldown_left > 0.0:
        _defense_cooldown_left = maxf(_defense_cooldown_left - delta, 0.0)

    if _defense_time_left > 0.0:
        _defense_time_left = maxf(_defense_time_left - delta, 0.0)
        if _defense_time_left <= 0.0:
            _play_if_exists(&"idle")

    if _attack_time_left > 0.0:
        _attack_time_left = maxf(_attack_time_left - delta, 0.0)
        if _attack_time_left <= 0.0:
            var finished_animation := _current_attack_animation
            _attack_hit_targets.clear()
            _current_attack_animation = &""
            _current_attack_damage = 0.0
            _attack_cooldown_left = maxf(
                _attack_cooldown_left,
                _cooldown_for_attack(finished_animation)
            )
            _on_enemy_attack_finished(finished_animation)
            _play_if_exists(&"idle")


func _apply_gravity(delta: float) -> void:
    if use_gravity and not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)


func _update_ai(delta: float) -> void:
    if fly_toward_target and not use_gravity:
        var wanted_y := _spawn_global_position.y
        if _has_aggro and is_instance_valid(_target):
            wanted_y = _target.global_position.y + fly_target_offset_y
        velocity.y = clampf((wanted_y - global_position.y) * 4.0, -chase_speed, chase_speed)

    if not is_instance_valid(_target):
        _find_target()

    _update_aggro()

    if _has_aggro and is_instance_valid(_target):
        _chase_target(delta)
        return

    if return_to_origin and absf(global_position.x - _spawn_global_position.x) > return_tolerance:
        _return_to_origin(delta)
        return

    if patrol_enabled and patrol_distance > 0.0 and patrol_speed > 0.0:
        _patrol(delta)
        return

    ai_state = AIState.PATROL
    velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
    _play_if_exists(&"idle")


func _find_target() -> void:
    _target = null
    if target_group == StringName():
        return

    var candidate := get_tree().get_first_node_in_group(target_group)
    if candidate is Node2D:
        _target = candidate as Node2D


func _update_aggro() -> void:
    if not is_instance_valid(_target):
        _set_aggro(false)
        return

    var offset := _target.global_position - Vector2(_body_global_x(), global_position.y)
    var horizontal_distance := absf(offset.x)
    var vertical_distance := absf(offset.y)

    if _has_aggro:
        var horizontal_limit := maxf(lose_aggro_range, detection_range)
        var vertical_limit := maxf(lose_aggro_vertical_range, detection_vertical_range)
        if horizontal_distance > horizontal_limit or vertical_distance > vertical_limit:
            _set_aggro(false)
    elif horizontal_distance <= detection_range and vertical_distance <= detection_vertical_range:
        _set_aggro(true)


func _set_aggro(active: bool) -> void:
    if _has_aggro == active:
        return
    _has_aggro = active
    aggro_changed.emit(active)


func _chase_target(delta: float) -> void:
    if not is_instance_valid(_target):
        _set_aggro(false)
        return

    var offset_x := _target.global_position.x - _body_global_x()
    var horizontal_distance := absf(offset_x)
    var direction := _normalized_direction(offset_x)
    _face_direction(direction)

    # Si por inercia o knockback el enemigo quedó demasiado encima del Player,
    # retrocede ligeramente en lugar de seguir empujándolo y quedarse pegado.
    if horizontal_distance < minimum_player_distance:
        ai_state = AIState.HOLD
        var retreat_direction := -direction
        if _can_move_horizontally(retreat_direction):
            velocity.x = retreat_direction * separation_speed
        else:
            velocity.x = 0.0
        _play_if_exists(&"idle")
        return

    # Empezamos a frenar un poco antes del rango exacto. Esto evita que la
    # velocidad de persecución haga que el cuerpo físico termine presionando al
    # Player mientras prepara el ataque.
    var stop_distance := maxf(attack_range + attack_stop_margin, minimum_player_distance)
    if horizontal_distance <= stop_distance:
        ai_state = AIState.HOLD
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * 2.2 * delta)

        if attacks_enabled and _attack_cooldown_left <= 0.0:
            _start_enemy_attack(_select_attack_animation())
        else:
            _play_if_exists(&"idle")
        return

    ai_state = AIState.CHASE
    if _can_move_horizontally(direction):
        velocity.x = direction * chase_speed
        _play_movement_animation()
    else:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
        _play_if_exists(&"idle")


func _start_enemy_attack(animation_name: StringName) -> void:
    if dead or _attack_time_left > 0.0 or _defense_time_left > 0.0:
        return
    if not sprite.sprite_frames.has_animation(animation_name):
        return

    _current_attack_animation = animation_name
    _current_attack_damage = _damage_for_attack(animation_name)
    _attack_total_time = _animation_duration(animation_name)
    _attack_time_left = _attack_total_time
    _attack_hit_targets.clear()
    _attack_window_index = -1
    _update_attack_hitbox_transform(animation_name)
    ai_state = AIState.ATTACK
    sprite.play(animation_name)
    attack_started.emit(animation_name, _current_attack_damage)


func _update_attack_damage_window() -> void:
    if _attack_time_left <= 0.0 or _current_attack_animation == &"":
        return
    if sprite.animation != _current_attack_animation:
        return

    if attack_hit_windows.is_empty():
        var active_frames := _active_frame_range_for_attack(_current_attack_animation)
        if sprite.frame < active_frames.x or sprite.frame > active_frames.y:
            return
    else:
        var window := -1
        for i in attack_hit_windows.size():
            if sprite.frame >= attack_hit_windows[i].x and sprite.frame <= attack_hit_windows[i].y:
                window = i
                break
        if window < 0:
            return
        # Cada ventana es un golpe nuevo: el Player puede recibir los dos.
        if window != _attack_window_index:
            _attack_window_index = window
            _attack_hit_targets.clear()

    _update_attack_hitbox_transform(_current_attack_animation)

    for body in _attack_hitbox.get_overlapping_bodies():
        if body == self:
            continue
        if not body.is_in_group(target_group):
            continue

        var body_id := body.get_instance_id()
        if _attack_hit_targets.has(body_id):
            continue

        var accepted := false
        if body.has_method("take_damage_from"):
            var result: Variant = body.call(
                "take_damage_from",
                global_position,
                _current_attack_damage
            )
            accepted = bool(result) if typeof(result) == TYPE_BOOL else true
        elif body.has_method("take_damage"):
            var result: Variant = body.call("take_damage", _current_attack_damage)
            accepted = bool(result) if typeof(result) == TYPE_BOOL else true

        if accepted:
            _attack_hit_targets.append(body_id)


func _ensure_attack_hitbox() -> void:
    _attack_hitbox = get_node_or_null("AttackHitbox") as Area2D

    if _attack_hitbox == null:
        _attack_hitbox = Area2D.new()
        _attack_hitbox.name = "AttackHitbox"
        _attack_hitbox.collision_layer = 0
        _attack_hitbox.collision_mask = 1
        _attack_hitbox.monitoring = true
        _attack_hitbox.monitorable = false
        add_child(_attack_hitbox)

    var shape_node := _attack_hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
    if shape_node == null:
        shape_node = CollisionShape2D.new()
        shape_node.name = "CollisionShape2D"
        _attack_hitbox.add_child(shape_node)

    _attack_shape = RectangleShape2D.new()
    _attack_shape.size = attack_hitbox_size
    shape_node.shape = _attack_shape
    _update_attack_hitbox_transform(attack_animation)


func _update_attack_hitbox_transform(animation_name: StringName) -> void:
    if _attack_hitbox == null or _attack_shape == null:
        return

    var profile_size := _hitbox_size_for_attack(animation_name)
    var profile_offset := _hitbox_offset_for_attack(animation_name)
    _attack_shape.size = profile_size
    _attack_hitbox.position = Vector2(
        _body_center_x() + profile_offset.x * _facing_direction(),
        profile_offset.y
    )


func _select_attack_animation() -> StringName:
    return attack_animation


func _damage_for_attack(_animation_name: StringName) -> float:
    return attack_damage


func _active_frame_range_for_attack(animation_name: StringName) -> Vector2i:
    var frame_count := sprite.sprite_frames.get_frame_count(animation_name)
    if frame_count <= 1:
        return Vector2i(0, 0)

    if attack_active_start_frame >= 0 and attack_active_end_frame >= attack_active_start_frame:
        return Vector2i(
            mini(attack_active_start_frame, frame_count - 1),
            mini(attack_active_end_frame, frame_count - 1)
        )

    # Ventana segura por defecto para assets nuevos.
    return Vector2i(
        int(floor((frame_count - 1) * 0.30)),
        int(ceil((frame_count - 1) * 0.72))
    )


func _hitbox_size_for_attack(_animation_name: StringName) -> Vector2:
    return attack_hitbox_size


func _hitbox_offset_for_attack(_animation_name: StringName) -> Vector2:
    return attack_hitbox_offset


func _cooldown_for_attack(_animation_name: StringName) -> float:
    return attack_cooldown


func _on_enemy_attack_finished(_animation_name: StringName) -> void:
    pass


func _process_special_state(_delta: float) -> bool:
    return false


func _cancel_special_state_on_hit() -> void:
    pass


func _return_to_origin(delta: float) -> void:
    var offset_x := _spawn_global_position.x - global_position.x
    if absf(offset_x) <= return_tolerance:
        ai_state = AIState.PATROL
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
        _play_if_exists(&"idle")
        return

    ai_state = AIState.RETURN
    var direction := _normalized_direction(offset_x)
    _face_direction(direction)

    if _can_move_horizontally(direction):
        velocity.x = direction * patrol_speed
        _play_movement_animation()
    else:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
        _play_if_exists(&"idle")


func _patrol(delta: float) -> void:
    ai_state = AIState.PATROL

    var left_limit := _spawn_global_position.x - patrol_distance
    var right_limit := _spawn_global_position.x + patrol_distance

    if global_position.x <= left_limit:
        _patrol_direction = 1.0
    elif global_position.x >= right_limit:
        _patrol_direction = -1.0

    if not _can_move_horizontally(_patrol_direction):
        _patrol_direction *= -1.0

    _face_direction(_patrol_direction)

    if _can_move_horizontally(_patrol_direction):
        velocity.x = _patrol_direction * patrol_speed
        _play_movement_animation()
    else:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * delta)
        _play_if_exists(&"idle")


func _can_move_horizontally(direction: float) -> bool:
    if is_zero_approx(direction):
        return false

    if test_move(global_transform, Vector2(direction * 3.0, 0.0)):
        return false

    if use_gravity and avoid_ledges and is_on_floor():
        return _has_floor_ahead(direction)

    return true


func _has_floor_ahead(direction: float) -> bool:
    var foot_y := _collision_foot_y()
    var ray_from := Vector2(_body_global_x(), global_position.y) + Vector2(direction * ledge_check_forward, foot_y - 3.0)
    var ray_to := ray_from + Vector2(0.0, ledge_check_depth)

    var query := PhysicsRayQueryParameters2D.create(ray_from, ray_to)
    query.collision_mask = collision_mask
    query.collide_with_areas = false
    query.collide_with_bodies = true
    query.exclude = [get_rid()]

    return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _collision_foot_y() -> float:
    if body_collision == null or body_collision.shape == null:
        return 16.0

    var shape := body_collision.shape
    var half_height := 16.0

    if shape is RectangleShape2D:
        half_height = (shape as RectangleShape2D).size.y * 0.5
    elif shape is CapsuleShape2D:
        half_height = (shape as CapsuleShape2D).height * 0.5
    elif shape is CircleShape2D:
        half_height = (shape as CircleShape2D).radius

    return body_collision.position.y + half_height


func _normalized_direction(value: float) -> float:
    if value < 0.0:
        return -1.0
    return 1.0


func _facing_direction() -> float:
    if sprite_faces_right:
        return -1.0 if sprite.flip_h else 1.0
    return 1.0 if sprite.flip_h else -1.0


func _face_direction(direction: float) -> void:
    if is_zero_approx(direction):
        return

    if sprite_faces_right:
        sprite.flip_h = direction < 0.0
    else:
        sprite.flip_h = direction > 0.0

    if mirror_sprite_on_flip:
        var center := _body_center_x()
        sprite.position.x = (2.0 * center - _sprite_base_x) if sprite.flip_h else _sprite_base_x

    if _current_attack_animation != &"":
        _update_attack_hitbox_transform(_current_attack_animation)


func _play_movement_animation() -> void:
    if sprite.sprite_frames.has_animation(&"run"):
        _play_if_exists(&"run")
    elif sprite.sprite_frames.has_animation(&"move"):
        _play_if_exists(&"move")
    elif sprite.sprite_frames.has_animation(&"walk"):
        _play_if_exists(&"walk")
    else:
        _play_if_exists(&"idle")


func take_continuous_damage_from(source_global_position: Vector2, amount: float) -> bool:
    # Daño para ataques multigolpe como el giro de attack 3. No usa la
    # invulnerabilidad corta de take hit ni cancela el ataque enemigo; así el
    # daño puede progresar durante el giro y el enemigo todavía puede responder.
    if dead or amount <= 0.0 or _is_special_invulnerable():
        return false

    if _defense_time_left <= 0.0 and _can_block_incoming():
        _start_defense()

    if _defense_time_left > 0.0:
        _block_defense_hit()
        return true

    current_health = maxf(current_health - amount, 0.0)
    damaged.emit(amount)
    health_changed.emit(current_health, max_health)

    if current_health <= 0.0:
        die()
        return true

    # Sin knockback ni reinicio continuo de take hit: eso evitaría que el
    # enemigo pudiera contraatacar mientras el Player está girando.
    return true


func take_damage_from(source_global_position: Vector2, amount: float) -> bool:
    return take_damage(amount, source_global_position, true)


func take_damage(
    amount: float,
    source_global_position: Vector2 = Vector2.ZERO,
    apply_knockback: bool = false
) -> bool:
    if dead or amount <= 0.0 or _invulnerability_left > 0.0 or _is_special_invulnerable():
        return false

    # Si este enemigo dispone de defensa, puede reaccionar al golpe antes de
    # entrar a take hit. Mientras la guardia esté activa bloquea completamente
    # hasta defense_max_hits impactos; el último rompe la guardia.
    if _defense_time_left <= 0.0 and _can_block_incoming():
        _start_defense()

    if _defense_time_left > 0.0:
        _block_defense_hit()
        return true

    _cancel_attack()
    _cancel_special_state_on_hit()

    current_health = maxf(current_health - amount, 0.0)
    damaged.emit(amount)
    health_changed.emit(current_health, max_health)

    if current_health <= 0.0:
        die()
        return true

    _invulnerability_left = invulnerability_time
    # Sin animación de daño, _hurt_animation_name() devuelve idle; su duración
    # completa (hasta 1.6 s en el mino) dejaría al enemigo aturdido de más.
    var hurt_animation := _hurt_animation_name()
    _hurt_time_left = (
        maxf(_animation_duration(hurt_animation), 0.18)
        if hurt_animation != &"idle"
        else 0.25
    )

    if apply_knockback:
        var direction := signf(global_position.x - source_global_position.x)
        if is_zero_approx(direction):
            direction = 1.0
        velocity.x = direction * knockback_horizontal
        velocity.y = knockback_vertical if use_gravity else 0.0

    _restart_if_exists(_hurt_animation_name())
    return true


## El Player hizo parry a este ataque: se corta y queda aturdido.
func receive_parry(stun_time: float) -> void:
    if dead:
        return
    _cancel_attack()
    _cancel_special_state_on_hit()
    _defense_time_left = 0.0
    _hurt_time_left = maxf(_hurt_time_left, stun_time)
    velocity.x = 0.0
    ai_state = AIState.HOLD
    _restart_if_exists(_hurt_animation_name())
    UnderkingdomCombatFX.guard_break(self, sprite)


func _can_block_incoming() -> bool:
    if not defense_enabled:
        return false
    if _defense_time_left > 0.0:
        return true
    if _defense_cooldown_left > 0.0 or _hurt_time_left > 0.0:
        return false
    if not sprite.sprite_frames.has_animation(defense_animation):
        return false
    return randf() <= defense_chance


func _start_defense() -> void:
    _cancel_attack()
    _defense_hits_remaining = defense_max_hits
    _defense_time_left = maxf(defense_duration, _animation_duration(defense_animation))
    _defense_cooldown_left = defense_cooldown
    ai_state = AIState.DEFEND
    velocity.x = 0.0
    _restart_if_exists(defense_animation)


func _block_defense_hit() -> void:
    blocked.emit()
    _defense_hits_remaining = maxi(_defense_hits_remaining - 1, 0)

    if _defense_hits_remaining > 0:
        UnderkingdomCombatFX.block_spark(self, sprite)
        return

    # Guard Break: el golpe que rompe la defensa queda bloqueado, pero el
    # enemigo/jefe queda expuesto y no puede volver a cubrirse inmediatamente.
    _defense_time_left = 0.0
    _defense_cooldown_left = maxf(_defense_cooldown_left, guard_break_recovery)
    _hurt_time_left = guard_break_stun_time
    ai_state = AIState.HOLD
    velocity.x = 0.0
    _restart_if_exists(_hurt_animation_name())
    UnderkingdomCombatFX.guard_break(self, sprite)
    guard_broken.emit()


func _is_special_invulnerable() -> bool:
    # Hook para bosses/enemigos con roll o Ultimate invulnerable.
    return false


func _body_center_x() -> float:
    if mirror_sprite_on_flip and body_collision != null:
        return body_collision.position.x
    return 0.0


func _body_global_x() -> float:
    return global_position.x + _body_center_x()


func _cancel_attack() -> void:
    _attack_window_index = -1
    _attack_time_left = 0.0
    _attack_total_time = 0.0
    _current_attack_animation = &""
    _current_attack_damage = 0.0
    _attack_hit_targets.clear()


func die() -> void:
    if dead:
        return

    dead = true
    _cancel_attack()
    _defense_time_left = 0.0
    velocity = Vector2.ZERO
    died.emit()

    if sprite.sprite_frames.has_animation(&"death"):
        sprite.play(&"death")
        await get_tree().create_timer(_animation_duration(&"death")).timeout
    else:
        # Sin animación de muerte: se desvanece con una nube de partículas.
        _play_if_exists(&"idle")
        sprite.pause()
        UnderkingdomCombatFX.death_puff(self)
        var tween := create_tween()
        tween.tween_property(sprite, "modulate:a", 0.0, 0.35)
        await tween.finished

    if not is_inside_tree():
        return

    _on_enemy_death_finished()
    death_finished.emit()

    if remove_on_death:
        queue_free()


func _on_enemy_death_finished() -> void:
    pass


func _hurt_animation_name() -> StringName:
    if sprite.sprite_frames.has_animation(&"take hit"):
        return &"take hit"
    if sprite.sprite_frames.has_animation(&"take hiit"):
        return &"take hiit"
    if sprite.sprite_frames.has_animation(&"hurt"):
        return &"hurt"
    if sprite.sprite_frames.has_animation(&"damage"):
        return &"damage"
    return &"idle"


func _restart_if_exists(animation_name: StringName) -> void:
    if not sprite.sprite_frames.has_animation(animation_name):
        return

    sprite.animation = animation_name
    sprite.frame = 0
    sprite.play()


func _play_if_exists(animation_name: StringName) -> void:
    if not sprite.sprite_frames.has_animation(animation_name):
        return

    if sprite.animation != animation_name or not sprite.is_playing():
        sprite.play(animation_name)


func _animation_duration(animation_name: StringName) -> float:
    if not sprite.sprite_frames.has_animation(animation_name):
        return 0.20

    var fps := sprite.sprite_frames.get_animation_speed(animation_name)
    if fps <= 0.0:
        return 0.20

    var duration := 0.0
    var frame_count := sprite.sprite_frames.get_frame_count(animation_name)

    for frame_index in range(frame_count):
        duration += sprite.sprite_frames.get_frame_duration(animation_name, frame_index) / fps

    return maxf(duration, 0.08)

extends CharacterBody2D
class_name UnderkingdomPlayer

## Player principal de prueba.
## Conserva movimiento, escalada, daño, respawn y cámara,
## y añade combate usando las animaciones que YA existen en player.tscn.

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float)
signal died
signal respawned
signal attack_started(animation_name: StringName, damage: float)

enum PlayerAction {
    NORMAL,
    ATTACK,
    AIR_ATTACK,
    ROLL,
    DEFEND,
    ULTIMATE,
    HURT
}

@export_category("Movimiento")
@export_range(20.0, 800.0, 5.0) var move_speed: float = 230.0
@export_range(100.0, 5000.0, 50.0) var acceleration: float = 1800.0
@export_range(100.0, 5000.0, 50.0) var deceleration: float = 2200.0
@export_range(-1200.0, -100.0, 10.0) var jump_velocity: float = -560.0
@export_range(100.0, 5000.0, 50.0) var gravity: float = 1500.0
@export_range(100.0, 3000.0, 50.0) var max_fall_speed: float = 1000.0

@export_category("Escaleras y rampas")
@export_range(30.0, 500.0, 5.0) var climb_speed: float = 150.0
@export_range(30.0, 500.0, 5.0) var climb_horizontal_speed: float = 120.0
@export_range(30.0, 85.0, 1.0) var max_stair_slope_degrees: float = 65.0
@export_range(0.0, 40.0, 1.0) var floor_snap_distance: float = 4.0

@export_category("Plataformas One Way")
@export_range(1, 32, 1) var one_way_collision_layer: int = 2
@export_range(0.05, 1.0, 0.05) var drop_through_time: float = 0.25
@export_range(20.0, 600.0, 10.0) var drop_down_speed: float = 160.0

@export_category("Vida y daño")
@export_range(0.25, 20.0, 0.25) var max_health: float = 4.0
@export_range(0.0, 3.0, 0.05) var invulnerability_time: float = 0.45
@export_range(0.0, 1500.0, 10.0) var knockback_horizontal: float = 260.0
@export_range(-1000.0, 0.0, 10.0) var knockback_vertical: float = -220.0
@export_range(0.0, 1.0, 0.01) var hurt_animation_time: float = 0.22
@export_range(0.0, 1.0, 0.05) var defense_damage_reduction: float = 1.0

@export_category("Guardia")
@export_range(1, 10, 1) var guard_max_hits: int = 3
@export_range(0.1, 3.0, 0.05) var guard_break_stun_time: float = 0.75
@export_range(0.1, 5.0, 0.05) var guard_recharge_delay: float = 1.25

@export_category("Combate")
@export_range(0.1, 10.0, 0.05) var attack_1_damage: float = 0.50
@export_range(0.1, 10.0, 0.05) var attack_2_damage: float = 0.75
@export_range(0.1, 10.0, 0.05) var attack_3_damage: float = 1.00
@export_range(0.1, 10.0, 0.05) var air_attack_damage: float = 0.75
@export_range(0.1, 20.0, 0.05) var ultimate_damage: float = 2.00
@export_range(0.0, 1.0, 0.01) var attack_active_start_ratio: float = 0.28
@export_range(0.0, 1.0, 0.01) var attack_active_end_ratio: float = 0.72
@export_range(10.0, 300.0, 1.0) var attack_hitbox_offset_x: float = 52.0
@export_range(-100.0, 200.0, 1.0) var attack_hitbox_offset_y: float = 34.0
@export_range(0.05, 2.0, 0.05) var combo_queue_window: float = 0.45
@export_range(1.0, 2.0, 0.05) var combo_base_speed_multiplier: float = 1.20
@export_range(0, 30, 1) var attack_1_chain_frame: int = 7
@export_range(0, 40, 1) var attack_2_chain_frame: int = 16
@export_range(50.0, 1200.0, 10.0) var roll_speed: float = 430.0
@export_range(0.1, 10.0, 0.1) var ultimate_cooldown: float = 6.0

@export_category("Adrenalina")
@export var adrenaline_enabled: bool = true
@export_range(0.1, 0.9, 0.05) var adrenaline_health_ratio: float = 0.50
@export_range(1.0, 2.0, 0.05) var adrenaline_attack_speed_multiplier: float = 1.25
@export var adrenaline_affects_ultimate: bool = false

@export_category("Robo de vida")
@export var lifesteal_enabled: bool = true
@export_range(0.25, 20.0, 0.25) var lifesteal_damage_required: float = 2.0
@export_range(0.25, 2.0, 0.25) var lifesteal_heal_amount: float = 0.25
@export_range(0.0, 1.0, 0.05) var ultimate_lifesteal_multiplier: float = 1.0

@export_category("Respawn")
@export_range(0.1, 5.0, 0.1) var respawn_delay: float = 0.8
@export var fall_limit_y: float = 1200.0

@export_category("Pruebas")
@export var enable_debug_keys: bool = true
@export var show_debug_hud: bool = true
@export var blink_while_invulnerable: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var debug_hud: CanvasLayer = get_node_or_null("DebugHUD")
@onready var info_label: Label = get_node_or_null("DebugHUD/Panel/Info")

var current_health: float
var spawn_position: Vector2
var dead: bool = false

var _jump_requested: bool = false
var _hurt_time_left: float = 0.0
var _invulnerability_left: float = 0.0
var _blink_accumulator: float = 0.0
var _blink_visible: bool = true

var _climb_zones: Array[Node] = []
var _climbing: bool = false
var _active_climb_zone: Node = null
var _drop_through_left: float = 0.0
var _normal_floor_snap_length: float = 4.0
var _terrain_collision_temporarily_disabled: bool = false


var _ledge_transition_zones: Array[Node] = []
var _active_ledge_transition_zone: Node = null
var _ledge_transition_cooldown: float = 0.0

var _action: PlayerAction = PlayerAction.NORMAL
var _action_time_left: float = 0.0
var _action_total_time: float = 0.0
var _current_attack_damage: float = 0.0
var _current_attack_animation: StringName = &""
var _combo_step: int = 0
var _combo_queued: bool = false
var _combo_queue_left: float = 0.0
var _combo_buffered_inputs: int = 0
var _roll_direction: float = 1.0
var _ultimate_cooldown_left: float = 0.0
var _attack_hit_targets: Array[int] = []
var _attack_subwindow_index: int = -1
var _current_attack_speed_multiplier: float = 1.0
var _lifesteal_damage_bank: float = 0.0

var _guard_hits_remaining: int = 3
var _guard_recharge_left: float = 0.0
var _guard_requires_release: bool = false
var _roll_collision_exceptions: Array[PhysicsBody2D] = []


func _ready() -> void:
    add_to_group("player")
    floor_max_angle = deg_to_rad(max_stair_slope_degrees)
    floor_snap_length = floor_snap_distance
    _normal_floor_snap_length = floor_snap_distance
    floor_stop_on_slope = true
    floor_block_on_wall = true
    safe_margin = 0.02

    spawn_position = global_position
    current_health = max_health
    _guard_hits_remaining = guard_max_hits

    attack_hitbox.monitoring = true
    attack_hitbox.monitorable = false
    _update_attack_hitbox_position()

    if debug_hud:
        debug_hud.visible = show_debug_hud

    _restore_sprite_visibility()
    _update_hud("LISTO")
    health_changed.emit(current_health, max_health)


func _unhandled_input(event: InputEvent) -> void:
    if dead:
        return

    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            request_attack()
        return

    if not (event is InputEventKey):
        return
    if not event.pressed or event.echo:
        return

    match event.keycode:
        KEY_SPACE, KEY_W, KEY_UP:
            _jump_requested = true
        KEY_F, KEY_Z:
            request_attack()
        KEY_SHIFT:
            request_roll()
        KEY_E:
            request_ultimate()
        KEY_R:
            if enable_debug_keys:
                respawn_now()
        KEY_H:
            if enable_debug_keys:
                take_damage(0.25)
        KEY_J:
            if enable_debug_keys:
                take_damage(1.0)
        KEY_K:
            if enable_debug_keys:
                die()


func _physics_process(delta: float) -> void:
    _update_damage_timers(delta)
    _update_drop_through(delta)
    _update_combat_timers(delta)
    _update_ledge_transition_timer(delta)

    if dead:
        return

    _cleanup_climb_zones()
    _cleanup_ledge_transition_zones()
    _process_simple_ledge_input()
    _update_attack_hitbox_position()
    _update_defense_state()

    if _action == PlayerAction.ROLL:
        _process_roll(delta)
    elif _action == PlayerAction.ATTACK:
        _process_attack_movement(delta)
    elif _action == PlayerAction.AIR_ATTACK:
        _process_air_attack_movement(delta)
    elif _action == PlayerAction.ULTIMATE:
        _process_attack_movement(delta)
    elif _action == PlayerAction.HURT:
        _process_hurt_movement(delta)
    elif _action == PlayerAction.DEFEND:
        _process_defense_movement(delta)
    else:
        if _can_climb() and _has_climb_input():
            _climbing = true
        elif _climbing and not _can_climb():
            _climbing = false

        if _climbing:
            _process_climbing()
        else:
            _process_normal_movement(delta)

    move_and_slide()

    if global_position.y > fall_limit_y:
        die()
        return

    _update_action_state()
    _update_attack_damage_window()

    var direction := _get_horizontal_input()
    _update_animation(direction)

    var state_text := "JUGANDO"
    if _climbing:
        state_text = "ESCALERA"
    elif _action != PlayerAction.NORMAL:
        state_text = _action_name()
    elif is_invulnerable():
        state_text = "INVULNERABLE"
    _update_hud(state_text)


func request_attack() -> void:
    if dead or _climbing:
        return

    if _action == PlayerAction.ATTACK:
        if _combo_step < 3:
            # Guardamos pulsaciones reales, no solo un booleano. Asi, si el
            # jugador pulsa dos veces durante attack 1, quedan preparados
            # attack 2 Y attack 3 en vez de perderse la tercera pulsacion.
            var remaining_steps := maxi(3 - _combo_step, 0)
            _combo_buffered_inputs = mini(_combo_buffered_inputs + 1, remaining_steps)
            _combo_queued = _combo_buffered_inputs > 0
            _combo_queue_left = maxf(
                _combo_queue_left,
                _action_time_left + combo_queue_window + 0.25
            )
        return

    if _action not in [PlayerAction.NORMAL, PlayerAction.DEFEND]:
        return

    if _action == PlayerAction.DEFEND:
        _leave_guard_for_action()

    if not is_on_floor():
        _start_attack(&"air attack", air_attack_damage, PlayerAction.AIR_ATTACK)
        return

    _combo_step = 1
    _combo_queued = false
    _combo_buffered_inputs = 0
    _start_attack(&"attack", attack_1_damage, PlayerAction.ATTACK)


func request_roll() -> void:
    if dead or _climbing or not is_on_floor():
        return
    if _action not in [PlayerAction.NORMAL, PlayerAction.DEFEND]:
        return

    if _action == PlayerAction.DEFEND:
        _leave_guard_for_action()

    var input_dir := _get_horizontal_input()
    if not is_zero_approx(input_dir):
        _roll_direction = input_dir
    else:
        _roll_direction = -1.0 if sprite.flip_h else 1.0

    _action = PlayerAction.ROLL
    _action_total_time = _animation_duration(&"roll")
    _action_time_left = _action_total_time
    _invulnerability_left = maxf(_invulnerability_left, _action_total_time * 0.82)
    _enable_roll_enemy_passthrough()
    sprite.play(&"roll")


func request_ultimate() -> void:
    if dead or _climbing or not is_on_floor():
        return
    if _ultimate_cooldown_left > 0.0:
        return
    if _action not in [PlayerAction.NORMAL, PlayerAction.DEFEND]:
        return

    if _action == PlayerAction.DEFEND:
        _leave_guard_for_action()

    _ultimate_cooldown_left = ultimate_cooldown
    _combo_step = 0
    _combo_queued = false
    _combo_buffered_inputs = 0
    _start_attack(&"attack ultimate", ultimate_damage, PlayerAction.ULTIMATE)


func _start_attack(animation_name: StringName, damage: float, action_type: PlayerAction) -> void:
    _action = action_type
    _current_attack_damage = damage
    _current_attack_animation = animation_name
    _current_attack_speed_multiplier = _attack_speed_multiplier_for(animation_name)
    sprite.speed_scale = _current_attack_speed_multiplier
    _action_total_time = _animation_duration(animation_name) / maxf(_current_attack_speed_multiplier, 0.01)
    _action_time_left = _action_total_time

    # Cada etapa del combo es un golpe independiente. El mismo enemigo puede
    # recibir attack, attack 2 y attack 3 una vez cada uno, pero nunca dos veces
    # dentro de la misma ventana de impacto.
    _attack_hit_targets.clear()
    _attack_subwindow_index = -1
    attack_hitbox.scale = Vector2.ONE
    sprite.play(animation_name)
    attack_started.emit(animation_name, damage)


func _start_combo_step(step: int) -> void:
    _combo_step = step
    _combo_queued = _combo_buffered_inputs > 0
    _combo_queue_left = 0.0

    match step:
        2:
            _start_attack(&"attack 2", attack_2_damage, PlayerAction.ATTACK)
        3:
            _start_attack(&"attack 3", attack_3_damage, PlayerAction.ATTACK)
        _:
            _finish_action()
            return

    # Si el jugador ya habia pulsado el siguiente ataque, conservamos ese
    # input durante esta nueva etapa para que el combo no se corte.
    if _combo_buffered_inputs > 0:
        _combo_queue_left = _action_time_left + combo_queue_window + 0.25


func _update_combat_timers(delta: float) -> void:
    if _ultimate_cooldown_left > 0.0:
        _ultimate_cooldown_left = maxf(_ultimate_cooldown_left - delta, 0.0)

    # La guardia solo se recarga después de pasar un tiempo fuera de DEFEND.
    if _guard_recharge_left > 0.0 and _action != PlayerAction.DEFEND:
        _guard_recharge_left = maxf(_guard_recharge_left - delta, 0.0)
        if _guard_recharge_left <= 0.0:
            _guard_hits_remaining = guard_max_hits

    if _combo_queue_left > 0.0:
        _combo_queue_left = maxf(_combo_queue_left - delta, 0.0)
        if _combo_queue_left <= 0.0:
            _combo_queued = false
            _combo_buffered_inputs = 0

    if _action in [
        PlayerAction.ATTACK,
        PlayerAction.AIR_ATTACK,
        PlayerAction.ROLL,
        PlayerAction.ULTIMATE,
        PlayerAction.HURT
    ]:
        _action_time_left = maxf(_action_time_left - delta, 0.0)


func _update_action_state() -> void:
    # Cancelamos solo los frames de recuperacion de attack 1 y attack 2.
    # El siguiente golpe puede arrancar antes de que termine toda la animacion,
    # siempre que el jugador ya lo haya dejado en el buffer.
    if (
        _action == PlayerAction.ATTACK
        and _combo_step < 3
        and _combo_buffered_inputs > 0
        and _can_chain_combo_early()
    ):
        _consume_combo_buffer_and_start_next()
        return

    if _action_time_left > 0.0:
        return

    if _action == PlayerAction.ATTACK:
        if _combo_buffered_inputs > 0 and _combo_step < 3:
            _consume_combo_buffer_and_start_next()
        else:
            _finish_action()
    elif _action in [
        PlayerAction.AIR_ATTACK,
        PlayerAction.ROLL,
        PlayerAction.ULTIMATE,
        PlayerAction.HURT
    ]:
        _finish_action()


func _can_chain_combo_early() -> bool:
    if sprite.animation != _current_attack_animation:
        return false

    match _current_attack_animation:
        &"attack":
            return sprite.frame >= attack_1_chain_frame
        &"attack 2":
            return sprite.frame >= attack_2_chain_frame
        _:
            return false


func _consume_combo_buffer_and_start_next() -> void:
    if _combo_buffered_inputs <= 0 or _combo_step >= 3:
        return

    _combo_buffered_inputs -= 1
    _combo_queued = _combo_buffered_inputs > 0
    _start_combo_step(_combo_step + 1)


func _finish_action() -> void:
    var previous_action := _action
    if previous_action == PlayerAction.ROLL:
        _disable_roll_enemy_passthrough()

    _action = PlayerAction.NORMAL
    _action_time_left = 0.0
    _action_total_time = 0.0
    _current_attack_damage = 0.0
    _current_attack_animation = &""
    _combo_step = 0
    _combo_queued = false
    _combo_queue_left = 0.0
    _combo_buffered_inputs = 0
    _attack_hit_targets.clear()
    _attack_subwindow_index = -1
    _current_attack_speed_multiplier = 1.0
    sprite.speed_scale = 1.0
    attack_hitbox.scale = Vector2.ONE
    _update_attack_hitbox_position()


func _update_defense_state() -> void:
    var wants_defense := (
        Input.is_key_pressed(KEY_Q)
        or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
    )

    if not wants_defense:
        _guard_requires_release = false

    if wants_defense:
        if _guard_requires_release:
            return
        if (
            _action == PlayerAction.NORMAL
            and is_on_floor()
            and not _climbing
            and _guard_hits_remaining > 0
        ):
            _action = PlayerAction.DEFEND
            _set_static_defense_pose()
        elif _action == PlayerAction.DEFEND:
            _set_static_defense_pose()
    elif _action == PlayerAction.DEFEND:
        _leave_guard_for_action()
        _finish_action()


func _process_normal_movement(delta: float) -> void:
    _restore_terrain_collision_if_needed()
    _try_start_drop_through()

    var direction := _get_horizontal_input()
    var target_speed := direction * move_speed
    var change_rate := acceleration if direction != 0.0 else deceleration
    velocity.x = move_toward(velocity.x, target_speed, change_rate * delta)

    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

    if _jump_requested and is_on_floor():
        velocity.y = jump_velocity
    _jump_requested = false


func _process_attack_movement(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
    _jump_requested = false


func _process_air_attack_movement(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0.0, deceleration * 0.35 * delta)
    velocity.y = minf(velocity.y + gravity * 0.65 * delta, max_fall_speed)
    _jump_requested = false


func _process_roll(delta: float) -> void:
    velocity.x = _roll_direction * roll_speed
    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
    _jump_requested = false


func _process_defense_movement(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0.0, deceleration * 1.5 * delta)
    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
    _jump_requested = false


func _process_hurt_movement(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0.0, deceleration * 0.35 * delta)
    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
    _jump_requested = false


func _try_start_drop_through() -> void:
    if _drop_through_left > 0.0:
        return
    if not is_on_floor():
        return

    var wants_down := Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
    if not wants_down:
        return

    set_collision_mask_value(one_way_collision_layer, false)
    _drop_through_left = drop_through_time
    floor_snap_length = 0.0
    velocity.y = maxf(velocity.y, drop_down_speed)


func _update_drop_through(delta: float) -> void:
    if _drop_through_left <= 0.0:
        return

    _drop_through_left = maxf(_drop_through_left - delta, 0.0)

    if _drop_through_left <= 0.0:
        set_collision_mask_value(one_way_collision_layer, true)
        floor_snap_length = _normal_floor_snap_length


func _apply_climb_collision_mode() -> void:
    var pass_through := false

    if _active_climb_zone != null:
        var value = _active_climb_zone.get("ignore_normal_terrain_while_climbing")
        if value != null:
            pass_through = bool(value)

    if pass_through and not _terrain_collision_temporarily_disabled:
        set_collision_mask_value(1, false)
        _terrain_collision_temporarily_disabled = true
    elif not pass_through:
        _restore_terrain_collision_if_needed()


func _restore_terrain_collision_if_needed() -> void:
    if _terrain_collision_temporarily_disabled:
        set_collision_mask_value(1, true)
        _terrain_collision_temporarily_disabled = false


func _process_climbing() -> void:
    _apply_climb_collision_mode()
    var horizontal := _get_horizontal_input()
    var vertical := 0.0

    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        vertical -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        vertical += 1.0

    velocity.x = horizontal * climb_horizontal_speed
    velocity.y = vertical * climb_speed
    _jump_requested = false


func set_climb_zone(zone: Node, inside: bool) -> void:
    if inside:
        if not _climb_zones.has(zone):
            _climb_zones.append(zone)
        _active_climb_zone = zone
    else:
        _climb_zones.erase(zone)

        if _active_climb_zone == zone:
            _active_climb_zone = _climb_zones[0] if not _climb_zones.is_empty() else null

        if _climb_zones.is_empty():
            _climbing = false
            _restore_terrain_collision_if_needed()


func _cleanup_climb_zones() -> void:
    for zone in _climb_zones.duplicate():
        if not is_instance_valid(zone):
            _climb_zones.erase(zone)

    if _active_climb_zone != null and not is_instance_valid(_active_climb_zone):
        _active_climb_zone = null

    if _climb_zones.is_empty():
        _climbing = false
        _restore_terrain_collision_if_needed()
    elif _active_climb_zone == null:
        _active_climb_zone = _climb_zones[0]


func _can_climb() -> bool:
    return not _climb_zones.is_empty()


func _has_climb_input() -> bool:
    return (
        Input.is_key_pressed(KEY_W)
        or Input.is_key_pressed(KEY_UP)
        or Input.is_key_pressed(KEY_S)
        or Input.is_key_pressed(KEY_DOWN)
    )


func set_ledge_transition_zone(zone: Node, inside: bool) -> void:
    if inside:
        if not _ledge_transition_zones.has(zone):
            _ledge_transition_zones.append(zone)
        _active_ledge_transition_zone = zone
    else:
        _ledge_transition_zones.erase(zone)

        if _active_ledge_transition_zone == zone:
            _active_ledge_transition_zone = (
                _ledge_transition_zones[0]
                if not _ledge_transition_zones.is_empty()
                else null
            )


func _cleanup_ledge_transition_zones() -> void:
    for zone in _ledge_transition_zones.duplicate():
        if not is_instance_valid(zone):
            _ledge_transition_zones.erase(zone)

    if (
        _active_ledge_transition_zone != null
        and not is_instance_valid(_active_ledge_transition_zone)
    ):
        _active_ledge_transition_zone = null

    if _active_ledge_transition_zone == null and not _ledge_transition_zones.is_empty():
        _active_ledge_transition_zone = _ledge_transition_zones[0]


func _update_ledge_transition_timer(delta: float) -> void:
    if _ledge_transition_cooldown > 0.0:
        _ledge_transition_cooldown = maxf(_ledge_transition_cooldown - delta, 0.0)


func _process_simple_ledge_input() -> void:
    if _active_ledge_transition_zone == null:
        return
    if _ledge_transition_cooldown > 0.0:
        return
    if dead or _action != PlayerAction.NORMAL or _climbing:
        return
    # La transición de la reja solo se inicia desde una superficie.
    # Así W no vuelve a disparar otro impulso mientras el Player está en el aire.
    if not is_on_floor():
        return

    var wants_up := Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
    var wants_down := Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)

    # SUBIR: un solo impulso físico; después actúan la gravedad y move_and_slide().
    if wants_up and _active_ledge_transition_zone.has_method("can_go_up"):
        if _active_ledge_transition_zone.call("can_go_up", self):
            velocity.y = float(
                _active_ledge_transition_zone.call("get_jump_velocity")
            )
            _jump_requested = false
            _ledge_transition_cooldown = 0.48
            return

    # BAJAR: ignorar temporalmente solo la capa One Way y caer.
    if wants_down and _active_ledge_transition_zone.has_method("can_go_down"):
        if _active_ledge_transition_zone.call("can_go_down", self):
            set_collision_mask_value(one_way_collision_layer, false)
            _drop_through_left = maxf(_drop_through_left, 0.32)
            floor_snap_length = 0.0
            velocity.y = float(
                _active_ledge_transition_zone.call("get_drop_velocity")
            )
            _jump_requested = false
            _ledge_transition_cooldown = 0.48

func _get_horizontal_input() -> float:
    var direction := 0.0
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        direction -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        direction += 1.0
    return direction


func _update_animation(direction: float) -> void:
    if _action != PlayerAction.NORMAL:
        return
    if _hurt_time_left > 0.0:
        return

    sprite.speed_scale = 1.0

    if direction < 0.0:
        sprite.flip_h = true
    elif direction > 0.0:
        sprite.flip_h = false

    var wanted: StringName = &"idle"
    if not is_on_floor():
        wanted = &"jump up" if velocity.y < 0.0 else &"jump down"
    elif absf(velocity.x) > 8.0:
        wanted = &"run"

    if sprite.animation != wanted or not sprite.is_playing():
        sprite.play(wanted)


func _update_attack_hitbox_position() -> void:
    var facing := -1.0 if sprite.flip_h else 1.0
    attack_hitbox.position = Vector2(
        attack_hitbox_offset_x * facing,
        attack_hitbox_offset_y
    )


func _update_attack_damage_window() -> void:
    if _action not in [
        PlayerAction.ATTACK,
        PlayerAction.AIR_ATTACK,
        PlayerAction.ULTIMATE
    ]:
        attack_hitbox.scale = Vector2.ONE
        _attack_subwindow_index = -1
        return
    if _current_attack_animation == &"":
        attack_hitbox.scale = Vector2.ONE
        _attack_subwindow_index = -1
        return
    if sprite.animation != _current_attack_animation:
        attack_hitbox.scale = Vector2.ONE
        _attack_subwindow_index = -1
        return

    # attack 3 es una animación de varias fases visuales. No puede tratarse
    # como un único golpe porque el giro, el golpe posterior y el fuego ocurren
    # en momentos y alcances diferentes.
    if _current_attack_animation == &"attack 3":
        _update_attack_3_subwindows()
        return

    var active_frames := _attack_active_frame_range(_current_attack_animation)
    var current_frame := sprite.frame
    if current_frame < active_frames.x or current_frame > active_frames.y:
        attack_hitbox.scale = Vector2.ONE
        _update_attack_hitbox_position()
        return

    attack_hitbox.scale = (
        Vector2(1.45, 1.20)
        if _action == PlayerAction.ULTIMATE
        else Vector2.ONE
    )
    _damage_attack_overlaps(_current_attack_damage)


func _update_attack_3_subwindows() -> void:
    var current_frame := sprite.frame
    var subwindow := -1
    var phase_damage := 0.0
    var phase_scale := Vector2.ONE
    var facing := -1.0 if sprite.flip_h else 1.0
    var phase_offset := Vector2(
        attack_hitbox_offset_x * facing,
        attack_hitbox_offset_y
    )

    # GIRO: daño progresivo real. Cada frame visual del giro es una ventana
    # independiente, de modo que el enemigo puede recibir varios impactos a lo
    # largo de la vuelta. La detección se hace de forma radial para que el daño
    # coincida con la espada girando alrededor del Player, incluso detrás.
    # 15 frames x (80 % / 15) + golpe 10 % + fuego 10 % = daño total ~1.0.
    if current_frame >= 3 and current_frame <= 17:
        subwindow = current_frame
        phase_damage = attack_3_damage * (0.80 / 15.0)

        if subwindow != _attack_subwindow_index:
            _attack_subwindow_index = subwindow
            _attack_hit_targets.clear()

        attack_hitbox.position = Vector2(0.0, attack_hitbox_offset_y)
        attack_hitbox.scale = Vector2(1.90, 1.35)
        _damage_attack_3_spin_targets(phase_damage)
        return

    # Golpe posterior y fuego final continúan siendo ventanas independientes.
    if current_frame >= 18 and current_frame <= 21:
        subwindow = 100
        phase_damage = attack_3_damage * 0.10
        phase_scale = Vector2(1.18, 1.10)
    elif current_frame >= 22 and current_frame <= 27:
        subwindow = 101
        phase_damage = attack_3_damage * 0.10
        phase_scale = Vector2(1.85, 1.30)
        phase_offset = Vector2(76.0 * facing, attack_hitbox_offset_y)
    else:
        attack_hitbox.scale = Vector2.ONE
        _update_attack_hitbox_position()
        return

    if subwindow != _attack_subwindow_index:
        _attack_subwindow_index = subwindow
        _attack_hit_targets.clear()

    attack_hitbox.position = phase_offset
    attack_hitbox.scale = phase_scale
    _damage_attack_overlaps(phase_damage)


func _damage_attack_3_spin_targets(damage_amount: float) -> void:
    # El giro usa una consulta física real centrada en el Player. Así detecta
    # CollisionShape2D delante y detrás con el mismo alcance, sin depender del
    # origen visual/root del enemigo.
    var spin_radius := attack_hitbox_offset_x + 41.0
    var hitbox_shape_node := attack_hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
    if hitbox_shape_node != null and hitbox_shape_node.shape is RectangleShape2D:
        var rect := hitbox_shape_node.shape as RectangleShape2D
        spin_radius = attack_hitbox_offset_x + rect.size.x * 0.5

    var circle := CircleShape2D.new()
    circle.radius = spin_radius

    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = circle
    query.transform = Transform2D(0.0, global_position + Vector2(0.0, attack_hitbox_offset_y))
    query.collision_mask = attack_hitbox.collision_mask
    query.collide_with_bodies = true
    query.collide_with_areas = false
    query.exclude = [get_rid()]

    var hits := get_world_2d().direct_space_state.intersect_shape(query, 32)
    for hit in hits:
        var target := hit.get("collider") as Node
        if target == null or target == self or not target.is_in_group("enemy"):
            continue

        var target_id := target.get_instance_id()
        if _attack_hit_targets.has(target_id):
            continue

        if _try_damage_continuous_target(target, damage_amount):
            _attack_hit_targets.append(target_id)


func _damage_attack_overlaps(damage_amount: float) -> void:
    for body in attack_hitbox.get_overlapping_bodies():
        if body == self:
            continue

        var body_id := body.get_instance_id()
        if _attack_hit_targets.has(body_id):
            continue

        # Solo consumimos el objetivo si el daño fue aceptado. Si el enemigo
        # estaba invulnerable, puede volver a intentarse durante la ventana.
        if _try_damage_attack_target(body, damage_amount):
            _attack_hit_targets.append(body_id)


func _attack_active_frame_range(animation_name: StringName) -> Vector2i:
    match animation_name:
        &"attack":
            return Vector2i(3, 7)
        &"attack 2":
            return Vector2i(3, 17)
        &"air attack":
            return Vector2i(2, 6)
        &"attack ultimate":
            return Vector2i(1, 15)
        _:
            var frame_count := sprite.sprite_frames.get_frame_count(animation_name)
            if frame_count <= 1:
                return Vector2i(0, 0)
            var start_frame := int(floor((frame_count - 1) * attack_active_start_ratio))
            var end_frame := int(ceil((frame_count - 1) * attack_active_end_ratio))
            return Vector2i(start_frame, maxi(start_frame, end_frame))


func _try_damage_attack_target(body: Node, damage_amount: float = -1.0) -> bool:
    var result: Variant = null
    var resolved_damage := _current_attack_damage if damage_amount < 0.0 else damage_amount
    var health_before := _enemy_health_value(body)

    if body.has_method("take_damage_from"):
        result = body.call("take_damage_from", global_position, resolved_damage)
    elif body.has_method("take_damage"):
        result = body.call("take_damage", resolved_damage)
    else:
        return false

    var accepted := bool(result) if typeof(result) == TYPE_BOOL else true
    if accepted:
        _register_actual_damage_for_lifesteal(body, health_before)
    return accepted


func _try_damage_continuous_target(body: Node, damage_amount: float) -> bool:
    var result: Variant = null
    var health_before := _enemy_health_value(body)

    if body.has_method("take_continuous_damage_from"):
        result = body.call("take_continuous_damage_from", global_position, damage_amount)
    else:
        return _try_damage_attack_target(body, damage_amount)

    var accepted := bool(result) if typeof(result) == TYPE_BOOL else true
    if accepted:
        _register_actual_damage_for_lifesteal(body, health_before)
    return accepted


func _enemy_health_value(body: Node) -> float:
    if not body.is_in_group("enemy"):
        return -1.0
    var value: Variant = body.get("current_health")
    if value == null:
        return -1.0
    return float(value)


func _register_actual_damage_for_lifesteal(body: Node, health_before: float) -> void:
    if health_before < 0.0 or not body.is_in_group("enemy"):
        return

    var value: Variant = body.get("current_health")
    if value == null:
        return

    var actual_damage := maxf(health_before - float(value), 0.0)
    _register_lifesteal_damage(actual_damage)


func _register_lifesteal_damage(actual_damage: float) -> void:
    if not lifesteal_enabled or actual_damage <= 0.0 or dead:
        return

    # No se guarda curación mientras la vida está llena; hay que combatir
    # estando herido para aprovechar el robo de vida.
    if current_health >= max_health:
        _lifesteal_damage_bank = 0.0
        return

    var multiplier := 1.0
    if _current_attack_animation == &"attack ultimate":
        multiplier = ultimate_lifesteal_multiplier

    _lifesteal_damage_bank += actual_damage * multiplier
    var requirement := maxf(lifesteal_damage_required, 0.01)

    while _lifesteal_damage_bank >= requirement and current_health < max_health:
        _lifesteal_damage_bank -= requirement
        heal(lifesteal_heal_amount)

    if current_health >= max_health:
        _lifesteal_damage_bank = 0.0


func _attack_speed_multiplier_for(animation_name: StringName) -> float:
    var multiplier := 1.0

    # attack 1 y attack 2 tenian demasiado tiempo muerto. Los aceleramos un
    # poco incluso con vida normal; attack 3 conserva su velocidad para no
    # comprimir el giro de dano progresivo.
    if animation_name in [&"attack", &"attack 2"]:
        multiplier *= maxf(combo_base_speed_multiplier, 1.0)

    if (
        adrenaline_enabled
        and max_health > 0.0
        and current_health <= max_health * adrenaline_health_ratio
    ):
        if animation_name != &"attack ultimate" or adrenaline_affects_ultimate:
            multiplier *= maxf(adrenaline_attack_speed_multiplier, 1.0)

    return multiplier


func is_adrenaline_active() -> bool:
    return (
        adrenaline_enabled
        and max_health > 0.0
        and current_health <= max_health * adrenaline_health_ratio
    )


## 0.0 = recién usada, 1.0 = lista. La usa el HUD.
func get_ultimate_ready_ratio() -> float:
    if ultimate_cooldown <= 0.0:
        return 1.0
    return 1.0 - clampf(_ultimate_cooldown_left / ultimate_cooldown, 0.0, 1.0)


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


func _is_attack_3_spin_active() -> bool:
    return (
        _action == PlayerAction.ATTACK
        and _current_attack_animation == &"attack 3"
        and sprite.animation == &"attack 3"
        and sprite.frame >= 0
        and sprite.frame <= 17
    )


func take_damage(
    amount: float,
    source_global_position: Vector2 = Vector2.ZERO,
    apply_knockback: bool = false
) -> bool:
    if dead or amount <= 0.0 or is_invulnerable():
        return false

    if _action == PlayerAction.DEFEND:
        # La guardia bloquea por completo hasta tres impactos. El tercer golpe
        # también queda bloqueado, pero rompe la guardia y deja al Player
        # vulnerable durante una breve recuperación.
        _block_guard_hit()
        return true

    current_health = maxf(current_health - amount, 0.0)
    damaged.emit(amount)
    health_changed.emit(current_health, max_health)

    if current_health <= 0.0:
        die()
        return true

    # Durante el giro de attack 3 el Player NO es invulnerable: pierde vida
    # normalmente. Sin embargo, el golpe no interrumpe el giro ni cambia la
    # animación a take hit. Conservamos la invulnerabilidad breve posterior
    # para evitar que una sola Hitbox enemiga vacíe toda la vida en un frame.
    if _is_attack_3_spin_active():
        _invulnerability_left = invulnerability_time
        _blink_accumulator = 0.0
        _blink_visible = true
        _update_hud("DAÑO -%.2f (GIRO)" % amount)
        return true

    _invulnerability_left = invulnerability_time
    _hurt_time_left = hurt_animation_time
    _blink_accumulator = 0.0
    _blink_visible = true
    _combo_step = 0
    _combo_queued = false
    _combo_buffered_inputs = 0

    if apply_knockback:
        _apply_knockback(source_global_position)

    _action = PlayerAction.HURT
    _current_attack_speed_multiplier = 1.0
    sprite.speed_scale = 1.0
    _action_total_time = maxf(_animation_duration(&"take hit"), hurt_animation_time)
    _action_time_left = _action_total_time
    sprite.play(&"take hit")
    _update_hud("DAÑO -%.2f" % amount)
    return true


func take_damage_from(source_global_position: Vector2, amount: float) -> bool:
    return take_damage(amount, source_global_position, true)


func _apply_knockback(source_global_position: Vector2) -> void:
    var horizontal_direction := signf(global_position.x - source_global_position.x)

    if is_zero_approx(horizontal_direction):
        horizontal_direction = -1.0 if not sprite.flip_h else 1.0

    velocity.x = horizontal_direction * knockback_horizontal
    velocity.y = knockback_vertical


func is_invulnerable() -> bool:
    return _invulnerability_left > 0.0 or _action == PlayerAction.ULTIMATE


func _update_damage_timers(delta: float) -> void:
    if _hurt_time_left > 0.0:
        _hurt_time_left = maxf(_hurt_time_left - delta, 0.0)

    if _invulnerability_left <= 0.0:
        _restore_sprite_visibility()
        return

    _invulnerability_left = maxf(_invulnerability_left - delta, 0.0)

    if blink_while_invulnerable:
        _blink_accumulator += delta
        if _blink_accumulator >= 0.08:
            _blink_accumulator = 0.0
            _blink_visible = not _blink_visible
            sprite.modulate.a = 1.0 if _blink_visible else 0.35

    if _invulnerability_left <= 0.0:
        _restore_sprite_visibility()


func _restore_sprite_visibility() -> void:
    _blink_visible = true
    _blink_accumulator = 0.0
    if is_instance_valid(sprite):
        sprite.modulate.a = 1.0


func _leave_guard_for_action() -> void:
    if _guard_hits_remaining < guard_max_hits:
        _guard_recharge_left = maxf(_guard_recharge_left, guard_recharge_delay)


func _set_static_defense_pose() -> void:
    if not sprite.sprite_frames.has_animation(&"defende"):
        return
    sprite.speed_scale = 1.0
    if sprite.animation != &"defende":
        sprite.play(&"defende")
    # La pose mostrada por el usuario corresponde al frame 5. La dejamos
    # completamente estática mientras Q/clic derecho permanezcan presionados.
    var frame_count := sprite.sprite_frames.get_frame_count(&"defende")
    sprite.frame = clampi(5, 0, maxi(frame_count - 1, 0))
    sprite.frame_progress = 0.0
    sprite.pause()


func _block_guard_hit() -> void:
    _guard_hits_remaining = maxi(_guard_hits_remaining - 1, 0)
    _guard_recharge_left = maxf(_guard_recharge_left, guard_recharge_delay)

    if _guard_hits_remaining > 0:
        _update_hud("BLOQUEO %d/%d" % [_guard_hits_remaining, guard_max_hits])
        return

    # Guard Break: el impacto se bloquea, pero la guardia termina y el Player
    # queda brevemente aturdido. No pierde vida por el golpe que rompió la guardia.
    _guard_requires_release = true
    _action = PlayerAction.HURT
    _action_total_time = guard_break_stun_time
    _action_time_left = guard_break_stun_time
    _hurt_time_left = guard_break_stun_time
    velocity.x = 0.0
    sprite.play(&"take hit")
    _update_hud("GUARD BREAK")


func _enable_roll_enemy_passthrough() -> void:
    _disable_roll_enemy_passthrough()
    for node in get_tree().get_nodes_in_group("enemy"):
        if node is PhysicsBody2D and node != self:
            var body := node as PhysicsBody2D
            add_collision_exception_with(body)
            body.add_collision_exception_with(self)
            _roll_collision_exceptions.append(body)


func _disable_roll_enemy_passthrough() -> void:
    for body in _roll_collision_exceptions:
        if is_instance_valid(body):
            remove_collision_exception_with(body)
            body.remove_collision_exception_with(self)
    _roll_collision_exceptions.clear()


func heal(amount: float) -> void:
    if dead or amount <= 0.0:
        return

    current_health = minf(current_health + amount, max_health)
    health_changed.emit(current_health, max_health)
    _update_hud("CURACIÓN")


func die() -> void:
    if dead:
        return

    dead = true
    velocity = Vector2.ZERO
    current_health = 0.0
    _invulnerability_left = 0.0
    _lifesteal_damage_bank = 0.0
    _current_attack_speed_multiplier = 1.0
    sprite.speed_scale = 1.0
    _disable_roll_enemy_passthrough()
    _action = PlayerAction.NORMAL
    _restore_sprite_visibility()

    health_changed.emit(current_health, max_health)
    died.emit()

    sprite.play(&"death")
    _update_hud("MUERTO — reapareciendo...")

    await get_tree().create_timer(respawn_delay).timeout

    if is_inside_tree():
        respawn_now()


func kill() -> void:
    die()


func respawn_now() -> void:
    global_position = spawn_position
    velocity = Vector2.ZERO
    current_health = max_health
    dead = false

    _jump_requested = false
    _hurt_time_left = 0.0
    _invulnerability_left = 0.0
    _drop_through_left = 0.0
    _ultimate_cooldown_left = 0.0
    _lifesteal_damage_bank = 0.0
    _current_attack_speed_multiplier = 1.0
    sprite.speed_scale = 1.0
    _guard_hits_remaining = guard_max_hits
    _guard_recharge_left = 0.0
    _guard_requires_release = false
    _disable_roll_enemy_passthrough()
    _ledge_transition_cooldown = 0.0
    set_collision_mask_value(one_way_collision_layer, true)
    set_collision_mask_value(1, true)
    _terrain_collision_temporarily_disabled = false
    floor_snap_length = _normal_floor_snap_length
    _restore_sprite_visibility()
    _finish_action()

    sprite.play(&"idle")
    health_changed.emit(current_health, max_health)
    respawned.emit()
    _update_hud("REAPARECIDO")


func set_spawn_point(new_position: Vector2) -> void:
    spawn_position = new_position


func _action_name() -> String:
    match _action:
        PlayerAction.ATTACK:
            return "ATAQUE %d" % _combo_step
        PlayerAction.AIR_ATTACK:
            return "ATAQUE AÉREO"
        PlayerAction.ROLL:
            return "ROLL"
        PlayerAction.DEFEND:
            return "DEFENSA"
        PlayerAction.ULTIMATE:
            return "ULTIMATE"
        PlayerAction.HURT:
            return "DAÑO"
        _:
            return "JUGANDO"


func _update_hud(state: String) -> void:
    if not info_label or not show_debug_hud:
        return

    var ult_text := "LISTA"
    if _ultimate_cooldown_left > 0.0:
        ult_text = "%.1fs" % _ultimate_cooldown_left

    var adrenaline_text := "ACTIVA" if is_adrenaline_active() else "normal"
    info_label.text = (
        "PRUEBA PLAYER — %s\n" % state
        + "Vida: %.2f / %.2f   Ultimate: %s   Adrenalina: %s\n" % [current_health, max_health, ult_text, adrenaline_text]
        + "Robo de vida: %.2f / %.2f daño\n" % [_lifesteal_damage_bank, lifesteal_damage_required]
        + "A/D: mover  ESPACIO/W/↑: saltar  F/Z o CLICK: atacar\n"
        + "Q o CLICK DER.: defender  SHIFT: roll  E: ultimate\n"
        + "H: daño 1/4  J: daño 1 corazón  K: morir  R: reaparecer"
    )

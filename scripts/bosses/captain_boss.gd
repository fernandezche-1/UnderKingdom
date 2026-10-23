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
@export_range(1.0, 2.0, 0.05) var phase_2_attack_speed_scale: float = 1.30
@export_range(1.0, 2.5, 0.05) var phase_3_attack_speed_scale: float = 1.50
@export_range(0.25, 1.0, 0.05) var phase_2_cooldown_multiplier: float = 0.72
@export_range(0.20, 1.0, 0.05) var phase_3_cooldown_multiplier: float = 0.58

@export_category("Capitán - Anti spam")
## Si el Player conecta varios ataques básicos distintos en muy poco tiempo,
## el Capitán entra brevemente en defensa total. Cada animación del combo
## cuenta una sola vez aunque tenga varios impactos internos.
@export_range(2, 10, 1) var spam_basic_attacks_to_trigger: int = 4
@export_range(0.4, 4.0, 0.1) var spam_detection_window: float = 1.60
@export_range(0.2, 3.0, 0.05) var spam_immunity_duration: float = 1.15
@export_range(0.5, 10.0, 0.1) var spam_immunity_cooldown: float = 3.50

@export_category("Capitán - Variación")
## Probabilidad de repetir el mismo ataque dos veces seguidas.
@export_range(0.0, 1.0, 0.05) var repeat_attack_chance: float = 0.25
@export_range(0, 10, 1) var min_attacks_between_ultimates: int = 0
@export_range(0.0, 1.0, 0.05) var ultimate_chance: float = 0.5
## El roll llega tras attacks_before_roll ± este valor.
@export_range(0, 3, 1) var roll_count_variation: int = 1

@export_category("Capitán - Progreso")
## Activo en Mundo 1: no reaparece si ya fue derrotado y, al morir, marca el
## progreso de Mundo 1 y suelta la llave de la reja. Se apaga cuando el Capitán
## se reutiliza en otro mapa (p. ej. el encuentro del cementerio con tiles).
@export var counts_as_world1_boss: bool = true

@export_category("Capitán - Plataformas")
## Salta a las plataformas donde está el Player y las atraviesa hacia abajo
## cuando el Player queda debajo o en otra plataforma.
@export var use_platforms: bool = true
## Capa de las plataformas one-way (la misma que one_way_collision_layer del Player).
@export_range(1, 32, 1) var one_way_collision_layer: int = 2
## Desnivel mínimo entre los dos para considerar que están a distinta altura.
@export_range(8.0, 64.0, 1.0) var platform_min_rise: float = 24.0
## Desnivel máximo al que llega de un salto.
@export_range(32.0, 240.0, 4.0) var jump_max_rise: float = 128.0
## Cuánto sube por encima de la plataforma antes de caer en ella.
@export_range(8.0, 64.0, 1.0) var jump_clearance: float = 22.0
@export_range(40.0, 400.0, 5.0) var jump_max_horizontal_speed: float = 230.0
## Separación con la que intenta caer junto al Player.
@export_range(0.0, 120.0, 2.0) var jump_landing_gap: float = 40.0
## Hasta dónde se acerca andando antes de saltar.
@export_range(0.0, 160.0, 2.0) var jump_approach_distance: float = 56.0
## Tiempo que el Player tiene que seguir arriba o abajo antes de que el
## Capitán vaya a por él. En fases 2 y 3 se acorta con el enfriamiento.
@export_range(0.0, 2.0, 0.05) var jump_reaction_time: float = 0.45
## Aviso antes de saltar: se agacha este tiempo.
@export_range(0.05, 0.6, 0.01) var jump_windup_time: float = 0.22
@export_range(0.0, 5.0, 0.05) var jump_cooldown: float = 1.0
## Al aterrizar junto al Player, ataca como muy pronto tras este tiempo.
@export_range(0.0, 1.0, 0.05) var landing_attack_delay: float = 0.25
@export_range(0.05, 1.0, 0.05) var drop_through_time: float = 0.25
@export_range(20.0, 600.0, 10.0) var drop_down_speed: float = 160.0

@export_category("Capitán - Aviso de Ultimate")
@export var ultimate_warning_color: Color = Color(1.0, 0.35, 0.2)
@export_range(1.0, 40.0, 0.5) var ultimate_warning_pulse_speed: float = 18.0

var boss_phase: int = 1
var _last_attack: StringName = &""
var _attacks_since_ultimate: int = 0
var _next_roll_threshold: int = 3
var _ultimate_warning_time: float = 0.0
var _ultimate_warning_active: bool = false
var _attacks_since_roll: int = 0
var _roll_pending: bool = false
var _roll_time_left: float = 0.0
var _roll_direction: float = 1.0
var _key_spawned: bool = false
var _roll_collision_exception_active: bool = false
var _spam_basic_attack_count: int = 0
var _spam_detection_left: float = 0.0
var _spam_immunity_left: float = 0.0
var _spam_immunity_cooldown_left: float = 0.0
var _last_registered_player_attack_sequence: int = -1

enum JumpState { NONE, WINDUP, AIRBORNE }
## Salto a una plataforma (cae junto al Player) o tajo vertical contra un
## Player colgado de una escalera (sube a su altura y vuelve al suelo).
enum JumpKind { PLATFORM, SLASH }

var _jump_state: JumpState = JumpState.NONE
var _jump_kind: JumpKind = JumpKind.PLATFORM
var _jump_velocity: Vector2 = Vector2.ZERO
var _jump_windup_left: float = 0.0
var _jump_air_time: float = 0.0
var _jump_cooldown_left: float = 0.0
var _off_level_time: float = 0.0
var _drop_through_left: float = 0.0


func _ready() -> void:
    # Si el jefe ya fue derrotado en esta ejecución, no reaparece. Si murió
    # antes de que se recogiera la llave, la llave vuelve a quedar disponible.
    if counts_as_world1_boss and GameManager.world1_boss_defeated:
        if not GameManager.world1_boss_key_collected:
            _spawn_boss_key()
        queue_free()
        return

    super._ready()
    add_to_group("boss")
    if counts_as_world1_boss:
        add_to_group("world1_boss")
    _next_roll_threshold = attacks_before_roll
    # Las one-way solo frenan desde arriba: caminar por debajo o saltar a
    # través de ellas sigue igual que antes.
    if use_platforms:
        set_collision_mask_value(one_way_collision_layer, true)
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

    # Ultimate solo entra en fase 3 y nunca dos veces casi seguidas.
    if (
        boss_phase >= 3
        and _attacks_since_ultimate >= min_attacks_between_ultimates
        and randf() <= ultimate_chance
    ):
        _attacks_since_ultimate = 0
        _last_attack = &"ultimate"
        return _last_attack

    var pool: Array[StringName] = [&"attack", &"attack2"]
    if boss_phase >= 2:
        pool.append(&"attack rapido")

    # Elección al azar para que el patrón no sea un ciclo fijo; repetir el
    # mismo golpe es posible pero poco frecuente.
    if randf() > repeat_attack_chance:
        pool.erase(_last_attack)

    _attacks_since_ultimate += 1
    _last_attack = pool.pick_random()
    return _last_attack


func _start_enemy_attack(animation_name: StringName) -> void:
    # Desde fase 2 el Capitán ejecuta las animaciones de ataque con mayor
    # velocidad. Ajustamos también el temporizador interno para que la ventana
    # de daño y el final del ataque sigan sincronizados con los frames.
    super._start_enemy_attack(animation_name)
    if _current_attack_animation != animation_name or _attack_time_left <= 0.0:
        return

    var speed_scale := _attack_speed_scale_for_phase()
    sprite.speed_scale = speed_scale
    _attack_total_time /= speed_scale
    _attack_time_left /= speed_scale


func _attack_speed_scale_for_phase() -> float:
    if boss_phase >= 3:
        return phase_3_attack_speed_scale
    if boss_phase >= 2:
        return phase_2_attack_speed_scale
    return 1.0


func take_player_attack_from(
    source_global_position: Vector2,
    amount: float,
    player_attack_animation: StringName,
    player_attack_sequence: int
) -> bool:
    var accepted := super.take_damage_from(source_global_position, amount)
    if accepted and not dead:
        _register_basic_player_attack(player_attack_animation, player_attack_sequence)
    return accepted


func take_player_continuous_attack_from(
    source_global_position: Vector2,
    amount: float,
    player_attack_animation: StringName,
    player_attack_sequence: int
) -> bool:
    var accepted := super.take_continuous_damage_from(source_global_position, amount)
    if accepted and not dead:
        _register_basic_player_attack(player_attack_animation, player_attack_sequence)
    return accepted


func _register_basic_player_attack(animation_name: StringName, attack_sequence: int) -> void:
    if animation_name not in [&"attack", &"attack 2", &"attack 3"]:
        return
    if attack_sequence == _last_registered_player_attack_sequence:
        return

    _last_registered_player_attack_sequence = attack_sequence

    # Durante la propia inmunidad o su enfriamiento no acumulamos otro disparo
    # anti-spam. Así el jefe no puede encadenar inmunidad de forma permanente.
    if _spam_immunity_left > 0.0 or _spam_immunity_cooldown_left > 0.0:
        return

    if _spam_detection_left <= 0.0:
        _spam_basic_attack_count = 0
        _spam_detection_left = spam_detection_window

    _spam_basic_attack_count += 1
    if _spam_basic_attack_count >= spam_basic_attacks_to_trigger:
        _activate_spam_immunity()


func _activate_spam_immunity() -> void:
    _spam_basic_attack_count = 0
    _spam_detection_left = 0.0
    _spam_immunity_left = spam_immunity_duration
    _spam_immunity_cooldown_left = spam_immunity_duration + spam_immunity_cooldown

    _cancel_attack()
    _roll_pending = false
    _roll_time_left = 0.0
    _disable_roll_player_passthrough()
    _end_jump()
    _defense_time_left = 0.0
    velocity.x = 0.0
    ai_state = AIState.DEFEND

    if sprite.sprite_frames.has_animation(defense_animation):
        _restart_if_exists(defense_animation)
    else:
        _play_if_exists(&"idle")


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
    var base_cooldown := 0.75
    match animation_name:
        &"ultimate":
            # Las Ultimates enemigas no tienen enfriamiento artificial.
            base_cooldown = 0.0
        &"attack rapido":
            base_cooldown = 0.85

    return base_cooldown * _phase_cooldown_multiplier()


func _phase_cooldown_multiplier() -> float:
    if boss_phase >= 3:
        return phase_3_cooldown_multiplier
    if boss_phase >= 2:
        return phase_2_cooldown_multiplier
    return 1.0


func _on_enemy_attack_finished(_animation_name: StringName) -> void:
    sprite.speed_scale = 1.0
    _attacks_since_roll += 1
    if boss_phase >= 2 and _attacks_since_roll >= _next_roll_threshold:
        _attacks_since_roll = 0
        _roll_pending = true
        _next_roll_threshold = maxi(
            attacks_before_roll + randi_range(-roll_count_variation, roll_count_variation),
            1
        )


func _physics_process(delta: float) -> void:
    # Si muere en el aire, cae durante la animación de muerte en vez de
    # quedarse flotando.
    if dead and use_gravity and not is_on_floor():
        velocity.x = 0.0
        _apply_gravity(delta)
        move_and_slide()
        return
    super._physics_process(delta)


func _process(delta: float) -> void:
    if _spam_detection_left > 0.0:
        _spam_detection_left = maxf(_spam_detection_left - delta, 0.0)
        if _spam_detection_left <= 0.0:
            _spam_basic_attack_count = 0

    if _spam_immunity_left > 0.0:
        _spam_immunity_left = maxf(_spam_immunity_left - delta, 0.0)

    if _spam_immunity_cooldown_left > 0.0:
        _spam_immunity_cooldown_left = maxf(_spam_immunity_cooldown_left - delta, 0.0)

    # Aviso previo al Ultimate: el sprite parpadea en color durante el
    # windup, hasta el primer frame que hace daño.
    var warning := (
        _current_attack_animation == &"ultimate"
        and _attack_time_left > 0.0
        and sprite.frame < _active_frame_range_for_attack(&"ultimate").x
    )

    if warning:
        _ultimate_warning_active = true
        _ultimate_warning_time += delta
        var pulse := 0.5 + 0.5 * sin(_ultimate_warning_time * ultimate_warning_pulse_speed)
        sprite.modulate = Color.WHITE.lerp(ultimate_warning_color, pulse)
    elif _ultimate_warning_active:
        _ultimate_warning_active = false
        _ultimate_warning_time = 0.0
        sprite.modulate = Color.WHITE


func _process_special_state(delta: float) -> bool:
    if _spam_immunity_left > 0.0:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * 2.0 * delta)
        _play_if_exists(defense_animation)
        return true

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

    if _jump_state != JumpState.NONE:
        return _process_jump(delta)

    # El roll espera a que pise suelo (p. ej. si lo tocó en medio de un salto).
    if not _roll_pending or not is_on_floor() or not sprite.sprite_frames.has_animation(&"roll"):
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


func receive_parry(stun_time: float) -> void:
    # El Ultimate es ininterrumpible: el parry lo bloquea sin gastar guardia,
    # pero Capitán no queda aturdido.
    if _current_attack_animation == &"ultimate" and _attack_time_left > 0.0:
        return
    super.receive_parry(stun_time)


func _cancel_attack() -> void:
    super._cancel_attack()
    sprite.speed_scale = 1.0


func _cancel_special_state_on_hit() -> void:
    _roll_pending = false
    _roll_time_left = 0.0
    _disable_roll_player_passthrough()
    # Golpeado en el aire, sale despedido y cae donde le toque.
    _end_jump()


func _can_block_incoming() -> bool:
    # No se cubre en el aire: pillarlo saltando es la recompensa.
    if _jump_state != JumpState.NONE or not is_on_floor():
        return false
    return super._can_block_incoming()


func _update_combat_timers(delta: float) -> void:
    super._update_combat_timers(delta)

    if _jump_cooldown_left > 0.0:
        _jump_cooldown_left = maxf(_jump_cooldown_left - delta, 0.0)

    if _drop_through_left > 0.0:
        _drop_through_left = maxf(_drop_through_left - delta, 0.0)
        if _drop_through_left <= 0.0:
            set_collision_mask_value(one_way_collision_layer, true)


func _play_movement_animation() -> void:
    if not is_on_floor() and _play_air_animation():
        return
    super._play_movement_animation()


## Plataformas: el Capitán sube a donde está el Player, baja de una one-way o
## sigue la persecución normal si están al mismo nivel.
func _chase_target(delta: float) -> void:
    if use_platforms and _navigate_platforms(delta):
        return
    super._chase_target(delta)


func _navigate_platforms(delta: float) -> bool:
    # En el aire (cayendo de una plataforma o tras un empujón) no decide nada:
    # conserva el impulso y espera a tocar suelo.
    if not is_on_floor():
        _play_air_animation()
        return true

    var offset_x := _target.global_position.x - _body_global_x()
    # El Player y el Capitán tienen el origen a la misma altura sobre los pies,
    # así que la diferencia de origen es el desnivel entre los dos.
    var rise := global_position.y - _target.global_position.y
    var target_above := rise > platform_min_rise and _is_target_settled()
    var wants_down := false

    if not target_above and _is_on_one_way_platform():
        if -rise > platform_min_rise:
            wants_down = true
        elif absf(rise) <= platform_min_rise:
            # Mismo nivel pero en otra plataforma: el borde no lo deja seguir.
            var stop_distance := maxf(attack_range + attack_stop_margin, minimum_player_distance)
            wants_down = (
                absf(offset_x) > stop_distance
                and not _can_move_horizontally(_normalized_direction(offset_x))
            )

    if not target_above and not wants_down:
        _off_level_time = 0.0
        return false

    _off_level_time += delta
    var reaction := jump_reaction_time * _phase_cooldown_multiplier()
    _face_direction(_normalized_direction(offset_x))

    if wants_down:
        if _off_level_time >= reaction:
            _start_drop_through()
        else:
            _hold_position(delta)
        return true

    # Player arriba: no lanza tajos al aire; se acerca y salta.
    if (
        rise <= jump_max_rise
        and _off_level_time >= reaction
        and _jump_cooldown_left <= 0.0
        and _try_start_jump()
    ):
        return true

    if absf(offset_x) > jump_approach_distance and _can_move_horizontally(_normalized_direction(offset_x)):
        ai_state = AIState.CHASE
        velocity.x = _normalized_direction(offset_x) * chase_speed
        _play_movement_animation()
    else:
        _hold_position(delta)
    return true


func _hold_position(delta: float) -> void:
    ai_state = AIState.HOLD
    velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * 2.0 * delta)
    _play_if_exists(&"idle")


## De pie sobre algo o colgado de una escalera: no está en mitad de un salto.
func _is_target_settled() -> bool:
    if _target is CharacterBody2D and (_target as CharacterBody2D).is_on_floor():
        return true
    return _target.has_method(&"is_climbing") and bool(_target.call(&"is_climbing"))


func _is_on_one_way_platform() -> bool:
    if not is_on_floor():
        return false
    var solid_mask := collision_mask & ~(1 << (one_way_collision_layer - 1))
    var feet := Vector2(_body_global_x(), global_position.y + _collision_foot_y())
    for side: float in [-8.0, 0.0, 8.0]:
        if _ray_hit(feet + Vector2(side, -2.0), 8.0, solid_mask).size() > 0:
            return false
    return true


func _ray_hit(from: Vector2, depth: float, mask: int) -> Dictionary:
    var query := PhysicsRayQueryParameters2D.create(from, from + Vector2(0.0, depth))
    query.collision_mask = mask
    query.collide_with_areas = false
    var exclude: Array[RID] = [get_rid()]
    if _target is CollisionObject2D:
        exclude.append((_target as CollisionObject2D).get_rid())
    query.exclude = exclude
    return get_world_2d().direct_space_state.intersect_ray(query)


## Altura del suelo bajo un punto, probando también a los lados por si está
## justo en un borde. NAN si no hay nada en depth píxeles.
func _surface_y_below(from: Vector2, depth: float) -> float:
    for side: float in [0.0, -8.0, 8.0]:
        var hit := _ray_hit(from + Vector2(side, 0.0), depth, collision_mask)
        if hit.size() > 0:
            return (hit.position as Vector2).y
    return NAN


func _start_drop_through() -> void:
    set_collision_mask_value(one_way_collision_layer, false)
    _drop_through_left = drop_through_time
    _off_level_time = 0.0
    velocity.y = maxf(velocity.y, drop_down_speed)
    _play_air_animation()


func _try_start_jump() -> bool:
    var target_body := _target as CharacterBody2D
    var on_floor := target_body != null and target_body.is_on_floor()
    var planned := _plan_platform_jump() if on_floor else _plan_slash_jump()
    if not planned:
        return false

    _jump_state = JumpState.WINDUP
    _jump_windup_left = jump_windup_time * _phase_cooldown_multiplier()
    _off_level_time = 0.0
    velocity.x = 0.0
    ai_state = AIState.HOLD
    # Aviso: se agacha (primer cuadro del roll) antes de despegar.
    if sprite.sprite_frames.has_animation(&"roll"):
        sprite.animation = &"roll"
        sprite.frame = 0
        sprite.pause()
    return true


## Busca dónde caer junto al Player sobre su plataforma y si el arco está libre.
func _plan_platform_jump() -> bool:
    var target_x := _target.global_position.x
    var surface_y := _surface_y_below(_target.global_position, 96.0)
    if is_nan(surface_y):
        return false

    var feet_offset := _collision_foot_y()
    var start := global_position
    var height := (start.y + feet_offset) - surface_y + jump_clearance
    if height <= jump_clearance:
        return false
    var launch_speed := sqrt(2.0 * gravity * height)
    var air_time := launch_speed / gravity + sqrt(2.0 * jump_clearance / gravity)

    var side := _normalized_direction(target_x - _body_global_x())
    for landing_x: float in [
        target_x - side * jump_landing_gap,
        target_x - side * jump_landing_gap * 0.5,
        target_x,
        target_x + side * jump_landing_gap,
    ]:
        var landing_feet := Vector2(landing_x, surface_y - 8.0)
        var landing_surface := _surface_y_below(landing_feet, 16.0)
        if is_nan(landing_surface) or absf(landing_surface - surface_y) > 2.0:
            continue
        var horizontal_speed := (landing_x - _body_global_x()) / air_time
        if absf(horizontal_speed) > jump_max_horizontal_speed:
            continue
        var jump_velocity := Vector2(horizontal_speed, -launch_speed)
        # El último tramo es el propio aterrizaje: no se comprueba.
        if not _jump_path_clear(start, jump_velocity, air_time * 0.92):
            continue
        _jump_kind = JumpKind.PLATFORM
        _jump_velocity = jump_velocity
        return true
    return false


## Player colgado de una escalera: sube hasta su altura, a distancia de tajo.
func _plan_slash_jump() -> bool:
    var height := global_position.y - _target.global_position.y + 4.0
    if height <= 0.0:
        return false
    var launch_speed := sqrt(2.0 * gravity * height)
    var rise_time := launch_speed / gravity

    var side := _normalized_direction(_target.global_position.x - _body_global_x())
    var reach := _hitbox_offset_for_attack(&"attack").x
    var apex_x := _target.global_position.x - side * reach
    var horizontal_speed := clampf(
        (apex_x - _body_global_x()) / rise_time,
        -jump_max_horizontal_speed,
        jump_max_horizontal_speed
    )
    var jump_velocity := Vector2(horizontal_speed, -launch_speed)
    if not _jump_path_clear(global_position, jump_velocity, rise_time):
        return false
    _jump_kind = JumpKind.SLASH
    _jump_velocity = jump_velocity
    return true


## Recorre el arco en tramos con test_move. Las one-way no frenan al subir.
func _jump_path_clear(start: Vector2, jump_velocity: Vector2, duration: float) -> bool:
    const STEPS := 12
    var step := duration / STEPS
    var position_now := start
    var vertical_speed := jump_velocity.y
    var xform := global_transform
    for i in STEPS:
        var next_vertical_speed := vertical_speed + gravity * step
        var motion := Vector2(jump_velocity.x * step, (vertical_speed + next_vertical_speed) * 0.5 * step)
        xform.origin = position_now
        if test_move(xform, motion):
            return false
        position_now += motion
        vertical_speed = next_vertical_speed
    return true


func _process_jump(delta: float) -> bool:
    if _jump_state == JumpState.WINDUP:
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * 2.0 * delta)
        _jump_windup_left -= delta
        if _jump_windup_left > 0.0:
            return true
        if not is_on_floor():
            _end_jump()
            return false
        _jump_state = JumpState.AIRBORNE
        _jump_air_time = 0.0
        velocity = _jump_velocity
        _face_direction(signf(_jump_velocity.x))
        _play_air_animation()
        return true

    _jump_air_time += delta
    if _jump_air_time > 0.05 and is_on_floor():
        _land()
        return false

    velocity.x = _jump_velocity.x
    _play_air_animation()
    _try_air_slash()
    return true


## Tajo aéreo (la animación attack ya es el ataque en el aire del sprite). En
## el salto vertical siempre; al subir a una plataforma, desde la fase 2 y solo
## si ya va a caer encima de ella, para no quedarse corto.
func _try_air_slash() -> void:
    if not attacks_enabled or _attack_cooldown_left > 0.0 or velocity.y < -80.0:
        return
    if not is_instance_valid(_target):
        return
    if _jump_kind == JumpKind.PLATFORM:
        if boss_phase < 2:
            return
        var feet := Vector2(_body_global_x(), global_position.y + _collision_foot_y())
        if is_nan(_surface_y_below(feet, jump_clearance + 12.0)):
            return

    _face_direction(_normalized_direction(_target.global_position.x - _body_global_x()))
    if not _target_in_attack_reach(&"attack"):
        return

    _end_jump()
    _start_enemy_attack(&"attack")


func _target_in_attack_reach(animation_name: StringName) -> bool:
    var shape := RectangleShape2D.new()
    shape.size = _hitbox_size_for_attack(animation_name)
    var offset := _hitbox_offset_for_attack(animation_name)
    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = shape
    query.transform = Transform2D(
        0.0,
        global_position + Vector2(_body_center_x() + offset.x * _facing_direction(), offset.y)
    )
    query.collision_mask = _attack_hitbox.collision_mask
    query.exclude = [get_rid()]
    for hit in get_world_2d().direct_space_state.intersect_shape(query, 8):
        if hit.collider == _target:
            return true
    return false


func _land() -> void:
    _end_jump()
    velocity.x = 0.0
    _jump_cooldown_left = jump_cooldown
    # Cae junto al Player: ataca enseguida, pero dejando ver el aterrizaje.
    _attack_cooldown_left = minf(_attack_cooldown_left, landing_attack_delay)
    _play_if_exists(&"idle")


func _end_jump() -> void:
    _jump_state = JumpState.NONE
    _jump_windup_left = 0.0


func _play_air_animation() -> bool:
    var animation_name: StringName = &"jump" if velocity.y < 0.0 else &"fall"
    if not sprite.sprite_frames.has_animation(animation_name):
        return false
    _play_if_exists(animation_name)
    return true


func _is_special_invulnerable() -> bool:
    # Respuesta anti-spam: durante un intervalo breve no acepta ningún daño.
    if _spam_immunity_left > 0.0:
        return true

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
    if not counts_as_world1_boss:
        return
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

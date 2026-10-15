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
    _next_roll_threshold = attacks_before_roll
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

    if boss_phase >= 3:
        return base_cooldown * phase_3_cooldown_multiplier
    if boss_phase >= 2:
        return base_cooldown * phase_2_cooldown_multiplier
    return base_cooldown


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

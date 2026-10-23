extends UnderkingdomCaptainBoss
class_name UnderkingdomQueenBoss

## La Reina, jefa de la mazmorra. Reutiliza la IA del Capitán (fases, roll,
## anti spam, Ultimate con aviso) con los cuadros de golpe de su propio arte
## (Water Priestess) y suma una curación: al entrar en fase 3 se cura una vez,
## salvo que el Player la interrumpa golpeándola.

@export_category("Reina - Curación")
@export var heal_animation: StringName = &"curacion"
@export_range(0.0, 10.0, 0.25) var heal_amount: float = 2.0

## Ventanas de golpe por animación (cuadros, a ojo del alcance del dibujo).
## Las que tienen varias son golpes distintos: el Player puede recibir cada uno.
const HIT_WINDOWS := {
    &"attack basic": [Vector2i(2, 3)],
    &"attack": [Vector2i(3, 6)],
    &"attack2": [Vector2i(2, 4), Vector2i(14, 17)],
    &"attack rapido": [Vector2i(2, 4), Vector2i(14, 17), Vector2i(20, 26)],
}
## Las animaciones de la Reina enemiga son lentas para un jefe.
const BOSS_ANIMATION_SPEEDS := {
    &"attack basic": 10.0,
    &"attack": 10.0,
    &"attack2": 12.0,
    &"attack rapido": 14.0,
    &"ultimate": 12.0,
    &"roll": 10.0,
    &"curacion": 8.0,
}

var _heal_pending: bool = false
var _heal_used: bool = false
var _heal_time_left: float = 0.0


func _ready() -> void:
    # Copia propia de los cuadros: cambiar sus velocidades no afecta a la Reina
    # enemiga de otros mapas, que comparte el recurso.
    sprite.sprite_frames = sprite.sprite_frames.duplicate()
    for animation_name in BOSS_ANIMATION_SPEEDS:
        if sprite.sprite_frames.has_animation(animation_name):
            sprite.sprite_frames.set_animation_speed(animation_name, BOSS_ANIMATION_SPEEDS[animation_name])
            sprite.sprite_frames.set_animation_loop(animation_name, false)
    super._ready()
    phase_changed.connect(_on_phase_changed)


func _on_phase_changed(new_phase: int) -> void:
    if new_phase >= 3 and not _heal_used and sprite.sprite_frames.has_animation(heal_animation):
        _heal_pending = true


func _select_attack_animation() -> StringName:
    var chosen := super._select_attack_animation()
    # El tajo corto se mezcla con los del Capitán para que no sea predecible.
    if chosen != &"ultimate" and randf() < 0.3:
        _last_attack = &"attack basic"
        return _last_attack
    return chosen


func _start_enemy_attack(animation_name: StringName) -> void:
    var windows: Array[Vector2i] = []
    windows.assign(HIT_WINDOWS.get(animation_name, []))
    # Con una sola ventana basta _active_frame_range_for_attack.
    if windows.size() <= 1:
        windows.clear()
    attack_hit_windows = windows
    super._start_enemy_attack(animation_name)


func _process_special_state(delta: float) -> bool:
    if _heal_time_left > 0.0:
        _heal_time_left = maxf(_heal_time_left - delta, 0.0)
        velocity.x = move_toward(velocity.x, 0.0, horizontal_deceleration * 2.0 * delta)
        if _heal_time_left <= 0.0:
            current_health = minf(current_health + heal_amount, max_health)
            health_changed.emit(current_health, max_health)
            UnderkingdomCombatFX.heal(self, sprite)
            _play_if_exists(&"idle")
        return true

    if super._process_special_state(delta):
        return true

    if _heal_pending and _attack_time_left <= 0.0:
        _heal_pending = false
        _heal_used = true
        _heal_time_left = _animation_duration(heal_animation)
        velocity.x = 0.0
        _restart_if_exists(heal_animation)
        return true
    return false


func _cancel_special_state_on_hit() -> void:
    super._cancel_special_state_on_hit()
    # Golpearla mientras se cura le hace perder la curación.
    _heal_time_left = 0.0


func _damage_for_attack(animation_name: StringName) -> float:
    match animation_name:
        &"attack basic", &"attack rapido":
            return 0.5
        &"attack", &"attack2":
            return 0.75
        &"ultimate":
            return 1.5
        _:
            return attack_damage


func _active_frame_range_for_attack(animation_name: StringName) -> Vector2i:
    if animation_name == &"ultimate":
        return Vector2i(12, 31)
    if HIT_WINDOWS.has(animation_name):
        var windows: Array = HIT_WINDOWS[animation_name]
        return windows[0]
    return super._active_frame_range_for_attack(animation_name)


func _hitbox_size_for_attack(animation_name: StringName) -> Vector2:
    match animation_name:
        &"attack basic":
            return Vector2(60.0, 48.0)
        &"attack":
            return Vector2(90.0, 52.0)
        &"attack2":
            return Vector2(92.0, 52.0)
        &"attack rapido":
            return Vector2(108.0, 56.0)
        &"ultimate":
            return Vector2(140.0, 80.0)
        _:
            return attack_hitbox_size


func _hitbox_offset_for_attack(animation_name: StringName) -> Vector2:
    match animation_name:
        &"attack basic":
            return Vector2(30.0, 40.0)
        &"attack rapido":
            return Vector2(54.0, 40.0)
        &"ultimate":
            return Vector2(38.0, 30.0)
        _:
            return Vector2(45.0, 40.0)

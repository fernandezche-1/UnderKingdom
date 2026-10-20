extends UnderkingdomEnemyBase
class_name UnderkingdomSimpleBoss

## Jefe genérico para arte con pocos ataques (Guardián de hielo, Demon Slime,
## Cthulhu). Cada animación de ataque tiene su perfil en attack_profiles; por
## debajo de phase_2_health_ratio el jefe entra en fase 2: ataca más rápido,
## persigue más rápido y puede pasar a volar. Los ataques con blast_frame
## levantan una explosión en el suelo delante del jefe que también hace daño.

signal phase_changed(new_phase: int)

const BLAST_FX := &"explosion_suelo"

@export_category("Jefe - Ataques")
## animación -> {"frames": Vector2i, "damage": float, "size": Vector2,
## "offset": Vector2, "min_phase": int, "blast_frame": int,
## "blast_min_phase": int}. Solo "frames" es obligatorio.
@export var attack_profiles: Dictionary = {}

@export_category("Jefe - Fase 2")
@export_range(0.05, 0.95, 0.05) var phase_2_health_ratio: float = 0.5
@export_range(1.0, 2.0, 0.05) var phase_2_attack_speed_scale: float = 1.25
@export_range(0.2, 1.0, 0.05) var phase_2_cooldown_multiplier: float = 0.7
@export_range(1.0, 2.0, 0.05) var phase_2_chase_multiplier: float = 1.25
## Al entrar en fase 2 deja la gravedad y persigue volando.
@export var phase_2_flies: bool = false
@export var fly_animation: StringName = &"fly"
@export var phase_2_fly_offset_y: float = 10.0

@export_category("Jefe - Explosión en el suelo")
@export_range(0.25, 5.0, 0.25) var blast_damage: float = 0.75
@export var blast_size: Vector2 = Vector2(80.0, 48.0)
## Distancia del centro de la explosión al cuerpo, hacia donde mira.
@export var blast_distance: float = 70.0

var boss_phase: int = 1
var _last_attack: StringName = &""
var _blast_done: bool = false
var _flying: bool = false


func _ready() -> void:
    super._ready()
    add_to_group("boss")
    health_changed.connect(_on_boss_health_changed)


func _on_boss_health_changed(current: float, maximum: float) -> void:
    if boss_phase >= 2 or maximum <= 0.0 or current / maximum > phase_2_health_ratio:
        return
    boss_phase = 2
    chase_speed *= phase_2_chase_multiplier
    if phase_2_flies:
        _flying = true
        use_gravity = false
        fly_toward_target = true
        fly_target_offset_y = phase_2_fly_offset_y
        avoid_ledges = false
        velocity.y = -120.0
    phase_changed.emit(boss_phase)


func _profile(animation_name: StringName) -> Dictionary:
    return attack_profiles.get(String(animation_name), {})


func _select_attack_animation() -> StringName:
    var pool: Array[StringName] = []
    for key in attack_profiles:
        var profile: Dictionary = attack_profiles[key]
        if int(profile.get("min_phase", 1)) <= boss_phase and sprite.sprite_frames.has_animation(StringName(key)):
            pool.append(StringName(key))
    if pool.is_empty():
        return attack_animation
    if pool.size() > 1:
        pool.erase(_last_attack)
    _last_attack = pool.pick_random()
    return _last_attack


func _start_enemy_attack(animation_name: StringName) -> void:
    _blast_done = false
    super._start_enemy_attack(animation_name)
    if _current_attack_animation != animation_name or boss_phase < 2:
        return
    sprite.speed_scale = phase_2_attack_speed_scale
    _attack_total_time /= phase_2_attack_speed_scale
    _attack_time_left /= phase_2_attack_speed_scale


func _update_attack_damage_window() -> void:
    super._update_attack_damage_window()
    if _blast_done or _current_attack_animation == &"" or sprite.animation != _current_attack_animation:
        return
    var profile := _profile(_current_attack_animation)
    var blast_frame := int(profile.get("blast_frame", -1))
    if blast_frame < 0 or boss_phase < int(profile.get("blast_min_phase", 1)) or sprite.frame < blast_frame:
        return
    _blast_done = true
    _ground_blast()


## Explosión en el suelo delante del jefe: efecto visual y daño de área.
func _ground_blast() -> void:
    if _flying:
        return
    var floor_y := global_position.y + _collision_foot_y()
    var center := Vector2(_body_global_x() + _facing_direction() * blast_distance, floor_y - blast_size.y * 0.5)
    # El dibujo de Ground Explosion apoya en el cuadro 101 de 128.
    UnderkingdomCombatFX.play_sprite(self, BLAST_FX, Vector2(center.x, floor_y - 37.0))

    var shape := RectangleShape2D.new()
    shape.size = blast_size
    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = shape
    query.transform = Transform2D(0.0, center)
    query.collision_mask = 1
    query.exclude = [get_rid()]
    for hit in get_world_2d().direct_space_state.intersect_shape(query, 8):
        var body := hit.get("collider") as Node
        if body != null and body.is_in_group(target_group) and body.has_method("take_damage_from"):
            body.call("take_damage_from", center, blast_damage)


## Armadura durante el ataque: el golpe quita vida pero no corta el ataque ni
## lo empuja. Fuera del ataque recibe el golpe normal de enemy_base.
func take_damage(
    amount: float,
    source_global_position: Vector2 = Vector2.ZERO,
    apply_knockback: bool = false
) -> bool:
    if _attack_time_left <= 0.0:
        return super.take_damage(amount, source_global_position, apply_knockback)
    if dead or amount <= 0.0 or _invulnerability_left > 0.0 or _is_special_invulnerable():
        return false
    current_health = maxf(current_health - amount, 0.0)
    damaged.emit(amount)
    health_changed.emit(current_health, max_health)
    if current_health <= 0.0:
        die()
    else:
        _invulnerability_left = invulnerability_time
    return true


func _on_enemy_attack_finished(_animation_name: StringName) -> void:
    sprite.speed_scale = 1.0


func _cancel_attack() -> void:
    super._cancel_attack()
    sprite.speed_scale = 1.0


func _play_movement_animation() -> void:
    if _flying and sprite.sprite_frames.has_animation(fly_animation):
        _play_if_exists(fly_animation)
        return
    super._play_movement_animation()


func _damage_for_attack(animation_name: StringName) -> float:
    return float(_profile(animation_name).get("damage", attack_damage))


func _active_frame_range_for_attack(animation_name: StringName) -> Vector2i:
    var profile := _profile(animation_name)
    if profile.has("frames"):
        return profile["frames"]
    return super._active_frame_range_for_attack(animation_name)


func _hitbox_size_for_attack(animation_name: StringName) -> Vector2:
    return _profile(animation_name).get("size", attack_hitbox_size)


func _hitbox_offset_for_attack(animation_name: StringName) -> Vector2:
    return _profile(animation_name).get("offset", attack_hitbox_offset)


func _cooldown_for_attack(animation_name: StringName) -> float:
    var cooldown := super._cooldown_for_attack(animation_name)
    return cooldown * phase_2_cooldown_multiplier if boss_phase >= 2 else cooldown

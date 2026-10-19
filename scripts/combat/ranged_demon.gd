extends "res://scripts/combat/enemy_base.gd"
class_name UnderkingdomRangedDemon

const FIREBALL_SCENE := preload("res://escenas/proyectiles/fuego_diablillo.tscn")

@export_category("Diablillo - Proyectil")
@export_range(1, 60, 1) var projectile_release_frame: int = 4
@export_range(40.0, 600.0, 5.0) var projectile_speed: float = 210.0
@export_range(0.05, 4.0, 0.05) var projectile_damage: float = 0.50
@export var projectile_spawn_offset: Vector2 = Vector2(24.0, -2.0)

var _projectile_spawned: bool = false


func _start_enemy_attack(animation_name: StringName) -> void:
	_projectile_spawned = false
	super._start_enemy_attack(animation_name)


func _update_attack_damage_window() -> void:
	if _attack_time_left <= 0.0 or _current_attack_animation == &"":
		return
	if sprite.animation != _current_attack_animation or _projectile_spawned:
		return

	var frame_count := sprite.sprite_frames.get_frame_count(_current_attack_animation)
	var release_frame := clampi(projectile_release_frame, 0, maxi(frame_count - 1, 0))
	if sprite.frame < release_frame:
		return

	_projectile_spawned = true
	_spawn_fireball()


func _spawn_fireball() -> void:
	if not is_instance_valid(_target):
		_find_target()
	if not is_instance_valid(_target):
		return

	var projectile := FIREBALL_SCENE.instantiate()
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root
	scene_root.add_child(projectile)

	var facing := _facing_direction()
	var origin := global_position + Vector2(projectile_spawn_offset.x * facing, projectile_spawn_offset.y)
	var target_position := _target.global_position + Vector2(0.0, -8.0)
	projectile.call(
		"setup",
		origin,
		target_position,
		projectile_speed,
		projectile_damage,
		projectile_damage,
		0.0,
		1.0
	)

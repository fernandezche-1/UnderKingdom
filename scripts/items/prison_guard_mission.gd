extends Node2D
class_name UnderkingdomPrisonGuardMission

const GUARD_SCENE: PackedScene = preload("res://escenas/enemigos/esqueleto_tumba.tscn")
const SWORD_SCENE: PackedScene = preload("res://escenas/objetos/espada_recuperable.tscn")

var _guard: UnderkingdomEnemyBase
var _reward_spawned: bool = false


func _ready() -> void:
	set_process(true)
	_sync_mission_objects()


func _sync_mission_objects() -> void:
	if GameManager.has_sword:
		return
	if GameManager.sword_guard_defeated:
		_spawn_sword()
		return
	if not GameManager.sword_mission_started:
		return
	if is_instance_valid(_guard):
		return
	_guard = GUARD_SCENE.instantiate() as UnderkingdomEnemyBase
	_guard.max_health = 2.0
	_guard.attack_damage = 0.25
	_guard.patrol_distance = 28.0
	_guard.patrol_speed = 20.0
	_guard.chase_speed = 34.0
	_guard.detection_range = 180.0
	_guard.attack_range = 38.0
	_guard.minimum_player_distance = 22.0
	_guard.position = Vector2.ZERO
	add_child(_guard)
	_guard.died.connect(_on_guard_defeated, CONNECT_ONE_SHOT)
	_guard.visible = false
	_guard.collision_layer = 0
	_guard.set_physics_process(false)


func _process(_delta: float) -> void:
	_sync_mission_objects()
	if not is_instance_valid(_guard) or _guard.dead:
		return
	var active := GameManager.sword_mission_started and not GameManager.has_sword
	_guard.visible = active
	_guard.collision_layer = 5 if active else 0
	_guard.set_physics_process(active)


func _on_guard_defeated() -> void:
	_guard.remove_from_group("enemy")
	_guard.remove_from_group("damageable")
	GameManager.mark_sword_guard_defeated()
	_spawn_sword()


func _spawn_sword() -> void:
	if _reward_spawned or GameManager.has_sword:
		return
	_reward_spawned = true
	var sword := SWORD_SCENE.instantiate() as Node2D
	add_child(sword)
	sword.global_position = (_guard.global_position if is_instance_valid(_guard) else global_position) + Vector2(0.0, -13.0)

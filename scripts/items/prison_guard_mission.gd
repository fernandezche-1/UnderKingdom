extends Node2D
class_name UnderkingdomPrisonGuardMission

## Conecta la misión al guardia que ya existe en el castillo.
@export var guard_path: NodePath = ^"../Guardia2"

const SWORD_SCENE: PackedScene = preload("res://escenas/objetos/espada_recuperable.tscn")
const SWORD_VISIBLE_HEIGHT: float = 34.0
const DROP_RAY_LENGTH: float = 320.0

var _guard: UnderkingdomEnemyBase
var _reward_spawned: bool = false


func _ready() -> void:
	var scene_path := get_tree().current_scene.scene_file_path if get_tree().current_scene != null else "<sin escena actual>"
	print("[SWORD_DROP] mission_ready scene=%s node=%s guard_path=%s has_sword=%s defeated=%s" % [scene_path, get_path(), guard_path, GameManager.has_sword, GameManager.sword_guard_defeated])
	if not GameManager.has_sword:
		GameManager.start_sword_mission()

	_guard = get_node_or_null(guard_path) as UnderkingdomEnemyBase
	if is_instance_valid(_guard):
		print("[SWORD_DROP] target_resolved node=%s source_scene=%s health=%.2f/%.2f" % [_guard.get_path(), _guard.scene_file_path, _guard.current_health, _guard.max_health])
	if GameManager.sword_guard_defeated:
		if is_instance_valid(_guard):
			_guard.remove_from_group("enemy")
			_guard.remove_from_group("damageable")
			_guard.queue_free()
		print("[SWORD_DROP] restore_pending_drop guard_defeated=true has_sword=%s" % GameManager.has_sword)
		_spawn_sword()
		return
	if not is_instance_valid(_guard):
		push_error("[SWORD_DROP] target_missing scene=%s mission=%s guard_path=%s" % [scene_path, get_path(), guard_path])
		return

	# Debilita solo al guardia de esta misión; conserva la escena, IA y animaciones.
	_guard.max_health = 2.0
	_guard.current_health = minf(_guard.current_health, _guard.max_health)
	_guard.defense_enabled = false
	_guard.add_to_group("sword_recovery_target")
	_guard.died.connect(_on_guard_defeated, CONNECT_ONE_SHOT)
	_guard.death_finished.connect(_on_guard_death_finished, CONNECT_ONE_SHOT)
	print("[SWORD_DROP] signal_connections died=%s death_finished=%s" % [_guard.died.is_connected(_on_guard_defeated), _guard.death_finished.is_connected(_on_guard_death_finished)])


func _on_guard_defeated() -> void:
	if not is_instance_valid(_guard):
		print("[SWORD_DROP] died_received but target_invalid")
		return
	print("[SWORD_DROP] died_received enemy=%s source_scene=%s map=%s health=%.2f dead=%s" % [_guard.get_path(), _guard.scene_file_path, get_tree().current_scene.scene_file_path, _guard.current_health, _guard.dead])
	_guard.remove_from_group("enemy")
	_guard.remove_from_group("damageable")
	GameManager.mark_sword_guard_defeated()
	print("[SWORD_DROP] defeated_flag=%s has_sword=%s" % [GameManager.sword_guard_defeated, GameManager.has_sword])


func _on_guard_death_finished() -> void:
	print("[SWORD_DROP] death_finished_received enemy=%s inside_tree=%s" % [_guard.get_path() if is_instance_valid(_guard) else "<invalid>", _guard.is_inside_tree() if is_instance_valid(_guard) else false])
	_spawn_sword()


func _spawn_sword() -> void:
	if _reward_spawned or GameManager.has_sword:
		print("[SWORD_DROP] spawn_skipped already_spawned=%s has_sword=%s defeated=%s" % [_reward_spawned, GameManager.has_sword, GameManager.sword_guard_defeated])
		return
	_reward_spawned = true
	var sword := SWORD_SCENE.instantiate() as Node2D
	if sword == null:
		push_error("[SWORD_DROP] instantiate_failed scene=%s" % SWORD_SCENE.resource_path)
		return
	add_child(sword)
	var death_position := _guard.global_position if is_instance_valid(_guard) else global_position
	var floor_position := _find_floor_position(death_position)
	# La textura mide 34 px de alto al tamaño mostrado. Apoyar su borde
	# inferior en el suelo mantiene visible la recompensa sin crear colisión.
	sword.global_position = floor_position - Vector2(0.0, SWORD_VISIBLE_HEIGHT)
	print("[SWORD_DROP] spawned instance=%s parent=%s scene=%s death_position=%s floor_position=%s global_position=%s visible=%s has_sword=%s" % [sword.get_path(), sword.get_parent().get_path(), SWORD_SCENE.resource_path, death_position, floor_position, sword.global_position, sword.is_visible_in_tree(), GameManager.has_sword])


func _find_floor_position(origin: Vector2) -> Vector2:
	var from := origin - Vector2(0.0, 24.0)
	var to := from + Vector2(0.0, DROP_RAY_LENGTH)
	var excluded: Array[RID] = []
	if is_instance_valid(_guard):
		excluded.append(_guard.get_rid())
	for player in get_tree().get_nodes_in_group("player"):
		if player is CollisionObject2D:
			excluded.append((player as CollisionObject2D).get_rid())
	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = excluded
	query.collide_with_areas = false
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.has("position"):
		print("[SWORD_DROP] floor_hit collider=%s position=%s" % [hit.get("collider").get_path() if hit.get("collider") is Node else "<non-node>", hit.position])
		return hit.position
	push_warning("[SWORD_DROP] floor_not_found origin=%s map=%s; using death height" % [origin, get_tree().current_scene.scene_file_path])
	return origin + Vector2(0.0, 10.0)

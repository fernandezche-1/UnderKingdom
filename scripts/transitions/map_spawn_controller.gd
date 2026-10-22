
extends Node
class_name UnderkingdomMapSpawnController

## Al cargar un mapa, coloca al jugador en el SpawnPoint
## solicitado por GameManager.
## Si no existe un jugador, crea una instancia automáticamente.

const PLAYER_SCENE := preload("res://escenas/player.tscn")

@export var player_group: StringName = &"player"
@export var default_spawn_id: StringName = &"SpawnInicio"
@export var auto_spawn_player_if_missing: bool = true


func _ready() -> void:
	call_deferred("_place_player")


func _place_player() -> void:
	# Esperar a que las plataformas estén registradas en física.
	await get_tree().physics_frame
	GameManager.remember_current_scene()

	var requested := GameManager.consume_spawn_id()

	if requested == &"":
		requested = default_spawn_id

	var target := _find_spawn_point(requested)

	if target == null and requested != default_spawn_id:
		target = _find_spawn_point(default_spawn_id)

	var player := get_tree().get_first_node_in_group(player_group)

	if player == null and auto_spawn_player_if_missing:
		player = PLAYER_SCENE.instantiate()
		get_tree().current_scene.add_child(player)

	if player == null:
		return

	var current_scene := get_tree().current_scene

	var saved_state: Dictionary = {}

	if current_scene != null:
		saved_state = GameManager.consume_pending_save_restore(
			current_scene.scene_file_path
		)

	# Posición de respaldo.
	var fallback_position: Vector2 = Vector2.ZERO

	if target != null:
		fallback_position = target.global_position
	elif player is Node2D:
		fallback_position = (player as Node2D).global_position

	# Reaparición después de morir.
	if GameManager.consume_death_respawn():
		var death_position: Vector2 = GameManager.respawn_position

		if not _is_safe_landing(player, death_position):
			death_position = _safe_fallback(
				player,
				target,
				fallback_position
			)

		_set_player_spawn(player, death_position)
		_ensure_player_camera(player)
		return

	if target == null:
		push_warning(
			"No se encontró SpawnPoint '%s' en el mapa actual."
			% requested
		)
		return

	# Buscar una posición segura.
	var spawn_position: Vector2 = _safe_fallback(
		player,
		target,
		fallback_position
	)

	# Restaurar progreso y posición guardada.
	if not saved_state.is_empty():
		var saved_position: Vector2 = _saved_position(
			saved_state,
			spawn_position
		)

		GameManager.restore_saved_player(
			player,
			saved_state,
			false
		)

		if _is_safe_landing(player, saved_position):
			spawn_position = saved_position

	_set_player_spawn(player, spawn_position)
	_ensure_player_camera(player)

	if current_scene != null:
		GameManager.autosave_region_entry(
			player,
			current_scene.scene_file_path,
			requested
		)


func _safe_fallback(
	player: Node,
	requested_spawn: Marker2D,
	fallback_position: Vector2
) -> Vector2:

	if requested_spawn != null:
		if _is_safe_landing(player, requested_spawn.global_position):
			return requested_spawn.global_position

	var default_spawn := _find_spawn_point(default_spawn_id)

	if default_spawn != null:
		if _is_safe_landing(player, default_spawn.global_position):
			return default_spawn.global_position

	for spawn_node in get_tree().get_nodes_in_group("spawn_point"):
		if spawn_node is Marker2D:
			if _is_safe_landing(player, spawn_node.global_position):
				return spawn_node.global_position

	push_warning(
		"No se encontró un SpawnPoint con suelo seguro; "
		+ "se conservará la última posición de respaldo."
	)

	return fallback_position


func _saved_position(
	state: Dictionary,
	fallback_position: Vector2
) -> Vector2:

	var location: Variant = state.get("position")

	if location is Array and location.size() == 2:
		return Vector2(
			float(location[0]),
			float(location[1])
		)

	return fallback_position


func _is_safe_landing(
	player: Node,
	candidate: Vector2
) -> bool:

	if not (player is CharacterBody2D):
		return false

	var body := player as CharacterBody2D

	var collision := body.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D

	if collision == null:
		return false

	if collision.shape == null or collision.disabled:
		return false

	# Calcular la posición de la colisión.
	var shape_transform := body.global_transform
	shape_transform.origin = candidate
	shape_transform *= collision.transform

	var space := body.get_world_2d().direct_space_state

	# Verificar que el jugador no aparezca dentro de un sólido.
	var overlap_query := PhysicsShapeQueryParameters2D.new()

	overlap_query.shape = collision.shape
	overlap_query.transform = shape_transform
	overlap_query.collision_mask = body.collision_mask
	overlap_query.collide_with_bodies = true
	overlap_query.collide_with_areas = false
	overlap_query.exclude = [body.get_rid()]

	if not space.intersect_shape(overlap_query, 1).is_empty():
		return false

	# Comprobar que exista suelo debajo de los pies.
	var shape_rect := collision.shape.get_rect()

	var feet_local := Vector2(
		shape_rect.position.x + shape_rect.size.x * 0.5,
		shape_rect.end.y
	)

	var feet_world := shape_transform * feet_local

	var ray_query := PhysicsRayQueryParameters2D.create(
		feet_world,
		feet_world + Vector2(0.0, 12.0),
		body.collision_mask,
		[body.get_rid()]
	)

	ray_query.collide_with_areas = false

	return not space.intersect_ray(ray_query).is_empty()


func _set_player_spawn(
	player: Node,
	position: Vector2
) -> void:

	if player is Node2D:
		(player as Node2D).global_position = position

	if player.has_method("set_spawn_point"):
		player.call("set_spawn_point", position)


func _ensure_player_camera(player: Node) -> void:
	var camera := player.get_node_or_null(
		"Camera2D"
	) as Camera2D

	if camera != null:
		camera.enabled = true
		camera.make_current()


func _find_spawn_point(id: StringName) -> Marker2D:
	for node in get_tree().get_nodes_in_group("spawn_point"):
		if node is Marker2D:
			if node.get("spawn_id") == id:
				return node

	return null

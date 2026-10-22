extends Node
class_name UnderkingdomMapSpawnController

## Al cargar un mapa, coloca al Player en el SpawnPoint solicitado
## por GameManager. Si el mapa todavía no contiene Player, puede crear una
## instancia automáticamente para facilitar la prueba de todos los mundos.

const PLAYER_SCENE := preload("res://escenas/player.tscn")

@export var player_group: StringName = &"player"
@export var default_spawn_id: StringName = &"SpawnInicio"
@export var auto_spawn_player_if_missing: bool = true


func _ready() -> void:
	call_deferred("_place_player")


func _place_player() -> void:
	# Dar un frame a los sistemas de ruta para registrar sus SpawnPoints.
	await get_tree().process_frame
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
	var saved_state := GameManager.consume_pending_save_restore(current_scene.scene_file_path) if current_scene != null else {}

	# Tras una muerte el mapa se recarga: se vuelve al último checkpoint o a
	# la entrada por la que se llegó, no al SpawnInicio.
	if GameManager.consume_death_respawn():
		player.global_position = GameManager.respawn_position
		if player.has_method("set_spawn_point"):
			player.call("set_spawn_point", GameManager.respawn_position)
		_ensure_player_camera(player)
		return

	if target == null:
		push_warning("No se encontró SpawnPoint '%s' en el mapa actual." % requested)
		return

	player.global_position = target.global_position
	if player.has_method("set_spawn_point"):
		player.call("set_spawn_point", target.global_position)
	if not saved_state.is_empty():
		GameManager.restore_saved_player(player, saved_state, true)
	_ensure_player_camera(player)
	GameManager.autosave_region_entry(player, current_scene.scene_file_path, requested)


func _ensure_player_camera(player: Node) -> void:
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.enabled = true
		camera.make_current()


func _find_spawn_point(id: StringName) -> Marker2D:
	for node in get_tree().get_nodes_in_group("spawn_point"):
		if node is Marker2D and node.get("spawn_id") == id:
			return node
	return null

extends Node

const PAUSE_SCENE := preload("res://escenas/menu/menu_pausa.tscn")

var _overlay: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	if event.keycode != KEY_ESCAPE or not event.pressed or event.echo:
		return

	if is_instance_valid(_overlay) and bool(_overlay.call("is_pause_open")):
		if bool(_overlay.call("is_options_open")):
			_overlay.call("show_pause_menu")
		else:
			resume_game()
		get_viewport().set_input_as_handled()
		return

	var player := get_tree().get_first_node_in_group("player")
	if player == null or bool(player.get("dead")) or bool(player.get("controls_locked")):
		return
	if GameManager.is_respawning_after_death():
		return

	if not is_instance_valid(_overlay):
		_overlay = PAUSE_SCENE.instantiate() as CanvasLayer
		get_tree().root.add_child(_overlay)

	_overlay.call("open_pause", player)
	get_tree().paused = true
	get_viewport().set_input_as_handled()


func resume_game() -> void:
	get_tree().paused = false
	if is_instance_valid(_overlay):
		_overlay.call("close_pause")


func return_to_main_menu() -> void:
	get_tree().paused = false
	if is_instance_valid(_overlay):
		_overlay.call("close_pause")
	var error := get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
	if error != OK:
		push_error("No se pudo volver al menú principal. Error de escena: %s" % error)


func quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()

extends Node

const PAUSE_SCENE := preload("res://escenas/menu/menu_pausa.tscn")

var _overlay: UnderkingdomPauseOverlay


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return

	if is_instance_valid(_overlay) and _overlay.is_pause_open():
		if _overlay.is_options_open():
			_overlay.show_pause_menu()
		else:
			resume_game()
		get_viewport().set_input_as_handled()
		return

	var player := get_tree().get_first_node_in_group("player") as UnderkingdomPlayer
	if player == null or player.dead or player.controls_locked:
		return
	if GameManager.is_respawning_after_death():
		return

	if not is_instance_valid(_overlay):
		_overlay = PAUSE_SCENE.instantiate() as UnderkingdomPauseOverlay
		get_tree().root.add_child(_overlay)

	_overlay.open_pause(player)
	get_tree().paused = true
	get_viewport().set_input_as_handled()


## Abre el menú de pausa en la pestaña de mejoras, como tienda de un NPC.
func open_shop(title: String) -> void:
	var player := get_tree().get_first_node_in_group("player") as UnderkingdomPlayer
	if player == null or player.dead:
		return
	if not is_instance_valid(_overlay):
		_overlay = PAUSE_SCENE.instantiate() as UnderkingdomPauseOverlay
		get_tree().root.add_child(_overlay)
	_overlay.open_shop(player, title)
	get_tree().paused = true


func resume_game() -> void:
	get_tree().paused = false
	if is_instance_valid(_overlay):
		_overlay.close_pause()


func return_to_main_menu() -> void:
	get_tree().paused = false
	if is_instance_valid(_overlay):
		_overlay.close_pause()
	var error := get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
	if error != OK:
		push_error("No se pudo volver al menú principal. Error de escena: %s" % error)


func quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()

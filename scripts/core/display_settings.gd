extends Node
## Pantalla completa (autoload `DisplaySettings`): la aplica al arrancar, la
## guarda en `user://ajustes.cfg` y la alterna con F11 desde cualquier pantalla.
## Los menús llaman a `set_fullscreen` y escuchan `fullscreen_changed` para que
## su casilla no quede desfasada si se usa F11 con las opciones abiertas.

signal fullscreen_changed(enabled: bool)

const SETTINGS_PATH: String = "user://ajustes.cfg"
const SECTION: String = "pantalla"
const KEY_FULLSCREEN: String = "pantalla_completa"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK and bool(config.get_value(SECTION, KEY_FULLSCREEN, false)):
		_apply(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		set_fullscreen(not is_fullscreen())
		get_viewport().set_input_as_handled()


func is_fullscreen() -> bool:
	var mode := DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


func set_fullscreen(enabled: bool) -> void:
	_apply(enabled)
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(SECTION, KEY_FULLSCREEN, enabled)
	config.save(SETTINGS_PATH)
	fullscreen_changed.emit(enabled)


func _apply(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

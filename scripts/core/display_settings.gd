extends Node
## Pantalla completa (autoload `DisplaySettings`): la aplica al arrancar, la
## guarda en `user://ajustes.cfg` y la alterna con F11 desde cualquier pantalla.
## Los menús llaman a `set_fullscreen` y escuchan `fullscreen_changed` para que
## su casilla no quede desfasada si se usa F11 con las opciones abiertas.

signal fullscreen_changed(enabled: bool)

const SETTINGS_PATH: String = "user://ajustes.cfg"
const SECTION: String = "pantalla"
const KEY_FULLSCREEN: String = "pantalla_completa"
const VIEWPORT_SIZE: Vector2i = Vector2i(480, 270)
const DEFAULT_WINDOWED_SIZE: Vector2i = Vector2i(1440, 810)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var config := ConfigFile.new()
	var fullscreen: bool = config.load(SETTINGS_PATH) == OK and bool(config.get_value(SECTION, KEY_FULLSCREEN, false))
	_apply(fullscreen)


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
	if not enabled:
		_fit_windowed_size(get_window())


## En pantallas pequeñas la ventana de 1440x810 no cabe: se reduce al mayor
## múltiplo entero de 480x270 que entre en el área útil y se recoloca dentro.
func _fit_windowed_size(window: Window) -> void:
	var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(maxi(0, window.current_screen))
	if usable_rect.size.x <= 0 or usable_rect.size.y <= 0:
		return

	var target_size: Vector2i = DEFAULT_WINDOWED_SIZE
	if target_size.x > usable_rect.size.x or target_size.y > usable_rect.size.y:
		var integer_scale: int = mini(
			floori(float(usable_rect.size.x) / VIEWPORT_SIZE.x),
			floori(float(usable_rect.size.y) / VIEWPORT_SIZE.y)
		)
		target_size = VIEWPORT_SIZE * integer_scale if integer_scale >= 1 else usable_rect.size
	window.size = target_size

	var max_position: Vector2i = usable_rect.position + usable_rect.size - window.size
	if window.size.x <= usable_rect.size.x and window.size.y <= usable_rect.size.y:
		window.position = Vector2i(
			clampi(window.position.x, usable_rect.position.x, max_position.x),
			clampi(window.position.y, usable_rect.position.y, max_position.y)
		)
	else:
		window.position = usable_rect.position

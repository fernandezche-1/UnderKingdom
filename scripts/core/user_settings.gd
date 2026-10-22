extends Node

const SETTINGS_PATH := "user://settings.cfg"
const VIEWPORT_SIZE := Vector2i(480, 270)
const DEFAULT_WINDOWED_SIZE := Vector2i(1440, 810)
const MAX_INTEGER_SCALE := 3


func _ready() -> void:
	var config := ConfigFile.new()
	var fullscreen := false
	if config.load(SETTINGS_PATH) == OK:
		fullscreen = bool(config.get_value("display", "fullscreen", false))
	_apply_window_mode(fullscreen)


func is_fullscreen() -> bool:
	return get_window().mode == Window.MODE_FULLSCREEN


func set_fullscreen(enabled: bool) -> void:
	_apply_window_mode(enabled)
	var config := ConfigFile.new()
	var load_error := config.load(SETTINGS_PATH)
	if load_error != OK and load_error != ERR_FILE_NOT_FOUND:
		push_warning("No se pudieron cargar las preferencias de pantalla.")
	config.set_value("display", "fullscreen", enabled)
	var save_error := config.save(SETTINGS_PATH)
	if save_error != OK:
		push_warning("No se pudo guardar la preferencia de pantalla completa.")


func _apply_window_mode(fullscreen: bool) -> void:
	var window := get_window()
	if fullscreen:
		window.mode = Window.MODE_FULLSCREEN
		return
	window.mode = Window.MODE_WINDOWED
	_fit_windowed_size(window)


func _fit_windowed_size(window: Window) -> void:
	var screen := maxi(0, window.current_screen)
	var usable_rect := DisplayServer.screen_get_usable_rect(screen)
	if usable_rect.size.x <= 0 or usable_rect.size.y <= 0:
		return

	var target_size := DEFAULT_WINDOWED_SIZE
	if target_size.x > usable_rect.size.x or target_size.y > usable_rect.size.y:
		var integer_scale := mini(
			floori(float(usable_rect.size.x) / VIEWPORT_SIZE.x),
			floori(float(usable_rect.size.y) / VIEWPORT_SIZE.y)
		)
		if integer_scale >= 1:
			target_size = VIEWPORT_SIZE * mini(integer_scale, MAX_INTEGER_SCALE)
		else:
			target_size = usable_rect.size
	window.size = target_size

	var max_position := usable_rect.position + usable_rect.size - window.size
	if window.size.x <= usable_rect.size.x and window.size.y <= usable_rect.size.y:
		window.position = Vector2i(
			clampi(window.position.x, usable_rect.position.x, max_position.x),
			clampi(window.position.y, usable_rect.position.y, max_position.y)
		)
	else:
		window.position = usable_rect.position

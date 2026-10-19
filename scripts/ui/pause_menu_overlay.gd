extends CanvasLayer
class_name UnderkingdomPauseOverlay

const UI_ATLAS := preload("res://prueba/FantasyUIfree/FantasyUIfree/freefantasy.png")
const BUTTON_REGION := Rect2(138, 5, 45, 23)
const KEY_NAMES := {
	"cementerio_capitan": "Capitán del Cementerio",
	"minas_caballero": "Caballero de Minas",
}

const COLOR_TEXT := Color(1.0, 0.9, 0.68)
const COLOR_HOVER := Color(1.2, 1.08, 0.82)
const COLOR_PRESSED := Color(0.76, 0.63, 0.43)

@onready var interface: Control = $Interfaz
@onready var header: Label = $Interfaz/TituloMenu
@onready var pause_buttons: VBoxContainer = $Interfaz/BotonesPausa
@onready var options_controls: VBoxContainer = $Interfaz/ControlesOpciones
@onready var health_bar: ProgressBar = $Interfaz/BarraVida
@onready var health_value: Label = $Interfaz/ValorVida
@onready var keys_value: Label = $Interfaz/EstadoLlaves
@onready var lifesteal_value: Label = $Interfaz/EstadoRoboVida
@onready var stats_value: Label = $Interfaz/Estadisticas

var _player: Variant
var _options_open := false
var _master_bus := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	interface.visible = false
	interface.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_master_bus = AudioServer.get_bus_index("Master")
	_apply_text_styles()
	_apply_button_styles()
	_connect_controls()
	_refresh_options()


func open_pause(player: Node) -> void:
	set_player(player)
	_options_open = false
	header.text = "PAUSA"
	pause_buttons.visible = true
	options_controls.visible = false
	interface.visible = true
	visible = true
	focus_resume()


func close_pause() -> void:
	interface.visible = false
	visible = false


func is_pause_open() -> bool:
	return visible and interface.visible


func _apply_text_styles() -> void:
	for node_path in [
		"Interfaz/EncabezadoJugador", "Interfaz/TituloMenu",
		"Interfaz/TituloVida", "Interfaz/TituloLlaves",
		"Interfaz/TituloRoboVida", "Interfaz/TituloEstadisticas",
		"Interfaz/ControlesOpciones/VolumenLabel",
	]:
		var label := get_node(node_path) as Label
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_color_override("font_outline_color", Color(0.12, 0.035, 0.025))
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_font_size_override("font_size", 9)

	for node_path in [
		"Interfaz/NombrePersonaje", "Interfaz/ValorVida",
		"Interfaz/EstadoLlaves", "Interfaz/EstadoRoboVida",
		"Interfaz/Estadisticas",
	]:
		var label := get_node(node_path) as Label
		label.add_theme_color_override("font_color", Color(0.94, 0.88, 0.75))
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.055))
		label.add_theme_constant_override("outline_size", 1)

	get_node("Interfaz/NombrePersonaje").add_theme_font_size_override("font_size", 9)
	get_node("Interfaz/ValorVida").add_theme_font_size_override("font_size", 9)
	get_node("Interfaz/Estadisticas").add_theme_font_size_override("font_size", 8)
	get_node("Interfaz/ValorVida").horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func _apply_button_styles() -> void:
	for button in [
		$Interfaz/BotonesPausa/Reanudar,
		$Interfaz/BotonesPausa/Opciones,
		$Interfaz/BotonesPausa/MenuPrincipal,
		$Interfaz/BotonesPausa/Salir,
		$Interfaz/ControlesOpciones/Volver,
	]:
		button.add_theme_font_size_override("font_size", 9)
		button.add_theme_color_override("font_color", COLOR_TEXT)
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.82))
		button.add_theme_color_override("font_pressed_color", Color(1.0, 0.86, 0.57))
		button.add_theme_stylebox_override("normal", _button_style(Color.WHITE))
		button.add_theme_stylebox_override("hover", _button_style(COLOR_HOVER))
		button.add_theme_stylebox_override("pressed", _button_style(COLOR_PRESSED))
		button.add_theme_stylebox_override("focus", _button_style(COLOR_HOVER))
		button.focus_mode = Control.FOCUS_ALL

	$Interfaz/ControlesOpciones/PantallaCompleta.add_theme_font_size_override("font_size", 8)
	$Interfaz/ControlesOpciones/PantallaCompleta.add_theme_color_override("font_color", COLOR_TEXT)


func _button_style(tint: Color) -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = UI_ATLAS
	atlas.region = BUTTON_REGION
	var style := StyleBoxTexture.new()
	style.texture = atlas
	style.texture_margin_left = 5.0
	style.texture_margin_right = 5.0
	style.texture_margin_top = 4.0
	style.texture_margin_bottom = 4.0
	style.content_margin_left = 5.0
	style.content_margin_right = 5.0
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	style.modulate_color = tint
	return style


func _connect_controls() -> void:
	var pause_manager := get_node("/root/PauseMenu")
	$Interfaz/BotonesPausa/Reanudar.pressed.connect(Callable(pause_manager, "resume_game"))
	$Interfaz/BotonesPausa/Opciones.pressed.connect(show_options)
	$Interfaz/BotonesPausa/MenuPrincipal.pressed.connect(Callable(pause_manager, "return_to_main_menu"))
	$Interfaz/BotonesPausa/Salir.pressed.connect(Callable(pause_manager, "quit_game"))
	$Interfaz/ControlesOpciones/Volver.pressed.connect(show_pause_menu)
	$Interfaz/ControlesOpciones/Volumen.value_changed.connect(_on_master_volume_changed)
	$Interfaz/ControlesOpciones/PantallaCompleta.toggled.connect(_on_fullscreen_toggled)
	$Interfaz/ControlesOpciones/Volumen.add_theme_stylebox_override("slider", _slider_track_style())
	$Interfaz/ControlesOpciones/Volumen.add_theme_stylebox_override("grabber_area", _slider_fill_style())
	$Interfaz/ControlesOpciones/Volumen.add_theme_stylebox_override("grabber_area_highlight", _slider_fill_style())


func _slider_track_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.08, 0.07)
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.53, 0.34, 0.18)
	return style


func _slider_fill_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.76, 0.42, 0.17)
	return style


func set_player(player: Node) -> void:
	if is_instance_valid(_player) and _player.has_signal("health_changed"):
		var old_callback := Callable(self, "_on_health_changed")
		if _player.is_connected("health_changed", old_callback):
			_player.disconnect("health_changed", old_callback)
	_player = player
	if _player.has_signal("health_changed"):
		var callback := Callable(self, "_on_health_changed")
		if not _player.is_connected("health_changed", callback):
			_player.connect("health_changed", callback)
	_update_player_info()


func _update_player_info() -> void:
	if not is_instance_valid(_player):
		return
	var current := float(_player.get("current_health"))
	var maximum := maxf(float(_player.get("max_health")), 0.01)
	_on_health_changed(current, maximum)
	_update_keys()
	_update_lifesteal()
	_update_combat_stats()


func _on_health_changed(current: float, maximum: float) -> void:
	var safe_maximum := maxf(maximum, 0.01)
	health_bar.max_value = safe_maximum
	health_bar.value = clampf(current, 0.0, safe_maximum)
	health_value.text = "%.2f / %.2f" % [current, safe_maximum]


func _update_keys() -> void:
	var rows := PackedStringArray()
	var world1_status := "obtenida" if GameManager.world1_boss_key_collected else "pendiente"
	rows.append("Jefe de Mundo 1: %s" % world1_status)
	for key_variant in KEY_NAMES.keys():
		var key_id := String(key_variant)
		var status := "obtenida" if GameManager.has_key(key_id) else "pendiente"
		rows.append("%s: %s" % [KEY_NAMES[key_id], status])
	for key_variant in GameManager.collected_keys.keys():
		var key_id := String(key_variant)
		if KEY_NAMES.has(key_id):
			continue
		rows.append("%s: obtenida" % key_id.replace("_", " ").capitalize())
	keys_value.text = "\n".join(rows)


func _update_lifesteal() -> void:
	if not bool(_player.get("lifesteal_enabled")):
		lifesteal_value.text = "Desactivado"
		return
	var required := maxf(float(_player.get("lifesteal_damage_required")), 0.01)
	var heal := float(_player.get("lifesteal_heal_amount"))
	var bank := float(_player.get("_lifesteal_damage_bank"))
	var ultimate_multiplier := float(_player.get("ultimate_lifesteal_multiplier"))
	lifesteal_value.text = "Cura %.2f por cada %.2f daño real.\nProgreso: %.2f / %.2f · Ultimate ×%.2f" % [
		heal, required, bank, required, ultimate_multiplier,
	]


func _update_combat_stats() -> void:
	stats_value.text = "Daño combo: %.2f / %.2f / %.2f\nVelocidad: %.0f px/s" % [
		float(_player.get("attack_1_damage")),
		float(_player.get("attack_2_damage")),
		float(_player.get("attack_3_damage")),
		float(_player.get("move_speed")),
	]


func show_options() -> void:
	_options_open = true
	header.text = "OPCIONES"
	pause_buttons.visible = false
	options_controls.visible = true
	$Interfaz/ControlesOpciones/Volumen.grab_focus()


func show_pause_menu() -> void:
	_options_open = false
	header.text = "PAUSA"
	pause_buttons.visible = true
	options_controls.visible = false
	focus_resume()


func is_options_open() -> bool:
	return _options_open


func focus_resume() -> void:
	$Interfaz/BotonesPausa/Reanudar.grab_focus()


func _refresh_options() -> void:
	var volume := $Interfaz/ControlesOpciones/Volumen as HSlider
	if _master_bus < 0:
		volume.editable = false
		volume.tooltip_text = "No existe el bus Master."
	else:
		volume.value = AudioServer.get_bus_volume_linear(_master_bus)
	var fullscreen := $Interfaz/ControlesOpciones/PantallaCompleta as CheckButton
	fullscreen.set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_master_volume_changed(value: float) -> void:
	if _master_bus >= 0:
		AudioServer.set_bus_volume_db(_master_bus, linear_to_db(maxf(value, 0.0001)))


func _on_fullscreen_toggled(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

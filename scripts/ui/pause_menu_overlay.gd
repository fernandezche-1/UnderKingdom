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
@onready var stats_page: Control = $Interfaz/PaginaEstadisticas
@onready var keys_page: Control = $Interfaz/PaginaLlaves
@onready var upgrades_page: Control = $Interfaz/PaginaMejoras
@onready var health_bar: ProgressBar = $Interfaz/PaginaEstadisticas/BarraVida
@onready var health_value: Label = $Interfaz/PaginaEstadisticas/ValorVida
@onready var stats_value: Label = $Interfaz/PaginaEstadisticas/StatsScroll/Estadisticas
@onready var keys_value: Label = $Interfaz/PaginaLlaves/ListaLlaves/EstadoLlaves
@onready var coins_value: Label = $Interfaz/PaginaMejoras/MonedasMejoras

var _player: Node
var _options_open := false
var _master_bus := -1
var _refresh_elapsed := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	interface.visible = false
	interface.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_master_bus = AudioServer.get_bus_index("Master")
	_apply_button_styles()
	_connect_controls()
	_refresh_options()
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.upgrades_changed.connect(_refresh_upgrades)
	_on_coins_changed(GameManager.coins)
	_refresh_upgrades()
	_refresh_keys()


func _process(delta: float) -> void:
	_refresh_elapsed += delta
	if _refresh_elapsed < 0.2:
		return
	_refresh_elapsed = 0.0
	_update_player_info()
	_refresh_keys()
	_refresh_upgrades()


func open_pause(player: Node) -> void:
	set_player(player)
	_options_open = false
	header.text = "PAUSA"
	pause_buttons.visible = true
	options_controls.visible = false
	_show_tab("stats")
	interface.visible = true
	visible = true
	focus_resume()


func close_pause() -> void:
	interface.visible = false
	visible = false


func is_pause_open() -> bool:
	return visible and interface.visible


func _apply_button_styles() -> void:
	var buttons: Array[Button] = [
		$Interfaz/Pestanas/TabEstadisticas,
		$Interfaz/Pestanas/TabLlaves,
		$Interfaz/Pestanas/TabMejoras,
		$Interfaz/BotonesPausa/Reanudar,
		$Interfaz/BotonesPausa/Opciones,
		$Interfaz/BotonesPausa/MenuPrincipal,
		$Interfaz/BotonesPausa/Salir,
		$Interfaz/ControlesOpciones/Volver,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/VidaMejora/VidaComprar,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/RoboMejora/RoboComprar,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/UltimateMejora/UltimateComprar,
	]
	for button in buttons:
		button.add_theme_font_size_override("font_size", 8)
		button.add_theme_color_override("font_color", COLOR_TEXT)
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.82))
		button.add_theme_color_override("font_pressed_color", Color(1.0, 0.86, 0.57))
		button.add_theme_stylebox_override("normal", _button_style(Color.WHITE))
		button.add_theme_stylebox_override("hover", _button_style(COLOR_HOVER))
		button.add_theme_stylebox_override("pressed", _button_style(COLOR_PRESSED))
		button.add_theme_stylebox_override("focus", _button_style(COLOR_HOVER))
		button.focus_mode = Control.FOCUS_ALL
	for label in [
		$Interfaz/PaginaEstadisticas/StatsScroll/Estadisticas,
		$Interfaz/PaginaLlaves/ListaLlaves/EstadoLlaves,
		$Interfaz/PaginaMejoras/MonedasMejoras,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/VidaMejora/VidaInfo,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/RoboMejora/RoboInfo,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/UltimateMejora/UltimateInfo,
	]:
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color(0.94, 0.88, 0.75))
		label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.055))
		label.add_theme_constant_override("outline_size", 1)
	$Interfaz/PaginaEstadisticas/NombrePersonaje.add_theme_font_size_override("font_size", 9)
	$Interfaz/PaginaEstadisticas/ValorVida.add_theme_font_size_override("font_size", 8)
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
	style.content_margin_left = 3.0
	style.content_margin_right = 3.0
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	style.modulate_color = tint
	return style


func _connect_controls() -> void:
	var pause_manager := get_node("/root/PauseMenu")
	$Interfaz/Pestanas/TabEstadisticas.pressed.connect(_on_stats_tab_pressed)
	$Interfaz/Pestanas/TabLlaves.pressed.connect(_on_keys_tab_pressed)
	$Interfaz/Pestanas/TabMejoras.pressed.connect(_on_upgrades_tab_pressed)
	$Interfaz/BotonesPausa/Reanudar.pressed.connect(Callable(pause_manager, "resume_game"))
	$Interfaz/BotonesPausa/Opciones.pressed.connect(show_options)
	$Interfaz/BotonesPausa/MenuPrincipal.pressed.connect(Callable(pause_manager, "return_to_main_menu"))
	$Interfaz/BotonesPausa/Salir.pressed.connect(Callable(pause_manager, "quit_game"))
	$Interfaz/ControlesOpciones/Volver.pressed.connect(show_pause_menu)
	$Interfaz/ControlesOpciones/Volumen.value_changed.connect(_on_master_volume_changed)
	$Interfaz/ControlesOpciones/PantallaCompleta.toggled.connect(_on_fullscreen_toggled)
	$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/VidaMejora/VidaComprar.pressed.connect(_purchase_health)
	$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/RoboMejora/RoboComprar.pressed.connect(_purchase_lifesteal)
	$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/UltimateMejora/UltimateComprar.pressed.connect(_purchase_ultimate)
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
	if is_instance_valid(_player) and _player.has_signal("health_changed"):
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
	var lifesteal_enabled := bool(_player.get("lifesteal_enabled"))
	var lifesteal_amount := float(_player.get("lifesteal_heal_amount"))
	var bank := float(_player.get("_lifesteal_damage_bank"))
	var damage_required := maxf(float(_player.get("lifesteal_damage_required")), 0.01)
	var ult_left := float(_player.call("get_ultimate_cooldown_left"))
	var ult_cooldown := float(_player.get("ultimate_cooldown"))
	var ult_state := "Lista" if ult_left <= 0.0 else "Enfriamiento: %.1f / %.1f s" % [ult_left, ult_cooldown]
	stats_value.text = (
		"Robo de vida: %s\nProgreso: %.2f / %.2f daño\n"
		+ "Combo: %.2f / %.2f / %.2f daño\nVelocidad: %.0f px/s\n"
		+ "Ultimate: %s"
	) % [
		("%.2f por cada 2 daño" % lifesteal_amount) if lifesteal_enabled else "Desactivado",
		bank, damage_required,
		float(_player.get("attack_1_damage")),
		float(_player.get("attack_2_damage")),
		float(_player.get("attack_3_damage")),
		float(_player.get("move_speed")), ult_state,
	]


func _on_health_changed(current: float, maximum: float) -> void:
	var safe_max := maxf(maximum, 0.01)
	health_bar.max_value = safe_max
	health_bar.value = clampf(current, 0.0, safe_max)
	health_value.text = "Vida: %.2f / %.2f" % [current, safe_max]


func _refresh_keys() -> void:
	var rows := PackedStringArray()
	rows.append("Llave del Jefe de Mundo 1: %s" % _key_status(GameManager.world1_boss_key_collected))
	for key_id in KEY_NAMES:
		var acquired := GameManager.has_key(key_id)
		rows.append("%s: %s" % [KEY_NAMES[key_id], _key_status(acquired)])
	for key_variant in GameManager.collected_keys.keys():
		var key_id := String(key_variant)
		if KEY_NAMES.has(key_id):
			continue
		rows.append("%s: obtenida" % key_id.replace("_", " ").capitalize())
	keys_value.text = "\n\n".join(rows)


func _key_status(acquired: bool) -> String:
	return "obtenida" if acquired else "pendiente"


func _refresh_upgrades() -> void:
	_update_upgrade_row("max_health", "Vida máxima", "corazones", "VidaComprar", "VidaInfo")
	_update_upgrade_row("lifesteal", "Robo de vida por cada 2 daño", "vida", "RoboComprar", "RoboInfo")
	_update_upgrade_row("ultimate_cooldown", "Cooldown de Ultimate", "s", "UltimateComprar", "UltimateInfo")


func _update_upgrade_row(upgrade_id: String, label: String, unit: String, button_name: String, info_name: String) -> void:
	var info := GameManager.get_upgrade_info(upgrade_id)
	var row_path := "Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/"
	var button := get_node(row_path + _row_container(button_name) + "/" + button_name) as Button
	var info_label := get_node(row_path + _row_container(button_name) + "/" + info_name) as Label
	var current_value := _format_upgrade_value(upgrade_id, float(info.value))
	if bool(info.at_max):
		info_label.text = "%s\nNivel %d/%d · Actual: %s %s\nNivel máximo" % [label, info.level, info.max_level, current_value, unit]
		button.text = "Nivel máximo"
		button.disabled = true
		return
	var next_value := _format_upgrade_value(upgrade_id, float(info.next_value))
	info_label.text = "%s\nNivel %d/%d · %s → %s %s" % [label, info.level, info.max_level, current_value, next_value, unit]
	button.text = "Mejorar · %d monedas" % int(info.cost)
	button.disabled = GameManager.coins < int(info.cost)


func _row_container(button_name: String) -> String:
	match button_name:
		"VidaComprar": return "VidaMejora"
		"RoboComprar": return "RoboMejora"
		_: return "UltimateMejora"


func _format_upgrade_value(upgrade_id: String, value: float) -> String:
	if upgrade_id == "ultimate_cooldown":
		return "%.1f" % value
	return "%.2f" % value if upgrade_id == "lifesteal" else "%.0f" % value


func _on_coins_changed(value: int) -> void:
	coins_value.text = "Monedas: %d" % value
	_refresh_upgrades()


func _purchase_health() -> void:
	GameManager.purchase_upgrade("max_health")
	_refresh_upgrades()


func _purchase_lifesteal() -> void:
	GameManager.purchase_upgrade("lifesteal")
	_refresh_upgrades()


func _purchase_ultimate() -> void:
	GameManager.purchase_upgrade("ultimate_cooldown")
	_refresh_upgrades()


func _on_stats_tab_pressed() -> void:
	_show_tab("stats")


func _on_keys_tab_pressed() -> void:
	_show_tab("keys")


func _on_upgrades_tab_pressed() -> void:
	_show_tab("upgrades")


func _show_tab(tab: String) -> void:
	stats_page.visible = tab == "stats"
	keys_page.visible = tab == "keys"
	upgrades_page.visible = tab == "upgrades"
	if tab == "keys":
		_refresh_keys()
	elif tab == "upgrades":
		_refresh_upgrades()
	match tab:
		"stats": $Interfaz/Pestanas/TabEstadisticas.grab_focus()
		"keys": $Interfaz/Pestanas/TabLlaves.grab_focus()
		"upgrades": $Interfaz/Pestanas/TabMejoras.grab_focus()


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

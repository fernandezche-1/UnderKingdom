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
@onready var skills_page: Control = $Interfaz/PaginaHabilidades
@onready var health_bar: ProgressBar = $Interfaz/PaginaEstadisticas/BarraVida
@onready var health_value: Label = $Interfaz/PaginaEstadisticas/ValorVida
@onready var stats_value: Label = $Interfaz/PaginaEstadisticas/StatsScroll/Estadisticas
@onready var keys_value: Label = $Interfaz/PaginaLlaves/ListaLlaves/EstadoLlaves
@onready var coins_value: Label = $Interfaz/PaginaMejoras/MonedasMejoras
@onready var soul_status: Label = $Interfaz/PaginaHabilidades/EstadoAlma
@onready var skill_info: Label = $Interfaz/PaginaHabilidades/DetalleHabilidad

var _selected_skill: StringName = &"attack_1"

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
	GameManager.skills_changed.connect(_refresh_skills)
	_on_coins_changed(GameManager.coins)
	_refresh_upgrades()
	_refresh_skills()
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
		$Interfaz/Pestanas/TabHabilidades,
		$Interfaz/BotonesPausa/Reanudar,
		$Interfaz/BotonesPausa/Opciones,
		$Interfaz/BotonesPausa/MenuPrincipal,
		$Interfaz/BotonesPausa/Guardar,
		$Interfaz/BotonesPausa/Salir,
		$Interfaz/ControlesOpciones/Volver,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/VidaMejora/VidaComprar,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/RoboMejora/RoboComprar,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/UltimateMejora/UltimateComprar,
		$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque1,
		$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque2,
		$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque3,
		$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/AtaqueAereo,
		$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/LlamaAncestral,
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
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/FuerzaInfo,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/ResistenciaInfo,
		$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/LlamaInfo,
		$Interfaz/PaginaHabilidades/NombrePersonaje,
		$Interfaz/PaginaHabilidades/EstadoAlma,
		$Interfaz/PaginaHabilidades/DetalleHabilidad,
		$Interfaz/PaginaHabilidades/GuiaFragmentos,
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
	$Interfaz/Pestanas/TabHabilidades.pressed.connect(_on_skills_tab_pressed)
	$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque1.pressed.connect(_on_skill_selected.bind(&"attack_1"))
	$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque2.pressed.connect(_on_skill_selected.bind(&"attack_2"))
	$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque3.pressed.connect(_on_skill_selected.bind(&"attack_3"))
	$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/AtaqueAereo.pressed.connect(_on_skill_selected.bind(&"air_attack"))
	$Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/LlamaAncestral.pressed.connect(_on_skill_selected.bind(&"ultimate"))
	$Interfaz/BotonesPausa/Reanudar.pressed.connect(Callable(pause_manager, "resume_game"))
	$Interfaz/BotonesPausa/Opciones.pressed.connect(show_options)
	$Interfaz/BotonesPausa/MenuPrincipal.pressed.connect(Callable(pause_manager, "return_to_main_menu"))
	$Interfaz/BotonesPausa/Guardar.pressed.connect(_save_from_pause)
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
	$Interfaz/PaginaEstadisticas/NombrePersonaje.text = GameManager.get_player_display_name()
	$Interfaz/PaginaHabilidades/NombrePersonaje.text = GameManager.get_player_display_name()
	$Interfaz/BotonesPausa/Guardar.disabled = not GameManager.has_active_save_slot()
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


func _save_from_pause() -> void:
	if GameManager.save_active_game({}, _player):
		$Interfaz/BotonesPausa/Guardar.text = "Partida guardada"
	else:
		$Interfaz/BotonesPausa/Guardar.text = "No se pudo guardar"
		$Interfaz/BotonesPausa/Guardar.tooltip_text = GameManager.last_save_error
	await get_tree().create_timer(1.3).timeout
	if is_instance_valid(self):
		$Interfaz/BotonesPausa/Guardar.text = "Guardar partida"


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
	$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/FuerzaInfo.text = "Fuerza: el daño existe por ataque; no hay mejora funcional."
	$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/ResistenciaInfo.text = "Resistencia: hay reducción al bloquear; no hay mejora funcional."
	$Interfaz/PaginaMejoras/MejorasScroll/ListaMejoras/LlamaInfo.text = "Llama Ancestral: habilidad bloqueada; mejora de poder no implementada."


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
	var skill_locked := upgrade_id == "ultimate_cooldown" and not GameManager.is_skill_unlocked(&"ultimate")
	var availability := "Bloqueada hasta recuperar la habilidad" if skill_locked else "Mejora disponible"
	info_label.text = "%s\nNivel %d/%d · %s → %s %s\n%s" % [label, info.level, info.max_level, current_value, next_value, unit, availability]
	button.text = "Habilidad bloqueada" if skill_locked else "Mejorar · %d monedas" % int(info.cost)
	button.disabled = skill_locked or GameManager.coins < int(info.cost)


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


func _on_skills_tab_pressed() -> void:
	_show_tab("skills")


func _refresh_skills() -> void:
	soul_status.text = "ALMA: FRAGMENTADA" if GameManager.soul_fragmentation_active else "ALMA: RESTAURADA"
	var buttons := {
		&"attack_1": $Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque1 as Button,
		&"attack_2": $Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque2 as Button,
		&"attack_3": $Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Ataque3 as Button,
		&"air_attack": $Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/AtaqueAereo as Button,
		&"ultimate": $Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/LlamaAncestral as Button,
	}
	for skill_id in buttons:
		var info := GameManager.get_skill_info(skill_id)
		var button: Button = buttons[skill_id]
		button.text = "%s  [%s]" % [info.name, "DISPONIBLE" if info.unlocked else "BLOQUEADA"]
		button.tooltip_text = String(info.description)
	_update_selected_skill()


func _on_skill_selected(skill_id: StringName) -> void:
	_selected_skill = skill_id
	_update_selected_skill()


func _update_selected_skill() -> void:
	var info := GameManager.get_skill_info(_selected_skill)
	if info.is_empty():
		return
	if bool(info.unlocked):
		skill_info.text = "%s\nDISPONIBLE\n%s" % [info.name, info.description]
	else:
		skill_info.text = "%s\nBLOQUEADA\nTu alma está fragmentada. Debes recuperar tu poder ancestral para utilizar esta habilidad." % info.name


func _show_tab(tab: String) -> void:
	stats_page.visible = tab == "stats"
	keys_page.visible = tab == "keys"
	upgrades_page.visible = tab == "upgrades"
	skills_page.visible = tab == "skills"
	if tab == "keys":
		_refresh_keys()
	elif tab == "upgrades":
		_refresh_upgrades()
	elif tab == "skills":
		_refresh_skills()
	match tab:
		"stats": $Interfaz/Pestanas/TabEstadisticas.grab_focus()
		"keys": $Interfaz/Pestanas/TabLlaves.grab_focus()
		"upgrades": $Interfaz/Pestanas/TabMejoras.grab_focus()
		"skills": $Interfaz/Pestanas/TabHabilidades.grab_focus()


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
	fullscreen.set_pressed_no_signal(UserSettings.is_fullscreen())


func _on_master_volume_changed(value: float) -> void:
	if _master_bus >= 0:
		AudioServer.set_bus_volume_db(_master_bus, linear_to_db(maxf(value, 0.0001)))


func _on_fullscreen_toggled(enabled: bool) -> void:
	UserSettings.set_fullscreen(enabled)

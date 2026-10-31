extends CanvasLayer
class_name UnderkingdomPauseOverlay

const KEY_ICON_ATLAS := preload("res://otra vez/fourSeasonsPlatformer_ [tileset, version 2.0]/objects_/items_.png")
const KEY_ICON_REGION := Rect2(48, 32, 16, 16)
const KEY_NAMES := {
	"calabozo_salida": "Salida del calabozo",
	"castillo_rey": "Rey Caído",
	"cementerio_capitan": "Capitán del Cementerio",
	"minas_caballero": "Caballero de Minas",
}
## Filas de la pestaña Datos: id y nombre que se muestra.
const STAT_ROWS: Array[Array] = [
	["lifesteal", "Robo de vida"],
	["lifesteal_progress", "Progreso del robo"],
	["combo", "Combo"],
	["speed", "Velocidad"],
]
## Nombre de la fila de cada mejora, qué mide y su unidad.
const UPGRADE_TEXTS := {
	"max_health": ["Vida máxima", "Corazones", ""],
	"lifesteal": ["Robo de vida", "Daño por curar", ""],
	"ultimate_cooldown": ["Ultimate", "Enfriamiento", " s"],
}

@onready var interface: Control = $Interfaz
@onready var header: Label = $Interfaz/TituloMenu
@onready var tab_stats: Button = $Interfaz/PanelJugador/Contenido/Pestanas/TabEstadisticas
@onready var tab_keys: Button = $Interfaz/PanelJugador/Contenido/Pestanas/TabLlaves
@onready var tab_upgrades: Button = $Interfaz/PanelJugador/Contenido/Pestanas/TabMejoras
@onready var stats_page: Control = $Interfaz/PanelJugador/Contenido/PaginaEstadisticas
@onready var keys_page: Control = $Interfaz/PanelJugador/Contenido/PaginaLlaves
@onready var upgrades_page: Control = $Interfaz/PanelJugador/Contenido/PaginaMejoras
@onready var health_bar: ProgressBar = $Interfaz/PanelJugador/Contenido/PaginaEstadisticas/Cabecera/Resumen/FilaVida/BarraVida
@onready var health_value: Label = $Interfaz/PanelJugador/Contenido/PaginaEstadisticas/Cabecera/Resumen/FilaVida/ValorVida
@onready var ultimate_value: Label = $Interfaz/PanelJugador/Contenido/PaginaEstadisticas/Cabecera/Resumen/EstadoUltimate
@onready var stats_grid: GridContainer = $Interfaz/PanelJugador/Contenido/PaginaEstadisticas/Estadisticas
@onready var abilities_flow: HFlowContainer = $Interfaz/PanelJugador/Contenido/PaginaEstadisticas/Habilidades
@onready var keys_list: VBoxContainer = $Interfaz/PanelJugador/Contenido/PaginaLlaves/ListaLlaves
@onready var coins_value: Label = $Interfaz/PanelJugador/Contenido/PaginaMejoras/FilaMonedas/MonedasMejoras
@onready var upgrades_list: VBoxContainer = $Interfaz/PanelJugador/Contenido/PaginaMejoras/MejorasScroll/ListaMejoras
@onready var pause_buttons: VBoxContainer = $Interfaz/PanelMenu/Margen/BotonesPausa
@onready var options_controls: VBoxContainer = $Interfaz/PanelMenu/Margen/ControlesOpciones
@onready var volume_slider: HSlider = $Interfaz/PanelMenu/Margen/ControlesOpciones/FilaVolumen/Volumen
@onready var volume_value: Label = $Interfaz/PanelMenu/Margen/ControlesOpciones/FilaVolumen/ValorVolumen
@onready var fullscreen_toggle: CheckButton = $Interfaz/PanelMenu/Margen/ControlesOpciones/PantallaCompleta
@onready var save_button: Button = $Interfaz/PanelMenu/Margen/BotonesPausa/Guardar
@onready var player_name_label: Label = $Interfaz/PanelJugador/Contenido/PaginaEstadisticas/Cabecera/Resumen/NombrePersonaje

var _player: UnderkingdomPlayer
var _options_open: bool = false
var _master_bus: int = -1
var _refresh_elapsed: float = 0.0
var _stat_values: Dictionary = {}
var _ability_labels: Dictionary = {}
## Por mejora: {"level": Label, "detail": Label, "button": Button}.
var _upgrade_rows: Dictionary = {}
var _keys_signature: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	interface.visible = false
	interface.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_master_bus = AudioServer.get_bus_index("Master")
	_build_stat_rows()
	_build_ability_labels()
	_build_upgrade_rows()
	_connect_controls()
	var selector := UnderkingdomMenuSelector.new()
	selector.name = "Selector"
	interface.add_child(selector)
	selector.watch(pause_buttons)
	selector.watch(options_controls)
	_refresh_options()
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.upgrades_changed.connect(_refresh_upgrades)
	_on_coins_changed(GameManager.coins)
	_refresh_keys()


func _process(delta: float) -> void:
	if not is_pause_open():
		return
	_refresh_elapsed += delta
	if _refresh_elapsed < 0.2:
		return
	_refresh_elapsed = 0.0
	_update_player_info()
	_refresh_keys()
	_refresh_upgrades()


## El botón B del mando vuelve atrás; Esc lo gestiona PauseMenu con la acción "pause".
func _unhandled_input(event: InputEvent) -> void:
	if not is_pause_open() or not event.is_action_pressed("ui_cancel"):
		return
	if _options_open:
		show_pause_menu()
	else:
		get_node("/root/PauseMenu").call("resume_game")
	get_viewport().set_input_as_handled()


func open_pause(player: UnderkingdomPlayer) -> void:
	set_player(player)
	_options_open = false
	header.text = "Pausa"
	pause_buttons.visible = true
	options_controls.visible = false
	_show_tab("stats")
	interface.visible = true
	visible = true
	focus_resume()


## La pestaña de mejoras con el nombre del vendedor como título.
func open_shop(player: UnderkingdomPlayer, title: String) -> void:
	open_pause(player)
	header.text = title
	_show_tab("upgrades")
	for upgrade_id: String in _upgrade_rows:
		var button: Button = _upgrade_rows[upgrade_id].button
		if not button.disabled:
			button.grab_focus()
			return
	tab_upgrades.grab_focus()


func close_pause() -> void:
	interface.visible = false
	visible = false


func is_pause_open() -> bool:
	return visible and interface.visible


func _build_stat_rows() -> void:
	for row: Array in STAT_ROWS:
		var name_label := Label.new()
		name_label.theme_type_variation = &"TextoTenue"
		name_label.text = String(row[1])
		stats_grid.add_child(name_label)
		var value_label := Label.new()
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stats_grid.add_child(value_label)
		_stat_values[row[0]] = value_label


## Las que faltan salen como "???" para no adelantar qué queda por encontrar.
func _build_ability_labels() -> void:
	for ability_id: String in GameManager.ABILITY_DEFINITIONS:
		var label := Label.new()
		abilities_flow.add_child(label)
		_ability_labels[ability_id] = label


func _refresh_abilities() -> void:
	for ability_id: String in _ability_labels:
		var label: Label = _ability_labels[ability_id]
		if GameManager.has_ability(ability_id):
			label.text = String(GameManager.ABILITY_DEFINITIONS[ability_id].name)
			label.theme_type_variation = &""
		else:
			label.text = "???"
			label.theme_type_variation = &"TextoTenue"


func _build_upgrade_rows() -> void:
	for upgrade_id: String in GameManager.UPGRADE_DEFINITIONS:
		var texts: Array = UPGRADE_TEXTS.get(upgrade_id, [upgrade_id.capitalize(), "Valor", ""])
		var row := PanelContainer.new()
		row.theme_type_variation = &"PanelFila"
		upgrades_list.add_child(row)

		var columns := HBoxContainer.new()
		columns.add_theme_constant_override("separation", 6)
		row.add_child(columns)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 2)
		columns.add_child(info)

		var title_row := HBoxContainer.new()
		info.add_child(title_row)
		var title := Label.new()
		title.theme_type_variation = &"TextoFuerte"
		title.text = String(texts[0])
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_row.add_child(title)
		var level := Label.new()
		level.theme_type_variation = &"TextoTenue"
		title_row.add_child(level)

		var detail := Label.new()
		info.add_child(detail)

		var button := Button.new()
		button.custom_minimum_size = Vector2(66.0, 0.0)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_purchase.bind(upgrade_id))
		columns.add_child(button)

		_upgrade_rows[upgrade_id] = {"level": level, "detail": detail, "button": button}
	_refresh_upgrades()


func _connect_controls() -> void:
	var pause_manager := get_node("/root/PauseMenu")
	tab_stats.pressed.connect(_show_tab.bind("stats"))
	tab_keys.pressed.connect(_show_tab.bind("keys"))
	tab_upgrades.pressed.connect(_show_tab.bind("upgrades"))
	# Moverse por las pestañas con teclado o mando ya cambia de página.
	tab_stats.focus_entered.connect(_show_tab.bind("stats"))
	tab_keys.focus_entered.connect(_show_tab.bind("keys"))
	tab_upgrades.focus_entered.connect(_show_tab.bind("upgrades"))
	$Interfaz/PanelMenu/Margen/BotonesPausa/Reanudar.pressed.connect(Callable(pause_manager, "resume_game"))
	$Interfaz/PanelMenu/Margen/BotonesPausa/Opciones.pressed.connect(show_options)
	save_button.pressed.connect(_save_from_pause)
	$Interfaz/PanelMenu/Margen/BotonesPausa/MenuPrincipal.pressed.connect(Callable(pause_manager, "return_to_main_menu"))
	$Interfaz/PanelMenu/Margen/BotonesPausa/Salir.pressed.connect(Callable(pause_manager, "quit_game"))
	$Interfaz/PanelMenu/Margen/ControlesOpciones/Volver.pressed.connect(show_pause_menu)
	volume_slider.value_changed.connect(_on_master_volume_changed)
	fullscreen_toggle.toggled.connect(DisplaySettings.set_fullscreen)
	DisplaySettings.fullscreen_changed.connect(fullscreen_toggle.set_pressed_no_signal)


func set_player(player: UnderkingdomPlayer) -> void:
	if is_instance_valid(_player) and _player.health_changed.is_connected(_on_health_changed):
		_player.health_changed.disconnect(_on_health_changed)
	_player = player
	if is_instance_valid(_player) and not _player.health_changed.is_connected(_on_health_changed):
		_player.health_changed.connect(_on_health_changed)
	_update_player_info()


func _update_player_info() -> void:
	# Sin ranura activa (mapa abierto directo desde el editor) no hay dónde guardar.
	save_button.disabled = not GameManager.has_active_save_slot()
	if GameManager.has_active_save_slot():
		player_name_label.text = GameManager.get_player_display_name()
	if not is_instance_valid(_player):
		return
	_on_health_changed(_player.current_health, _player.max_health)
	var damage_required: float = maxf(_player.lifesteal_damage_required, 0.01)
	var lifesteal_text: String = "Desactivado"
	if _player.is_lifesteal_active():
		lifesteal_text = "%.2f cada %.2f de daño" % [_player.lifesteal_heal_amount, damage_required]
	(_stat_values.lifesteal as Label).text = lifesteal_text
	(_stat_values.lifesteal_progress as Label).text = "%.2f / %.2f" % [_player.get_lifesteal_progress(), damage_required]
	(_stat_values.combo as Label).text = "%.2f · %.2f · %.2f" % [
		_player.attack_1_damage, _player.attack_2_damage, _player.attack_3_damage,
	]
	(_stat_values.speed as Label).text = "%.0f px/s" % _player.move_speed
	_refresh_abilities()

	var ult_left: float = _player.get_ultimate_cooldown_left()
	if not GameManager.has_ability("ultimate"):
		ultimate_value.text = "Ultimate sin conseguir"
		ultimate_value.theme_type_variation = &"TextoTenue"
	elif ult_left > 0.0:
		ultimate_value.text = "Ultimate en %.1f s" % ult_left
		ultimate_value.theme_type_variation = &"TextoTenue"
	else:
		ultimate_value.text = "Ultimate lista"
		ultimate_value.theme_type_variation = &"TextoAcento"


func _on_health_changed(current: float, maximum: float) -> void:
	var safe_max := maxf(maximum, 0.01)
	health_bar.max_value = safe_max
	health_bar.value = clampf(current, 0.0, safe_max)
	health_value.text = "%s / %s" % [_format_hearts(current), _format_hearts(safe_max)]


## 4 en vez de 4.00, y 3.75 cuando hay cuartos de corazón.
func _format_hearts(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(roundi(value))
	return "%.2f" % value


func _refresh_keys() -> void:
	var entries: Array[Array] = []
	for key_id: String in KEY_NAMES:
		entries.append([String(KEY_NAMES[key_id]), GameManager.has_key(key_id)])
	for key_variant: Variant in GameManager.collected_keys.keys():
		var key_id: String = String(key_variant)
		if not KEY_NAMES.has(key_id):
			entries.append([key_id.replace("_", " ").capitalize(), true])
	var signature: String = str(entries)
	if signature == _keys_signature:
		return
	_keys_signature = signature
	for child: Node in keys_list.get_children():
		child.queue_free()
	for entry: Array in entries:
		keys_list.add_child(_make_key_row(String(entry[0]), bool(entry[1])))


func _make_key_row(key_name: String, acquired: bool) -> Control:
	var row := PanelContainer.new()
	row.theme_type_variation = &"PanelFila"
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 6)
	row.add_child(columns)

	var icon := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = KEY_ICON_ATLAS
	atlas.region = KEY_ICON_REGION
	icon.texture = atlas
	icon.custom_minimum_size = Vector2(16.0, 16.0)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	if not acquired:
		icon.modulate = Color(0.25, 0.22, 0.28, 0.9)
	columns.add_child(icon)

	var name_label := Label.new()
	name_label.text = key_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not acquired:
		name_label.theme_type_variation = &"TextoTenue"
	columns.add_child(name_label)

	var status := Label.new()
	status.text = "Obtenida" if acquired else "Pendiente"
	status.theme_type_variation = &"TextoAcento" if acquired else &"TextoTenue"
	columns.add_child(status)
	return row


func _refresh_upgrades() -> void:
	for upgrade_id: String in _upgrade_rows:
		var row: Dictionary = _upgrade_rows[upgrade_id]
		var info: Dictionary = GameManager.get_upgrade_info(upgrade_id)
		var texts: Array = UPGRADE_TEXTS.get(upgrade_id, [upgrade_id, "Valor", ""])
		var unit: String = String(texts[2])
		var level_label: Label = row.level
		var detail_label: Label = row.detail
		var button: Button = row.button
		level_label.text = "Nv %d/%d" % [info.level, info.max_level]
		var current_value: String = _format_upgrade_value(upgrade_id, float(info.value)) + unit
		if bool(info.at_max):
			detail_label.text = "%s: %s" % [texts[1], current_value]
			button.text = "Máximo"
			button.disabled = true
			continue
		var next_value: String = _format_upgrade_value(upgrade_id, float(info.next_value)) + unit
		detail_label.text = "%s: %s » %s" % [texts[1], current_value, next_value]
		if upgrade_id == "ultimate_cooldown" and not GameManager.has_ability("ultimate"):
			button.text = "Sin Ultimate"
			button.disabled = true
			continue
		button.text = "%d monedas" % int(info.cost)
		button.disabled = not GameManager.can_spend_coins(int(info.cost))


func _format_upgrade_value(upgrade_id: String, value: float) -> String:
	if upgrade_id == "ultimate_cooldown":
		return "%.1f" % value
	return "%.2f" % value if upgrade_id == "lifesteal" else "%.0f" % value


func _on_coins_changed(value: int) -> void:
	coins_value.text = str(value)
	_refresh_upgrades()


func _purchase(upgrade_id: String) -> void:
	GameManager.purchase_upgrade(upgrade_id)
	_refresh_upgrades()


func _save_from_pause() -> void:
	var saved: bool = GameManager.save_active_game({}, _player)
	if saved:
		save_button.text = "Partida guardada"
	elif GameManager.last_save_error == "unsafe":
		# En el aire, atacando o con enemigos cerca.
		save_button.text = "Ahora no se puede"
	else:
		save_button.text = "No se pudo guardar"
		push_warning("Guardado: %s" % GameManager.last_save_error)
	await get_tree().create_timer(1.3, true, false, true).timeout
	if is_instance_valid(save_button):
		save_button.text = "Guardar partida"


func _show_tab(tab: String) -> void:
	stats_page.visible = tab == "stats"
	keys_page.visible = tab == "keys"
	upgrades_page.visible = tab == "upgrades"
	tab_stats.set_pressed_no_signal(tab == "stats")
	tab_keys.set_pressed_no_signal(tab == "keys")
	tab_upgrades.set_pressed_no_signal(tab == "upgrades")
	if tab == "keys":
		_refresh_keys()
	elif tab == "upgrades":
		_refresh_upgrades()


func show_options() -> void:
	_options_open = true
	header.text = "Opciones"
	pause_buttons.visible = false
	options_controls.visible = true
	volume_slider.grab_focus()


func show_pause_menu() -> void:
	_options_open = false
	header.text = "Pausa"
	pause_buttons.visible = true
	options_controls.visible = false
	focus_resume()


func is_options_open() -> bool:
	return _options_open


func focus_resume() -> void:
	$Interfaz/PanelMenu/Margen/BotonesPausa/Reanudar.grab_focus()


func _refresh_options() -> void:
	if _master_bus < 0:
		volume_slider.editable = false
		volume_slider.tooltip_text = "No existe el bus Master."
	else:
		volume_slider.set_value_no_signal(AudioServer.get_bus_volume_linear(_master_bus))
	_update_volume_label(volume_slider.value)
	fullscreen_toggle.set_pressed_no_signal(DisplaySettings.is_fullscreen())


func _on_master_volume_changed(value: float) -> void:
	_update_volume_label(value)
	if _master_bus >= 0:
		AudioServer.set_bus_volume_db(_master_bus, linear_to_db(maxf(value, 0.0001)))


func _update_volume_label(value: float) -> void:
	volume_value.text = "%d%%" % roundi(value * 100.0)

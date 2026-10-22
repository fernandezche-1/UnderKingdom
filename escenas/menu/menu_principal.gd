extends Control

const GAME_SCENE := "res://escenas/mapas/prologo_prision/camara_sellado_alma.tscn"
const BACKGROUND := preload("res://fondos/cementerio.png")
const UI_ATLAS := preload("res://prueba/FantasyUIfree/FantasyUIfree/freefantasy.png")
const BUTTON_REGION := Rect2(138, 5, 45, 23)
const FRAME_REGION := Rect2(163, 48, 83, 127)

const COLOR_TEXT := Color(1.0, 0.9, 0.68)
const COLOR_HOVER := Color(1.22, 1.1, 0.82)
const COLOR_PRESSED := Color(0.76, 0.63, 0.43)
const COLOR_DISABLED := Color(0.48, 0.44, 0.38)

var _main_buttons: VBoxContainer
var _continue_button: Button
var _options_panel: VBoxContainer
var _master_bus := -1
var _profile_panel: PanelContainer
var _profile_title: Label
var _profile_name: LineEdit
var _profile_message: Label
var _profile_slots: VBoxContainer
var _profile_mode := "new"
var _pending_slot := 0
var _overwrite_dialog: ConfirmationDialog


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_master_bus = AudioServer.get_bus_index("Master")
	_build_background()
	_build_menu_frame()
	_build_title()
	_build_main_menu()
	_build_options()
	_build_profile_panel()
	_show_main_menu()


func _build_background() -> void:
	var background := TextureRect.new()
	background.name = "FondoCementerio"
	background.texture = BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)

	var shade := ColorRect.new()
	shade.name = "SombraFondo"
	shade.color = Color(0.015, 0.02, 0.045, 0.46)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)


func _build_menu_frame() -> void:
	var frame := TextureRect.new()
	frame.name = "MarcoMenu"
	frame.texture = _atlas_texture(FRAME_REGION)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.anchor_left = 1.0
	frame.anchor_right = 1.0
	frame.anchor_top = 0.0
	frame.anchor_bottom = 1.0
	frame.offset_left = -176.0
	frame.offset_right = -10.0
	frame.offset_top = 7.0
	frame.offset_bottom = -7.0
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)


func _build_title() -> void:
	var title := Label.new()
	title.name = "Titulo"
	title.text = "UNDERKINGDOM"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.anchor_left = 1.0
	title.anchor_right = 1.0
	title.anchor_top = 0.0
	title.anchor_bottom = 0.0
	title.offset_left = -177.0
	title.offset_right = -9.0
	title.offset_top = 47.0
	title.offset_bottom = 77.0
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", COLOR_TEXT)
	title.add_theme_color_override("font_outline_color", Color(0.12, 0.035, 0.025))
	title.add_theme_constant_override("outline_size", 3)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)


func _build_main_menu() -> void:
	_main_buttons = VBoxContainer.new()
	_main_buttons.name = "BotonesPrincipales"
	_main_buttons.anchor_left = 1.0
	_main_buttons.anchor_right = 1.0
	_main_buttons.anchor_top = 0.0
	_main_buttons.anchor_bottom = 0.0
	_main_buttons.offset_left = -146.0
	_main_buttons.offset_right = -28.0
	_main_buttons.offset_top = 91.0
	_main_buttons.offset_bottom = 213.0
	_main_buttons.add_theme_constant_override("separation", 4)
	add_child(_main_buttons)

	var new_game := _make_button("Nueva partida")
	new_game.name = "NuevaPartida"
	new_game.pressed.connect(_on_new_game_pressed)
	_main_buttons.add_child(new_game)

	_continue_button = _make_button("Continuar")
	_continue_button.name = "Continuar"
	_continue_button.pressed.connect(_show_continue_profiles)
	_main_buttons.add_child(_continue_button)

	var options := _make_button("Opciones")
	options.name = "Opciones"
	options.pressed.connect(_show_options)
	_main_buttons.add_child(options)

	var quit := _make_button("Salir")
	quit.name = "Salir"
	quit.pressed.connect(_on_quit_pressed)
	_main_buttons.add_child(quit)


func _build_options() -> void:
	_options_panel = VBoxContainer.new()
	_options_panel.name = "ControlesOpciones"
	_options_panel.anchor_left = 1.0
	_options_panel.anchor_right = 1.0
	_options_panel.anchor_top = 0.0
	_options_panel.anchor_bottom = 0.0
	_options_panel.offset_left = -146.0
	_options_panel.offset_right = -28.0
	_options_panel.offset_top = 88.0
	_options_panel.offset_bottom = 219.0
	_options_panel.add_theme_constant_override("separation", 3)
	add_child(_options_panel)

	var volume_label := Label.new()
	volume_label.text = "VOLUMEN GENERAL"
	volume_label.add_theme_font_size_override("font_size", 9)
	volume_label.add_theme_color_override("font_color", COLOR_TEXT)
	_options_panel.add_child(volume_label)

	var volume_slider := HSlider.new()
	volume_slider.name = "VolumenGeneral"
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_slider.custom_minimum_size.y = 18.0
	if _master_bus >= 0:
		volume_slider.value = AudioServer.get_bus_volume_linear(_master_bus)
	else:
		volume_slider.editable = false
		volume_slider.tooltip_text = "No existe el bus Master."
	volume_slider.value_changed.connect(_on_master_volume_changed)
	_options_panel.add_child(volume_slider)

	var fullscreen := CheckButton.new()
	fullscreen.name = "PantallaCompleta"
	fullscreen.text = "Pantalla completa"
	fullscreen.add_theme_font_size_override("font_size", 9)
	fullscreen.add_theme_color_override("font_color", COLOR_TEXT)
	fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen.toggled.connect(_on_fullscreen_toggled)
	_options_panel.add_child(fullscreen)

	var back := _make_button("Volver")
	back.name = "Volver"
	back.pressed.connect(_show_main_menu)
	_options_panel.add_child(back)


func _build_profile_panel() -> void:
	_profile_panel = PanelContainer.new()
	_profile_panel.name = "Perfiles"
	_profile_panel.visible = false
	_profile_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_profile_panel.offset_left = 24.0
	_profile_panel.offset_top = 28.0
	_profile_panel.offset_right = -24.0
	_profile_panel.offset_bottom = -28.0
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.045, 0.075, 0.96)
	panel_style.border_color = Color(0.45, 0.34, 0.23, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_content_margin_all(8.0)
	_profile_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(_profile_panel)
	var contents := VBoxContainer.new()
	contents.name = "ContenidoPerfiles"
	contents.add_theme_constant_override("separation", 5)
	_profile_panel.add_child(contents)
	_profile_title = Label.new()
	_profile_title.name = "Titulo"
	_profile_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_profile_title.add_theme_font_size_override("font_size", 12)
	_profile_title.add_theme_color_override("font_color", COLOR_TEXT)
	contents.add_child(_profile_title)
	_profile_name = LineEdit.new()
	_profile_name.placeholder_text = "Nombre del protagonista"
	_profile_name.max_length = 16
	_profile_name.custom_minimum_size.y = 22.0
	_profile_name.add_theme_font_size_override("font_size", 9)
	contents.add_child(_profile_name)
	_profile_message = Label.new()
	_profile_message.add_theme_font_size_override("font_size", 8)
	_profile_message.add_theme_color_override("font_color", COLOR_TEXT)
	_profile_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contents.add_child(_profile_message)
	_profile_slots = VBoxContainer.new()
	_profile_slots.add_theme_constant_override("separation", 3)
	contents.add_child(_profile_slots)
	var back := _make_button("Volver")
	back.pressed.connect(_hide_profiles)
	contents.add_child(back)
	_overwrite_dialog = ConfirmationDialog.new()
	_overwrite_dialog.title = "Reemplazar partida"
	_overwrite_dialog.dialog_text = "Esta ranura ya tiene una partida. ¿Quieres reemplazarla? Se conservará una copia del archivo anterior."
	_overwrite_dialog.confirmed.connect(_confirm_overwrite)
	add_child(_overwrite_dialog)


func _show_new_profiles() -> void:
	_profile_mode = "new"
	_profile_panel.visible = true
	_profile_title.text = "CREAR PERSONAJE"
	_profile_name.visible = true
	_profile_name.text = ""
	_profile_message.text = "Elige una ranura. Tu aventura comenzará en la prisión."
	_main_buttons.visible = false
	_options_panel.visible = false
	_refresh_profile_slots()
	_profile_name.grab_focus()


func _show_continue_profiles() -> void:
	_profile_mode = "continue"
	_profile_panel.visible = true
	_profile_title.text = "CONTINUAR"
	_profile_name.visible = false
	_profile_message.text = "Selecciona una partida guardada."
	_main_buttons.visible = false
	_options_panel.visible = false
	_refresh_profile_slots()


func _refresh_profile_slots() -> void:
	for child in _profile_slots.get_children():
		child.queue_free()
	for slot_id in range(1, GameManager.SAVE_SLOT_COUNT + 1):
		var info: Dictionary = GameManager.get_save_slot_info(slot_id)
		var summary := "Ranura %d: Vacía" % slot_id
		if bool(info.get("valid", false)):
			summary = "Ranura %d: %s — %s" % [slot_id, info.player_name, info.region]
		elif bool(info.get("exists", false)):
			summary = "Ranura %d: Archivo no válido" % slot_id
		var button := _make_button(summary)
		button.custom_minimum_size.y = 30.0
		button.pressed.connect(_on_profile_slot_pressed.bind(slot_id, info))
		if _profile_mode == "continue" and not bool(info.get("valid", false)):
			button.disabled = true
		_profile_slots.add_child(button)


func _on_profile_slot_pressed(slot_id: int, info: Dictionary) -> void:
	if _profile_mode == "continue":
		if GameManager.load_save_slot(slot_id):
			return
		_profile_message.text = GameManager.last_save_error
		return
	var normalized := GameManager.normalize_player_name(_profile_name.text)
	if normalized.is_empty():
		_profile_message.text = "Usa entre 1 y 16 letras; puedes incluir espacios, apóstrofo o guion."
		return
	_profile_name.text = normalized
	_pending_slot = slot_id
	if bool(info.get("exists", false)):
		_overwrite_dialog.popup_centered()
		return
	_start_new_profile(slot_id, false)


func _confirm_overwrite() -> void:
	_start_new_profile(_pending_slot, true)


func _start_new_profile(slot_id: int, overwrite: bool) -> void:
	if not ResourceLoader.exists(GAME_SCENE):
		_profile_message.text = "No se encontró la escena inicial de la prisión."
		return
	_reset_new_game_progress()
	if not GameManager.create_new_profile(slot_id, _profile_name.text, overwrite):
		_profile_message.text = GameManager.last_save_error
		return
	get_tree().set_meta(GameManager.PRISON_CINEMATIC_META_KEY, false)
	var error := get_tree().change_scene_to_file(GAME_SCENE)
	if error != OK:
		_profile_message.text = "No se pudo iniciar la partida (%d)." % error


func _hide_profiles() -> void:
	_profile_panel.visible = false
	_show_main_menu()


func _make_button(label_text: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size.y = 25.0
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.82))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.86, 0.57))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.48, 0.39))
	button.add_theme_stylebox_override("normal", _button_style(Color.WHITE))
	button.add_theme_stylebox_override("hover", _button_style(COLOR_HOVER))
	button.add_theme_stylebox_override("pressed", _button_style(COLOR_PRESSED))
	button.add_theme_stylebox_override("focus", _button_style(COLOR_HOVER))
	button.add_theme_stylebox_override("disabled", _button_style(COLOR_DISABLED))
	return button


func _button_style(tint: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = _atlas_texture(BUTTON_REGION)
	style.texture_margin_left = 5.0
	style.texture_margin_right = 5.0
	style.texture_margin_top = 4.0
	style.texture_margin_bottom = 4.0
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	style.modulate_color = tint
	return style


func _atlas_texture(region: Rect2) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = UI_ATLAS
	texture.region = region
	return texture


func _show_main_menu() -> void:
	if _main_buttons == null:
		return
	_main_buttons.visible = true
	_options_panel.visible = false
	_profile_panel.visible = false
	_continue_button.disabled = not GameManager.has_any_valid_save_slot()
	var start_button := _main_buttons.get_node("NuevaPartida") as Button
	start_button.grab_focus()


func _show_options() -> void:
	_main_buttons.visible = false
	_options_panel.visible = true
	var slider := _options_panel.get_node("VolumenGeneral") as HSlider
	slider.grab_focus()


func _on_new_game_pressed() -> void:
	_show_new_profiles()


func _reset_new_game_progress() -> void:
	var manager: Variant = get_node_or_null("/root/GameManager")
	if manager == null:
		return

	manager.pending_spawn_id = &""
	manager.previous_scene_path = ""
	manager.current_scene_path = ""
	manager.world1_boss_defeated = false
	manager.world1_boss_key_collected = false
	manager.reset_cinematics_for_new_game()
	manager.coins = 0
	manager.potions = 0
	manager.cthulhu_revealed = false
	manager.w2_knight_defeated = false
	manager.respawn_scene_path = ""
	manager.respawn_position = Vector2.ZERO
	manager.consumed_objects.clear()
	manager.completed_encounters.clear()
	manager.collected_keys.clear()
	manager.upgrade_levels = {"max_health": 0, "lifesteal": 0, "ultimate_cooldown": 0}
	manager.active_save_slot = 0
	manager.pending_save_restore.clear()
	manager.last_checkpoint_id = ""
	manager.cancel_pending_autosave()
	manager.world1_boss_defeated_changed.emit(false)
	manager.world1_boss_key_changed.emit(false)
	manager.coins_changed.emit(0)
	manager.potions_changed.emit(0)
	manager.cthulhu_revealed_changed.emit(false)
	manager.w2_knight_defeated_changed.emit(false)


func _on_master_volume_changed(value: float) -> void:
	if _master_bus < 0:
		return
	AudioServer.set_bus_volume_db(_master_bus, linear_to_db(maxf(value, 0.0001)))


func _on_fullscreen_toggled(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func _on_quit_pressed() -> void:
	get_tree().quit()

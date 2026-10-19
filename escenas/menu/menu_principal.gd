extends Control

const GAME_SCENE := "res://escenas/mapas/tiles_cementerio_combate.tscn"
const BACKGROUND := preload("res://fondos/cementerio.png")
const UI_ATLAS := preload("res://prueba/FantasyUIfree/FantasyUIfree/freefantasy.png")
const BUTTON_REGION := Rect2(138, 5, 45, 23)
const FRAME_REGION := Rect2(163, 48, 83, 127)

const COLOR_TEXT := Color(1.0, 0.9, 0.68)
const COLOR_HOVER := Color(1.22, 1.1, 0.82)
const COLOR_PRESSED := Color(0.76, 0.63, 0.43)
const COLOR_DISABLED := Color(0.48, 0.44, 0.38)

var _main_buttons: VBoxContainer
var _options_panel: VBoxContainer
var _master_bus := -1


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_master_bus = AudioServer.get_bus_index("Master")
	_build_background()
	_build_menu_frame()
	_build_title()
	_build_main_menu()
	_build_options()
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

	var continue_row := HBoxContainer.new()
	continue_row.name = "ContinuarNoDisponible"
	continue_row.add_theme_constant_override("separation", 2)
	_main_buttons.add_child(continue_row)

	var continue_button := _make_button("Continuar")
	continue_button.name = "Continuar"
	continue_button.disabled = true
	continue_button.focus_mode = Control.FOCUS_NONE
	continue_button.tooltip_text = "No hay un sistema de guardado implementado."
	continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	continue_row.add_child(continue_button)

	var unavailable := Label.new()
	unavailable.name = "EstadoContinuar"
	unavailable.text = "SIN\nGUARDADO"
	unavailable.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unavailable.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	unavailable.add_theme_font_size_override("font_size", 7)
	unavailable.add_theme_color_override("font_color", COLOR_DISABLED)
	unavailable.custom_minimum_size.x = 32.0
	unavailable.mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_row.add_child(unavailable)

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
	var start_button := _main_buttons.get_node("NuevaPartida") as Button
	start_button.grab_focus()


func _show_options() -> void:
	_main_buttons.visible = false
	_options_panel.visible = true
	var slider := _options_panel.get_node("VolumenGeneral") as HSlider
	slider.grab_focus()


func _on_new_game_pressed() -> void:
	if not ResourceLoader.exists(GAME_SCENE):
		push_error("No existe la escena inicial: %s" % GAME_SCENE)
		return
	_reset_new_game_progress()
	var error := get_tree().change_scene_to_file(GAME_SCENE)
	if error != OK:
		push_error("No se pudo iniciar la partida. Error de escena: %s" % error)


func _reset_new_game_progress() -> void:
	var manager: Variant = get_node_or_null("/root/GameManager")
	if manager == null:
		return

	manager.pending_spawn_id = &""
	manager.previous_scene_path = ""
	manager.current_scene_path = ""
	manager.world1_boss_defeated = false
	manager.world1_boss_key_collected = false
	manager.coins = 0
	manager.potions = 0
	manager.cthulhu_revealed = false
	manager.w2_knight_defeated = false
	manager.cinematics_seen.clear()
	manager.completed_encounters.clear()
	manager.collected_keys.clear()
	manager.respawn_scene_path = ""
	manager.respawn_position = Vector2.ZERO
	manager.consumed_objects.clear()
	manager.reset_cinematics_for_new_game()
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

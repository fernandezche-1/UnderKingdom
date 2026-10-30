extends Control

## "Nueva partida" empieza en la cinemática inicial, que sale a la prisión.
const NEW_GAME_SCENE := "res://escenas/cinematica/cinematica_inicial.tscn"
## La prisión también es el fondo del menú.
const GAME_SCENE := "res://escenas/mapas/prologo_prision/camara_sellado_alma.tscn"
const ORNAMENT := preload("res://escenas/ui/texturas/adorno_linea.png")

const MENU_LEFT: float = 40.0
const MENU_TOP: float = 104.0
const FADE_IN_TIME: float = 0.6
const FADE_OUT_TIME: float = 0.35
## Fondo: la Cámara del Sellado (donde empieza la partida) sin su cinemática.
## Se quitan los nodos que actúan solos; el resto es decorado.
const PRISON_REMOVED_NODES: Array[String] = [
	"Camera2D", "CharacterBody2D/player", "prision inicio", "GuardiaMision",
	"CharacterBody2D2", "SalidaPrision",
]
## Paneo de ida y vuelta por la sala, en píxeles de mundo (borde izquierdo de
## la vista) y segundos por vuelta completa.
const PAN_FROM: float = 120.0
const PAN_TO: float = 190.0
const PAN_PERIOD: float = 40.0
const VIEW_TOP: float = 120.0

var _main_buttons: VBoxContainer
var _continue_button: Button
var _delete_button: Button
var _options_panel: VBoxContainer
## Ranuras de guardado: un mismo panel sirve para crear, continuar y eliminar.
var _profile_panel: VBoxContainer
var _profile_title: Label
var _profile_name: LineEdit
var _profile_message: Label
var _profile_slots: VBoxContainer
var _profile_mode: String = "new"
## Confirmación de reemplazar o eliminar una ranura ocupada.
var _confirm_panel: VBoxContainer
var _confirm_message: Label
var _confirm_buttons: VBoxContainer
var _confirm_action: String = ""
var _pending_slot: int = 0
var _selector: UnderkingdomMenuSelector
var _volume_value: Label
var _fade: ColorRect
var _master_bus: int = -1
var _starting: bool = false
var _prison: Node2D
var _pan_time: float = 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_master_bus = AudioServer.get_bus_index("Master")
	_build_background()
	_build_wisps()
	_build_title()
	_build_main_menu()
	_build_options()
	_build_profile_panel()
	_build_confirm_panel()
	_build_footer()
	_selector = UnderkingdomMenuSelector.new()
	_selector.name = "Selector"
	add_child(_selector)
	_selector.watch(_main_buttons)
	_selector.watch(_options_panel)
	_selector.watch(_confirm_buttons)
	_build_fade()
	_show_main_menu()


func _unhandled_input(event: InputEvent) -> void:
	if _starting or not event.is_action_pressed("ui_cancel"):
		return
	if _confirm_panel.visible:
		_hide_confirm()
	elif _profile_panel.visible or _options_panel.visible:
		_show_main_menu()
	else:
		return
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _prison == null:
		return
	_pan_time += delta
	var t: float = (1.0 - cos(_pan_time * TAU / PAN_PERIOD)) * 0.5
	# Posición entera: sin subpíxeles el pixel art no tiembla.
	_prison.position = Vector2(-roundf(lerpf(PAN_FROM, PAN_TO, t)), -VIEW_TOP)


func _build_background() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "FondoOscuro"
	backdrop.color = Color(0.018, 0.025, 0.055)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Las capas de la prisión tienen z_index negativo: el respaldo va aún más abajo.
	backdrop.z_index = -100
	add_child(backdrop)
	_build_prison()

	# Oscurece el lado del menú y deja ver el cementerio a la derecha.
	var side_shade := TextureRect.new()
	side_shade.name = "SombraLateral"
	side_shade.texture = _gradient_texture(Vector2(1.0, 0.0), [
		Color(0.012, 0.012, 0.035, 0.94),
		Color(0.012, 0.012, 0.035, 0.86),
		Color(0.012, 0.012, 0.035, 0.0),
	], PackedFloat32Array([0.0, 0.6, 1.0]))
	side_shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	side_shade.stretch_mode = TextureRect.STRETCH_SCALE
	side_shade.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	side_shade.offset_right = 340.0
	side_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(side_shade)

	var bottom_shade := TextureRect.new()
	bottom_shade.name = "SombraInferior"
	bottom_shade.texture = _gradient_texture(Vector2(0.0, 1.0), [
		Color(0.012, 0.012, 0.035, 0.0),
		Color(0.012, 0.012, 0.035, 0.75),
	], PackedFloat32Array([0.0, 1.0]))
	bottom_shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bottom_shade.stretch_mode = TextureRect.STRETCH_SCALE
	bottom_shade.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_shade.offset_top = -70.0
	bottom_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom_shade)


func _build_prison() -> void:
	var scene := load(GAME_SCENE) as PackedScene
	if scene == null:
		push_warning("Menú: no se pudo cargar la prisión para el fondo.")
		return
	_prison = scene.instantiate() as Node2D
	# Sin script no arranca la cinemática ni guarda nada.
	_prison.set_script(null)
	for node_path: String in PRISON_REMOVED_NODES:
		var node := _prison.get_node_or_null(node_path)
		if node != null:
			node.get_parent().remove_child(node)
			node.free()
	# La prisión del menú es solo arte: no procesa física, entrada ni lógica del mapa.
	_prison.process_mode = Node.PROCESS_MODE_DISABLED
	_prison.name = "FondoPrision"
	add_child(_prison)
	for sprite: Node in _prison.find_children("*", "AnimatedSprite2D", true, false):
		(sprite as AnimatedSprite2D).play()
	_process(0.0)


func _gradient_texture(direction: Vector2, colors: Array[Color], offsets: PackedFloat32Array) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray(colors)
	gradient.offsets = offsets
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2.ZERO
	texture.fill_to = direction
	texture.width = 64
	texture.height = 64
	return texture


## Ánimas: lucecitas frías que suben despacio entre las tumbas.
func _build_wisps() -> void:
	var ramp := Gradient.new()
	ramp.colors = PackedColorArray([
		Color(0.62, 0.92, 1.0, 0.0),
		Color(0.62, 0.92, 1.0, 0.75),
		Color(0.62, 0.92, 1.0, 0.45),
		Color(0.62, 0.92, 1.0, 0.0),
	])
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.75, 1.0])
	var wisps := CPUParticles2D.new()
	wisps.name = "Animas"
	wisps.amount = 30
	wisps.lifetime = 10.0
	wisps.preprocess = 10.0
	wisps.position = Vector2(240.0, 285.0)
	wisps.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	wisps.emission_rect_extents = Vector2(250.0, 12.0)
	wisps.direction = Vector2.UP
	wisps.spread = 25.0
	wisps.gravity = Vector2(0.0, -1.5)
	wisps.initial_velocity_min = 6.0
	wisps.initial_velocity_max = 15.0
	wisps.tangential_accel_min = -2.0
	wisps.tangential_accel_max = 2.0
	wisps.scale_amount_min = 2.0
	wisps.scale_amount_max = 2.0
	wisps.color_ramp = ramp
	add_child(wisps)


func _build_title() -> void:
	var title := Label.new()
	title.name = "Titulo"
	title.theme_type_variation = &"Titulo"
	title.text = "Underkingdom"
	title.position = Vector2(28.0, 30.0)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)

	var ornament := NinePatchRect.new()
	ornament.name = "Adorno"
	ornament.texture = ORNAMENT
	ornament.patch_margin_left = 8
	ornament.patch_margin_right = 8
	ornament.position = Vector2(26.0, 80.0)
	ornament.size = Vector2(232.0, 5.0)
	ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ornament)


func _build_main_menu() -> void:
	_main_buttons = _make_list("BotonesPrincipales")

	var new_game := _make_button("Nueva partida")
	new_game.name = "NuevaPartida"
	new_game.pressed.connect(_on_new_game_pressed)
	_main_buttons.add_child(new_game)

	_continue_button = _make_button("Continuar")
	_continue_button.name = "Continuar"
	_continue_button.pressed.connect(_show_profiles.bind("continue"))
	_main_buttons.add_child(_continue_button)

	_delete_button = _make_button("Eliminar partida")
	_delete_button.name = "EliminarPartida"
	_delete_button.pressed.connect(_show_profiles.bind("delete"))
	_main_buttons.add_child(_delete_button)

	var options := _make_button("Opciones")
	options.name = "Opciones"
	options.pressed.connect(_show_options)
	_main_buttons.add_child(options)

	var quit := _make_button("Salir")
	quit.name = "Salir"
	quit.pressed.connect(_on_quit_pressed)
	_main_buttons.add_child(quit)


func _build_options() -> void:
	_options_panel = _make_list("ControlesOpciones")
	_options_panel.add_theme_constant_override("separation", 5)
	_options_panel.visible = false

	var volume_row := HBoxContainer.new()
	volume_row.name = "FilaVolumen"
	volume_row.add_theme_constant_override("separation", 6)
	_options_panel.add_child(volume_row)

	var volume_label := Label.new()
	volume_label.text = "Volumen"
	volume_row.add_child(volume_label)

	var volume_slider := HSlider.new()
	volume_slider.name = "VolumenGeneral"
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if _master_bus >= 0:
		volume_slider.value = AudioServer.get_bus_volume_linear(_master_bus)
	else:
		volume_slider.editable = false
		volume_slider.tooltip_text = "No existe el bus Master."
	volume_slider.value_changed.connect(_on_master_volume_changed)
	volume_row.add_child(volume_slider)

	_volume_value = Label.new()
	_volume_value.name = "ValorVolumen"
	_volume_value.theme_type_variation = &"TextoTenue"
	_volume_value.custom_minimum_size.x = 24.0
	_volume_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	volume_row.add_child(_volume_value)
	_update_volume_label(volume_slider.value)

	var fullscreen := CheckButton.new()
	fullscreen.name = "PantallaCompleta"
	fullscreen.text = "Pantalla completa"
	fullscreen.button_pressed = DisplaySettings.is_fullscreen()
	fullscreen.toggled.connect(DisplaySettings.set_fullscreen)
	DisplaySettings.fullscreen_changed.connect(fullscreen.set_pressed_no_signal)
	_options_panel.add_child(fullscreen)

	var back := _make_button("Volver")
	back.name = "Volver"
	back.pressed.connect(_show_main_menu)
	_options_panel.add_child(back)


func _build_profile_panel() -> void:
	_profile_panel = _make_list("Perfiles")
	_profile_panel.position.y = MENU_TOP - 12.0
	_profile_panel.custom_minimum_size.x = 260.0
	_profile_panel.visible = false

	_profile_title = Label.new()
	_profile_title.name = "Titulo"
	_profile_title.theme_type_variation = &"Encabezado"
	_profile_panel.add_child(_profile_title)

	_profile_name = LineEdit.new()
	_profile_name.name = "Nombre"
	_profile_name.placeholder_text = "Nombre del protagonista"
	_profile_name.max_length = 16
	_profile_name.custom_minimum_size.x = 170.0
	_profile_name.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	# Enter en el nombre pasa a elegir la ranura.
	_profile_name.text_submitted.connect(func(_text: String) -> void: _focus_first_slot())
	_profile_panel.add_child(_profile_name)

	_profile_message = Label.new()
	_profile_message.name = "Mensaje"
	_profile_message.theme_type_variation = &"TextoTenue"
	_profile_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_profile_panel.add_child(_profile_message)

	_profile_slots = VBoxContainer.new()
	_profile_slots.name = "Ranuras"
	_profile_slots.add_theme_constant_override("separation", 3)
	_profile_panel.add_child(_profile_slots)


func _build_confirm_panel() -> void:
	_confirm_panel = _make_list("Confirmar")
	_confirm_panel.position.y = MENU_TOP - 12.0
	_confirm_panel.custom_minimum_size.x = 260.0
	_confirm_panel.visible = false

	_confirm_message = Label.new()
	_confirm_message.name = "Mensaje"
	_confirm_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_confirm_panel.add_child(_confirm_message)

	_confirm_buttons = VBoxContainer.new()
	_confirm_buttons.name = "Botones"
	_confirm_buttons.add_theme_constant_override("separation", 3)
	_confirm_panel.add_child(_confirm_buttons)

	var cancel := _make_button("Cancelar")
	cancel.name = "Cancelar"
	cancel.pressed.connect(_hide_confirm)
	_confirm_buttons.add_child(cancel)

	var accept := _make_button("Aceptar")
	accept.name = "Aceptar"
	accept.pressed.connect(_on_confirm_accepted)
	_confirm_buttons.add_child(accept)


func _build_footer() -> void:
	var hint := Label.new()
	hint.name = "Ayuda"
	hint.theme_type_variation = &"TextoTenue"
	hint.text = "Enter / A  aceptar      Esc / B  volver"
	hint.position = Vector2(28.0, 252.0)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)


func _build_fade() -> void:
	_fade = ColorRect.new()
	_fade.name = "Fundido"
	_fade.color = Color(0.0, 0.0, 0.0, 1.0)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	create_tween().tween_property(_fade, "color:a", 0.0, FADE_IN_TIME)


func _make_list(list_name: String) -> VBoxContainer:
	var list := VBoxContainer.new()
	list.name = list_name
	list.position = Vector2(MENU_LEFT, MENU_TOP)
	list.custom_minimum_size.x = 170.0
	list.add_theme_constant_override("separation", 3)
	add_child(list)
	return list


func _make_button(label_text: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.theme_type_variation = &"BotonMenu"
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.focus_mode = Control.FOCUS_ALL
	return button


func _show_main_menu() -> void:
	if _main_buttons == null:
		return
	var target := "NuevaPartida"
	if _options_panel.visible:
		target = "Opciones"
	elif _profile_panel.visible:
		target = {"continue": "Continuar", "delete": "EliminarPartida"}.get(_profile_mode, "NuevaPartida")
	_main_buttons.visible = true
	_options_panel.visible = false
	_profile_panel.visible = false
	_confirm_panel.visible = false
	_continue_button.disabled = not GameManager.has_any_valid_save_slot()
	_delete_button.disabled = not _has_existing_save_slot()
	var target_button := _main_buttons.get_node(target) as Button
	if target_button.disabled:
		target_button = _main_buttons.get_node("NuevaPartida") as Button
	target_button.grab_focus()


func _has_existing_save_slot() -> bool:
	for slot_id: int in range(1, GameManager.SAVE_SLOT_COUNT + 1):
		if bool(GameManager.get_save_slot_info(slot_id).get("exists", false)):
			return true
	return false


func _show_options() -> void:
	_main_buttons.visible = false
	_options_panel.visible = true
	(_options_panel.get_node("FilaVolumen/VolumenGeneral") as HSlider).grab_focus()


func _on_new_game_pressed() -> void:
	_show_profiles("new")


## mode: "new" (nombre + ranura), "continue" o "delete".
func _show_profiles(mode: String) -> void:
	_profile_mode = mode
	_main_buttons.visible = false
	_options_panel.visible = false
	_confirm_panel.visible = false
	_profile_panel.visible = true
	_profile_name.visible = mode == "new"
	match mode:
		"new":
			_profile_title.text = "Nueva partida"
			_profile_message.text = "Escribe un nombre y elige una ranura."
		"continue":
			_profile_title.text = "Continuar"
			_profile_message.text = "Elige una partida guardada."
		_:
			_profile_title.text = "Eliminar partida"
			_profile_message.text = "Elige la ranura que quieres borrar."
	_refresh_profile_slots()
	if mode == "new":
		_profile_name.text = ""
		_profile_name.grab_focus()
	else:
		_focus_first_slot()


func _refresh_profile_slots() -> void:
	for child: Node in _profile_slots.get_children():
		_profile_slots.remove_child(child)
		child.queue_free()
	for slot_id: int in range(1, GameManager.SAVE_SLOT_COUNT + 1):
		var info: Dictionary = GameManager.get_save_slot_info(slot_id)
		var summary := "Ranura %d · vacía" % slot_id
		if bool(info.get("valid", false)):
			summary = "Ranura %d · %s · %s" % [slot_id, info.player_name, info.region]
		elif bool(info.get("exists", false)):
			summary = "Ranura %d · archivo dañado" % slot_id
		var button := _make_button(summary)
		button.name = "Ranura%d" % slot_id
		if _profile_mode == "continue":
			button.disabled = not bool(info.get("valid", false))
		elif _profile_mode == "delete":
			button.disabled = not bool(info.get("exists", false))
		button.pressed.connect(_on_profile_slot_pressed.bind(slot_id, info))
		_profile_slots.add_child(button)
	var back := _make_button("Volver")
	back.name = "Volver"
	back.pressed.connect(_show_main_menu)
	_profile_slots.add_child(back)
	_selector.watch(_profile_slots)


func _focus_first_slot() -> void:
	for child: Node in _profile_slots.get_children():
		var button := child as Button
		if button != null and not button.disabled:
			button.grab_focus()
			return


func _on_profile_slot_pressed(slot_id: int, info: Dictionary) -> void:
	if _starting:
		return
	_pending_slot = slot_id
	match _profile_mode:
		"continue":
			_continue_game(slot_id)
		"delete":
			_show_confirm("delete", "Se borrará todo el progreso de la ranura %d. No se puede deshacer." % slot_id)
		_:
			var normalized := GameManager.normalize_player_name(_profile_name.text)
			if normalized.is_empty():
				_profile_message.text = "El nombre lleva de 1 a 16 letras; admite espacios, apóstrofo y guion."
				_profile_name.grab_focus()
				return
			_profile_name.text = normalized
			if bool(info.get("exists", false)):
				_show_confirm("overwrite", "La ranura %d ya tiene una partida. ¿Reemplazarla? Se guarda una copia de la anterior." % slot_id)
			else:
				_start_new_game(slot_id, false)


func _show_confirm(action: String, message: String) -> void:
	_confirm_action = action
	_confirm_message.text = message
	(_confirm_buttons.get_node("Aceptar") as Button).text = "Eliminar" if action == "delete" else "Reemplazar"
	_profile_panel.visible = false
	_confirm_panel.visible = true
	(_confirm_buttons.get_node("Cancelar") as Button).grab_focus()


func _hide_confirm() -> void:
	_confirm_panel.visible = false
	_profile_panel.visible = true
	var slot_button := _profile_slots.get_node_or_null("Ranura%d" % _pending_slot) as Button
	if slot_button != null:
		slot_button.grab_focus()


func _on_confirm_accepted() -> void:
	if _confirm_action == "overwrite":
		_start_new_game(_pending_slot, true)
		return
	if not GameManager.delete_save_slot(_pending_slot):
		_hide_confirm()
		_profile_message.text = GameManager.last_save_error
		return
	if not _has_existing_save_slot():
		_show_main_menu()
		return
	_hide_confirm()
	_profile_message.text = "Partida eliminada."
	_refresh_profile_slots()
	_focus_first_slot()


func _start_new_game(slot_id: int, overwrite: bool) -> void:
	if not ResourceLoader.exists(NEW_GAME_SCENE):
		push_error("No existe la escena inicial: %s" % NEW_GAME_SCENE)
		return
	GameManager.reset_for_new_game()
	if not GameManager.create_new_profile(slot_id, _profile_name.text, overwrite):
		_confirm_panel.visible = false
		_profile_panel.visible = true
		_profile_message.text = GameManager.last_save_error
		return
	get_tree().set_meta(GameManager.PRISON_CINEMATIC_META_KEY, false)
	await _fade_out()
	var error := get_tree().change_scene_to_file(NEW_GAME_SCENE)
	if error != OK:
		push_error("No se pudo iniciar la partida. Error de escena: %s" % error)


func _continue_game(slot_id: int) -> void:
	await _fade_out()
	if GameManager.load_save_slot(slot_id):
		return
	# La partida no cargó: se deshace el fundido y se explica por qué.
	_starting = false
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	create_tween().tween_property(_fade, "color:a", 0.0, FADE_OUT_TIME)
	_profile_message.text = GameManager.last_save_error
	_focus_first_slot()


func _fade_out() -> void:
	_starting = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, FADE_OUT_TIME)
	await tween.finished


func _on_master_volume_changed(value: float) -> void:
	_update_volume_label(value)
	if _master_bus < 0:
		return
	AudioServer.set_bus_volume_db(_master_bus, linear_to_db(maxf(value, 0.0001)))


func _update_volume_label(value: float) -> void:
	_volume_value.text = "%d%%" % roundi(value * 100.0)


func _on_quit_pressed() -> void:
	get_tree().quit()

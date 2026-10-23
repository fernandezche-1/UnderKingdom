extends RefCounted
class_name UnderkingdomEdwinMenuStyle

## Presentation only: existing menus retain their nodes, callbacks and state.
const MENU_THEME := preload("res://escenas/ui/tema_underkingdom.tres")
const HEADING := preload("res://fuentes/Jacquard12-Regular.ttf")
const ORNAMENT := preload("res://escenas/ui/texturas/adorno_linea.png")
const PANEL := preload("res://escenas/ui/texturas/marco_panel.png")
const SELECTOR := preload("res://scripts/ui/menu_selector.gd")


static func apply(root: Control, main_menu: bool) -> void:
	root.theme = MENU_THEME
	for node in root.find_children("*", "Control", true, false):
		if node is Button:
			if node.get_parent().name in ["BotonesPrincipales", "BotonesPausa", "ControlesOpciones"]:
				node.theme_type_variation = &"BotonMenu"
				node.alignment = HORIZONTAL_ALIGNMENT_LEFT
			if node.get_parent().name == "Pestanas":
				node.theme_type_variation = &"BotonPestana"
			for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
				node.remove_theme_stylebox_override(state)
		if node is NinePatchRect and node.name in ["PanelJugador", "PanelMenu"]:
			node.texture = PANEL
			node.patch_margin_left = 8
			node.patch_margin_right = 8
			node.patch_margin_top = 8
			node.patch_margin_bottom = 8
	if main_menu:
		_style_main(root)
	else:
		var title := root.get_node("TituloMenu") as Label
		title.add_theme_font_override("font", HEADING)
		title.add_theme_font_size_override("font_size", 24)
		root.get_node("PaginaHabilidades/DetalleHabilidad").add_theme_font_size_override("font_size", 7)
		var guide := root.get_node("PaginaHabilidades/GuiaFragmentos") as Label
		guide.text = "Recupera poderes con fragmentos y reliquias."
		guide.add_theme_font_size_override("font_size", 7)
		guide.offset_top = 176
		guide.offset_bottom = 194
		_watch(root, [root.get_node("BotonesPausa"), root.get_node("ControlesOpciones")])


static func _watch(root: Control, lists: Array) -> void:
	var selector := SELECTOR.new()
	selector.name = "SelectorEdwin"
	root.add_child(selector)
	for list in lists:
		selector.watch(list)


static func _style_main(root: Control) -> void:
	var title := root.get_node("Titulo") as Label
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	title.position = Vector2(28, 25)
	title.size = Vector2(260, 52)
	title.text = "Underkingdom"
	title.add_theme_font_override("font", HEADING)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_constant_override("outline_size", 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var ornament := NinePatchRect.new()
	ornament.name = "AdornoEdwin"
	ornament.texture = ORNAMENT
	ornament.patch_margin_left = 8
	ornament.patch_margin_right = 8
	ornament.position = Vector2(28, 81)
	ornament.size = Vector2(232, 5)
	ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(ornament)
	for name in ["BotonesPrincipales", "ControlesOpciones"]:
		var list := root.get_node(name) as Control
		list.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		list.position = Vector2(40, 99)
		list.size = Vector2(184, 154)
	# The profile and confirmation panels retain their foreground order.
	root.move_child(root.get_node("Perfiles"), root.get_child_count() - 1)
	root.move_child(root.get_node("ConfirmarEliminarPartida"), root.get_child_count() - 1)
	_watch(root, [root.get_node("BotonesPrincipales"), root.get_node("ControlesOpciones")])
	var shade := TextureRect.new()
	shade.name = "SombraLateralEdwin"
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0.012, 0.012, 0.035, 0.95), Color(0.012, 0.012, 0.035, 0.0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_to = Vector2.RIGHT
	shade.texture = texture
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)
	root.move_child(shade, 2)
	_add_wisps(root)
	root.modulate.a = 0.0
	root.create_tween().tween_property(root, "modulate:a", 1.0, 0.6)


static func _add_wisps(root: Control) -> void:
	var ramp := Gradient.new()
	ramp.colors = PackedColorArray([Color(0.62, 0.92, 1, 0), Color(0.62, 0.92, 1, 0.7), Color(0.62, 0.92, 1, 0)])
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	var wisps := CPUParticles2D.new()
	wisps.name = "AnimasEdwin"
	wisps.amount = 30
	wisps.lifetime = 10.0
	wisps.preprocess = 10.0
	wisps.position = Vector2(240, 285)
	wisps.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	wisps.emission_rect_extents = Vector2(250, 12)
	wisps.direction = Vector2.UP
	wisps.spread = 25
	wisps.gravity = Vector2(0, -1.5)
	wisps.initial_velocity_min = 6
	wisps.initial_velocity_max = 15
	wisps.scale_amount_min = 2
	wisps.scale_amount_max = 2
	wisps.color_ramp = ramp
	root.add_child(wisps)
	root.move_child(wisps, 3)

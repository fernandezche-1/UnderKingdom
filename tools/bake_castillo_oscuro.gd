extends SceneTree

## Conversión manual de una sola vez. No forma parte del juego.
const MAP = "res://escenas/mapas/prologo/castillo_oscuro.tscn"
const ORIGINAL = "res://escenas/mapas/prologo/castillo_oscuro.before_editable_20261022.tscn"
const OUTPUT = "res://escenas/mapas/prologo/castillo_editable"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var map = load(ORIGINAL).instantiate()
	# Keep readable unique names even though baking occurs outside the SceneTree.
	var generator = GDScript.new()
	var names = RegEx.new()
	names.compile("add_child\\((\\w+)\\)")
	generator.source_code = names.sub(map.get_script().source_code, "add_child($1, true)", true)
	assert(generator.reload() == OK)
	map.set_script(generator)
	for method in ["_build_backdrop", "_build_platforms", "_build_architecture", "_build_torches", "_build_trap", "_build_coins"]:
		map.call(method)
	var original_children = map.get_children()
	var layers = {}
	var castle = load("res://escenas/mapas/prologo/tileset_dark_castle.tres")
	for layer_name in ["Fondo", "Arquitectura", "Terreno", "Plataformas", "Decoracion", "PrimerPlano", "ElementosInteractivos"]:
		var layer = TileMapLayer.new()
		layer.name = layer_name + "Temporal"
		layer.tile_set = castle
		layer.collision_enabled = false
		map.add_child(layer)
		layer.owner = map
		layers[layer_name] = layer
	var platform_tiles = TileSet.new()
	platform_tiles.tile_size = Vector2i(8, 8)
	platform_tiles.add_physics_layer()
	platform_tiles.set_physics_layer_collision_layer(0, 1)
	platform_tiles.set_physics_layer_collision_mask(0, 0)
	var platform_rects = []
	for child in original_children:
		if child is StaticBody2D:
			var width = int(child.get_child(0).shape.size.x)
			platform_rects.append(Rect2i(int(child.position.x), int(child.position.y), width, 16))
	var widths = []
	for rect in platform_rects:
		if not widths.has(rect.size.x): widths.append(rect.size.x)
	for width in widths:
		var image = Image.create(width + 16, 16, false, Image.FORMAT_RGBA8)
		image.fill(Color.TRANSPARENT)
		image.fill_rect(Rect2i(0, 0, width, 16), Color("241936"))
		image.fill_rect(Rect2i(0, 0, width, 3), Color("a369b9"))
		image.fill_rect(Rect2i(2, 3, width - 4, 1), Color("624274"))
		for brick_x in range(4, width - 8, 24):
			image.fill_rect(Rect2i(brick_x, 8, 20, 1), Color("100d1c"))
			image.fill_rect(Rect2i(brick_x + 10, 13, 14, 1), Color("100d1c"))
		var image_path = OUTPUT + "/plataforma_%d.png" % width
		assert(image.save_png(image_path) == OK)
		# ImageTexture is embedded, so the saved scene does not depend on import timing.
		var source = TileSetAtlasSource.new()
		source.texture = ImageTexture.create_from_image(image)
		source.texture.resource_name = "Plataforma original %d px" % width
		source.texture_region_size = Vector2i(8, 8)
		platform_tiles.add_source(source, width)
		for x in range((width + 16) / 8):
			for y in range(2):
				source.create_tile(Vector2i(x, y))
				if x * 8 < width:
					var data = source.get_tile_data(Vector2i(x, y), 0)
					data.set_collision_polygons_count(0, 1)
					data.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-4,-4), Vector2(4,-4), Vector2(4,4), Vector2(-4,4)]))
	assert(ResourceSaver.save(platform_tiles, OUTPUT + "/plataformas_originales.tres") == OK)
	platform_tiles.take_over_path(OUTPUT + "/plataformas_originales.tres")
	for key in ["Terreno", "Plataformas"]:
		layers[key].tile_set = platform_tiles
		layers[key].collision_enabled = true
		layers[key].position.y = 6
	for rect in platform_rects:
		var layer = layers["Terreno" if rect.position.y >= 270 else "Plataformas"]
		for x in range((rect.size.x + 16) / 8):
			for y in range(2):
				layer.set_cell(Vector2i(rect.position.x / 8 + x, (rect.position.y - 6) / 8 + y), rect.size.x, Vector2i(x, y))
	var architecture_tiles = castle.duplicate(true)
	var atlas = architecture_tiles.get_source(0)
	for child in original_children:
		if child is StaticBody2D or (child is ColorRect and str(child.name).begins_with("Piedra")) or (child is ColorRect and str(child.name).begins_with("Borde")) or (child is ColorRect and str(child.name).begins_with("JuntaLadrillo")):
			map.remove_child(child)
			child.free()
			continue
		if child is Sprite2D:
			# Original atlas regions, split into the same 16 px tiles without rescaling.
			var piece = TileMapLayer.new()
			piece.name = child.name
			piece.tile_set = architecture_tiles
			piece.collision_enabled = false
			piece.position = child.position
			piece.z_index = child.z_index
			layers["Arquitectura"].add_child(piece)
			piece.owner = map
			for x in range(int(child.region_rect.size.x / 16)):
				for y in range(int(child.region_rect.size.y / 16)):
					var coord = Vector2i(child.region_rect.position / 16) + Vector2i(x,y)
					if not atlas.has_tile(coord): atlas.create_tile(coord)
					piece.set_cell(Vector2i(x,y), 0, coord)
			map.remove_child(child)
			child.free()
			continue
		var category = ""
		if child is ColorRect:
			category = "Fondo" if child.z_index <= -12 else "Arquitectura"
		elif child is AnimatedSprite2D or child is PointLight2D: category = "Decoracion"
		elif child is Polygon2D: category = "PrimerPlano"
		elif str(child.name).begins_with("Moneda_") or child.name == "TrampaPinchos": category = "ElementosInteractivos"
		if category != "":
			if child is AnimatedSprite2D: child.autoplay = "fuego"
			child.owner = null
			map.remove_child(child)
			layers[category].add_child(child)
			child.owner = map
	assert(ResourceSaver.save(architecture_tiles, OUTPUT + "/arquitectura_dark_castle.tres") == OK)
	architecture_tiles.take_over_path(OUTPUT + "/arquitectura_dark_castle.tres")
	for key in layers: layers[key].name = key
	map.set_script(null)
	var packed = PackedScene.new()
	assert(packed.pack(map) == OK)
	assert(ResourceSaver.save(packed, MAP) == OK)
	assert(ResourceSaver.set_uid(MAP, ResourceUID.text_to_id("uid://ghvgmf6rhw3q")) == OK)
	map.free()
	print("Castillo convertido: 16 plataformas, geometría original y siete capas permanentes.")
	quit()

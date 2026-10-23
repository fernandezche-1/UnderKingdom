extends SceneTree

func _initialize() -> void:
	call_deferred("validate")

func validate() -> void:
	var map = load("res://escenas/mapas/prologo/castillo_oscuro.tscn").instantiate()
	assert(map.get_script() == null)
	var original = load("res://escenas/mapas/prologo/castillo_oscuro.before_editable_20261022.tscn").instantiate()
	original.call("_build_platforms")
	var expected = {}
	for body in original.get_children():
		if body is StaticBody2D:
			var width = int(body.get_child(0).shape.size.x)
			for x in range(int(body.position.x), int(body.position.x) + width):
				for y in range(int(body.position.y), int(body.position.y) + 16):
					expected[Vector2i(x,y)] = true
	var actual = {}
	var expected_image = Image.create(1200, 400, false, Image.FORMAT_RGBA8)
	var actual_image = Image.create(1200, 400, false, Image.FORMAT_RGBA8)
	for z in [0, 1]:
		for child in original.get_children():
			if child is ColorRect and child.z_index == z:
				expected_image.fill_rect(Rect2i(Vector2i(child.position), Vector2i(child.size)), child.color)
	for key in ["Fondo", "Arquitectura", "Terreno", "Plataformas", "Decoracion", "PrimerPlano", "ElementosInteractivos"]:
		assert(map.get_node(key) is TileMapLayer)
	for key in ["Terreno", "Plataformas"]:
		var layer = map.get_node(key)
		for cell in layer.get_used_cells():
			var source = layer.tile_set.get_source(layer.get_cell_source_id(cell))
			var coord = layer.get_cell_atlas_coords(cell)
			assert(source.has_tile(coord))
			var data = source.get_tile_data(coord, 0)
			var image = source.texture.get_image()
			for x in range(8):
				for y in range(8):
					var color = image.get_pixel(coord.x * 8 + x, coord.y * 8 + y)
					var pixel = cell * 8 + Vector2i(layer.position) + Vector2i(x,y)
					if color.a > 0: actual_image.set_pixelv(pixel, color)
			if data.get_collision_polygons_count(0) == 0: continue
			for x in range(8):
				for y in range(8):
					var pixel = cell * 8 + Vector2i(layer.position) + Vector2i(x,y)
					assert(not actual.has(pixel), "Duplicated collision")
					actual[pixel] = true
	assert(actual.size() == expected.size())
	assert(actual_image.get_data() == expected_image.get_data(), "Platform appearance changed")
	for pixel in expected: assert(actual.has(pixel), "Collision changed at %s" % pixel)
	assert(map.get_node("ElementosInteractivos").get_child_count() == 11)
	assert(map.get_node("Decoracion").get_child_count() == 8)
	assert(map.get_node("PrimerPlano").get_child_count() == 5)
	for key in ["SpawnInicio", "DesdeCastillo", "ControladorSpawn", "MapBounds", "Camera2D", "SalidaCementerio"]:
		assert(map.get_node(key).position == original.get_node(key).position if map.get_node(key) is Node2D else true)
	# Exercise real physics without running gameplay controllers or writing save data.
	map.get_node("ControladorSpawn").set_script(null)
	map.get_node("SalidaCementerio").set_script(null)
	root.add_child(map)
	await physics_frame
	await physics_frame
	var space = map.get_world_2d().direct_space_state
	for body in original.get_children():
		if body is StaticBody2D:
			var start = body.position + Vector2(1, -1)
			var hit = space.intersect_ray(PhysicsRayQueryParameters2D.create(start, start + Vector2(0, 3), 1))
			assert(not hit.is_empty(), "Missing platform physics")
	assert(space.intersect_ray(PhysicsRayQueryParameters2D.create(Vector2(784,310), Vector2(784,345),1)).is_empty())
	print("PASS: persisted layers, valid atlas cells, no duplicate collision pixels, %d identical solid pixels, 16 physical platforms, pit, spawns and object counts." % actual.size())
	original.free()
	map.queue_free()
	quit()

@tool
extends SceneTree

const SCENE_PATH := "res://escenas/mapas/tiles_castillo_combate.tscn"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("No se pudo cargar: ", SCENE_PATH)
		return
	var root := packed.instantiate()
	root.name = "DiagnosticoCastillo"
	for path in ["Terreno2", "Terreno2/Terreno"]:
		var layer_for_probe := root.get_node_or_null(path) as TileMapLayer
		if layer_for_probe != null:
			layer_for_probe.physics_quadrant_size = 1
	get_root().add_child(root)
	await physics_frame
	var layers: Array[TileMapLayer] = []
	for path in ["Terreno2", "Terreno2/Terreno"]:
		var layer := root.get_node_or_null(path) as TileMapLayer
		if layer != null:
			layers.append(layer)
			print("LAYER ", path, " collision_enabled=", layer.collision_enabled,
				" local_transform=", layer.transform, " used_cells=", layer.get_used_cells().size())
			for physics_layer in range(layer.tile_set.get_physics_layers_count()):
				print("  TILESET_PHYSICS index=", physics_layer,
					" layer=", layer.tile_set.get_physics_layer_collision_layer(physics_layer),
					" mask=", layer.tile_set.get_physics_layer_collision_mask(physics_layer))
			_dump_layer(layer)
		else:
			print("NO ENCONTRADO: ", path)
	for path in ["PuertaArmeria", "PuntoEquipamientoFuturo", "colisionesarmeria"]:
		var node := root.get_node_or_null(path)
		if node != null:
			print("NODE ", path, " type=", node.get_class(), " global_position=", node.global_position)
			_dump_shapes(node, root)
	_dump_collision_grid(layers)
	_dump_route_blockers(root)
	print("FIN DIAGNOSTICO. Ventana espacial incluida por capa: x 1000..1750, y 400..900; coordenadas globales del mapa.")
	quit()

func _dump_layer(layer: TileMapLayer) -> void:
	var tile_set := layer.tile_set
	if tile_set == null:
		return
	for cell in layer.get_used_cells():
		var world_center := layer.to_global(layer.map_to_local(cell))
		if world_center.x < 1000.0 or world_center.x > 1750.0 or world_center.y < 400.0 or world_center.y > 900.0:
			continue
		var data := layer.get_cell_tile_data(cell)
		if data == null:
			continue
		var physics_info := []
		for physics_layer in range(tile_set.get_physics_layers_count()):
			var count := data.get_collision_polygons_count(physics_layer)
			if count == 0:
				continue
			var polys := []
			for polygon_index in range(count):
				var world_points := PackedVector2Array()
				for point in data.get_collision_polygon_points(physics_layer, polygon_index):
					world_points.append(layer.to_global(layer.map_to_local(cell) + point))
				polys.append(world_points)
			physics_info.append({"layer": physics_layer, "polygons": polys})
		if not physics_info.is_empty():
			print("CELL node=", layer.name, " cell=", cell,
				" source=", layer.get_cell_source_id(cell), " atlas=", layer.get_cell_atlas_coords(cell),
				" alt=", layer.get_cell_alternative_tile(cell), " center=", world_center,
				" physics=", physics_info)

func _dump_shapes(node: Node, root: Node) -> void:
	if node is CollisionShape2D:
		var shape_node := node as CollisionShape2D
		print("  SHAPE ", root.get_path_to(shape_node), " type=", shape_node.shape.get_class() if shape_node.shape else "null",
			" global_position=", shape_node.global_position, " disabled=", shape_node.disabled,
			" size=", shape_node.shape.size if shape_node.shape is RectangleShape2D else "n/a")
	for child in node.get_children():
		_dump_shapes(child, root)

func _dump_route_blockers(scene_root: Node) -> void:
	var player := scene_root.get_node_or_null("player") as CharacterBody2D
	if player == null:
		print("ROUTE_TEST skipped: no se encontró player")
		return
	var body_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_shape == null or body_shape.shape == null:
		print("ROUTE_TEST skipped: player no tiene CollisionShape2D")
		return
	var start: Vector2 = (scene_root.get_node("PuertaArmeria") as Node2D).global_position
	var finish: Vector2 = (scene_root.get_node("PuntoEquipamientoFuturo") as Node2D).global_position
	var space: PhysicsDirectSpaceState2D = (scene_root as Node2D).get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = body_shape.shape
	query.collision_mask = player.collision_mask
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var sample_count := int(ceil(start.distance_to(finish) / 8.0))
	query.exclude = [player.get_rid()]
	var previous_signature := ""
	for i in range(sample_count + 1):
		var player_origin: Vector2 = start.lerp(finish, float(i) / sample_count)
		query.transform = Transform2D(player.global_rotation, player_origin + body_shape.position)
		var hits: Array[Dictionary] = space.intersect_shape(query, 16)
		if hits.is_empty():
			continue
		var hit: Dictionary = hits[0]
		var collider := hit.get("collider") as Object
		var body_rid: RID = hit.get("rid", RID())
		var cell_text := "n/a"
		if collider is TileMapLayer:
			var tile_layer := collider as TileMapLayer
			cell_text = "%s api_cell=%s estimated_cell=%s" % [tile_layer.name,
				str(tile_layer.get_coords_for_body_rid(body_rid)),
				str(tile_layer.local_to_map(tile_layer.to_local(player_origin + body_shape.position)))]
		var signature := "%s|%s" % [collider.get_class() if collider else "null", cell_text]
		if signature != previous_signature:
			print("ROUTE_BLOCK sample=", i, "/", sample_count, " player_origin=", player_origin,
				" collider=", collider, " rid=", body_rid, " tile=", cell_text)
			previous_signature = signature
	print("ROUTE_TEST from door node origin to equipment node center, straight-line samples=", sample_count,
		" step<=8px; diagnostic only, not a navigation/pathfinding result.")

func _dump_collision_grid(layers: Array[TileMapLayer]) -> void:
	print("COLLISION_GRID columns=75..99 rows=25..50; . empty, 2=Terreno2, T=Terreno, X=both; y increases downward")
	var mask_by_cell: Dictionary = {}
	for layer in layers:
		for cell in layer.get_used_cells():
			var world_center := layer.to_global(layer.map_to_local(cell))
			if world_center.x < 1200.0 or world_center.x > 1600.0 or world_center.y < 400.0 or world_center.y > 816.0:
				continue
			var tile_data := layer.get_cell_tile_data(cell)
			if tile_data == null:
				continue
			var has_collision := false
			for physics_layer in range(layer.tile_set.get_physics_layers_count()):
				if tile_data.get_collision_polygons_count(physics_layer) > 0:
					has_collision = true
					break
			if has_collision:
				var key := "%d,%d" % [cell.x, cell.y]
				if not mask_by_cell.has(key):
					mask_by_cell[key] = 0
				mask_by_cell[key] |= 1 if layer.name == "Terreno2" else 2
	var header := "     "
	for x in range(75, 100):
		header += str(x % 10)
	print(header)
	for y in range(25, 51):
		var row := ""
		for x in range(75, 100):
			var mask: int = mask_by_cell.get("%d,%d" % [x, y], 0)
			row += "." if mask == 0 else "2" if mask == 1 else "T" if mask == 2 else "X"
		print("%02d %s" % [y, row])

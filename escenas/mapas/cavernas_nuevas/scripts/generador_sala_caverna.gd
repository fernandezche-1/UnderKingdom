@tool
extends Node2D

## Construye las capas de tiles de cada sala. Los TileMapLayer permanecen
## editables y usan el atlas 16x16 configurado en cavernas_tileset.tres.

const TILE_SIZE: int = 16
const TILESET: TileSet = preload("res://escenas/mapas/cavernas_nuevas/tilesets/cavernas_tileset.tres")

@export_range(1, 6, 1) var room_number: int = 1:
	set(value):
		room_number = value
		_built = false
		if is_inside_tree():
			_build_room()

var _built: bool = false


func _ready() -> void:
	_build_room()


func _build_room() -> void:
	if _built:
		return
	var config: Dictionary = _get_room_config(room_number)
	if config.is_empty():
		return
	var terrain: TileMapLayer = get_node_or_null("Terreno") as TileMapLayer
	var platforms: TileMapLayer = get_node_or_null("Plataformas") as TileMapLayer
	var details: TileMapLayer = get_node_or_null("Detalles") as TileMapLayer
	var ceiling: TileMapLayer = get_node_or_null("Techo") as TileMapLayer
	if terrain == null or platforms == null or details == null or ceiling == null:
		push_error("La sala %d no tiene sus TileMapLayer requeridos." % room_number)
		return
	terrain.tile_set = TILESET
	platforms.tile_set = TILESET
	details.tile_set = TILESET
	ceiling.tile_set = TILESET
	terrain.clear()
	platforms.clear()
	details.clear()
	ceiling.clear()
	terrain.z_index = 0
	platforms.z_index = 1
	details.z_index = 2
	ceiling.z_index = -1
	_build_terrain(terrain, config)
	_build_platforms(platforms, config)
	_build_details(details, config)
	_build_ceiling(ceiling, config)
	var bounds: Node2D = get_node_or_null("SistemasMapa/MapBounds") as Node2D
	if bounds != null:
		bounds.set("right", config["width"])
		bounds.set("bottom", config["height"])
	_built = true


func _build_terrain(layer: TileMapLayer, config: Dictionary) -> void:
	var width_cells: int = int(config["width"]) / TILE_SIZE
	var bottom_cell: int = int(config["height"]) / TILE_SIZE
	var profile: Array = config["profile"]
	for x_cell: int in range(width_cells):
		var world_x: int = x_cell * TILE_SIZE + TILE_SIZE / 2
		var surface_y: int = _surface_y(profile, world_x)
		var first_row: int = maxi(0, floori(float(surface_y) / TILE_SIZE))
		for y_cell: int in range(first_row, bottom_cell):
			var atlas_x: int = posmod(x_cell + y_cell * 3 + room_number, 4)
			var atlas_y: int = 0 if y_cell == first_row else 1 + posmod(x_cell * 5 + y_cell + room_number, 3)
			layer.set_cell(Vector2i(x_cell, y_cell), 0, Vector2i(atlas_x, atlas_y))


func _build_platforms(layer: TileMapLayer, config: Dictionary) -> void:
	var platforms: Array = config["platforms"]
	for platform_index: int in range(platforms.size()):
		var platform: Rect2i = platforms[platform_index]
		var left_cell: int = floori(float(platform.position.x) / TILE_SIZE)
		var top_cell: int = floori(float(platform.position.y) / TILE_SIZE)
		var cell_count: int = maxi(1, ceili(float(platform.size.x) / TILE_SIZE))
		for offset: int in range(cell_count):
			var atlas_x: int = posmod(offset + platform_index + room_number, 3)
			layer.set_cell(Vector2i(left_cell + offset, top_cell), 1, Vector2i(atlas_x, 3))


func _build_details(layer: TileMapLayer, config: Dictionary) -> void:
	var profile: Array = config["profile"]
	var markers: Array = config["markers"]
	for marker_x: int in markers:
		var cell_x: int = floori(float(marker_x) / TILE_SIZE)
		var surface_y: int = _surface_y(profile, marker_x)
		var cell_y: int = floori(float(surface_y) / TILE_SIZE) - 1
		var atlas: Vector2i = Vector2i(3, 4) if posmod(cell_x, 2) == 0 else Vector2i(22, 9)
		layer.set_cell(Vector2i(cell_x, cell_y), 2, atlas)


func _build_ceiling(layer: TileMapLayer, config: Dictionary) -> void:
	var width_cells: int = int(config["width"]) / TILE_SIZE
	var ceiling_base: int = 96 + posmod(room_number * 3, 4) * TILE_SIZE
	for x_cell: int in range(width_cells):
		var jagged_ceiling: int = ceiling_base + posmod(x_cell + room_number, 5) * TILE_SIZE
		var last_row: int = floori(float(jagged_ceiling) / TILE_SIZE)
		for y_cell: int in range(last_row + 1):
			var atlas_x: int = posmod(x_cell * 3 + y_cell + room_number, 4)
			var atlas_y: int = 1 + posmod(x_cell + room_number, 3)
			layer.set_cell(Vector2i(x_cell, y_cell), 0, Vector2i(atlas_x, atlas_y))


func _surface_y(profile: Array, x: int) -> int:
	for index: int in range(profile.size() - 1):
		var start: Vector2i = profile[index]
		var finish: Vector2i = profile[index + 1]
		if x <= finish.x:
			var width: int = maxi(1, finish.x - start.x)
			var factor: float = clampf(float(x - start.x) / float(width), 0.0, 1.0)
			return roundi(lerpf(float(start.y), float(finish.y), factor) / TILE_SIZE) * TILE_SIZE
	return profile[profile.size() - 1].y


func _get_room_config(id: int) -> Dictionary:
	match id:
		1:
			return {"width": 1280, "height": 640, "profile": [Vector2i(0, 416), Vector2i(160, 416), Vector2i(320, 400), Vector2i(480, 400), Vector2i(640, 368), Vector2i(800, 384), Vector2i(960, 400), Vector2i(1120, 384), Vector2i(1280, 384)], "platforms": [Rect2i(208, 336, 96, 16), Rect2i(352, 288, 96, 16), Rect2i(528, 320, 112, 16), Rect2i(720, 272, 96, 16), Rect2i(896, 320, 112, 16), Rect2i(1056, 288, 96, 16)], "markers": [144, 432, 688, 928, 1168]}
		2:
			return {"width": 1440, "height": 640, "profile": [Vector2i(0, 432), Vector2i(192, 448), Vector2i(384, 416), Vector2i(576, 432), Vector2i(768, 400), Vector2i(960, 432), Vector2i(1152, 416), Vector2i(1440, 432)], "platforms": [Rect2i(160, 352, 96, 16), Rect2i(288, 288, 96, 16), Rect2i(432, 336, 112, 16), Rect2i(624, 288, 112, 16), Rect2i(784, 320, 96, 16), Rect2i(928, 272, 112, 16), Rect2i(1088, 320, 96, 16), Rect2i(1248, 352, 96, 16)], "markers": [128, 336, 544, 752, 1008, 1200, 1376]}
		3:
			return {"width": 1280, "height": 896, "profile": [Vector2i(0, 848), Vector2i(160, 816), Vector2i(320, 752), Vector2i(480, 688), Vector2i(640, 624), Vector2i(800, 528), Vector2i(960, 432), Vector2i(1120, 320), Vector2i(1280, 208)], "platforms": [Rect2i(144, 736, 112, 16), Rect2i(304, 672, 112, 16), Rect2i(464, 608, 112, 16), Rect2i(624, 544, 112, 16), Rect2i(784, 448, 112, 16), Rect2i(944, 352, 112, 16), Rect2i(1088, 256, 112, 16)], "markers": [112, 432, 752, 1056, 1232]}
		4:
			return {"width": 1440, "height": 640, "profile": [Vector2i(0, 432), Vector2i(192, 432), Vector2i(384, 416), Vector2i(576, 432), Vector2i(768, 400), Vector2i(960, 416), Vector2i(1152, 432), Vector2i(1440, 416)], "platforms": [Rect2i(192, 352, 112, 16), Rect2i(352, 288, 112, 16), Rect2i(512, 336, 96, 16), Rect2i(688, 272, 112, 16), Rect2i(864, 320, 96, 16), Rect2i(1024, 256, 112, 16), Rect2i(1200, 320, 96, 16)], "markers": [128, 320, 560, 784, 1008, 1328]}
		5:
			return {"width": 1440, "height": 640, "profile": [Vector2i(0, 416), Vector2i(192, 400), Vector2i(384, 416), Vector2i(576, 384), Vector2i(768, 416), Vector2i(960, 400), Vector2i(1152, 416), Vector2i(1440, 384)], "platforms": [Rect2i(176, 336, 128, 16), Rect2i(352, 272, 112, 16), Rect2i(528, 320, 112, 16), Rect2i(720, 256, 128, 16), Rect2i(912, 304, 112, 16), Rect2i(1088, 240, 112, 16), Rect2i(1264, 320, 96, 16)], "markers": [112, 336, 592, 832, 1056, 1360]}
		6:
			return {"width": 1440, "height": 640, "profile": [Vector2i(0, 416), Vector2i(192, 432), Vector2i(384, 416), Vector2i(576, 448), Vector2i(768, 416), Vector2i(960, 432), Vector2i(1152, 400), Vector2i(1440, 416)], "platforms": [Rect2i(160, 336, 112, 16), Rect2i(320, 272, 96, 16), Rect2i(496, 320, 112, 16), Rect2i(704, 256, 112, 16), Rect2i(880, 304, 96, 16), Rect2i(1040, 240, 112, 16), Rect2i(1232, 320, 96, 16)], "markers": [112, 336, 608, 848, 1088, 1376]}
	return {}

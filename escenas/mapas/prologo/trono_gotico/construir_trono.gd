extends SceneTree

## Authoring tool only. The exported map has no generator attached.
const OUT := "res://escenas/mapas/prologo/trono_gotico/"
const LAYERS := ["FondoAtmosfera", "MuroFondo", "Arquitectura", "Terreno", "Plataformas", "Decoracion", "ElementosInteractivos", "Peligros"]
var room: Node2D
var tiles: TileSet
var layers: Dictionary = {}


func _initialize() -> void:
	call_deferred("build")


func attach(parent: Node, child: Node, label: String) -> Node:
	child.name = label
	parent.add_child(child)
	child.owner = room
	return child


func atlas(id: int, path: String) -> void:
	var source := TileSetAtlasSource.new()
	source.texture = load(path)
	source.texture_region_size = Vector2i(8, 8)
	tiles.add_source(source, id)


func cell(layer: TileMapLayer, at: Vector2i, source_id: int, uv: Vector2i) -> void:
	var source := tiles.get_source(source_id) as TileSetAtlasSource
	if not source.has_tile(uv):
		source.create_tile(uv)
		if source_id in [3, 4]:
			var data := source.get_tile_data(uv, 0)
			var physics_layer := 0 if source_id == 3 else 1
			data.set_collision_polygons_count(physics_layer, 1)
			data.set_collision_polygon_points(physics_layer, 0, PackedVector2Array([Vector2(-4,-4), Vector2(4,-4), Vector2(4,4), Vector2(-4,4)]))
			if source_id == 4:
				data.set_collision_polygon_one_way(physics_layer, 0, true)
				data.set_collision_polygon_one_way_margin(physics_layer, 0, 2.0)
	layer.set_cell(at, source_id, uv)


func stamp(layer: TileMapLayer, source_id: int, rect: Rect2i, position: Vector2i) -> void:
	for y in range(rect.size.y / 8):
		for x in range(rect.size.x / 8):
			cell(layer, position / 8 + Vector2i(x,y), source_id, rect.position / 8 + Vector2i(x,y))


func scaled_stamp(parent: Node, label: String, source_id: int, rect: Rect2i, at: Vector2, factor: int) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.tile_set = tiles
	layer.collision_enabled = false
	layer.position = at
	layer.scale = Vector2.ONE * factor
	attach(parent, layer, label)
	stamp(layer, source_id, rect, Vector2i.ZERO)
	return layer


func solid(rect: Rect2i) -> void:
	for y in range(rect.position.y / 8, rect.end.y / 8):
		for x in range(rect.position.x / 8, rect.end.x / 8):
			var uv := Vector2i(2 + posmod(x, 6), 2 if y == rect.position.y / 8 else 4 + posmod(y, 3))
			cell(layers.Terreno, Vector2i(x,y), 3, uv)


func platform(x: int, y: int, width: int) -> void:
	for xx in range(x / 8, (x + width) / 8):
		cell(layers.Plataformas, Vector2i(xx,y/8), 4, Vector2i(2 + posmod(xx,6),2))
		cell(layers.Arquitectura, Vector2i(xx,y/8+1), 0, Vector2i(2 + posmod(xx,6),3))
	for xx in range(x + 16, x + width - 8, 32):
		stamp(layers.Arquitectura, 2, Rect2i(112,128,16,16), Vector2i(xx,y+16))


func rect_area(parent: Node, label: String, script_path: String, center: Vector2, size: Vector2) -> Area2D:
	var area := Area2D.new()
	area.set_script(load(script_path))
	area.position = center
	area.collision_layer = 0
	area.collision_mask = 1
	attach(parent, area, label)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	attach(area, collision, "CollisionShape2D")
	return area


func light(parent: Node, label: String, at: Vector2, color: Color, radius: int) -> void:
	var point := PointLight2D.new()
	point.position = at
	point.color = color
	point.energy = 0.75
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(1,1,1,0.8), Color(1,1,1,0.0)])
	var texture := GradientTexture2D.new()
	texture.width = radius * 2
	texture.height = radius * 2
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5,0.5)
	texture.fill_to = Vector2(0.5,0)
	point.texture = texture
	attach(parent, point, label)


func torch(at: Vector2i, number: int) -> void:
	stamp(layers.Decoracion, 1, Rect2i(0,160,16,32), at)
	var fire := AnimatedSprite2D.new()
	fire.position = Vector2(at) + Vector2(8,5)
	var frames := SpriteFrames.new()
	frames.set_animation_speed(&"default", 6.0)
	for y in [64,80,96,112]:
		var texture := AtlasTexture.new()
		texture.atlas = load("res://assets_prueba/dungeon_platformer/dungeontilesetfull.png")
		texture.region = Rect2(432,y,16,16)
		frames.add_frame(&"default", texture)
	fire.sprite_frames = frames
	fire.autoplay = "default"
	attach(layers.Decoracion, fire, "Llama%d" % number)
	light(layers.Decoracion, "LuzAntorcha%d" % number, fire.position, Color(1.0,0.55,0.28), 80)


func build() -> void:
	room = Node2D.new()
	room.name = "CastilloTronoGotico"
	room.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tiles = TileSet.new()
	tiles.tile_size = Vector2i(8,8)
	tiles.add_physics_layer()
	tiles.set_physics_layer_collision_layer(0,1)
	tiles.set_physics_layer_collision_mask(0,0)
	tiles.add_physics_layer()
	tiles.set_physics_layer_collision_layer(1,2)
	tiles.set_physics_layer_collision_mask(1,0)
	for id in [0,3,4]:
		atlas(id, "res://dark_castle_tileset.png")
	atlas(1,"res://assets_prueba/dungeon_platformer/dungeontilesetfull.png")
	atlas(2,"res://prueba/dungeon_sidescroller-Raou/Tilesetv3.png")
	for i in LAYERS.size():
		var layer := TileMapLayer.new()
		layer.tile_set = tiles
		layer.z_index = [-30,-20,-10,0,1,2,3,4][i]
		layer.collision_enabled = LAYERS[i] in ["Terreno","Plataformas"]
		attach(room, layer, LAYERS[i])
		layers[LAYERS[i]] = layer
	# Backgrounds are painted cells, never a full-room picture.
	for y in range(56):
		for x in range(144):
			cell(layers.FondoAtmosfera,Vector2i(x,y),0,Vector2i(2+posmod(x,6),4+posmod(y,3)))
			if x in range(2,142) and y in range(4,48):
				cell(layers.MuroFondo,Vector2i(x,y),0,Vector2i(2+posmod(x,2),4+posmod(y,2)))
	layers.FondoAtmosfera.modulate = Color(0.42,0.52,0.85)
	layers.MuroFondo.modulate = Color(0.55,0.62,0.95)
	# Pilasters, ribbing, wall cornices and individually editable gothic windows.
	for x in [24,280,752,1096]:
		stamp(layers.Arquitectura,2,Rect2i(80,32,32,32),Vector2i(x,48))
		for y in range(80,368,8):
			stamp(layers.Arquitectura,2,Rect2i(88,64,16,8),Vector2i(x+8,y))
		stamp(layers.Arquitectura,2,Rect2i(80,80,32,16),Vector2i(x,368))
	for x in range(16,1136,8):
		cell(layers.Arquitectura,Vector2i(x/8,4),0,Vector2i(2+posmod(x/8,6),2))
		cell(layers.Arquitectura,Vector2i(x/8,43),0,Vector2i(10+posmod(x/8,6),6))
	scaled_stamp(layers.Arquitectura,"ArcoDelTrono",2,Rect2i(0,304,80,112),Vector2(64,96),2)
	for entry in [["VentanaCentral",Vector2(448,72)],["VentanaDerecha",Vector2(904,56)]]:
		scaled_stamp(layers.Arquitectura,entry[0],2,Rect2i(192,48,32,48),entry[1]-Vector2(0,40),3)
	for x in [336,656,832]:
		stamp(layers.Arquitectura,0,Rect2i(208,0,24,32),Vector2i(x,64))
	# Main floor, recessed spike pit, room boundary and throne dais.
	solid(Rect2i(0,384,512,64))
	solid(Rect2i(656,384,496,64))
	solid(Rect2i(512,416,144,32))
	solid(Rect2i(0,32,16,352))
	solid(Rect2i(1136,32,16,352))
	solid(Rect2i(0,16,1152,16))
	solid(Rect2i(80,368,160,16))
	solid(Rect2i(96,352,144,16))
	solid(Rect2i(112,336,128,16))
	platform(256,288,128)
	platform(432,208,272)
	platform(528,320,112)
	platform(752,240,48)
	platform(864,192,192)
	platform(1008,288,80)
	# A 40 px opening lets the existing 20 px player collider descend through
	# the ladder mouth instead of being blocked by a one-way balcony tile.
	for x in range(552,592,8):
		layers.Plataformas.erase_cell(Vector2i(x/8,26))
		layers.Arquitectura.erase_cell(Vector2i(x/8,27))
	# A throne built from individual stone and upholstery cells.
	var silhouette := ["   G   ","  GGG  "," GGGGG "," GRRRG "," GRRRG "," GRRRG ","GGRRRGG","GGGGGGG"," G   G "]
	for y in silhouette.size():
		for x in silhouette[y].length():
			if silhouette[y][x] == "G":
				cell(layers.Decoracion,Vector2i(17+x,33+y),2,Vector2i(18,18))
			elif silhouette[y][x] == "R":
				cell(layers.Decoracion,Vector2i(17+x,33+y),2,Vector2i(13,53))
	(tiles.get_source(2) as TileSetAtlasSource).get_tile_data(Vector2i(13,53),0).modulate=Color(0.85,0.5,1.4)
	# Wall torches, hanging lamps and chains.
	for i in 5:
		torch([Vector2i(256,320),Vector2i(400,248),Vector2i(712,312),Vector2i(824,176),Vector2i(1072,312)][i],i)
	for entry in [[Vector2i(328,32),80],[Vector2i(600,32),64],[Vector2i(824,32),72],[Vector2i(1048,32),64]]:
		var at: Vector2i = entry[0]
		for y in range(at.y,at.y+entry[1],8):
			cell(layers.Decoracion,Vector2i(at.x/8,y/8),0,Vector2i(30,2))
		stamp(layers.Decoracion,2,Rect2i(88,376,24,32),Vector2i(at.x-8,at.y+entry[1]))
		light(layers.Decoracion,"LuzLampara%d" % at.x,Vector2(at.x+4,at.y+entry[1]+16),Color(0.65,0.60,1.0),96)
	# Wooden ladder remains painted; its separate climb detector is editable.
	for y in range(200,320,8):
		stamp(layers.Decoracion,2,Rect2i(0,696+posmod(y/8,3)*8,16,8),Vector2i(568,y))
	var climb := rect_area(layers.ElementosInteractivos,"EscaleraCentral","res://scripts/environment/climb_zone.gd",Vector2(576,260),Vector2(32,152))
	climb.set("ignore_normal_terrain_while_climbing",true)
	# Balcony rails behind the walking surface, not a blocking wall.
	for x in range(440,704,16):
		if x>=552 and x<592:
			continue
		stamp(layers.Arquitectura,2,Rect2i(128,80,16,16),Vector2i(x,184))
	for x in range(872,1056,16):
		stamp(layers.Arquitectura,2,Rect2i(128,80,16,16),Vector2i(x,168))
	for at in [Vector2i(928,160),Vector2i(944,160),Vector2i(960,160)]:
		stamp(layers.ElementosInteractivos,1,Rect2i(256,128,16,32),at)
	for at in [Vector2i(248,368),Vector2i(360,368),Vector2i(688,368),Vector2i(904,368)]:
		stamp(layers.Decoracion,2,Rect2i(144,648,8,16),at)
	for at in [Vector2i(304,376),Vector2i(720,376),Vector2i(976,376)]:
		stamp(layers.Decoracion,2,Rect2i(0,0,32,8),at)
	# Existing interactive chest with loot, no placeholder logic.
	var chest := load("res://escenas/objetos/cofre.tscn").instantiate() as Node2D
	chest.position = Vector2(496,199)
	attach(layers.ElementosInteractivos,chest,"CofreBalcon")
	chest.set("coin_count",3)
	chest.set("potion_count",1)
	# Visible spikes and matching lethal detector.
	for x in range(512,656,16):
		stamp(layers.Peligros,0,Rect2i(240,48,16,16),Vector2i(x,400))
	rect_area(layers.Peligros,"PinchosLetales","res://scripts/environment/kill_zone.gd",Vector2(584,407),Vector2(144,14))
	scaled_stamp(layers.Arquitectura,"PuertaDerecha",0,Rect2i(272,16,32,48),Vector2(1064,288),2)
	var systems := Node2D.new()
	attach(room,systems,"SistemasMapa")
	for entry in [["SpawnEntrada",Vector2(48,321),&"SpawnInicio"],["SpawnSalida",Vector2(1032,321),&"DesdeSalida"]]:
		var spawn := Marker2D.new()
		spawn.set_script(load("res://scripts/transitions/spawn_point.gd"))
		spawn.position = entry[1]
		spawn.set("spawn_id",entry[2])
		attach(systems,spawn,entry[0])
	var bounds := Node2D.new()
	bounds.set_script(load("res://scripts/camera/map_bounds.gd"))
	bounds.set("left",0)
	bounds.set("top",0)
	bounds.set("right",1152)
	bounds.set("bottom",448)
	attach(systems,bounds,"MapBounds")
	var exit := rect_area(systems,"SalidaDerecha","res://scripts/transitions/map_transition.gd",Vector2(1100,348),Vector2(40,72))
	exit.set("require_interaction",true)
	exit.set("target_scene_path","res://escenas/mapas/prologo/castillo_oscuro.tscn")
	exit.set("target_spawn_id",&"SpawnInicio")
	exit.set("prompt_text","E - SALIR AL CASTILLO")
	var prompt := Label.new()
	prompt.position = Vector2(-80,-68)
	prompt.add_theme_font_size_override("font_size",8)
	attach(exit,prompt,"Prompt")
	var player := load("res://escenas/player.tscn").instantiate() as Node2D
	player.position = Vector2(48,321)
	player.set("show_debug_hud",false)
	attach(room,player,"player")
	var controller := Node.new()
	controller.set_script(load("res://scripts/transitions/map_spawn_controller.gd"))
	attach(systems,controller,"SpawnController")
	var ambient := CanvasModulate.new()
	ambient.color = Color(0.82,0.86,1.0)
	attach(room,ambient,"LuzAmbiente")
	light(layers.Arquitectura,"LuzVitralTrono",Vector2(144,208),Color(0.40,0.55,1.0),144)
	assert(ResourceSaver.save(tiles,OUT+"tileset_trono.tres") == OK)
	tiles.take_over_path(OUT+"tileset_trono.tres")
	var packed := PackedScene.new()
	assert(packed.pack(room) == OK)
	assert(ResourceSaver.save(packed,OUT+"castillo_trono_gotico.tscn") == OK)
	print("BUILT: eight persistent TileMapLayer layers, reusable atlas tiles, player, chest, ladder, spikes and exit")
	room.free()
	quit()

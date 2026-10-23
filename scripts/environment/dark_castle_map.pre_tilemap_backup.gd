extends Node2D

const COIN_SCENE: PackedScene = preload("res://escenas/objetos/coin_pickup.tscn")
const KILL_ZONE_SCENE: PackedScene = preload("res://escenas/sistemas/kill_zone.tscn")
const CASTLE_TEXTURE: Texture2D = preload("res://dark_castle_tileset.png")

const LEVEL_WIDTH := 1152.0
const LEVEL_HEIGHT := 400.0


func _ready() -> void:
	_build_backdrop()
	_build_platforms()
	_build_architecture()
	_build_torches()
	_build_trap()
	_build_coins()


func _build_backdrop() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "Fondo"
	backdrop.position = Vector2.ZERO
	backdrop.size = Vector2(LEVEL_WIDTH, LEVEL_HEIGHT)
	backdrop.color = Color("090713")
	backdrop.z_index = -20
	add_child(backdrop)
	backdrop.owner = self

	# Siluetas de mampostería en el fondo, espaciadas para conservar el contraste.
	for x in range(24, 1152, 48):
		_add_rect("JuntaFondo", Vector2(x, 88 + (x % 3) * 8), Vector2(24, 5), Color("211638"), -12)
		_add_rect("JuntaFondo", Vector2(x + 12, 96 + (x % 2) * 12), Vector2(16, 4), Color("171129"), -12)


func _build_platforms() -> void:
	# Recorrido inferior, con un foso corto que se puede saltar.
	_add_platform(0, 326, 336)
	_add_platform(344, 270, 192)
	_add_platform(536, 310, 208)
	_add_platform(824, 326, 328)
	# Galerías superiores; los desniveles quedan dentro del salto del jugador.
	_add_platform(64, 206, 176)
	_add_platform(272, 174, 160)
	_add_platform(448, 222, 192)
	_add_platform(672, 182, 208)
	_add_platform(904, 230, 144)
	# Peldaños hacen accesibles las galerías por ambos lados.
	_add_platform(224, 238, 40)
	_add_platform(264, 206, 40)
	_add_platform(400, 198, 40)
	_add_platform(416, 246, 32)
	_add_platform(640, 254, 40)
	_add_platform(656, 222, 16)
	_add_platform(880, 214, 24)


func _add_platform(x: float, top: float, width: float) -> void:
	var body := StaticBody2D.new()
	body.name = "Plataforma_%d_%d" % [int(x), int(top)]
	body.position = Vector2(x, top)
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	body.owner = self

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 16)
	collision.shape = shape
	collision.position = Vector2(width * 0.5, 8)
	body.add_child(collision)
	collision.owner = self

	_add_rect("Piedra", Vector2(x, top), Vector2(width, 16), Color("241936"), 0)
	_add_rect("BordePlataforma", Vector2(x, top), Vector2(width, 3), Color("a369b9"), 1)
	_add_rect("BordeLuz", Vector2(x + 2, top + 3), Vector2(maxf(width - 4, 1), 1), Color("624274"), 1)
	for brick_x in range(int(x + 4), int(x + width - 8), 24):
		_add_rect("JuntaLadrillo", Vector2(brick_x, top + 8), Vector2(20, 1), Color("100d1c"), 1)
		_add_rect("JuntaLadrillo", Vector2(brick_x + 10, top + 13), Vector2(14, 1), Color("100d1c"), 1)


func _build_architecture() -> void:
	# Ventanas y arcos del atlas original de dark castle.
	for window_position in [Vector2(112, 112), Vector2(344, 104), Vector2(744, 104), Vector2(984, 120)]:
		_add_atlas_sprite("VentanaGotica", Vector2(window_position), Rect2(80, 16, 48, 48), -3)
	for banner_position in [Vector2(208, 80), Vector2(592, 64), Vector2(912, 80)]:
		_add_atlas_sprite("Estandarte", Vector2(banner_position), Rect2(208, 16, 16, 48), 2)

	for column_x in [48, 256, 432, 640, 888, 1088]:
		_add_rect("Columna", Vector2(column_x, 112), Vector2(12, 126), Color("171326"), -2)
		_add_rect("Capitel", Vector2(column_x - 4, 112), Vector2(20, 7), Color("342348"), -1)
		_add_rect("BaseColumna", Vector2(column_x - 3, 232), Vector2(18, 8), Color("342348"), -1)

	_add_atlas_sprite("ArcoDeSalida", Vector2(1040, 246), Rect2(272, 16, 48, 64), 3)
	_add_rect("UmbralSalida", Vector2(1038, 310), Vector2(52, 4), Color("af76c3"), 4)


func _build_torches() -> void:
	for torch_position in [Vector2(176, 174), Vector2(480, 190), Vector2(704, 150), Vector2(960, 198)]:
		var torch := AnimatedSprite2D.new()
		torch.name = "AntorchaAnimada"
		torch.position = torch_position
		torch.z_index = 5
		torch.sprite_frames = _make_torch_frames()
		torch.play("fuego")
		add_child(torch)
		torch.owner = self

		var light := PointLight2D.new()
		light.name = "LuzMorada"
		light.position = torch_position + Vector2(10, 10)
		light.color = Color(0.56, 0.28, 0.86, 0.42)
		light.energy = 0.65
		light.texture_scale = 0.45
		light.shadow_enabled = false
		var glow := GradientTexture2D.new()
		glow.width = 64
		glow.height = 64
		glow.fill = GradientTexture2D.FILL_RADIAL
		var glow_gradient := Gradient.new()
		glow_gradient.colors = PackedColorArray([Color(0.7, 0.36, 1.0, 0.42), Color(0.7, 0.36, 1.0, 0.0)])
		glow.gradient = glow_gradient
		light.texture = glow
		add_child(light)
		light.owner = self


func _make_torch_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("fuego")
	frames.set_animation_loop("fuego", true)
	frames.set_animation_speed("fuego", 6.0)
	for frame_x in [18, 38, 58]:
		var atlas := AtlasTexture.new()
		atlas.atlas = CASTLE_TEXTURE
		atlas.region = Rect2(frame_x, 110, 20, 20)
		frames.add_frame("fuego", atlas)
	return frames


func _build_coins() -> void:
	for coin_position in [
		Vector2(128, 184), Vector2(176, 184), Vector2(320, 152), Vector2(376, 152),
		Vector2(496, 200), Vector2(576, 200), Vector2(720, 160), Vector2(792, 160),
		Vector2(944, 208), Vector2(1000, 208)
	]:
		var coin := COIN_SCENE.instantiate()
		coin.name = "Moneda_%d_%d" % [int(coin_position.x), int(coin_position.y)]
		coin.position = coin_position
		add_child(coin)
		coin.owner = self


func _build_trap() -> void:
	# Un foso de pinchos bajo el salto central: evita el cruce al caer.
	for spike_index in range(5):
		var spike := Polygon2D.new()
		spike.name = "Pincho_%d" % spike_index
		spike.position = Vector2(748 + spike_index * 15, 348)
		spike.color = Color("bd8bd0")
		spike.polygon = PackedVector2Array([Vector2(0, 16), Vector2(7, 0), Vector2(14, 16)])
		spike.z_index = 2
		add_child(spike)
		spike.owner = self

	var kill_zone := KILL_ZONE_SCENE.instantiate()
	kill_zone.name = "TrampaPinchos"
	kill_zone.position = Vector2(784, 366)
	add_child(kill_zone)
	kill_zone.owner = self


func _add_atlas_sprite(sprite_name: String, sprite_position: Vector2, region: Rect2, draw_order: int) -> void:
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = CASTLE_TEXTURE
	sprite.centered = false
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.position = sprite_position
	sprite.z_index = draw_order
	add_child(sprite)
	sprite.owner = self


func _add_rect(rect_name: String, rect_position: Vector2, rect_size: Vector2, color: Color, draw_order: int) -> void:
	var rect := ColorRect.new()
	rect.name = rect_name
	rect.position = rect_position
	rect.size = rect_size
	rect.color = color
	rect.z_index = draw_order
	add_child(rect)
	rect.owner = self

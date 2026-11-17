extends Node2D
class_name UnderkingdomSnowArea

## Nieve y escarcha de la ruina helada (P73, ficha de la ruina): partículas en un
## rectángulo de `width_tiles` x `height_tiles` piezas de 16 px (origen arriba a
## la izquierda, en una esquina de pieza). Sin arte de ningún pack: cada copo es
## un cuadrado de 1 o 2 px del juego, dibujado con `draw_rect` en posiciones
## enteras, así que se queda en la rejilla de 480x270 con el escalado entero (las
## CPUParticles2D podrían caer entre píxeles con el stretch `canvas_items`).
## Los copos no se dibujan en las celdas con bloque de la capa `Terreno` del mapa:
## al entrar en una, desaparecen (y renacen), así que la nieve puede ir delante del
## Player sin pintarse sobre la roca. Fuera de pantalla no se mueve ni se dibuja.
##
## Tipos (`kind`):
## - MOTES: escarcha suspendida. Motas que nacen en cualquier celda abierta,
##   flotan despacio, bajan un poco y se apagan; las de 2 px brillan más.
## - FLAKES: nieve que cae. Nace arriba del rectángulo (una grieta del techo) y
##   cae a `fall_speed`, meciéndose, hasta tocar roca o salir por abajo.
## - BLIZZARD: ventisca. Nace en el borde de donde sopla `wind` y cruza la sala
##   de lado, hasta tocar roca o salir.

enum Kind { MOTES, FLAKES, BLIZZARD }

const TILE: float = 16.0

@export var kind: Kind = Kind.MOTES
@export_range(1, 200, 1) var width_tiles: int = 10
@export_range(1, 100, 1) var height_tiles: int = 6
## Copos a la vez en el rectángulo.
@export_range(1, 400, 1) var amount: int = 40
## Viento en px/s: en MOTES es una deriva lenta; en BLIZZARD, la ventisca.
@export var wind: Vector2 = Vector2.ZERO
## Velocidad de caída de FLAKES, en px/s.
@export_range(1.0, 120.0, 1.0) var fall_speed: float = 24.0
## Vaivén de lado, en px/s.
@export_range(0.0, 40.0, 1.0) var sway: float = 6.0
## Vida de una mota (MOTES), en segundos.
@export var mote_life: Vector2 = Vector2(5.0, 9.0)
@export var color: Color = Color(0.92, 0.97, 1.0, 0.9)
## Parte de los copos que mide 2 px (el resto, 1 px). En BLIZZARD los pequeños
## son trazos de 2x1, que se leen como velocidad.
@export_range(0.0, 1.0, 0.05) var big_ratio: float = 0.3
## Sin sombreado: la luz ambiente (CanvasModulate) del mapa no la oscurece.
@export var unshaded: bool = true
## Capa del mapa con los bloques. Vacío: la busca como hermana de un antecesor
## ("Terreno", la del constructor).
@export var terrain_path: NodePath

var _pos: PackedVector2Array = []
var _vel: PackedVector2Array = []
var _age: PackedFloat32Array = []
var _life: PackedFloat32Array = []
var _phase: PackedFloat32Array = []
var _big: PackedByteArray = []
var _solid: PackedByteArray = []
var _open_cells: PackedInt32Array = []
var _size: Vector2 = Vector2.ZERO
var _active: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if unshaded:
		var mat := CanvasItemMaterial.new()
		mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		material = mat
	_size = Vector2(width_tiles, height_tiles) * TILE
	_build_solid_grid()
	_pos.resize(amount)
	_vel.resize(amount)
	_age.resize(amount)
	_life.resize(amount)
	_phase.resize(amount)
	_big.resize(amount)
	for i: int in amount:
		_big[i] = 1 if _rng.randf() < big_ratio else 0
		_spawn(i, true)
	var notifier := VisibleOnScreenNotifier2D.new()
	notifier.name = "EnPantalla"
	notifier.rect = Rect2(Vector2.ZERO, _size)
	notifier.screen_entered.connect(_set_active.bind(true))
	notifier.screen_exited.connect(_set_active.bind(false))
	add_child(notifier)
	_set_active(false)


## Fuera de pantalla no se mueve ni dibuja. El nodo sigue visible: oculto, su
## VisibleOnScreenNotifier2D tampoco se vería y no avisaría al volver.
func _set_active(active: bool) -> void:
	_active = active
	set_process(active)
	queue_redraw()


func is_active() -> bool:
	return _active


func _process(delta: float) -> void:
	for i: int in amount:
		_age[i] += delta
		var p: Vector2 = _pos[i] + _vel[i] * delta
		p.x += sin(_age[i] * 1.7 + _phase[i]) * sway * delta
		_pos[i] = p
		var dead: bool = p.x < 0.0 or p.y < 0.0 or p.x >= _size.x or p.y >= _size.y
		if not dead:
			dead = is_solid_at(p)
		if not dead and kind == Kind.MOTES:
			dead = _age[i] >= _life[i]
		if dead:
			_spawn(i, false)
	queue_redraw()


func _draw() -> void:
	if not _active:
		return
	for i: int in amount:
		var c: Color = color
		var alpha: float = color.a
		if kind == Kind.MOTES:
			alpha *= sin(PI * clampf(_age[i] / _life[i], 0.0, 1.0))
			if _big[i] == 1:
				alpha = minf(1.0, alpha * (1.2 + 0.4 * sin(_age[i] * 5.0 + _phase[i])))
		else:
			alpha *= clampf(_age[i] / 0.4, 0.0, 1.0)
		if alpha <= 0.02:
			continue
		c.a = alpha
		var s: Vector2 = Vector2(2.0, 2.0) if _big[i] == 1 else Vector2(1.0, 1.0)
		if kind == Kind.BLIZZARD and _big[i] == 0:
			s = Vector2(2.0, 1.0)
		draw_rect(Rect2(_pos[i].floor(), s), c)


## ¿Hay bloque en ese punto (en coordenadas del nodo)?
func is_solid_at(p: Vector2) -> bool:
	var cx: int = int(p.x / TILE)
	var cy: int = int(p.y / TILE)
	if cx < 0 or cy < 0 or cx >= width_tiles or cy >= height_tiles:
		return true
	return _solid[cy * width_tiles + cx] == 1


## Copos que se ven ahora (para las pruebas).
func live_positions() -> PackedVector2Array:
	return _pos


func _spawn(i: int, prewarm: bool) -> void:
	_phase[i] = _rng.randf() * TAU
	_age[i] = 0.0
	_life[i] = 1.0e9
	match kind:
		Kind.MOTES:
			_life[i] = _rng.randf_range(mote_life.x, mote_life.y)
			_age[i] = _rng.randf() * _life[i] if prewarm else 0.0
			_pos[i] = _random_open_point()
			_vel[i] = wind + Vector2(_rng.randf_range(-4.0, 4.0), _rng.randf_range(1.0, 5.0))
		Kind.FLAKES:
			var y: float = _rng.randf() * _size.y if prewarm else 0.0
			_pos[i] = Vector2(_rng.randf() * _size.x, y)
			_vel[i] = Vector2(wind.x, fall_speed * _rng.randf_range(0.8, 1.2))
			_age[i] = 1.0 if prewarm else 0.0
		Kind.BLIZZARD:
			var x: float
			if prewarm:
				x = _rng.randf() * _size.x
			else:
				x = 0.0 if wind.x >= 0.0 else _size.x - 0.01
			_pos[i] = Vector2(x, _rng.randf() * _size.y)
			_vel[i] = wind * _rng.randf_range(0.75, 1.25) + Vector2(0.0, _rng.randf_range(4.0, 16.0))
			_age[i] = 1.0 if prewarm else 0.0
	# Al nacer dentro de la roca (la grieta de FLAKES o el borde de BLIZZARD dan
	# con un bloque), se prueba en otro sitio abierto del rectángulo.
	if is_solid_at(_pos[i]) and kind != Kind.MOTES:
		_pos[i] = _random_open_point()


func _random_open_point() -> Vector2:
	if _open_cells.is_empty():
		return Vector2(-1.0, -1.0)
	var cell: int = _open_cells[_rng.randi_range(0, _open_cells.size() - 1)]
	var cx: int = cell % width_tiles
	var cy: int = cell / width_tiles
	return Vector2((cx + _rng.randf()) * TILE, (cy + _rng.randf()) * TILE)


func _build_solid_grid() -> void:
	_solid.resize(width_tiles * height_tiles)
	_solid.fill(0)
	_open_cells.clear()
	var terrain: TileMapLayer = _find_terrain()
	for cy: int in height_tiles:
		for cx: int in width_tiles:
			var solid: bool = false
			if terrain != null:
				var world: Vector2 = to_global(Vector2((cx + 0.5) * TILE, (cy + 0.5) * TILE))
				var map_cell: Vector2i = terrain.local_to_map(terrain.to_local(world))
				solid = terrain.get_cell_source_id(map_cell) != -1
			_solid[cy * width_tiles + cx] = 1 if solid else 0
			if not solid:
				_open_cells.append(cy * width_tiles + cx)


func _find_terrain() -> TileMapLayer:
	if not terrain_path.is_empty():
		return get_node_or_null(terrain_path) as TileMapLayer
	var node: Node = get_parent()
	while node != null:
		var found: TileMapLayer = node.get_node_or_null("Terreno") as TileMapLayer
		if found != null:
			return found
		node = node.get_parent()
	return null

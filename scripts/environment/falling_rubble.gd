extends Node2D
class_name UnderkingdomFallingRubble

## Escombro del derrumbe (collapse_sequence.gd, P64). Aparece arriba, cae en
## vertical hasta `landing_y` y, si toca al Player por el camino, le quita
## `damage_amount`. Lo crea la secuencia de derrumbe: no tiene escena propia.
## Solo daña al Player (máscara 1); a los enemigos no les afecta.

const TILE: float = 16.0
const SIZE: int = 12

@export_range(0.25, 4.0, 0.25) var damage_amount: float = 0.5
@export_range(40.0, 600.0, 10.0) var fall_speed: float = 240.0
@export var player_group: StringName = &"player"

## Altura global del suelo donde se estrella.
var landing_y: float = 0.0

var _area: Area2D = null
var _hit: bool = false
var _landed: bool = false

static var _texture: Texture2D = null


func _ready() -> void:
	z_index = 20
	var sprite := Sprite2D.new()
	sprite.texture = _rubble_texture()
	sprite.position = Vector2(0.0, -SIZE * 0.5)
	add_child(sprite)

	_area = Area2D.new()
	_area.collision_layer = 0
	_area.collision_mask = 1
	_area.monitorable = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(SIZE, SIZE)
	shape.shape = rect
	shape.position = Vector2(0.0, -SIZE * 0.5)
	_area.add_child(shape)
	add_child(_area)


func _physics_process(delta: float) -> void:
	if _landed:
		return
	global_position.y = minf(global_position.y + fall_speed * delta, landing_y)
	if not _hit:
		for body: Node2D in _area.get_overlapping_bodies():
			if body.is_in_group(player_group) and body.has_method("take_damage"):
				_hit = true
				body.call("take_damage", damage_amount, global_position, true)
				break
	if global_position.y >= landing_y:
		_land()


func _land() -> void:
	_landed = true
	_area.set_deferred("monitoring", false)
	UnderkingdomCollapse.dust_burst(get_parent(), global_position, 6, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_delay(0.3)
	tween.tween_callback(queue_free)


## Dibujo provisional de 12 x 12 (arte pendiente), hecho una sola vez.
static func _rubble_texture() -> Texture2D:
	if _texture == null:
		var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
		var base := Color(0.36, 0.32, 0.38)
		var light := Color(0.52, 0.47, 0.55)
		var dark := Color(0.2, 0.17, 0.24)
		for x in SIZE:
			for y in SIZE:
				# Esquinas recortadas para que parezca una piedra.
				var corner := (x == 0 or x == SIZE - 1) and (y == 0 or y == SIZE - 1)
				if corner:
					continue
				var color := base
				if y <= 2 and x <= 7:
					color = light
				elif y >= SIZE - 3 or x >= SIZE - 3:
					color = dark
				image.set_pixel(x, y, color)
		_texture = ImageTexture.create_from_image(image)
	return _texture

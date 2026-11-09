extends Node2D
class_name UnderkingdomDarkZone

## Zona oscura (P65): un rectángulo de `width_tiles` x `height_tiles` piezas de 16 px
## (origen arriba a la izquierda) que se oscurece casi del todo. Con la llave
## `key_id` ("antorcha", la llama eterna) el Player lleva una luz de
## `light_radius_tiles` piezas; sin ella, solo un halo mínimo (`dark_radius`), para
## que la zona siga siendo jugable. La oscuridad es una capa dentro del mundo
## (`z_index` alto, bajo el HUD) con un shader que deja un círculo claro en el
## Player, con el borde en escalones para no romper el pixel art. No usa
## `CanvasModulate` ni luces 2D, así que puede haber varias zonas por escena.
## Detalle en docs/P65_LLAMA_ETERNA.md.

const TILE: float = 16.0
const SHADER_CODE: String = """
shader_type canvas_item;
uniform vec4 dark_color : source_color = vec4(0.0, 0.0, 0.03, 0.94);
uniform vec2 light_pos = vec2(-100000.0, -100000.0);
uniform float radius = 80.0;
uniform float edge = 24.0;
uniform float steps = 4.0;
varying vec2 world_pos;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}
void fragment() {
	float d = distance(world_pos, light_pos);
	float band = max(min(edge, radius), 1.0);
	float t = clamp((d - (radius - band)) / band, 0.0, 1.0);
	t = ceil(t * steps) / steps;
	COLOR = vec4(dark_color.rgb, dark_color.a * t);
}
"""

@export_range(1, 128, 1) var width_tiles: int = 10
@export_range(1, 64, 1) var height_tiles: int = 6
## Llave que da la luz (la llama eterna).
@export var key_id: String = "antorcha"
@export_range(1.0, 12.0, 0.5) var light_radius_tiles: float = 5.0
## Radio del halo sin la llave, en píxeles.
@export_range(0.0, 64.0, 1.0) var dark_radius: float = 20.0
@export var dark_color: Color = Color(0.0, 0.0, 0.03, 0.94)
## Ancho del borde difuso, en píxeles; `light_steps` escalones.
@export_range(1.0, 48.0, 1.0) var edge_width: float = 24.0
@export_range(1, 8, 1) var light_steps: int = 4
## Parpadeo de la llama, en píxeles de radio (0 = fija).
@export_range(0.0, 4.0, 1.0) var flicker_px: float = 2.0
@export var player_group: StringName = &"player"

var _material: ShaderMaterial = null
var _time: float = 0.0


func _ready() -> void:
	z_index = 50
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_material = ShaderMaterial.new()
	_material.shader = shader
	_material.set_shader_parameter("dark_color", dark_color)
	_material.set_shader_parameter("edge", edge_width)
	_material.set_shader_parameter("steps", float(light_steps))
	var rect := ColorRect.new()
	rect.name = "Oscuridad"
	rect.size = Vector2(width_tiles, height_tiles) * TILE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.material = _material
	add_child(rect)
	_update_light()


func _process(delta: float) -> void:
	_time += delta
	_update_light()


## Radio claro actual en píxeles, con la llama o sin ella (sin parpadeo).
func current_radius() -> float:
	if key_id.is_empty() or GameManager.has_key(key_id):
		return light_radius_tiles * TILE
	return dark_radius


func _update_light() -> void:
	var radius: float = current_radius()
	if flicker_px > 0.0 and radius > dark_radius:
		radius += roundf(sin(_time * 9.0) * flicker_px)
	_material.set_shader_parameter("radius", radius)
	var player := get_tree().get_first_node_in_group(player_group) as Node2D
	if player == null:
		return
	var point: Vector2 = player.global_position
	var body := player.get_node_or_null("CollisionShape2D") as Node2D
	if body != null:
		point = body.global_position
	_material.set_shader_parameter("light_pos", point)

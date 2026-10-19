extends Node2D
class_name UnderkingdomMapAmbience

## Ambientación de un mapa con tiles: oscurece el mundo con un CanvasModulate,
## le pone una luz al Player, enciende luces en las piezas que brillan
## (antorchas, fogatas, hongos, cristales, lava) y en la llave del jefe, y
## dibuja una viñeta.
## Va en la escena _combate del mapa (no en la base generada), como hijo de la
## raíz. Las luces se buscan al cargar en las capas Decorado y Liquidos, así
## que sobreviven a regenerar el mapa con el constructor.
## El HUD, la barra de jefe y los menús viven en CanvasLayer propios y no se
## oscurecen.

const LIGHT_STEPS := 8
const HALO_STEPS := 4
## Los halos van detrás del terreno (z 0) y de los personajes, delante del fondo.
const HALO_Z_INDEX := -1
const VIGNETTE_LAYER := 5

## Color de la oscuridad: multiplica todo el mundo. Blanco = sin efecto.
@export var ambient_color: Color = Color(0.42, 0.42, 0.58)

@export_group("Luz del Player")
@export var player_light_enabled: bool = true
@export_range(16, 256, 8) var player_light_radius: int = 96
@export var player_light_color: Color = Color(0.85, 0.85, 1.0)
@export_range(0.0, 2.0, 0.05) var player_light_energy: float = 0.7

@export_group("Luces del mapa")
@export var tile_lights_enabled: bool = true
## Si es falso, las luces no tocan los fondos con parallax (solo los tiñe el
## color de ambiente): una antorcha no ilumina las montañas lejanas.
@export var lights_on_backgrounds: bool = false
@export_range(0.0, 1.0, 0.05) var flicker_amount: float = 0.15
## La llave que suelta el jefe brilla para que se vea en la oscuridad.
@export var key_light: bool = true
## Resplandor visible en el aire alrededor de cada luz del mapa (las luces
## solo iluminan lo que tienen detrás; en zonas de cielo no se verían).
@export_range(0.0, 1.0, 0.05) var halo_strength: float = 0.4
@export_range(0.1, 1.0, 0.05) var halo_size: float = 0.6

@export_group("Viñeta")
@export_range(0.0, 1.0, 0.05) var vignette_strength: float = 0.55
## Distancia al centro (0 = centro, 1 = esquina) donde empieza a oscurecer.
@export_range(0.0, 1.0, 0.05) var vignette_start: float = 0.45
@export var vignette_color: Color = Color(0.02, 0.01, 0.04)

## Piezas que dan luz: coordenadas en el atlas del tileset -> [color, radio, energía, parpadea].
const DECOR_LIGHTS := {
    Vector2i(0, 10): [Color(1.0, 0.62, 0.3), 56, 0.9, true],     # antorcha
    Vector2i(27, 4): [Color(1.0, 0.55, 0.25), 72, 1.0, true],    # fogata / checkpoint
    Vector2i(0, 15): [Color(0.35, 0.9, 1.0), 32, 0.6, false],    # hongos luminosos
    Vector2i(22, 9): [Color(0.75, 0.45, 1.0), 32, 0.6, false],   # cristales
}
const LAVA_SURFACE := Vector2i(12, 8)
const LAVA_LIGHT := [Color(1.0, 0.35, 0.1), 48, 0.9, true]
const LAVA_LIGHT_SPACING := 3
const KEY_LIGHT := [Color(1.0, 0.85, 0.4), 40, 0.8, true]

static var _texture_cache: Dictionary = {}
static var _halo_cache: Dictionary = {}

var _map_root: Node = null
var _lights_root: Node2D = null
## Luces que parpadean: [PointLight2D, energía base, fase, halo o null].
var _flickering: Array = []
var _time: float = 0.0


func _ready() -> void:
    _map_root = owner if owner != null else get_parent()
    _lights_root = Node2D.new()
    _lights_root.name = "Luces"
    add_child(_lights_root)

    _add_canvas_modulate()
    if not lights_on_backgrounds:
        _hide_backgrounds_from_lights()
    if tile_lights_enabled:
        _add_decor_lights()
        _add_lava_lights()
    if player_light_enabled:
        _add_player_light.call_deferred()
    if key_light:
        get_tree().node_added.connect(_on_node_added)
    if vignette_strength > 0.0:
        _add_vignette()
    set_process(not _flickering.is_empty() and flicker_amount > 0.0)


func _process(delta: float) -> void:
    _time += delta
    for entry: Array in _flickering:
        var light := entry[0] as PointLight2D
        if not is_instance_valid(light):
            continue
        var phase: float = entry[2]
        var wave: float = sin(_time * 7.0 + phase) * 0.6 + sin(_time * 13.0 + phase * 1.7) * 0.4
        var factor: float = 1.0 + wave * flicker_amount
        light.energy = float(entry[1]) * factor
        var halo := entry[3] as Sprite2D
        if halo != null:
            halo.self_modulate.a = halo_strength * factor


func _add_canvas_modulate() -> void:
    var modulate_node := CanvasModulate.new()
    modulate_node.name = "Oscuridad"
    modulate_node.color = ambient_color
    add_child(modulate_node)


func _hide_backgrounds_from_lights() -> void:
    for child: Node in _map_root.get_children():
        if child is Parallax2D:
            for item: Node in child.get_children():
                if item is CanvasItem:
                    (item as CanvasItem).light_mask = 0


func _add_decor_lights() -> void:
    var layer := _map_root.get_node_or_null("Decorado") as TileMapLayer
    if layer == null:
        return
    for cell: Vector2i in layer.get_used_cells():
        var coords := layer.get_cell_atlas_coords(cell)
        if DECOR_LIGHTS.has(coords):
            _spawn_light(_cell_position(layer, cell), DECOR_LIGHTS[coords])


func _add_lava_lights() -> void:
    var layer := _map_root.get_node_or_null("Liquidos") as TileMapLayer
    if layer == null:
        return
    # Una luz cada pocas piezas de superficie, empezando por el borde de cada tramo.
    for cell: Vector2i in layer.get_used_cells():
        if layer.get_cell_atlas_coords(cell) != LAVA_SURFACE:
            continue
        var run_start := cell
        while layer.get_cell_atlas_coords(run_start + Vector2i.LEFT) == LAVA_SURFACE:
            run_start += Vector2i.LEFT
        if (cell.x - run_start.x) % LAVA_LIGHT_SPACING == 1 or _is_short_run(layer, run_start):
            _spawn_light(_cell_position(layer, cell), LAVA_LIGHT)


func _is_short_run(layer: TileMapLayer, run_start: Vector2i) -> bool:
    # Tramos de una sola pieza: la regla de arriba nunca les pondría luz.
    return layer.get_cell_atlas_coords(run_start + Vector2i.RIGHT) != LAVA_SURFACE


func _cell_position(layer: TileMapLayer, cell: Vector2i) -> Vector2:
    return _lights_root.to_local(layer.to_global(layer.map_to_local(cell)))


func _add_player_light() -> void:
    var player := get_tree().get_first_node_in_group("player") as Node2D
    if player == null:
        return
    var light := _make_light(player_light_color, player_light_radius, player_light_energy)
    light.name = "LuzAmbiente"
    var body := player.get_node_or_null("CollisionShape2D") as Node2D
    if body != null:
        light.position = body.position
    player.add_child(light)


func _on_node_added(node: Node) -> void:
    if node is Node2D and node.is_in_group("boss_key"):
        var light := _make_light(KEY_LIGHT[0], KEY_LIGHT[1], KEY_LIGHT[2])
        node.add_child.call_deferred(light)
        var halo := _make_halo(KEY_LIGHT[0], KEY_LIGHT[1])
        if halo != null:
            node.add_child.call_deferred(halo)
        if KEY_LIGHT[3]:
            _track_flicker(light, halo)


func _spawn_light(at: Vector2, preset: Array) -> void:
    var light := _make_light(preset[0], preset[1], preset[2])
    light.position = at
    _lights_root.add_child(light)
    var halo := _make_halo(preset[0], preset[1])
    if halo != null:
        halo.position = at
        _lights_root.add_child(halo)
    if preset[3]:
        _track_flicker(light, halo)


func _track_flicker(light: PointLight2D, halo: Sprite2D = null) -> void:
    _flickering.append([light, light.energy, randf() * TAU, halo])
    set_process(flicker_amount > 0.0)


## Sprite aditivo con anillos, sin sombreado: se ve aunque no haya nada detrás.
func _make_halo(color: Color, light_radius: int) -> Sprite2D:
    if halo_strength <= 0.0:
        return null
    var halo := Sprite2D.new()
    halo.texture = _halo_texture(maxi(4, int(light_radius * halo_size)))
    halo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    halo.z_index = HALO_Z_INDEX
    halo.modulate = Color(color.r, color.g, color.b, 1.0)
    halo.self_modulate.a = halo_strength
    var material_ := CanvasItemMaterial.new()
    material_.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
    material_.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
    halo.material = material_
    return halo


func _make_light(color: Color, radius: int, energy: float) -> PointLight2D:
    var light := PointLight2D.new()
    light.texture = _light_texture(radius)
    light.color = color
    light.energy = energy
    light.blend_mode = Light2D.BLEND_MODE_ADD
    return light


## Círculo con caída suave en escalones finos, un texel por píxel del juego:
## ilumina superficies sin dejar anillos marcados dentro del suelo.
static func _light_texture(radius: int) -> Texture2D:
    if _texture_cache.has(radius):
        return _texture_cache[radius]
    var size := radius * 2
    var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
    var center := Vector2(radius, radius)
    for y: int in size:
        for x: int in size:
            var distance := (Vector2(x, y) + Vector2(0.5, 0.5)).distance_to(center) / float(radius)
            var value := 0.0
            if distance < 1.0:
                value = pow(ceil((1.0 - distance) * LIGHT_STEPS) / LIGHT_STEPS, 1.5)
            image.set_pixel(x, y, Color(value, value, value, 1.0))
    var texture := ImageTexture.create_from_image(image)
    _texture_cache[radius] = texture
    return texture


## Anillos de pixel art bien marcados: el resplandor que se ve en el aire.
static func _halo_texture(radius: int) -> Texture2D:
    if _halo_cache.has(radius):
        return _halo_cache[radius]
    var size := radius * 2
    var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
    var center := Vector2(radius, radius)
    for y: int in size:
        for x: int in size:
            var distance := (Vector2(x, y) + Vector2(0.5, 0.5)).distance_to(center) / float(radius)
            var alpha := 0.0
            if distance < 1.0:
                alpha = pow(ceil((1.0 - distance) * HALO_STEPS) / HALO_STEPS, 2.0)
            image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
    var texture := ImageTexture.create_from_image(image)
    _halo_cache[radius] = texture
    return texture


func _add_vignette() -> void:
    var layer := CanvasLayer.new()
    layer.name = "Vineta"
    layer.layer = VIGNETTE_LAYER
    var rect := ColorRect.new()
    rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var shader := Shader.new()
    shader.code = VIGNETTE_SHADER
    var material_ := ShaderMaterial.new()
    material_.shader = shader
    material_.set_shader_parameter("tint", vignette_color)
    material_.set_shader_parameter("strength", vignette_strength)
    material_.set_shader_parameter("start", vignette_start)
    material_.set_shader_parameter("resolution", Vector2(
        ProjectSettings.get_setting("display/window/size/viewport_width"),
        ProjectSettings.get_setting("display/window/size/viewport_height")))
    rect.material = material_
    layer.add_child(rect)
    add_child(layer)


## Oscurece hacia los bordes. Calcula por píxel del juego (480x270) y en
## escalones, para que no se vea más fino que el pixel art.
const VIGNETTE_SHADER := """
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float strength = 0.5;
uniform float start = 0.45;
uniform vec2 resolution = vec2(480.0, 270.0);

void fragment() {
    vec2 uv = (floor(UV * resolution) + 0.5) / resolution;
    float aspect = resolution.x / resolution.y;
    vec2 offset = (uv - 0.5) * vec2(aspect, 1.0);
    float distance_ = length(offset) / length(vec2(aspect, 1.0) * 0.5);
    float amount = smoothstep(start, 1.0, distance_);
    amount = floor(amount * 6.0) / 6.0;
    COLOR = vec4(tint.rgb, amount * strength);
}
"""

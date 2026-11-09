extends Area2D
class_name UnderkingdomInfernalFire

## Fuego infernal (pide E5; P61): gruta de cristal de las minas, altar este de
## las profundidades y paso de las cadenas del infierno. Es una franja de
## `width_tiles` x `height_tiles` piezas de 16 px, con el origen arriba a la
## izquierda.
## - Sin E5 (resistencia `infernal_fire` del atuendo, P59): quita
##   `damage_amount` y empuja al Player hacia el lado por el que llegó. Con la
##   invulnerabilidad de siempre; insistir mata (M3).
## - Con E5: no hace daño ni empuja (M4).
## No es una `burn_zone`: las quemaduras normales no cambian y el Fire Knight
## solo resiste este fuego (la lava sigue matando). A los enemigos no les afecta.

const TILE: float = 16.0
const FLAME_TEXTURE: Texture2D = preload("res://sprites/trampas/fuego_rojo.png")
const FLAME_FRAMES: Array[int] = [256, 320, 384, 320]

@export_range(1, 64, 1) var width_tiles: int = 3
@export_range(1, 8, 1) var height_tiles: int = 1
@export_range(0.25, 4.0, 0.25) var damage_amount: float = 0.5
## Resistencia del atuendo que lo apaga (`OUTFIT_DEFINITIONS`, clave `resist`).
@export var resist_kind: String = "infernal_fire"
## Tinte provisional para distinguirlo del fuego normal (arte pendiente).
@export var flame_tint: Color = Color(0.75, 0.85, 1.6)

var _player: Node2D = null
## Lado por el que el Player llegó: -1 a la izquierda, 1 a la derecha.
var _entry_side: float = -1.0


func _ready() -> void:
    collision_layer = 0
    collision_mask = 1
    monitoring = true
    _build()


func _build() -> void:
    var size := Vector2(width_tiles, height_tiles) * TILE
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    shape.shape = rect
    shape.position = size * 0.5
    add_child(shape)

    var frames := SpriteFrames.new()
    frames.set_animation_speed(&"default", 8.0)
    for x: int in FLAME_FRAMES:
        var atlas := AtlasTexture.new()
        atlas.atlas = FLAME_TEXTURE
        atlas.region = Rect2(x, 0, 64, 64)
        frames.add_frame(&"default", atlas)
    # Una llama por pieza, a escala 1 (como trampa_fuego.tscn).
    for ix: int in width_tiles:
        for iy: int in height_tiles:
            var flame := AnimatedSprite2D.new()
            flame.sprite_frames = frames
            flame.modulate = flame_tint
            flame.position = Vector2((ix + 0.5) * TILE, (iy + 1.0) * TILE - 15.0)
            add_child(flame)
            flame.play(&"default")
            flame.frame = (ix + iy) % FLAME_FRAMES.size()


func _physics_process(_delta: float) -> void:
    if not is_instance_valid(_player):
        _player = get_tree().get_first_node_in_group("player") as Node2D
        if _player == null:
            return
    var center_x: float = global_position.x + width_tiles * TILE * 0.5
    if not overlaps_body(_player):
        _entry_side = signf(_player.global_position.x - center_x)
        if is_zero_approx(_entry_side):
            _entry_side = -1.0
        return
    if is_passable() or not _player.has_method("take_damage"):
        return
    # El origen del golpe queda del lado contrario al de entrada, así el empuje
    # del Player (se aleja del origen) lo devuelve por donde vino.
    var source: Vector2 = _player.global_position - Vector2(_entry_side * 16.0, 0.0)
    _player.call("take_damage", damage_amount, source, true)


## True con E5: el fuego no daña ni empuja.
func is_passable() -> bool:
    return GameManager.has_outfit_resistance(resist_kind)

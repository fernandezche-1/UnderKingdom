extends StaticBody2D
class_name UnderkingdomArenaBarrier

## Puerta o barrera sólida que se abre y se cierra (sala de jefe, atajo,
## puerta con llave). La colisión es la del CollisionShape2D hijo: un
## rectángulo de 16 px de grosor y largo múltiplo de 16. Si es más alto que
## ancho es una puerta vertical; si no, una trampilla horizontal.
## Se dibuja con piezas del tileset del nivel, sin arte nuevo: inicio (arriba o
## izquierda), cuerpo repetido y final (abajo o derecha).

const TILE := 16.0

@export var piece_start: Texture2D
@export var piece_middle: Texture2D
@export var piece_end: Texture2D
@export_range(0.0, 1.0, 0.05) var fade_time: float = 0.25
@export var start_closed: bool = false

@onready var collision: CollisionShape2D = $CollisionShape2D

var closed: bool = false
var _pieces: Node2D = null
var _tween: Tween = null


func _ready() -> void:
    _build_pieces()
    set_closed(start_closed, false)


func close() -> void:
    set_closed(true)


func open() -> void:
    set_closed(false)


func set_closed(value: bool, animated: bool = true) -> void:
    closed = value
    # Diferido: se suele llamar desde la señal de un Area2D (consulta de física).
    collision.set_deferred("disabled", not value)

    if _tween != null:
        _tween.kill()
    var target_alpha := 1.0 if value else 0.0
    if not animated or fade_time <= 0.0:
        _pieces.modulate.a = target_alpha
        _pieces.visible = value
        return

    _pieces.visible = true
    _tween = create_tween()
    _tween.tween_property(_pieces, "modulate:a", target_alpha, fade_time)
    if not value:
        _tween.tween_callback(_pieces.hide)


func _build_pieces() -> void:
    _pieces = Node2D.new()
    _pieces.name = "Piezas"
    add_child(_pieces)

    var rect := collision.shape as RectangleShape2D
    if rect == null:
        push_warning("ArenaBarrier %s: la colisión debe ser un RectangleShape2D." % name)
        return

    var vertical := rect.size.y >= rect.size.x
    var length := rect.size.y if vertical else rect.size.x
    var count := maxi(int(round(length / TILE)), 1)
    var step := Vector2(0.0, TILE) if vertical else Vector2(TILE, 0.0)
    var top_left := collision.position - rect.size * 0.5
    for index in count:
        var texture := piece_middle
        if index == 0 and piece_start != null:
            texture = piece_start
        elif index == count - 1 and piece_end != null:
            texture = piece_end
        if texture == null:
            continue
        var piece := Sprite2D.new()
        piece.texture = texture
        piece.centered = false
        piece.position = top_left + step * index
        _pieces.add_child(piece)

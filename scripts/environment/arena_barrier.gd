extends StaticBody2D
class_name UnderkingdomArenaBarrier

## Barrera de arena: muro sólido que se cierra durante un combate y se abre al
## terminarlo. La colisión es la del CollisionShape2D hijo (un rectángulo de
## 16 px de ancho y alto múltiplo de 16). Se dibuja como una columna de piezas
## del tileset del nivel, sin arte nuevo: tope, cuerpo repetido y base.

const TILE := 16.0

@export var column_top: Texture2D
@export var column_middle: Texture2D
@export var column_bottom: Texture2D
@export_range(0.0, 1.0, 0.05) var fade_time: float = 0.25
@export var start_closed: bool = false

@onready var collision: CollisionShape2D = $CollisionShape2D

var closed: bool = false
var _column: Node2D = null
var _tween: Tween = null


func _ready() -> void:
    _build_column()
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
        _column.modulate.a = target_alpha
        _column.visible = value
        return

    _column.visible = true
    _tween = create_tween()
    _tween.tween_property(_column, "modulate:a", target_alpha, fade_time)
    if not value:
        _tween.tween_callback(_column.hide)


func _build_column() -> void:
    _column = Node2D.new()
    _column.name = "Columna"
    add_child(_column)

    var rect := collision.shape as RectangleShape2D
    if rect == null:
        push_warning("ArenaBarrier %s: la colisión debe ser un RectangleShape2D." % name)
        return

    var pieces := maxi(int(round(rect.size.y / TILE)), 1)
    var top_left := collision.position - rect.size * 0.5
    for index in pieces:
        var texture := column_middle
        if index == 0 and column_top != null:
            texture = column_top
        elif index == pieces - 1 and column_bottom != null:
            texture = column_bottom
        if texture == null:
            continue
        var piece := Sprite2D.new()
        piece.texture = texture
        piece.centered = false
        piece.position = top_left + Vector2(0.0, index * TILE)
        _column.add_child(piece)

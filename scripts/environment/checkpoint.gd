extends Area2D
class_name UnderkingdomCheckpoint

## Checkpoint genérico. Al tocarlo, el Player guarda aquí su punto de
## reaparición: al morir, el mapa se recarga y vuelve a este punto.
## El nodo se coloca donde debe quedar el Player al reaparecer.

@export var respawn_offset: Vector2 = Vector2.ZERO
@export var message: String = "PUNTO DE CONTROL"

var _activated: bool = false


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if _activated or not body.is_in_group("player"):
        return
    _activated = true
    var point := global_position + respawn_offset
    # Tras reaparecer aquí no se repite el aviso.
    var already_saved := GameManager.respawn_position == point
    if body.has_method("set_spawn_point"):
        body.call("set_spawn_point", point)
    if not already_saved and message != "":
        _show_message()


func _show_message() -> void:
    var label := Label.new()
    label.text = message
    label.add_theme_font_size_override("font_size", 8)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.size = Vector2(120, 12)
    label.position = Vector2(-60, -48)
    add_child(label)
    var tween := label.create_tween().set_parallel(true)
    tween.tween_property(label, "position:y", -60.0, 1.2)
    tween.tween_property(label, "modulate:a", 0.0, 1.2).set_delay(0.6)
    tween.chain().tween_callback(label.queue_free)

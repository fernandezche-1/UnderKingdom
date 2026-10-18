extends UnderkingdomArenaBarrier
class_name UnderkingdomLockedDoor

## Puerta con llave: bloquea el paso hasta que el Player llega a ella con la
## llave key_id de GameManager. Una vez abierta queda abierta para toda la
## partida (se guarda como objeto consumido, igual que los cofres).

@export var key_id: String = ""
@export var player_group: StringName = &"player"
## Distancia a cada lado de la puerta a la que se detecta al Player.
@export_range(0.0, 64.0, 1.0) var detect_margin: float = 20.0
@export var locked_message: String = "NECESITAS UNA LLAVE"
@export var opened_message: String = "PUERTA ABIERTA"

var _message: Label = null
var _message_tween: Tween = null


func _ready() -> void:
    start_closed = not GameManager.is_object_consumed(self)
    super._ready()
    if closed:
        _build_detector()


func _build_detector() -> void:
    var rect := collision.shape as RectangleShape2D
    if rect == null:
        return
    var detector := Area2D.new()
    detector.name = "Detector"
    detector.collision_layer = 0
    detector.collision_mask = 1
    detector.monitorable = false
    var shape := CollisionShape2D.new()
    var area_rect := RectangleShape2D.new()
    area_rect.size = rect.size + Vector2(detect_margin * 2.0, 0.0)
    shape.shape = area_rect
    shape.position = collision.position
    detector.add_child(shape)
    add_child(detector)
    detector.body_entered.connect(_on_detector_body_entered)


func _on_detector_body_entered(body: Node2D) -> void:
    if not closed or not body.is_in_group(player_group):
        return
    if not GameManager.has_key(key_id):
        _show_message(locked_message)
        return
    GameManager.mark_object_consumed(self)
    open()
    _show_message(opened_message)


func _show_message(text: String) -> void:
    if text.is_empty():
        return
    if _message == null:
        _message = Label.new()
        _message.add_theme_font_size_override("font_size", 8)
        _message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _message.size = Vector2(160, 12)
        _message.z_index = 20
        add_child(_message)
    if _message_tween != null:
        _message_tween.kill()

    var top := collision.position.y - (collision.shape as RectangleShape2D).size.y * 0.5
    _message.text = text
    _message.position = Vector2(-80.0, top - 20.0)
    _message.modulate.a = 1.0
    _message.visible = true
    _message_tween = _message.create_tween()
    _message_tween.tween_interval(1.4)
    _message_tween.tween_property(_message, "modulate:a", 0.0, 0.4)
    _message_tween.tween_callback(_message.hide)

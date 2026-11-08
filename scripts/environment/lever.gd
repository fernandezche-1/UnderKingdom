extends AnimatedSprite2D
class_name UnderkingdomLever

## Palanca que se tira con E (la misma acción que npc.gd y los cofres). Al
## tirar marca encounter_id en GameManager.completed_encounters, y toda
## barrera con ese id en open_on_encounter (arena_barrier.gd, en esta escena o
## en otra) se abre en ese momento o al cargarse. Se tira una sola vez y se
## recuerda en la partida. Detalle en docs/P49_PALANCA_Y_BARRERA.md.
##
## El origen está arriba a la izquierda (centered = false): una palanca de
## 1 x 2 piezas se coloca en (columna * 16, (fila del pie - 1) * 16).

signal pulled

## Id que marca al tirar. Las barreras que abre lo llevan en open_on_encounter.
@export var encounter_id: String = ""
@export_range(0, 10, 1) var idle_frame: int = 0
@export_range(0, 10, 1) var pulled_frame: int = 1

@export_category("Interaccion")
## Distancia en horizontal, desde el centro de la palanca, a la que se puede tirar.
@export_range(8.0, 160.0, 1.0) var interaction_radius: float = 24.0
@export_range(16.0, 160.0, 1.0) var interaction_vertical_range: float = 72.0
@export var prompt_text: String = "E  Tirar"

@export_category("Aviso")
@export var pulled_message: String = "SE OYE UN MECANISMO"
## Sacudida de la cámara en píxeles (0 = sin sacudida). Usa shake() de la
## cámara, que solo mueve offset, como la pared agrietada.
@export_range(0.0, 8.0, 1.0) var shake_strength: float = 3.0
@export_range(0.0, 1.0, 0.01) var shake_time: float = 0.25

var is_pulled: bool = false
var _prompt: Label = null
var _message: Label = null
var _message_tween: Tween = null


func _ready() -> void:
    stop()
    if encounter_id.is_empty():
        push_warning("Palanca %s: falta encounter_id; no abrirá ninguna barrera." % name)
    is_pulled = GameManager.is_encounter_completed(encounter_id)
    _set_frame(pulled_frame if is_pulled else idle_frame)
    add_to_group("interactable")
    _build_prompt()


func _process(_delta: float) -> void:
    var player := get_tree().get_first_node_in_group("player") as Node2D
    _prompt.visible = player != null and can_interact(player)


func can_interact(player: Node) -> bool:
    if is_pulled or encounter_id.is_empty() or not (player is Node2D):
        return false
    var to_player := (player as Node2D).global_position - _center_global()
    return absf(to_player.x) <= interaction_radius and absf(to_player.y) <= interaction_vertical_range


func interact(player: Node) -> bool:
    if not can_interact(player):
        return false
    pull()
    return true


## Tira de la palanca. Público para poder probarla o accionarla desde otro script.
func pull() -> void:
    if is_pulled:
        return
    is_pulled = true
    _prompt.visible = false
    _set_frame(pulled_frame)
    # Abre las barreras que escuchan este id y guarda la partida.
    GameManager.mark_encounter_completed(encounter_id)
    _play_feedback()
    pulled.emit()


func _play_feedback() -> void:
    _show_message(pulled_message)
    if shake_strength <= 0.0:
        return
    var camera := get_viewport().get_camera_2d()
    if camera != null and camera.has_method("shake"):
        camera.call("shake", shake_strength, shake_time)


func _size() -> Vector2:
    if sprite_frames == null or not sprite_frames.has_animation(animation):
        return Vector2(16, 32)
    var texture := sprite_frames.get_frame_texture(animation, 0)
    return texture.get_size() if texture != null else Vector2(16, 32)


func _center_global() -> Vector2:
    var size := _size()
    var local_center := Vector2.ZERO if centered else size * 0.5
    return to_global(local_center + offset)


func _top_local() -> float:
    var size := _size()
    return (-size.y * 0.5 if centered else 0.0) + offset.y


func _set_frame(frame_index: int) -> void:
    if sprite_frames == null or not sprite_frames.has_animation(animation):
        return
    var count := sprite_frames.get_frame_count(animation)
    if count <= 0:
        return
    frame = clampi(frame_index, 0, count - 1)


func _build_prompt() -> void:
    _prompt = _make_label(64.0)
    _prompt.text = prompt_text
    _prompt.position = Vector2(_center_local_x() - 32.0, _top_local() - 14.0)
    _prompt.visible = false
    add_child(_prompt)


func _show_message(text: String) -> void:
    if text.is_empty():
        return
    if _message == null:
        _message = _make_label(160.0)
        _message.position = Vector2(_center_local_x() - 80.0, _top_local() - 26.0)
        add_child(_message)
    if _message_tween != null:
        _message_tween.kill()
    _message.text = text
    _message.modulate.a = 1.0
    _message.visible = true
    _message_tween = _message.create_tween()
    _message_tween.tween_interval(1.4)
    _message_tween.tween_property(_message, "modulate:a", 0.0, 0.4)
    _message_tween.tween_callback(_message.hide)


func _center_local_x() -> float:
    return (0.0 if centered else _size().x * 0.5) + offset.x


func _make_label(width: float) -> Label:
    var label := Label.new()
    label.add_theme_font_size_override("font_size", 8)
    label.add_theme_color_override("font_outline_color", Color.BLACK)
    label.add_theme_constant_override("outline_size", 3)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.size = Vector2(width, 12)
    label.z_index = 30
    return label

extends Area2D
class_name UnderkingdomMapTransition

## Transición reutilizable entre escenas.
## Azul: siguiente mapa. Morado: mapa anterior.
## Puede funcionar automáticamente o requerir interacción con una tecla.

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_id: StringName = &"SpawnInicio"
@export var player_group: StringName = &"player"
@export var enabled: bool = true
@export_range(0.0, 3.0, 0.05) var trigger_delay: float = 0.0
@export var require_interaction: bool = false
@export var interaction_keycode: int = KEY_E
@export var prompt_text: String = "E - VIAJAR"
@export var marker_color: Color = Color(0.15, 0.55, 1.0, 0.65)
@export var require_world1_boss_key: bool = false
@export var require_w2_knight_defeated: bool = false
@export var locked_prompt_text: String = "DERROTA A CAPITAN Y RECOGE LA LLAVE"
@export var knight_locked_prompt_text: String = "DERROTA AL CABALLERO DE LA REINA"

var _changing_scene: bool = false
var _player_inside: Node = null
var _prompt: Label = null
var _marker: Polygon2D = null


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

    _prompt = get_node_or_null("Prompt") as Label
    _marker = get_node_or_null("Marker") as Polygon2D

    if _prompt != null:
        _refresh_prompt_text()
        _prompt.visible = false
    if _marker != null:
        _marker.color = marker_color


func _unhandled_input(event: InputEvent) -> void:
    if not require_interaction or _player_inside == null:
        return
    if not enabled or _changing_scene:
        return
    if not (event is InputEventKey):
        return

    var key_event := event as InputEventKey
    if not key_event.pressed or key_event.echo:
        return
    if key_event.keycode != interaction_keycode:
        return

    get_viewport().set_input_as_handled()
    _request_transition()


func _on_body_entered(body: Node) -> void:
    if not body.is_in_group(player_group):
        return

    _player_inside = body
    if _prompt != null:
        _refresh_prompt_text()
        _prompt.visible = require_interaction

    if not require_interaction:
        _request_transition()


func _on_body_exited(body: Node) -> void:
    if body != _player_inside:
        return

    _player_inside = null
    if _prompt != null:
        _prompt.visible = false


func _refresh_prompt_text() -> void:
    if _prompt == null:
        return
    if require_world1_boss_key and not GameManager.has_world1_boss_key():
        _prompt.text = locked_prompt_text
    elif require_w2_knight_defeated and not GameManager.has_w2_knight_been_defeated():
        _prompt.text = knight_locked_prompt_text
    else:
        _prompt.text = prompt_text


func _request_transition() -> void:
    if not enabled or _changing_scene:
        return
    if require_world1_boss_key and not GameManager.has_world1_boss_key():
        if _prompt != null:
            _refresh_prompt_text()
            _prompt.visible = true
        return
    if require_w2_knight_defeated and not GameManager.has_w2_knight_been_defeated():
        if _prompt != null:
            _refresh_prompt_text()
            _prompt.visible = true
        return
    if target_scene_path.is_empty():
        push_warning("MapTransition no tiene target_scene_path configurado.")
        return
    if not ResourceLoader.exists(target_scene_path):
        push_error("No existe la escena destino: %s" % target_scene_path)
        return

    _changing_scene = true
    if _prompt != null:
        _prompt.visible = false

    GameManager.set_transition(target_spawn_id)

    if trigger_delay > 0.0:
        await get_tree().create_timer(trigger_delay).timeout

    get_tree().change_scene_to_file(target_scene_path)

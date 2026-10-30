extends AnimatedSprite2D
class_name UnderkingdomNPC

## Personaje con el que se habla. Con el Player cerca aparece "E Hablar"; con E
## se abre su diálogo (un JSON de dialogues/, mismo formato que las
## cinemáticas) y el Player queda quieto hasta que termina. Sus líneas usan
## speaker_id "friend" (sin retrato) y las del Player "player".

signal talked

const DIALOGUE_SCENE := preload("res://escenas/ui/dialogue_ui.tscn")

@export_file("*.json") var dialogue_path: String = ""
## Distancia en horizontal a la que se puede hablar.
@export_range(16.0, 160.0, 1.0) var interaction_radius: float = 44.0
@export_range(16.0, 160.0, 1.0) var interaction_vertical_range: float = 72.0
@export var prompt_text: String = "E  Hablar"
@export var face_player: bool = true
@export var sprite_faces_right: bool = true

var _talking: bool = false
## Tras cerrar el diálogo, la misma E no vuelve a abrirlo.
var _cooldown_left: float = 0.0
var _prompt: Label = null


func _ready() -> void:
    add_to_group("interactable")
    _build_prompt()
    if sprite_frames != null and sprite_frames.has_animation(&"idle"):
        play(&"idle")


func _build_prompt() -> void:
    _prompt = Label.new()
    _prompt.text = prompt_text
    _prompt.add_theme_font_size_override("font_size", 8)
    _prompt.add_theme_color_override("font_outline_color", Color.BLACK)
    _prompt.add_theme_constant_override("outline_size", 3)
    _prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _prompt.size = Vector2(64, 12)
    var top := -16.0
    if sprite_frames != null:
        var tex := sprite_frames.get_frame_texture(animation, 0)
        if tex != null:
            top = -tex.get_size().y * 0.5 if centered else 0.0
    _prompt.position = Vector2(-32, top - 14.0)
    _prompt.z_index = 30
    _prompt.visible = false
    add_child(_prompt)


func _process(delta: float) -> void:
    if _cooldown_left > 0.0:
        _cooldown_left = maxf(_cooldown_left - delta, 0.0)
    var player := get_tree().get_first_node_in_group("player") as Node2D
    var near := player != null and can_interact(player)
    _prompt.visible = near
    if near and face_player and not _talking:
        var to_player := player.global_position.x - global_position.x
        flip_h = (to_player < 0.0) if sprite_faces_right else (to_player > 0.0)


func can_interact(player: Node) -> bool:
    if _talking or _cooldown_left > 0.0 or not (player is Node2D):
        return false
    var offset := (player as Node2D).global_position - global_position
    return absf(offset.x) <= interaction_radius and absf(offset.y) <= interaction_vertical_range


func interact(player: Node) -> bool:
    if not can_interact(player):
        return false
    _talk(player)
    return true


func _talk(player: Node) -> void:
    _talking = true
    _prompt.visible = false
    player.call("set_controls_locked", true)
    player.set("cinematic_invulnerable", true)

    var lines := _load_lines()
    var dialogue := DIALOGUE_SCENE.instantiate() as UnderkingdomDialogueUI
    get_tree().current_scene.add_child(dialogue)
    dialogue.start_dialogue(lines, {"friend": null})
    if not lines.is_empty():
        await dialogue.dialogue_finished
    dialogue.queue_free()

    if is_instance_valid(player):
        player.set("cinematic_invulnerable", false)
        player.call("set_controls_locked", false)
    _talking = false
    _cooldown_left = 0.4
    talked.emit()
    _after_dialogue(player)


## Para subclases: qué pasa al terminar de hablar (el Barquero abre su tienda).
func _after_dialogue(_player: Node) -> void:
    pass


func _load_lines() -> Array:
    if dialogue_path.is_empty() or not FileAccess.file_exists(dialogue_path):
        push_warning("NPC %s: falta el diálogo %s" % [name, dialogue_path])
        return []
    var result: Variant = JSON.parse_string(FileAccess.get_file_as_string(dialogue_path))
    if result is Array:
        return result
    push_warning("NPC %s: formato de diálogo incorrecto en %s" % [name, dialogue_path])
    return []

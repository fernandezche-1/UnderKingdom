extends CanvasLayer
class_name UnderkingdomDialogueUI

signal dialogue_finished
signal line_shown(line: Dictionary)

@onready var panel: Control = $Panel
@onready var left_portrait: TextureRect = $Panel/LeftPortrait
@onready var right_portrait: TextureRect = $Panel/RightPortrait
@onready var speaker_label: Label = $Panel/SpeakerName
@onready var dialogue_label: Label = $Panel/DialogueText
@onready var continue_label: Label = $Panel/ContinueHint

# Retratos originales suministrados con el proyecto, NO cuadros enteros del actor.
const PLAYER_FACE: Texture2D = preload("res://Elementals_fire_knight_FREE_v1.1/Elementals_fire_knight_FREE_v1.1/fire_knight.png")
const CAPTAIN_FACE: Texture2D = preload("res://elementals_wind_hashashin_FREE_v1.1/elementals_wind_hashashin_FREE_v1.1/wind_hashashin.png")

var _lines: Array = []
var _index: int = -1
var _portraits: Dictionary = {}
var _active: bool = false
var _pause_advance: bool = false
var _pause_serial: int = 0
var _portrait_tween: Tween
var _single_portrait_mode: bool = false


func _ready() -> void:
    visible = false


## portraits admite {"player": Texture2D o {"neutral": Texture2D, "sad": Texture2D}, ...}.
## Si no existe una emoción, usa neutral, y si no hay retrato lo oculta.
func start_dialogue(lines: Array, portraits: Dictionary = {}) -> void:
    if lines.is_empty():
        dialogue_finished.emit()
        return
    _lines = lines.duplicate(true)
    _portraits = {"player": PLAYER_FACE, "friend": CAPTAIN_FACE}
    _portraits.merge(portraits, true)
    _index = -1
    _active = true
    _pause_advance = false
    visible = true
    _advance()


## Compacta el diálogo para la cinemática de la Cámara del Sellado sin cambiar
## la presentación de esta escena en sus otros usos.
func configure_prison_cinematic() -> void:
    _single_portrait_mode = true
    panel.offset_top = 200.0
    panel.offset_bottom = 262.0
    panel.color = Color(0.035, 0.035, 0.055, 0.88)
    left_portrait.offset_left = 12.0
    left_portrait.offset_top = 8.0
    left_portrait.offset_right = 52.0
    left_portrait.offset_bottom = 48.0
    left_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    right_portrait.offset_left = 412.0
    right_portrait.offset_top = 8.0
    right_portrait.offset_right = 452.0
    right_portrait.offset_bottom = 48.0
    right_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    speaker_label.offset_left = 62.0
    speaker_label.offset_top = 4.0
    speaker_label.offset_right = 402.0
    speaker_label.offset_bottom = 19.0
    dialogue_label.offset_left = 62.0
    dialogue_label.offset_top = 19.0
    dialogue_label.offset_right = 402.0
    dialogue_label.offset_bottom = 58.0
    continue_label.offset_left = 420.0
    continue_label.offset_top = 50.0
    continue_label.offset_right = 456.0
    continue_label.offset_bottom = 61.0


func _unhandled_input(event: InputEvent) -> void:
    if not _active:
        return
    if event.is_action_pressed("dialogue_advance"):
        get_viewport().set_input_as_handled()
        if not _pause_advance:
            _advance()


func _advance() -> void:
    _index += 1
    if _index >= _lines.size():
        _finish_dialogue()
        return
    if not (_lines[_index] is Dictionary):
        _advance()
        return
    var line: Dictionary = _lines[_index]
    var speaker_id := String(line.get("speaker_id", ""))
    var emotion := String(line.get("expression", "neutral"))
    var displayed_name := String(line.get("name", ""))
    if speaker_id == "player":
        var thought_suffix := ""
        var suffix_start := displayed_name.find("(")
        if suffix_start >= 0:
            thought_suffix = " " + displayed_name.substr(suffix_start)
        displayed_name = GameManager.get_player_display_name() + thought_suffix
    speaker_label.text = displayed_name
    dialogue_label.text = String(line.get("text", ""))
    continue_label.text = "E  »"
    _pause_serial += 1
    var this_serial := _pause_serial
    _pause_advance = float(line.get("pause_before", 0.0)) > 0.0
    if _pause_advance:
        continue_label.text = "..."
        _release_pause_after(float(line.get("pause_before", 0.0)), this_serial)

    _set_portrait(left_portrait, "player", emotion if speaker_id == "player" else "neutral")
    _set_portrait(right_portrait, "friend", emotion if speaker_id == "friend" else "neutral")
    var player_active := speaker_id == "player"
    var friend_active := speaker_id == "friend"
    if _single_portrait_mode:
        left_portrait.visible = player_active and left_portrait.texture != null
        right_portrait.visible = friend_active and right_portrait.texture != null
    left_portrait.modulate = _emotion_tint(emotion) if player_active else Color(0.32, 0.32, 0.38, 0.87)
    right_portrait.modulate = _emotion_tint(emotion) if friend_active else Color(0.32, 0.32, 0.38, 0.87)
    if speaker_id not in ["player", "friend"]:
        left_portrait.visible = false
        right_portrait.visible = false
    if _portrait_tween != null and _portrait_tween.is_running():
        _portrait_tween.kill()
    var active_portrait := left_portrait if player_active else right_portrait
    if player_active or friend_active:
        # Solo se crea el tween si hay retrato que animar (la narración no tiene).
        _portrait_tween = create_tween()
        active_portrait.pivot_offset = active_portrait.size * 0.5
        active_portrait.scale = Vector2(0.95, 0.95)
        _portrait_tween.tween_property(active_portrait, "scale", Vector2.ONE, 0.15)
    left_portrait.scale = Vector2.ONE if not player_active else left_portrait.scale
    right_portrait.scale = Vector2.ONE if not friend_active else right_portrait.scale
    line_shown.emit(line)


func _release_pause_after(seconds: float, serial: int) -> void:
    await get_tree().create_timer(seconds).timeout
    if _active and _pause_serial == serial:
        _pause_advance = false
        continue_label.text = "E  »"


func _set_portrait(view: TextureRect, actor_id: String, expression: String) -> void:
    var value: Variant = _portraits.get(actor_id)
    var texture: Texture2D = null
    if value is Texture2D:
        texture = value
    elif value is Dictionary:
        var entries: Dictionary = value
        var selected: Variant = entries.get(expression, entries.get("neutral"))
        if selected is Texture2D:
            texture = selected
    view.texture = texture
    view.visible = texture != null


func _emotion_tint(emotion: String) -> Color:
    match emotion:
        "anger":
            return Color(1.0, 0.78, 0.75)
        "sad":
            return Color(0.78, 0.86, 1.0)
        "fear":
            return Color(0.83, 0.81, 1.0)
        _:
            return Color.WHITE


func _finish_dialogue() -> void:
    _active = false
    _pause_advance = false
    visible = false
    _lines.clear()
    dialogue_finished.emit()

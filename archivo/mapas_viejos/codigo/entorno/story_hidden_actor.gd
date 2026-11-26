extends CharacterBody2D
class_name UnderkingdomStoryHiddenActor

## Oculta un actor hasta que el progreso narrativo lo habilite.
## Se usa en W2 para que Cthulhu no aparezca antes de su revelacion.

@export var hide_until_cthulhu_reveal: bool = true

var _saved_collision_layer: int = 0
var _saved_collision_mask: int = 0


func _ready() -> void:
    _saved_collision_layer = collision_layer
    _saved_collision_mask = collision_mask

    if GameManager.has_signal("cthulhu_revealed_changed"):
        if not GameManager.cthulhu_revealed_changed.is_connected(_on_reveal_changed):
            GameManager.cthulhu_revealed_changed.connect(_on_reveal_changed)

    _apply_story_visibility()


func _on_reveal_changed(_revealed: bool) -> void:
    _apply_story_visibility()


func _apply_story_visibility() -> void:
    var should_show := true
    if hide_until_cthulhu_reveal:
        should_show = GameManager.is_cthulhu_revealed()

    visible = should_show
    collision_layer = _saved_collision_layer if should_show else 0
    collision_mask = _saved_collision_mask if should_show else 0
    process_mode = Node.PROCESS_MODE_INHERIT if should_show else Node.PROCESS_MODE_DISABLED
    set_physics_process(should_show)
    set_process(should_show)

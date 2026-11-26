extends UnderkingdomNPC
class_name UnderkingdomMerchantNPC

## El Barquero: sale de la tierra la primera vez que el Player se acerca, habla
## y abre la tienda de mejoras (la pestaña Mejoras del menú de pausa). La
## primera charla de la partida es su presentación; después dice una línea corta.

const PRESENTED_ID := "barquero_presentado"

@export_file("*.json") var repeat_dialogue_path: String = ""
@export var shop_title: String = "EL BARQUERO"
@export var rise_animation: StringName = &"rise"
@export_range(0.0, 400.0, 5.0) var rise_range: float = 120.0

var _risen: bool = false


func _ready() -> void:
    super._ready()
    if sprite_frames != null and sprite_frames.has_animation(rise_animation):
        play(rise_animation)
        pause()
        frame = 0
    else:
        _risen = true


func _process(delta: float) -> void:
    if not _risen:
        _prompt.visible = false
        var player := get_tree().get_first_node_in_group("player") as Node2D
        if player != null and absf(player.global_position.x - global_position.x) <= rise_range \
                and absf(player.global_position.y - global_position.y) <= interaction_vertical_range:
            _risen = true
            play(rise_animation)
            animation_finished.connect(_on_risen, CONNECT_ONE_SHOT)
        return
    super._process(delta)


func _on_risen() -> void:
    play(&"idle")


func can_interact(player: Node) -> bool:
    return _risen and animation != rise_animation and super.can_interact(player)


func _load_lines() -> Array:
    if GameManager.has_seen_cinematic(PRESENTED_ID) and not repeat_dialogue_path.is_empty():
        var saved := dialogue_path
        dialogue_path = repeat_dialogue_path
        var lines := super._load_lines()
        dialogue_path = saved
        return lines
    return super._load_lines()


func _after_dialogue(_player: Node) -> void:
    GameManager.mark_cinematic_seen(PRESENTED_ID)
    PauseMenu.open_shop(shop_title)

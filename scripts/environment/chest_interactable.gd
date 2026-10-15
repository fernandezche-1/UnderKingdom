extends AnimatedSprite2D
class_name UnderkingdomChest

## Cofre de dos estados: frame 0 cerrado, frame 1 abierto.
## E abre/cierra visualmente. El loot solo sale en la primera apertura.

const COIN_SCENE: PackedScene = preload("res://escenas/objetos/coin_pickup.tscn")
const POTION_SCENE: PackedScene = preload("res://escenas/objetos/potion_pickup.tscn")

@export_category("Interaccion")
@export_range(16.0, 160.0, 1.0) var interaction_radius: float = 54.0

@export_category("Loot")
@export_range(0, 20, 1) var coin_count: int = 0
@export_range(0, 20, 1) var potion_count: int = 0
@export var coin_offsets: PackedVector2Array = PackedVector2Array()
@export var potion_offsets: PackedVector2Array = PackedVector2Array()

var is_open: bool = false
var loot_given: bool = false


func _ready() -> void:
    stop()
    # Si ya se abrió antes de recargar el mapa (muerte), queda abierto y vacío.
    loot_given = GameManager.is_object_consumed(self)
    is_open = loot_given
    frame = 1 if is_open else 0
    frame_progress = 0.0
    add_to_group("interactable")


func can_interact(player: Node) -> bool:
    if not (player is Node2D):
        return false
    return global_position.distance_to((player as Node2D).global_position) <= interaction_radius


func interact(player: Node) -> bool:
    if not can_interact(player):
        return false
    _toggle_chest()
    return true


func _toggle_chest() -> void:
    is_open = not is_open
    stop()
    frame = 1 if is_open else 0
    frame_progress = 0.0

    if is_open and not loot_given:
        loot_given = true
        GameManager.mark_object_consumed(self)
        _spawn_loot()


func _spawn_loot() -> void:
    for index in range(coin_count):
        var offset := _offset_for_index(coin_offsets, index, coin_count, 7.0, Vector2(0, -8))
        _spawn_drop(COIN_SCENE, offset)

    for index in range(potion_count):
        var offset := _offset_for_index(potion_offsets, index, potion_count, 10.0, Vector2(0, -18))
        _spawn_drop(POTION_SCENE, offset)


func _spawn_drop(scene: PackedScene, offset: Vector2) -> void:
    if scene == null or get_parent() == null:
        return

    var drop := scene.instantiate()
    get_parent().add_child(drop)
    if drop is Node2D:
        (drop as Node2D).global_position = global_position + offset


func _offset_for_index(
    offsets: PackedVector2Array,
    index: int,
    count: int,
    spacing: float,
    base: Vector2
) -> Vector2:
    if index < offsets.size():
        return offsets[index]

    var center := (float(count) - 1.0) * 0.5
    return base + Vector2((float(index) - center) * spacing, 0.0)

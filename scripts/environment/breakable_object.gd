extends StaticBody2D
class_name UnderkingdomBreakableObject

## Base reutilizable para cajas, estatuas y otros objetos del escenario.
## Recibe daño de los ataques del Player, cambia de estado visual y conserva
## los escombros una vez destruido.

signal damaged(current_health: float, max_health: float)
signal destroyed

const COIN_SCENE: PackedScene = preload("res://escenas/objetos/coin_pickup.tscn")
const POTION_SCENE: PackedScene = preload("res://escenas/objetos/potion_pickup.tscn")

@export_category("Objeto rompible")
@export_range(0.25, 20.0, 0.25) var max_health: float = 3.0
@export_range(0, 10, 1) var intact_frame: int = 0
@export_range(0, 10, 1) var damaged_frame: int = 1
@export_range(0, 10, 1) var critical_frame: int = 2
@export_range(0, 10, 1) var destroyed_frame: int = 3
@export_range(0.0, 1.0, 0.05) var critical_health_ratio: float = 0.50
@export var disable_collision_when_destroyed: bool = true

@export_category("Drops")
@export_range(0, 20, 1) var coin_drop_count: int = 0
@export_range(0, 20, 1) var potion_drop_count: int = 0
@export var coin_drop_offsets: PackedVector2Array = PackedVector2Array()
@export var potion_drop_offsets: PackedVector2Array = PackedVector2Array()

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var current_health: float = 0.0
var is_destroyed: bool = false


func _ready() -> void:
    current_health = max_health
    sprite.stop()
    _set_frame(intact_frame)


func take_damage_from(_source_global_position: Vector2, amount: float) -> bool:
    return take_damage(amount)


func take_continuous_damage_from(_source_global_position: Vector2, amount: float) -> bool:
    return take_damage(amount)


func take_damage(amount: float) -> bool:
    if is_destroyed or amount <= 0.0:
        return false

    current_health = maxf(current_health - amount, 0.0)
    damaged.emit(current_health, max_health)

    if current_health <= 0.0:
        _break_object()
    else:
        _refresh_damage_frame()

    return true


func _refresh_damage_frame() -> void:
    if current_health <= max_health * critical_health_ratio:
        _set_frame(critical_frame)
    elif current_health < max_health:
        _set_frame(damaged_frame)
    else:
        _set_frame(intact_frame)


func _break_object() -> void:
    if is_destroyed:
        return

    is_destroyed = true
    current_health = 0.0
    _set_frame(destroyed_frame)

    # El objeto deja de bloquear y de recibir golpes, pero conserva escombros.
    collision_layer = 0
    collision_mask = 0
    if disable_collision_when_destroyed and collision_shape != null:
        collision_shape.set_deferred("disabled", true)

    _spawn_configured_drops()
    destroyed.emit()


func _set_frame(frame_index: int) -> void:
    if sprite == null or sprite.sprite_frames == null:
        return
    var count := sprite.sprite_frames.get_frame_count(sprite.animation)
    if count <= 0:
        return
    sprite.frame = clampi(frame_index, 0, count - 1)


func _spawn_configured_drops() -> void:
    for index in range(coin_drop_count):
        var offset := _drop_offset(coin_drop_offsets, index, coin_drop_count, Vector2(0, -10))
        _spawn_drop(COIN_SCENE, offset)

    for index in range(potion_drop_count):
        var offset := _drop_offset(potion_drop_offsets, index, potion_drop_count, Vector2(0, -18))
        _spawn_drop(POTION_SCENE, offset)


func _spawn_drop(scene: PackedScene, offset: Vector2) -> void:
    if scene == null or get_parent() == null:
        return
    var drop := scene.instantiate()
    get_parent().add_child(drop)
    if drop is Node2D:
        (drop as Node2D).global_position = global_position + offset


func _drop_offset(offsets: PackedVector2Array, index: int, count: int, base: Vector2) -> Vector2:
    if index < offsets.size():
        return offsets[index]
    var center := (float(count) - 1.0) * 0.5
    return base + Vector2((float(index) - center) * 8.0, 0.0)

extends Area2D
class_name UnderkingdomBossKeyPickup

## Llave obligatoria del primer jefe.
## Puede existir ya colocada en Mundo 1, pero permanece oculta/inactiva hasta
## que Capitán sea derrotado. Esto hace fiable la aparición y la recogida.

@export var player_group: StringName = &"player"
@export_range(0.0, 20.0, 0.5) var bob_height: float = 3.0
@export_range(0.0, 10.0, 0.1) var bob_speed: float = 2.5
@export_range(8.0, 100.0, 1.0) var pickup_radius: float = 42.0
@export var activate_after_world1_boss_defeated: bool = true

var _base_y: float = 0.0
var _time: float = 0.0
var _collected: bool = false
var _active: bool = false

@onready var pickup_collision: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D


func _ready() -> void:
    collision_layer = 0
    collision_mask = 1
    monitorable = false
    _base_y = position.y

    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)
    if not GameManager.world1_boss_defeated_changed.is_connected(_on_boss_defeated_changed):
        GameManager.world1_boss_defeated_changed.connect(_on_boss_defeated_changed)

    if GameManager.world1_boss_key_collected:
        queue_free()
        return

    if activate_after_world1_boss_defeated and not GameManager.world1_boss_defeated:
        _set_pickup_active(false)
    else:
        activate_pickup()


func activate_pickup() -> void:
    if _collected or GameManager.world1_boss_key_collected:
        return

    _active = true
    visible = true
    monitoring = true
    _base_y = position.y
    _time = 0.0
    set_process(true)
    set_physics_process(true)
    if pickup_collision != null:
        pickup_collision.set_deferred("disabled", false)

    # Si el Player ya está encima cuando aparece la llave, la recogida sigue
    # funcionando sin depender de un nuevo evento body_entered.
    call_deferred("_check_existing_overlaps")


func _set_pickup_active(value: bool) -> void:
    _active = value
    visible = value
    monitoring = value
    set_process(value)
    set_physics_process(value)
    if pickup_collision != null:
        pickup_collision.set_deferred("disabled", not value)


func _on_boss_defeated_changed(defeated: bool) -> void:
    if defeated:
        activate_pickup()


func _process(delta: float) -> void:
    if not _active or _collected:
        return
    _time += delta
    position.y = _base_y + sin(_time * bob_speed) * bob_height


func _physics_process(_delta: float) -> void:
    if not _active or _collected:
        return

    _check_existing_overlaps()
    if _collected:
        return

    # Segundo respaldo: comprobar la distancia contra el centro físico del
    # Player. Es más fiable que usar solamente la posición raíz del personaje.
    var player := get_tree().get_first_node_in_group(player_group) as Node2D
    if not is_instance_valid(player):
        return

    var player_point := player.global_position
    var player_collision := player.get_node_or_null("CollisionShape2D") as Node2D
    if player_collision != null:
        player_point = player_collision.global_position

    if global_position.distance_to(player_point) <= pickup_radius:
        _collect()


func _check_existing_overlaps() -> void:
    if not _active or _collected or not is_inside_tree():
        return
    for body in get_overlapping_bodies():
        if _is_player(body):
            _collect()
            return


func _on_body_entered(body: Node) -> void:
    if not _active or _collected or not _is_player(body):
        return
    _collect()


func _is_player(body: Node) -> bool:
    return body != null and body.is_in_group(player_group)


func _collect() -> void:
    if _collected:
        return
    _collected = true
    _active = false
    monitoring = false
    if pickup_collision != null:
        pickup_collision.set_deferred("disabled", true)
    GameManager.grant_world1_boss_key()
    queue_free()

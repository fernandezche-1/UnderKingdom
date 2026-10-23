extends Area2D
class_name UnderkingdomAbilityPickup

## Reliquia que da una habilidad al Player (GameManager.unlock_ability). Puede
## ir colocada en el mapa o la suelta una BossArena con ability_reward. Una vez
## recogida no vuelve a aparecer en la partida.

@export var player_group: StringName = &"player"
## Id de GameManager.ABILITY_DEFINITIONS.
@export var ability_id: String = ""
@export_range(0.0, 20.0, 0.5) var bob_height: float = 3.0
@export_range(0.0, 10.0, 0.1) var bob_speed: float = 2.5
## Respaldo por distancia al centro del Player, como la llave de jefe.
@export_range(8.0, 100.0, 1.0) var pickup_radius: float = 24.0

var _base_y: float = 0.0
var _time: float = 0.0
var _collected: bool = false


func _ready() -> void:
    collision_layer = 0
    collision_mask = 1
    monitorable = false
    _base_y = position.y
    if ability_id.is_empty() or GameManager.is_ability_unlocked(ability_id):
        queue_free()
        return
    body_entered.connect(_on_body_entered)
    # Si cae encima del Player no habrá un body_entered nuevo.
    call_deferred("_check_existing_overlaps")


func _process(delta: float) -> void:
    _time += delta
    position.y = _base_y + sin(_time * bob_speed) * bob_height


func _physics_process(_delta: float) -> void:
    if _collected:
        return
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
    if _collected or not is_inside_tree():
        return
    for body in get_overlapping_bodies():
        if body.is_in_group(player_group):
            _collect()
            return


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group(player_group):
        _collect()


func _collect() -> void:
    if _collected:
        return
    _collected = true
    set_deferred("monitoring", false)
    UnderkingdomCombatFX.pickup_sparkle(self)
    GameManager.unlock_ability(ability_id)
    queue_free()

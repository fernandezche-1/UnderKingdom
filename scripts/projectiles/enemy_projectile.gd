extends Area2D
class_name UnderkingdomEnemyProjectile

## Proyectil reutilizable para enemigos. El daño puede ser fijo o crecer
## con la distancia recorrida (usado por el Caballero de la Reina).

@export_range(10.0, 1200.0, 5.0) var default_speed: float = 240.0
@export_range(0.05, 10.0, 0.05) var default_damage: float = 0.50
@export_range(0.1, 10.0, 0.1) var lifetime: float = 4.0
@export var rotate_to_direction: bool = true
@export var target_group: StringName = &"player"

var velocity: Vector2 = Vector2.ZERO
var _spawn_position: Vector2 = Vector2.ZERO
var _damage_min: float = 0.50
var _damage_max: float = 0.50
var _distance_damage_min: float = 0.0
var _distance_damage_max: float = 1.0
var _distance_scaled_damage: bool = false
var _life_left: float = 0.0
var _spent: bool = false


func _ready() -> void:
    _life_left = lifetime
    body_entered.connect(_on_body_entered)


func setup(
    origin: Vector2,
    target: Vector2,
    speed: float = -1.0,
    damage_min: float = -1.0,
    damage_max: float = -1.0,
    distance_damage_min: float = 0.0,
    distance_damage_max: float = 1.0
) -> void:
    global_position = origin
    _spawn_position = origin

    var direction := (target - origin).normalized()
    if direction == Vector2.ZERO:
        direction = Vector2.RIGHT

    var actual_speed := default_speed if speed <= 0.0 else speed
    velocity = direction * actual_speed

    _damage_min = default_damage if damage_min < 0.0 else damage_min
    _damage_max = _damage_min if damage_max < 0.0 else maxf(damage_max, _damage_min)
    _distance_damage_min = maxf(distance_damage_min, 0.0)
    _distance_damage_max = maxf(distance_damage_max, _distance_damage_min + 1.0)
    _distance_scaled_damage = _damage_max > _damage_min + 0.001

    if rotate_to_direction:
        rotation = direction.angle()


func _physics_process(delta: float) -> void:
    if _spent:
        return

    global_position += velocity * delta
    _life_left -= delta
    if _life_left <= 0.0:
        queue_free()


func _on_body_entered(body: Node) -> void:
    if _spent or body == null:
        return

    if body.is_in_group(target_group):
        _spent = true
        set_deferred("monitoring", false)
        var damage := _damage_for_travel_distance()
        if body.has_method("take_damage_from"):
            body.call("take_damage_from", global_position, damage)
        elif body.has_method("take_damage"):
            body.call("take_damage", damage)
        queue_free()
        return

    # El proyectil también se destruye contra terreno/cuerpos sólidos.
    if body is PhysicsBody2D:
        _spent = true
        set_deferred("monitoring", false)
        queue_free()


func _damage_for_travel_distance() -> float:
    if not _distance_scaled_damage:
        return _damage_min

    var travelled := _spawn_position.distance_to(global_position)
    var ratio := inverse_lerp(_distance_damage_min, _distance_damage_max, travelled)
    return lerpf(_damage_min, _damage_max, clampf(ratio, 0.0, 1.0))

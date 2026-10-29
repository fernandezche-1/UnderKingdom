extends Area2D
class_name UnderkingdomPlayerProjectile

## Bola de fuego del Player. Avanza en línea recta, daña al primer enemigo o
## jefe que toca y se apaga contra el terreno. Las plataformas one-way (capa 2)
## no la detienen.

@export_range(10.0, 1200.0, 5.0) var speed: float = 300.0
@export_range(0.25, 10.0, 0.25) var damage: float = 1.0
@export_range(0.1, 10.0, 0.1) var lifetime: float = 1.5

var _direction: float = 1.0
var _life_left: float = 0.0
var _spent: bool = false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
    _life_left = lifetime
    body_entered.connect(_on_body_entered)


func setup(origin: Vector2, direction: float, new_damage: float) -> void:
    global_position = origin
    _direction = -1.0 if direction < 0.0 else 1.0
    damage = new_damage
    if is_instance_valid(sprite):
        sprite.flip_h = _direction < 0.0


func _physics_process(delta: float) -> void:
    if _spent:
        return

    global_position.x += speed * _direction * delta
    _life_left -= delta
    if _life_left <= 0.0:
        queue_free()


func _on_body_entered(body: Node) -> void:
    if _spent or body == null or body.is_in_group("player"):
        return

    _spent = true
    set_deferred("monitoring", false)
    var accepted: Variant = null
    if body.has_method("take_damage_from"):
        accepted = body.call("take_damage_from", global_position, damage)
    elif body.has_method("take_damage"):
        accepted = body.call("take_damage", damage)
    if accepted != null and (typeof(accepted) != TYPE_BOOL or bool(accepted)):
        UnderkingdomCombatFX.hit_flash(body)
    queue_free()

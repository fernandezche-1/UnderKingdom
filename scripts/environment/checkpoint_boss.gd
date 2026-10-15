extends Area2D
class_name UnderkingdomBossCheckpoint

## Checkpoint previo al Capitán. Al cruzarlo guarda el punto de reaparición y
## cierra la barrera detrás del Player. Al derrotar al jefe, la barrera se abre.

@export var respawn_offset: Vector2 = Vector2(0, -20)
@export var barrier_collision_path: NodePath = NodePath("../collisiones jefe mapa/CollisionShape2D")

@onready var barrier_collision: CollisionShape2D = get_node_or_null(barrier_collision_path) as CollisionShape2D

var _activated: bool = false


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    GameManager.world1_boss_defeated_changed.connect(_on_boss_defeated_changed)

    # Antes de iniciar el combate la entrada queda abierta para poder cruzarla.
    _set_barrier_closed(false)
    if GameManager.world1_boss_defeated:
        monitoring = false


func _on_body_entered(body: Node2D) -> void:
    if _activated or not body.is_in_group("player"):
        return

    _activated = true
    if body.has_method("set_spawn_point"):
        body.call("set_spawn_point", global_position + respawn_offset)

    if not GameManager.world1_boss_defeated:
        _set_barrier_closed(true)

    monitoring = false


func _on_boss_defeated_changed(defeated: bool) -> void:
    if defeated:
        _set_barrier_closed(false)


func _set_barrier_closed(closed: bool) -> void:
    if barrier_collision == null:
        return
    barrier_collision.set_deferred("disabled", not closed)

extends Area2D
class_name UnderkingdomLedgeTransitionZone

## Paso sencillo entre dos alturas.
## W/↑ da UN impulso de salto real.
## S/↓ da UN impulso de caída real.
## No hay movimiento vertical libre ni efecto de "vuelo".

@export var player_group: StringName = &"player"
@export_range(-1200.0, -100.0, 10.0) var assisted_jump_velocity: float = -760.0
@export_range(20.0, 600.0, 10.0) var assisted_drop_velocity: float = 190.0
@export_range(0.0, 200.0, 1.0) var side_threshold: float = 22.0


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
    if body.is_in_group(player_group) and body.has_method("set_ledge_transition_zone"):
        body.call("set_ledge_transition_zone", self, true)


func _on_body_exited(body: Node) -> void:
    if body.is_in_group(player_group) and body.has_method("set_ledge_transition_zone"):
        body.call("set_ledge_transition_zone", self, false)


func can_go_up(player: Node2D) -> bool:
    return player.global_position.y > global_position.y + side_threshold


func can_go_down(player: Node2D) -> bool:
    return player.global_position.y < global_position.y - side_threshold


func get_jump_velocity() -> float:
    return assisted_jump_velocity


func get_drop_velocity() -> float:
    return assisted_drop_velocity

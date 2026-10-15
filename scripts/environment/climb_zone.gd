extends Area2D
class_name UnderkingdomClimbZone

## Zona para escaleras verticales o tramos que requieran trepado.
## El Player podrá usar W/↑, S/↓ y A/D dentro de ella.

@export var player_group: StringName = &"player"
@export var ignore_normal_terrain_while_climbing: bool = false
## Direccion positiva = bajar (S/abajo). Vector2.DOWN mantiene una escalera vertical.
@export var climb_axis: Vector2 = Vector2.DOWN
## En escaleras diagonales se desactiva para mantener al Player sobre la pendiente.
@export var allow_horizontal_adjustment: bool = true


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(player_group) and body.has_method("set_climb_zone"):
		body.call("set_climb_zone", self, true)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group(player_group) and body.has_method("set_climb_zone"):
		body.call("set_climb_zone", self, false)

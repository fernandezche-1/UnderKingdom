extends Area2D
class_name KillZone

## Zona letal reutilizable.
## Detecta únicamente cuerpos pertenecientes al grupo configurado en `player_group`.
signal lethal_contact(body: Node)

@export var player_group: StringName = &"player"
@export var fallback_damage: float = 9999.0
@export var print_warning_if_unhandled: bool = true

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group(player_group):
        return

    lethal_contact.emit(body)

    if body.has_method("die"):
        body.call("die")
        return

    if body.has_method("kill"):
        body.call("kill")
        return

    if body.has_method("take_damage"):
        body.call("take_damage", fallback_damage)
        return

    if print_warning_if_unhandled:
        push_warning(
            "KillZone detectó al jugador, pero el cuerpo no tiene die(), kill() ni take_damage()."
        )

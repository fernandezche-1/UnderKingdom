extends Area2D
class_name BurnZone

## Zona de quemadura reutilizable.
## Valor por defecto: 1/4 de corazón por tic.
signal damage_tick(body: Node, amount: float)

@export var player_group: StringName = &"player"
@export_range(0.01, 10.0, 0.01) var damage_per_tick: float = 0.25
@export_range(0.05, 10.0, 0.05) var tick_interval: float = 0.50
@export var damage_immediately: bool = false
@export var print_warning_if_unhandled: bool = true

var _targets: Array[Node] = []
var _elapsed: float = 0.0
var _warned_missing_damage_method: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
    _remove_invalid_targets()

    if _targets.is_empty():
        _elapsed = 0.0
        return

    _elapsed += delta

    while _elapsed >= tick_interval:
        _elapsed -= tick_interval
        for body in _targets.duplicate():
            _apply_tick(body)

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group(player_group):
        return

    if not _targets.has(body):
        _targets.append(body)

    if damage_immediately:
        _apply_tick(body)

func _on_body_exited(body: Node) -> void:
    _targets.erase(body)

    if _targets.is_empty():
        _elapsed = 0.0

func _apply_tick(body: Node) -> void:
    if not is_instance_valid(body):
        return

    damage_tick.emit(body, damage_per_tick)

    if body.has_method("take_damage"):
        body.call("take_damage", damage_per_tick)
        return

    if print_warning_if_unhandled and not _warned_missing_damage_method:
        _warned_missing_damage_method = true
        push_warning(
            "BurnZone detectó al jugador, pero todavía no existe take_damage(cantidad)."
        )

func _remove_invalid_targets() -> void:
    for body in _targets.duplicate():
        if not is_instance_valid(body):
            _targets.erase(body)

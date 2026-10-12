extends StaticBody2D
class_name UnderkingdomWorld1BossGateBlocker

## Bloqueo adicional de la puerta/reja de Mundo 1.
## No modifica la lógica W/S existente: solo mantiene una colisión sólida
## mientras no se haya recogido la llave soltada por Capitán.

@onready var gate_collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
    GameManager.world1_boss_key_changed.connect(_on_key_state_changed)
    _sync_lock_state()


func _on_key_state_changed(_has_key: bool) -> void:
    _sync_lock_state()


func _sync_lock_state() -> void:
    if gate_collision == null:
        return
    gate_collision.set_deferred("disabled", GameManager.world1_boss_key_collected)

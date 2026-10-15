extends Node

## Conecta al elfo original de W2 con el progreso narrativo.
## Este elfo es el Caballero de la Reina; no se crea un personaje visual nuevo.

@export var knight_path: NodePath = NodePath("../CaballeroDeLaReina")


func _ready() -> void:
    var knight := get_node_or_null(knight_path)

    # Si ya fue derrotado durante esta partida, no reaparece al volver a W2.
    if GameManager.has_w2_knight_been_defeated():
        if knight != null:
            knight.queue_free()
        return

    if knight == null:
        push_warning("No se encontro al CaballeroDeLaReina en W2.")
        return

    if knight.has_signal("death_finished"):
        knight.connect("death_finished", _on_knight_defeated)
    elif knight.has_signal("died"):
        knight.connect("died", _on_knight_defeated)


func _on_knight_defeated() -> void:
    GameManager.mark_w2_knight_defeated()

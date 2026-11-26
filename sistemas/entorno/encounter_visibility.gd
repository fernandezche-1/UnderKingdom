extends Node
class_name UnderkingdomEncounterVisibility

## Muestra u oculta un nodo (NPC, enemigo u objeto) según los encuentros
## superados en `GameManager.completed_encounters` (K3 de FASE2_DECISIONES).
## Se pone como hijo del nodo a controlar, o se apunta a otro con `target`.
## Oculto: no se ve, no colisiona (capa y máscara a 0 en el nodo y sus
## descendientes) y no procesa. Se actualiza al cargar y cuando se marca un
## encuentro. Con las dos exportaciones vacías no hace nada.

## Nodo controlado. Vacío: el padre.
@export var target: NodePath = NodePath("")
## Mientras este encuentro no esté superado, el nodo está oculto.
@export var show_when_encounter: String = ""
## En cuanto este encuentro esté superado, el nodo se oculta.
@export var hide_when_encounter: String = ""

var _node: Node = null
var _saved_process_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT
## CollisionObject2D -> [capa, máscara] originales.
var _saved_collision: Dictionary = {}
var _hidden: bool = false


func _ready() -> void:
    # Sigue escuchando aunque el nodo controlado deje de procesar.
    process_mode = Node.PROCESS_MODE_ALWAYS
    _node = get_node_or_null(target) if not target.is_empty() else get_parent()
    if _node == null or _node == self:
        return
    _saved_process_mode = _node.process_mode
    if not GameManager.encounter_completed.is_connected(_on_encounter_completed):
        GameManager.encounter_completed.connect(_on_encounter_completed)
    _apply()
    # El _ready del padre corre después del nuestro: se repite para que no
    # deshaga la colisión.
    _apply.call_deferred()


func should_show() -> bool:
    if not show_when_encounter.is_empty() and not GameManager.is_encounter_completed(show_when_encounter):
        return false
    if not hide_when_encounter.is_empty() and GameManager.is_encounter_completed(hide_when_encounter):
        return false
    return true


func is_node_hidden() -> bool:
    return _hidden


func _on_encounter_completed(encounter_id: String) -> void:
    if encounter_id == show_when_encounter or encounter_id == hide_when_encounter:
        _apply()


func _apply() -> void:
    if not is_instance_valid(_node):
        return
    var show_it: bool = should_show()
    _hidden = not show_it
    if _node is CanvasItem:
        (_node as CanvasItem).visible = show_it
    if show_it:
        _node.process_mode = _saved_process_mode
    else:
        _node.process_mode = Node.PROCESS_MODE_DISABLED
    _set_collisions(_node, show_it)


func _set_collisions(root: Node, enabled: bool) -> void:
    if root is CollisionObject2D:
        var body := root as CollisionObject2D
        if enabled:
            if _saved_collision.has(body):
                var saved: Array = _saved_collision[body]
                body.collision_layer = int(saved[0])
                body.collision_mask = int(saved[1])
                _saved_collision.erase(body)
        else:
            if not _saved_collision.has(body):
                _saved_collision[body] = [body.collision_layer, body.collision_mask]
            body.collision_layer = 0
            body.collision_mask = 0
    for child in root.get_children():
        _set_collisions(child, enabled)

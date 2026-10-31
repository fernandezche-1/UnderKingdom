extends UnderkingdomEnemyBase

## Carcelero del calabozo: se le gana a puño, suelta la espada oxidada y abre
## la reja de la salida.

const ENCOUNTER_ID := "calabozo_carcelero_derrotado"
const SWORD_SCENE := preload("res://escenas/objetos/espada_oxidada.tscn")
const SWORD_GROUP := &"calabozo_espada_oxidada"

@export var exit_gate: UnderkingdomArenaBarrier

func _ready() -> void:
	super._ready()
	GameManager.start_sword_mission()
	if GameManager.is_encounter_completed(ENCOUNTER_ID):
		_open_gate()
		_drop_sword_if_needed(global_position)
		queue_free()

func _on_enemy_death_finished() -> void:
	GameManager.mark_encounter_completed(ENCOUNTER_ID)
	GameManager.mark_sword_guard_defeated()
	_open_gate()
	_drop_sword_if_needed(global_position)

func _open_gate() -> void:
	if is_instance_valid(exit_gate):
		exit_gate.set_closed.call_deferred(false)

func _drop_sword_if_needed(drop_position: Vector2) -> void:
	if GameManager.has_sword:
		return
	if not get_tree().get_nodes_in_group(SWORD_GROUP).is_empty():
		return
	var sword := SWORD_SCENE.instantiate() as Node2D
	sword.add_to_group(SWORD_GROUP)
	var root := get_tree().current_scene
	var container := root.get_node_or_null("Objetos")
	if container == null:
		container = root
	container.add_child.call_deferred(sword)
	sword.global_position = drop_position + Vector2(0, 4)

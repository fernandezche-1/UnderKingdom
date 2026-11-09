extends UnderkingdomEnemyBase

## Carcelero del calabozo: primera pelea con la espada oxidada. Suelta la llave
## de la reja de la salida.

const ENCOUNTER_ID := "calabozo_carcelero_derrotado"
const KEY_ID := "calabozo_salida"
const KEY_SCENE := preload("res://escenas/items/llave_jefe_m1.tscn")

func _ready() -> void:
	super._ready()
	GameManager.start_sword_mission()
	if GameManager.is_encounter_completed(ENCOUNTER_ID):
		_drop_key_if_needed(global_position)
		queue_free()

func _on_enemy_death_finished() -> void:
	GameManager.mark_encounter_completed(ENCOUNTER_ID)
	GameManager.mark_sword_guard_defeated()
	_drop_key_if_needed(global_position)

func _drop_key_if_needed(drop_position: Vector2) -> void:
	if GameManager.has_key(KEY_ID):
		return
	var key := KEY_SCENE.instantiate() as UnderkingdomBossKeyPickup
	key.key_id = KEY_ID
	var root := get_tree().current_scene
	var container := root.get_node_or_null("Objetos")
	if container == null:
		container = root
	container.add_child.call_deferred(key)
	key.global_position = drop_position + Vector2(0, -8)

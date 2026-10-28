extends UnderkingdomEnemyBase

const KEY_ID := "llave_armeria_castillo"
const ENCOUNTER_ID := "castillo_guardia10_derrotado"
const KEY_SCENE := preload("res://escenas/items/llave_armeria_castillo.tscn")

func _ready() -> void:
	super._ready()
	if not died.is_connected(_on_key_guard_died):
		died.connect(_on_key_guard_died)
	if not death_finished.is_connected(_on_key_guard_death_finished):
		death_finished.connect(_on_key_guard_death_finished)
	if GameManager.is_encounter_completed(ENCOUNTER_ID):
		print("[ARMORY_KEY] recovery_on_load guard=%s map=%s key_owned=%s" % [get_path(), get_tree().current_scene.scene_file_path, GameManager.has_key(KEY_ID)])
		_drop_key_if_needed()
		queue_free()

func _on_key_guard_died() -> void:
	print("[ARMORY_KEY] signal=died guard=%s position=%s" % [get_path(), global_position])

func _on_key_guard_death_finished() -> void:
	print("[ARMORY_KEY] signal=death_finished guard=%s position=%s" % [get_path(), global_position])

func _on_enemy_death_finished() -> void:
	print("[ARMORY_KEY] death_finished guard=%s scene=%s map=%s death_position=%s" % [get_path(), scene_file_path, get_tree().current_scene.scene_file_path, global_position])
	GameManager.mark_encounter_completed(ENCOUNTER_ID)
	_drop_key_if_needed()

func _drop_key_if_needed() -> void:
	if GameManager.has_key(KEY_ID):
		print("[ARMORY_KEY] drop_skipped reason=already_collected key_id=%s" % KEY_ID)
		return
	for item in get_tree().get_nodes_in_group("castle_armory_key"):
		if is_instance_valid(item):
			print("[ARMORY_KEY] drop_skipped reason=pickup_exists pickup=%s position=%s" % [item.get_path(), item.global_position])
			return
	var pickup := KEY_SCENE.instantiate() as UnderkingdomBossKeyPickup
	pickup.key_id = KEY_ID
	pickup.add_to_group("castle_armory_key")
	var root := get_tree().current_scene
	var container := root.get_node_or_null("Objetos")
	if container == null:
		container = root
	container.add_child(pickup)
	pickup.set_spawn_global_position(global_position + Vector2(0, 12))
	print("[ARMORY_KEY] spawned pickup=%s key_id=%s position=%s parent=%s map=%s" % [pickup.get_path(), KEY_ID, pickup.global_position, container.get_path(), root.scene_file_path])


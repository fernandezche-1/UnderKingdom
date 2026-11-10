extends StaticBody2D
class_name UnderkingdomCastleKeyDoor

@export var key_id := "llave_armeria_castillo"
@export var interaction_radius := 52.0
@export var locked_message := "La puerta está cerrada. Necesito encontrar la llave"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blocker: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea

var _message: Label
var _message_tween: Tween
var _prompt: Label
var _near_player: Node2D

func _ready() -> void:
	add_to_group("interactable")
	var opened := bool(GameManager.consumed_objects.get(_persistent_door_key(), false))
	blocker.disabled = opened
	sprite.frame = 1 if opened else 0
	interaction_area.collision_mask = 1
	if not interaction_area.body_entered.is_connected(_on_interaction_body_entered):
		interaction_area.body_entered.connect(_on_interaction_body_entered)
	if not interaction_area.body_exited.is_connected(_on_interaction_body_exited):
		interaction_area.body_exited.connect(_on_interaction_body_exited)
	if not GameManager.key_changed.is_connected(_on_key_changed):
		GameManager.key_changed.connect(_on_key_changed)
	_create_prompt()
	_update_prompt()
	print("[ARMORY_DOOR] ready path=%s opened=%s blocker_disabled=%s key_id=%s key_owned=%s area_layer=%d area_mask=%d" % [get_path(), opened, blocker.disabled, key_id, GameManager.has_key(key_id), interaction_area.collision_layer, interaction_area.collision_mask])

func can_interact(player: Node) -> bool:
	var inside_area := is_instance_valid(_near_player) and player == _near_player
	var allowed := inside_area and not blocker.disabled
	if not allowed:
		print("[ARMORY_DOOR] can_interact=false player=%s inside_area=%s blocker_disabled=%s key_id=%s key_owned=%s" % [player.get_path() if is_instance_valid(player) else "<invalid>", inside_area, blocker.disabled, key_id, GameManager.has_key(key_id)])
	return allowed

func interact(player: Node) -> bool:
	if not can_interact(player):
		print("[ARMORY_DOOR] interaction_rejected player=%s reason=outside_area_or_open" % (player.get_path() if is_instance_valid(player) else "<invalid>"))
		return false
	if not GameManager.has_key(key_id):
		print("[ARMORY_DOOR] interaction_locked player=%s required_key=%s" % [player.get_path(), key_id])
		_show_message(locked_message)
		return true
	GameManager.consumed_objects[_persistent_door_key()] = true
	GameManager.request_autosave()
	blocker.set_deferred("disabled", true)
	sprite.frame = 1
	print("[ARMORY_DOOR] opened player=%s key_id=%s blocker_disable_deferred=true save_key=%s" % [player.get_path(), key_id, _persistent_door_key()])
	call_deferred("_log_opened_state")
	_prompt.hide()
	_show_message("Puerta abierta")
	return true

func _log_opened_state() -> void:
	print("[ARMORY_DOOR] open_state_applied blocker_disabled=%s frame=%d saved_open=%s" % [blocker.disabled, sprite.frame, bool(GameManager.consumed_objects.get(_persistent_door_key(), false))])

func _on_interaction_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_near_player = body
	print("[ARMORY_DOOR] area_enter player=%s player_layer=%d area_mask=%d door_open=%s key_id=%s key_owned=%s" % [body.get_path(), body.collision_layer, interaction_area.collision_mask, blocker.disabled, key_id, GameManager.has_key(key_id)])
	_update_prompt()

func _on_interaction_body_exited(body: Node2D) -> void:
	if body != _near_player:
		return
	print("[ARMORY_DOOR] area_exit player=%s" % body.get_path())
	_near_player = null
	_update_prompt()

func _on_key_changed(changed_key_id: String, _has_key: bool) -> void:
	if changed_key_id == key_id:
		_update_prompt()

func _create_prompt() -> void:
	_prompt = Label.new()
	_prompt.name = "InteractionPrompt"
	_prompt.position = Vector2(-64, -54)
	_prompt.size = Vector2(128, 20)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 9)
	_prompt.z_index = 30
	add_child(_prompt)

func _update_prompt() -> void:
	if _prompt == null:
		return
	if not is_instance_valid(_near_player) or blocker.disabled:
		_prompt.hide()
		return
	_prompt.text = "E - Abrir puerta" if GameManager.has_key(key_id) else "E - Necesito una llave"
	_prompt.show()

func _persistent_door_key() -> String:
	return "res://escenas/mapas/tiles_castillo.tscn|PuertaArmeria"

func _show_message(value: String) -> void:
	if _message == null:
		_message = Label.new()
		_message.position = Vector2(-80, -40)
		_message.size = Vector2(160, 24)
		_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_message.add_theme_font_size_override("font_size", 9)
		_message.z_index = 30
		add_child(_message)
	if _message_tween != null:
		_message_tween.kill()
	_message.text = value
	_message.modulate.a = 1.0
	_message.show()
	_message_tween = create_tween()
	_message_tween.tween_interval(1.5)
	_message_tween.tween_property(_message, "modulate:a", 0.0, 0.35)
	_message_tween.tween_callback(_message.hide)

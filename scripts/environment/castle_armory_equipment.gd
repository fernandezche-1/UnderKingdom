extends Area2D
class_name UnderkingdomCastleArmoryEquipment

const PROMPT := "E - PONERSE ARMADURA Y RECUPERAR ESPADA"
const KEY_ID := "llave_armeria_castillo"
const DOOR_STATE_KEY := "res://escenas/mapas/tiles_castillo.tscn|PuertaArmeria"

@onready var prompt: Label = $Prompt

var _near_player: Node = null
var _recovering := false

func _ready() -> void:
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt.text = PROMPT
	prompt.hide()

func _process(_delta: float) -> void:
	var show_prompt := (
		is_instance_valid(_near_player)
		and _equipment_available()
	)
	prompt.visible = show_prompt

func can_interact(player: Node) -> bool:
	return (
		player == _near_player
		and not _recovering
		and _equipment_available()
	)

func _equipment_available() -> bool:
	return (
		GameManager.has_key(KEY_ID)
		and bool(GameManager.consumed_objects.get(DOOR_STATE_KEY, false))
		and not GameManager.castle_equipment_recovered
		and not GameManager.has_sword
	)

func interact(player: Node) -> bool:
	if not can_interact(player):
		return false
	_recovering = true
	var armed_player := player as UnderkingdomPlayer
	if armed_player == null:
		_recovering = false
		return false
	call_deferred("_recover_equipment", armed_player)
	return true

func _recover_equipment(armed_player: UnderkingdomPlayer) -> void:
	if not is_instance_valid(armed_player):
		_recovering = false
		return
	armed_player.set_controls_locked(true)
	var visual := armed_player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if visual != null:
		var glow := armed_player.create_tween()
		glow.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		glow.tween_property(visual, "modulate", Color(1.0, 0.55, 0.18, 0.2), 0.22)
		await glow.finished
	if not is_instance_valid(armed_player):
		_recovering = false
		return
	var recovered := GameManager.recover_castle_equipment(armed_player)
	if visual != null and is_instance_valid(visual):
		var return_glow := armed_player.create_tween()
		return_glow.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		return_glow.tween_property(visual, "modulate", Color.WHITE, 0.28 if recovered else 0.12)
		await return_glow.finished
	if is_instance_valid(armed_player):
		armed_player.set_controls_locked(false)
	_recovering = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near_player = body

func _on_body_exited(body: Node2D) -> void:
	if body == _near_player:
		_near_player = null

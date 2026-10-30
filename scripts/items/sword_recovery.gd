extends Node2D
class_name UnderkingdomSwordRecovery

@export_range(24.0, 96.0, 4.0) var interaction_radius: float = 56.0
@export var notice_title: String = "Espada recuperada"
@export_multiline var notice_text: String = "Mi arma ha vuelto a mis manos... pero mi llama continúa debilitada."

@onready var icon: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt

var _busy: bool = false


func _ready() -> void:
	add_to_group("interactable")
	if GameManager.has_sword or GameManager.is_object_consumed(self):
		queue_free()
		return
	visible = GameManager.sword_mission_started
	prompt.visible = false


func _process(_delta: float) -> void:
	if not visible and GameManager.sword_mission_started:
		visible = true
	if _busy or GameManager.has_sword:
		prompt.visible = false
		return
	var nearby := false
	for player in get_tree().get_nodes_in_group("player"):
		if can_interact(player):
			nearby = true
			break
	prompt.visible = nearby


func can_interact(player: Node) -> bool:
	return (
		not _busy
		and not GameManager.has_sword
		and GameManager.sword_mission_started
		and player is Node2D
		and global_position.distance_to((player as Node2D).global_position) <= interaction_radius
	)


func interact(player: Node) -> bool:
	if not can_interact(player) or not player is UnderkingdomPlayer:
		return false
	_busy = true
	prompt.visible = false
	(player as UnderkingdomPlayer).set_controls_locked(true)
	_recover(player as UnderkingdomPlayer)
	return true


func _recover(player: UnderkingdomPlayer) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(icon, "scale", Vector2(0.0, 1.6), 0.42)
	tween.tween_property(icon, "modulate:a", 0.0, 0.42)
	tween.tween_property(icon, "position:y", icon.position.y - 12.0, 0.42)
	await tween.finished
	if not is_instance_valid(player):
		return
	if not GameManager.recover_sword(player):
		player.set_controls_locked(false)
		_busy = false
		return
	GameManager.mark_object_consumed(self)
	UnderkingdomCombatFX.pickup_sparkle(self)
	var hud := player.get_node_or_null("PlayerHUD")
	if hud != null and hud.has_method("show_story_notice"):
		hud.call("show_story_notice", notice_title, notice_text)
	player.set_controls_locked(false)
	queue_free()

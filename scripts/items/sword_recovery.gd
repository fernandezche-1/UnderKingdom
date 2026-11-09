extends Node2D
class_name UnderkingdomSwordRecovery

@export_range(24.0, 96.0, 4.0) var interaction_radius: float = 56.0
@export var notice_title: String = "Espada recuperada"
@export_multiline var notice_text: String = "Mi arma ha vuelto a mis manos... pero mi llama continúa debilitada."
## Falso si la espada se encuentra en el mapa, sin vencer antes a un guardia.
@export var requires_guard_defeated: bool = true

@onready var icon: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt

var _busy: bool = false


func _ready() -> void:
	add_to_group("interactable")
	if _already_owned() or GameManager.is_object_consumed(self):
		queue_free()
		return
	visible = _is_available()
	prompt.visible = false


func _process(_delta: float) -> void:
	if not visible and _is_available():
		visible = true
	if _busy or _already_owned():
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
		and not _already_owned()
		and _is_available()
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


## Lo que da ya se tiene: el objeto no aparece o deja de poder tomarse.
func _already_owned() -> bool:
	return GameManager.has_sword


## Se ve y se puede tomar (la espada, desde que empieza su misión).
func _is_available() -> bool:
	return GameManager.sword_mission_started


## Da el premio. Devuelve false si no se pudo, y el objeto se queda.
func _grant(player: UnderkingdomPlayer) -> bool:
	return GameManager.recover_sword(player, requires_guard_defeated)


func _recover(player: UnderkingdomPlayer) -> void:
	var start_scale := icon.scale
	var start_y := icon.position.y
	var tween := create_tween().set_parallel(true)
	tween.tween_property(icon, "scale", Vector2(0.0, 1.6), 0.42)
	tween.tween_property(icon, "modulate:a", 0.0, 0.42)
	tween.tween_property(icon, "position:y", icon.position.y - 12.0, 0.42)
	await tween.finished
	if not is_instance_valid(player):
		return
	if not _grant(player):
		player.set_controls_locked(false)
		_busy = false
		icon.scale = start_scale
		icon.modulate.a = 1.0
		icon.position.y = start_y
		return
	GameManager.mark_object_consumed(self)
	UnderkingdomCombatFX.pickup_sparkle(self)
	var hud := player.get_node_or_null("PlayerHUD")
	if hud != null and hud.has_method("show_story_notice"):
		hud.call("show_story_notice", notice_title, notice_text)
	player.set_controls_locked(false)
	queue_free()

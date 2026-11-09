extends Node2D
class_name UnderkingdomMineElevator

## Cabina del ascensor minero (`:C:`, P60). El atajo une dos escenas (el sótano
## del castillo y la estación de las minas), así que hay una cabina en cada una
## y la cabina no recorre el pozo: el jugador entra, pulsa E (la misma acción
## que npc.gd y la palanca), la cabina traquetea `travel_time` segundos, la
## pantalla se funde a negro y el juego cambia de escena al spawn de la cabina
## gemela (`target_spawn_id`). Cada cabina lleva su propio spawn
## (`arrival_spawn_id`), un hijo `Spawn` que este script mantiene en su sitio.
## Con `requires_encounter` la cabina no funciona hasta que GameManager marca
## ese encuentro (la palanca de las minas): dice `no_power_message`.
## El origen es el centro de la base de la cabina. Detalle en
## docs/P60_ASCENSOR_MINERO.md.

signal travel_started
signal blocked

const TILE: float = 16.0
const OVERLAY_LAYER: int = 100
## Los spawns marcan el origen del Player, que está 62 px sobre sus pies.
const SPAWN_HEIGHT: float = 62.0

@export_file("*.tscn") var target_scene_path: String = ""
## Spawn de la cabina gemela, en la escena de destino.
@export var target_spawn_id: StringName = &""
## Id del spawn de ESTA cabina (donde aparece quien llega por el ascensor).
@export var arrival_spawn_id: StringName = &""
## Encuentro que enciende la cabina; vacío = siempre funciona.
@export var requires_encounter: String = ""

@export_category("Cabina")
## Tamaño en piezas de 16 px; el pozo del ascensor mide 3 de ancho.
@export var size_tiles: Vector2i = Vector2i(3, 3)
## Dibujo opcional (a escala 1, del tamaño de la cabina). Sin él se dibuja una
## cabina provisional de madera y hierro.
@export var cabin_texture: Texture2D = null

@export_category("Interaccion")
@export var prompt_text: String = "E  Subir"
@export var no_power_message: String = "NO HAY CORRIENTE"
@export_range(8.0, 160.0, 1.0) var interaction_radius: float = 24.0
@export_range(16.0, 160.0, 1.0) var interaction_vertical_range: float = 72.0

@export_category("Viaje")
## Segundos que traquetea la cabina antes de cambiar de escena.
@export_range(0.2, 3.0, 0.05) var travel_time: float = 1.0
## Parte final de travel_time en la que la pantalla se funde a negro.
@export_range(0.05, 1.0, 0.05) var fade_time: float = 0.4
## Segundos de negro tras el cambio de escena antes de volver a ver.
@export_range(0.0, 1.5, 0.05) var arrival_hold: float = 0.3
@export_range(0.0, 8.0, 1.0) var shake_strength: float = 2.0

var is_traveling: bool = false
var _origin: Vector2 = Vector2.ZERO
var _prompt: Label = null
var _message: Label = null
var _message_tween: Tween = null
var _spawn: UnderkingdomSpawnPoint = null
var _rattle_left: float = 0.0


func _ready() -> void:
	z_index = -1
	_origin = position
	add_to_group("interactable")
	_build_spawn()
	_build_prompt()


func _process(delta: float) -> void:
	if _rattle_left > 0.0:
		_rattle_left -= delta
		# Traqueteo de 1 px, a escala entera.
		position = _origin + Vector2(float(randi_range(-1, 1)), 0.0)
		if _rattle_left <= 0.0:
			position = _origin
	var player := get_tree().get_first_node_in_group("player") as Node2D
	_prompt.visible = not is_traveling and player != null and can_interact(player)


func can_interact(player: Node) -> bool:
	if is_traveling or not (player is Node2D):
		return false
	var to_player := (player as Node2D).global_position - _center_global()
	return absf(to_player.x) <= interaction_radius and absf(to_player.y) <= interaction_vertical_range


func interact(player: Node) -> bool:
	if not can_interact(player):
		return false
	if not has_power():
		_show_message(no_power_message)
		blocked.emit()
		return true
	travel(player)
	return true


func has_power() -> bool:
	return requires_encounter.is_empty() or GameManager.is_encounter_completed(requires_encounter)


## Inicia el viaje. Público para probarlo o accionarlo desde otro script.
func travel(player: Node = null) -> void:
	if is_traveling:
		return
	if target_scene_path.is_empty() or not ResourceLoader.exists(target_scene_path):
		push_error("Ascensor %s: no existe la escena destino '%s'." % [name, target_scene_path])
		return
	is_traveling = true
	_prompt.visible = false
	if player != null and player.has_method("set_controls_locked"):
		player.call("set_controls_locked", true)
	_rattle_left = travel_time
	var camera := get_viewport().get_camera_2d()
	if camera != null and camera.has_method("shake") and shake_strength > 0.0:
		camera.call("shake", shake_strength, travel_time)
	_start_fade()
	travel_started.emit()


func _start_fade() -> void:
	# La capa cuelga de la raíz: sobrevive al cambio de escena y es ella la que
	# se funde de vuelta cuando llega la nueva.
	var layer := CanvasLayer.new()
	layer.layer = OVERLAY_LAYER
	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)
	get_tree().root.add_child(layer)

	var tween := layer.create_tween()
	tween.tween_interval(maxf(travel_time - fade_time, 0.0))
	tween.tween_property(rect, "color:a", 1.0, fade_time)
	tween.tween_callback(_change_scene)
	tween.tween_interval(arrival_hold + 0.2)
	tween.tween_property(rect, "color:a", 0.0, fade_time)
	tween.tween_callback(layer.queue_free)


func _change_scene() -> void:
	GameManager.set_transition(target_spawn_id)
	if GameManager.is_autosave_region(target_scene_path):
		GameManager.request_autosave({
			"scene_path": target_scene_path,
			"spawn_id": String(target_spawn_id),
			"clear_position": true,
		})
	get_tree().call_deferred("change_scene_to_file", target_scene_path)


func _draw() -> void:
	var w: float = float(size_tiles.x) * TILE
	var h: float = float(size_tiles.y) * TILE
	var rect := Rect2(-w * 0.5, -h, w, h)
	if cabin_texture != null:
		draw_texture(cabin_texture, rect.position)
		return
	# Cabina provisional (G4): fondo oscuro, marco de hierro y travesaños.
	draw_rect(rect, Color(0.13, 0.09, 0.07, 0.85))
	var iron := Color(0.36, 0.34, 0.33)
	var wood := Color(0.40, 0.27, 0.16)
	draw_rect(Rect2(rect.position, Vector2(w, 2)), iron)
	draw_rect(Rect2(rect.position + Vector2(0, h - 2), Vector2(w, 2)), iron)
	draw_rect(Rect2(rect.position, Vector2(2, h)), iron)
	draw_rect(Rect2(rect.position + Vector2(w - 2, 0), Vector2(2, h)), iron)
	var x: float = rect.position.x + 8.0
	while x < rect.end.x - 8.0:
		draw_rect(Rect2(Vector2(x, rect.position.y + 2), Vector2(2, h - 4)), wood)
		x += 12.0


func _build_spawn() -> void:
	_spawn = UnderkingdomSpawnPoint.new()
	_spawn.name = "Spawn"
	_spawn.spawn_id = arrival_spawn_id
	_spawn.position = Vector2(0.0, -SPAWN_HEIGHT)
	add_child(_spawn)


func _center_global() -> Vector2:
	return to_global(Vector2(0.0, -float(size_tiles.y) * TILE * 0.5))


func _top_local() -> float:
	return -float(size_tiles.y) * TILE


func _build_prompt() -> void:
	_prompt = _make_label(96.0)
	_prompt.text = prompt_text
	_prompt.position = Vector2(-48.0, _top_local() - 14.0)
	_prompt.visible = false
	add_child(_prompt)


func _show_message(text: String) -> void:
	if text.is_empty():
		return
	if _message == null:
		_message = _make_label(160.0)
		_message.position = Vector2(-80.0, _top_local() - 26.0)
		add_child(_message)
	if _message_tween != null:
		_message_tween.kill()
	_message.text = text
	_message.modulate.a = 1.0
	_message.visible = true
	_message_tween = _message.create_tween()
	_message_tween.tween_interval(1.4)
	_message_tween.tween_property(_message, "modulate:a", 0.0, 0.4)
	_message_tween.tween_callback(_message.hide)


func _make_label(width: float) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(width, 12)
	label.z_index = 30
	return label

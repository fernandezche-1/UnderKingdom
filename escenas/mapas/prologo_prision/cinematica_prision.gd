extends Node2D
## Secuencia de apertura de la Cámara del Sellado del Alma.
## El Player existente representa al prisionero durante el plano y se conserva
## como el Player jugable al final; no se instancia ni duplica otro personaje.

const DIALOGUE_SCENE := preload("res://escenas/ui/dialogue_ui.tscn")
const QUEEN_PORTRAIT := preload("res://Elementals_water_priestess_FREE_v1.1/Elementals_water_priestess_FREE_v1.1/water_priestess.png")
const ONCE_KEY := "underkingdom_camara_sellado_alma_completada"

@onready var prisoner_marker: Marker2D = $MarcadoresCinematica/ProtagonistaEncadenado
@onready var player_transition_marker: Marker2D = $MarcadoresCinematica/PlayerTransicion
@onready var exit_transition: UnderkingdomMapTransition = $SalidaPrision
@onready var queen_marker: Marker2D = $MarcadoresCinematica/ReinaDelAgua
@onready var exit_marker: Marker2D = $MarcadoresCinematica/SalidaPrision
@onready var ritual_marker: Marker2D = $MarcadoresCinematica/CentroCirculoRitual
@onready var dialogue_frame: Marker2D = $EncuadresCamara/PlanoDialogo
@onready var ritual_frame: Marker2D = $EncuadresCamara/PlanoRitual
@onready var cinematic_camera: Camera2D = $Camera2D
@onready var wall_tiles: TileMapLayer = $MuroFondo
@onready var floor_tiles: TileMapLayer = $Terreno
@onready var prisoner_shell: Node2D = $CharacterBody2D
@onready var prisoner: UnderkingdomPlayer = $CharacterBody2D/player
@onready var queen: CharacterBody2D = $CharacterBody2D2
@onready var ritual: Node2D = $CirculoRitual
@onready var ring_one: Line2D = $CirculoRitual/Anillo1
@onready var ring_two: Line2D = $CirculoRitual/Anillo2
@onready var ring_three: Line2D = $CirculoRitual/Anillo3

var _dialogue: UnderkingdomDialogueUI
var _queen_sprite: AnimatedSprite2D
var _player_camera: Camera2D
var _cinematic_actor: AnimatedSprite2D
var _queen_approached: bool = false

const LINES := [
	{"speaker_id":"player", "name":"GUERRERO", "text":"¿Por qué haces esto? Le serví a este reino. Juré proteger a su rey."},
	{"speaker_id":"friend", "name":"REINA", "text":"Y, sin embargo, aquí estás. Arrodillado ante mí."},
	{"speaker_id":"player", "name":"GUERRERO", "text":"El rey jamás habría permitido esto."},
	{"speaker_id":"friend", "name":"REINA", "text":"Mi esposo está muerto. Sus decisiones ya no tienen importancia."},
	{"speaker_id":"player", "name":"GUERRERO", "text":"¿Qué ocurrió realmente aquella noche?"},
	{"speaker_id":"friend", "name":"REINA", "text":"Ocurrió una desgracia. Eso es todo lo que el pueblo necesita saber."},
	{"speaker_id":"player", "name":"GUERRERO", "text":"No puedes ocultar la verdad para siempre."},
	{"speaker_id":"friend", "name":"REINA", "text":"No necesito ocultarla eternamente. Solo necesito que nadie crea tus palabras."},
	{"speaker_id":"player", "name":"GUERRERO", "text":"¿Con qué derecho condenas a un hombre que ha servido fielmente a este reino?"},
	{"speaker_id":"friend", "name":"REINA", "text":"¿Con qué derecho?"},
	{"speaker_id":"friend", "name":"REINA", "text":"Porque soy la reina.", "pause_before":0.4},
	{"speaker_id":"player", "name":"GUERRERO", "text":"Una corona no te convierte en alguien superior."},
	{"speaker_id":"friend", "name":"REINA", "text":"Mi pueblo me ama, me respeta y me obedece."},
	{"speaker_id":"player", "name":"GUERRERO", "text":"Tu pueblo no conoce tu verdadero rostro."},
	{"speaker_id":"friend", "name":"REINA", "text":"Mi pueblo conoce exactamente lo que yo permito que conozca."},
	{"speaker_id":"friend", "name":"REINA", "text":"El reino jamás te recordará como un héroe."},
	{"speaker_id":"friend", "name":"REINA", "text":"Para ellos, solo serás un traidor."},
	{"speaker_id":"friend", "name":"REINA", "text":"Y la verdad morirá contigo."}
]


func _ready() -> void:
	_build_lower_corridor()
	if not _resolve_nodes():
		return
	if get_tree().get_meta(ONCE_KEY, false) or GameManager.has_seen_cinematic(GameManager.PRISON_CINEMATIC_ID):
		_restore_completed_scene()
		var saved_state := GameManager.consume_pending_save_restore(get_tree().current_scene.scene_file_path)
		if not saved_state.is_empty():
			GameManager.restore_saved_player(prisoner, saved_state, true)
		return
	var pending_state := GameManager.consume_pending_save_restore(get_tree().current_scene.scene_file_path)
	if not pending_state.is_empty():
		GameManager.restore_saved_player(prisoner, pending_state, false)
	_prepare_scene()
	call_deferred("_run_cinematic")


func _run_cinematic() -> void:
	await get_tree().create_timer(0.9).timeout
	if not is_inside_tree(): return
	await _queen_walk_to_cell()
	await _move_camera(dialogue_frame.global_position, 0.8)
	_dialogue = DIALOGUE_SCENE.instantiate() as UnderkingdomDialogueUI
	add_child(_dialogue)
	_dialogue.configure_prison_cinematic()
	_dialogue.line_shown.connect(_on_line_shown)
	_dialogue.start_dialogue(LINES, {"friend": QUEEN_PORTRAIT})
	await _dialogue.dialogue_finished
	if not is_inside_tree(): return
	await _queen_departure()
	await get_tree().create_timer(0.8).timeout
	await _play_inner_monologue()
	await _ritual_sequence()
	await _chain_break_sequence()
	_transition_to_player()


func _play_inner_monologue() -> void:
	_dialogue.start_dialogue([
		{"speaker_id":"player", "name":"PLAYER (PENSAMIENTO)", "text":"«El rey ha muerto... y ahora solo me espera la muerte en este lugar.»"},
		{"speaker_id":"player", "name":"PLAYER (PENSAMIENTO)", "text":"«Aquella batalla contra los guerreros de la Reina... apenas puedo recordar cómo terminó.»"},
		{"speaker_id":"player", "name":"PLAYER (PENSAMIENTO)", "text":"«La Reina fragmentó mi alma. Puedo sentirlo... mi fuerza, mi energía, todo lo que alguna vez fui...»"},
		{"speaker_id":"player", "name":"PLAYER (PENSAMIENTO)", "text":"«Apenas puedo mantenerme en pie. Incluso invocar la Llama Ancestral parece imposible.»"},
		{"speaker_id":"player", "name":"PLAYER (PENSAMIENTO)", "text":"«Pero aún queda una chispa dentro de mí.»"},
		{"speaker_id":"player", "name":"PLAYER (PENSAMIENTO)", "text":"«No moriré encadenado en este reino podrido. Tengo que escapar... cueste lo que cueste.»"}
	])
	await _dialogue.dialogue_finished


func _resolve_nodes() -> bool:
	_queen_sprite = queen.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	_player_camera = prisoner.get_node_or_null("Camera2D") as Camera2D
	if _queen_sprite == null or _player_camera == null:
		push_error("Cinemática de prisión: faltan la animación de la reina o la cámara del Player.")
		return false
	return true


func _prepare_scene() -> void:
	# Congelar la física completa evita gravedad, ataques, temporizadores de combate
	# y cualquier respuesta de movimiento mientras el actor está encadenado.
	_cinematic_actor = prisoner_shell.get_node("AnimatedSprite2D") as AnimatedSprite2D
	var default_frame := _cinematic_actor.sprite_frames.get_frame_texture(&"default", 0)
	var scaled_frame_height := default_frame.get_height() * absf(_cinematic_actor.scale.y)
	var scaled_sprite_offset_y := _cinematic_actor.offset.y * absf(_cinematic_actor.scale.y)
	var actor_ground_offset := _cinematic_actor.position.y + scaled_sprite_offset_y + scaled_frame_height * 0.5
	prisoner_shell.global_position = Vector2(
		prisoner_marker.global_position.x - _cinematic_actor.position.x,
		prisoner_marker.global_position.y - actor_ground_offset
	)
	prisoner.global_position = _player_position_at_marker(player_transition_marker)
	prisoner.velocity = Vector2.ZERO
	prisoner.controls_locked = true
	prisoner.cinematic_invulnerable = true
	prisoner.set_physics_process(false)
	_cinematic_actor.play(&"default")
	prisoner.visible = false
	var player_hud := prisoner.get_node("PlayerHUD") as CanvasLayer
	var debug_hud := prisoner.get_node("DebugHUD") as CanvasLayer
	player_hud.visible = false
	debug_hud.visible = false
	_player_camera.enabled = false
	cinematic_camera.enabled = true
	cinematic_camera.make_current()
	queen.set_physics_process(false)
	queen.global_position = queen_marker.global_position + Vector2(100.0, 0.0)
	if _queen_sprite.sprite_frames.has_animation(&"idle"):
		_queen_sprite.play(&"idle")
	else:
		_queen_sprite.stop()
	ring_one.modulate.a = 0.35
	ring_two.modulate.a = 0.30
	ring_three.modulate.a = 0.25


func _ritual_sequence() -> void:
	await _move_camera(ritual_frame.global_position, 0.7)
	if _cinematic_actor.sprite_frames.has_animation(&"new_animation_1"):
		_align_cinematic_actor_to_floor(&"new_animation_1")
		_cinematic_actor.play(&"new_animation_1")
	var glow := create_tween().set_parallel(true)
	glow.tween_property(ring_one, "modulate", Color(1.0, 0.18, 0.14, 1.0), 0.7)
	glow.tween_property(ring_two, "modulate", Color(0.95, 0.25, 0.18, 0.9), 0.7)
	glow.tween_property(ring_three, "modulate", Color(1.0, 0.4, 0.26, 0.85), 0.7)
	glow.tween_property(ritual, "rotation", TAU, 4.0)
	await get_tree().create_timer(2.0).timeout
	await _move_camera(dialogue_frame.global_position, 1.0)


func _on_line_shown(line: Dictionary) -> void:
	if _queen_approached or String(line.get("text", "")) != "Porque soy la reina.":
		return
	_queen_approached = true
	_queen_sprite.flip_h = true
	var approach := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	approach.tween_property(queen, "global_position:x", prisoner.global_position.x + 48.0, 1.0)


func _queen_departure() -> void:
	_dialogue.start_dialogue([
		{"speaker_id":"friend", "name":"REINA", "text":"Ahora no eres más que las cenizas de lo que alguna vez fuiste."},
		{"speaker_id":"friend", "name":"REINA", "text":"Disfruta tu eternidad, traidor."}
	], {"friend": QUEEN_PORTRAIT})
	await _dialogue.dialogue_finished
	_queen_sprite.flip_h = exit_marker.global_position.x < queen.global_position.x
	if _queen_sprite.sprite_frames.has_animation(&"run"):
		_queen_sprite.play(&"run")
	var departure := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	departure.tween_property(queen, "global_position", exit_marker.global_position, 3.0)
	departure.parallel().tween_property(queen, "modulate:a", 0.0, 1.2).set_delay(1.8)
	await departure.finished
	queen.visible = false


func _chain_break_sequence() -> void:
	# Reproduce las animaciones incluidas en el SpriteFrames de prision.tscn.
	await _play_prison_animation(&"new_animation_2", 1.7)
	await _play_prison_animation(&"new_animation_3", 2.5)
	prisoner_shell.visible = false
	await get_tree().create_timer(0.25).timeout


func _transition_to_player() -> void:
	if not is_instance_valid(prisoner): return
	# El actor encadenado se oculta y el Player original ocupa su marcador de suelo.
	prisoner_shell.visible = false
	prisoner.reparent(self, true)
	prisoner.global_position = _player_position_at_marker(player_transition_marker)
	prisoner.velocity = Vector2.ZERO
	prisoner.sprite.flip_h = false
	if is_instance_valid(_cinematic_actor):
		_cinematic_actor.visible = false
		_cinematic_actor.queue_free()
	prisoner.visible = true
	prisoner.controls_locked = false
	prisoner.cinematic_invulnerable = false
	prisoner.set_physics_process(true)
	prisoner.sprite.play(&"idle")
	exit_transition.enabled = true
	var player_hud := prisoner.get_node("PlayerHUD") as CanvasLayer
	var debug_hud := prisoner.get_node("DebugHUD") as CanvasLayer
	player_hud.visible = true
	debug_hud.visible = prisoner.show_debug_hud
	_player_camera.enabled = true
	_player_camera.global_position = cinematic_camera.global_position
	_player_camera.zoom = cinematic_camera.zoom
	_player_camera.limit_left = cinematic_camera.limit_left
	_player_camera.limit_top = cinematic_camera.limit_top
	_player_camera.limit_right = cinematic_camera.limit_right
	_player_camera.limit_bottom = cinematic_camera.limit_bottom
	_player_camera.reset_smoothing()
	_player_camera.make_current()
	var camera_follow := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_follow.tween_property(_player_camera, "position", Vector2(0.0, 16.0), 0.9)
	get_tree().set_meta(ONCE_KEY, true)
	GameManager.mark_cinematic_seen(GameManager.PRISON_CINEMATIC_ID)
	GameManager.request_autosave({"scene_path": GameManager.PRISON_SCENE_PATH, "spawn_id": "PrisonStart", "position": prisoner.global_position})
	if is_instance_valid(_dialogue):
		_dialogue.queue_free()


func _restore_completed_scene() -> void:
	prisoner.reparent(self, true)
	prisoner.global_position = _player_position_at_marker(player_transition_marker)
	prisoner.visible = false
	prisoner_shell.visible = false
	prisoner.controls_locked = false
	prisoner.cinematic_invulnerable = false
	prisoner.set_physics_process(true)
	prisoner.visible = true
	exit_transition.enabled = true
	queen.visible = false
	cinematic_camera.enabled = false
	_player_camera.enabled = true
	_player_camera.make_current()
	(prisoner.get_node("PlayerHUD") as CanvasLayer).visible = true


func _queen_walk_to_cell() -> void:
	# Camina desde el extremo del pasillo hasta el marcador frente a los barrotes.
	queen.global_position = queen_marker.global_position + Vector2(100.0, 0.0)
	_queen_sprite.flip_h = true
	if _queen_sprite.sprite_frames.has_animation(&"run"):
		_queen_sprite.play(&"run")
	var walk := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	walk.tween_property(queen, "global_position", queen_marker.global_position, 1.8)
	await walk.finished
	if _queen_sprite.sprite_frames.has_animation(&"idle"):
		_queen_sprite.play(&"idle")


func _build_lower_corridor() -> void:
	# La fuente 0 del TileSet es piedra y la fuente 1 contiene el piso existente.
	# La extension hacia el este conecta el corredor con la puerta de salida.
	for x in range(20, 63):
		for y in range(22, 30):
			floor_tiles.set_cell(Vector2i(x, y), 1, Vector2i(8, 1))
	for y in range(16, 22):
		wall_tiles.set_cell(Vector2i(20, y), 0, Vector2i(9, 1))
		if y < 18:
			wall_tiles.set_cell(Vector2i(44, y), 0, Vector2i(9, 1))
		else:
			wall_tiles.erase_cell(Vector2i(44, y))


func _queen_portrait() -> Texture2D:
	return QUEEN_PORTRAIT


func _player_position_at_marker(marker: Marker2D) -> Vector2:
	var player_collider := prisoner.get_node("CollisionShape2D") as CollisionShape2D
	var collider_shape := player_collider.shape as RectangleShape2D
	var feet_offset := player_collider.position.y + collider_shape.size.y * 0.5
	return Vector2(
		marker.global_position.x,
		marker.global_position.y - feet_offset
	)


func _align_cinematic_actor_to_floor(animation_name: StringName) -> void:
	var reference_frame := _cinematic_actor.sprite_frames.get_frame_texture(&"default", 0)
	var animation_frame := _cinematic_actor.sprite_frames.get_frame_texture(animation_name, 0)
	_cinematic_actor.offset.y = (reference_frame.get_height() - animation_frame.get_height()) * 0.5


func _play_prison_animation(animation_name: StringName, fallback_seconds: float) -> void:
	if not _cinematic_actor.sprite_frames.has_animation(animation_name):
		await get_tree().create_timer(fallback_seconds).timeout
		return
	_align_cinematic_actor_to_floor(animation_name)
	_cinematic_actor.play(animation_name)
	var frame_count := _cinematic_actor.sprite_frames.get_frame_count(animation_name)
	var fps := _cinematic_actor.sprite_frames.get_animation_speed(animation_name)
	var duration := fallback_seconds if fps <= 0.0 else float(frame_count) / fps
	await get_tree().create_timer(duration).timeout


func _move_camera(target: Vector2, duration: float) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cinematic_camera, "global_position", target, duration)
	await tween.finished

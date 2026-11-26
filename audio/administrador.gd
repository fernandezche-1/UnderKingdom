extends Node
## Mezcla del juego. Los efectos confirmados por el gameplay llegan como eventos.

signal evento_reproducido(evento: StringName, bus: StringName)

const Catalogo := preload("res://audio/catalogo.gd")
const BUSES := {
	&"Master": ["General", 0.86], &"Musica": ["Música", 0.72], &"Efectos": ["Efectos", 0.84],
	&"Ambiente": ["Ambiente", 0.74], &"Dialogos": ["Diálogos", 0.88], &"Interfaz": ["Interfaz", 0.73],
}
const SETTINGS := "user://audio.cfg"
const POSITIONAL_LIMIT := 24
const UI_LIMIT := 5
const HEARING_DISTANCE := 760.0
const SILENCE := -80.0
const FADE := 1.15
const LOCAL_PLAYERS := &"audio_local_juego"

var _settings := ConfigFile.new()
var _settings_timer: Timer
var _dirty := false
var _closing := false
var _samples: Dictionary = {}
var _positional: Array[AudioStreamPlayer2D] = []
var _ui: Array[AudioStreamPlayer] = []
var _last: Dictionary = {}
var _last_cleanup := 0
var _rng := RandomNumberGenerator.new()
var _score: Array[AudioStreamPlayer] = []
var _ambience: Array[AudioStreamPlayer] = []
var _mix_tweens: Dictionary = {}
var _requested_tracks: Dictionary = {}
var _zone := ""
var _encounters: Dictionary = {}
var _preview: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_settings.load(SETTINGS)
	for bus: StringName in BUSES:
		_apply_volume(bus, get_volume(bus))
	_settings_timer = Timer.new()
	_settings_timer.one_shot = true
	_settings_timer.ignore_time_scale = true
	_settings_timer.timeout.connect(flush_settings)
	add_child(_settings_timer)
	for i in 2:
		_score.append(_new_player(&"Musica"))
		_ambience.append(_new_player(&"Ambiente"))
	get_tree().node_added.connect(_register_control)
	get_tree().scene_changed.connect(_scene_audio_changed)
	_scene_audio_changed.call_deferred()


func _exit_tree() -> void:
	flush_settings()
	_stop_players()


## Da tiempo al mezclador nativo a retirar las reproducciones antes del cierre.
func quit_game(exit_code: int = 0) -> void:
	if _closing:
		return
	_closing = true
	get_tree().paused = true
	flush_settings()
	_stop_players()
	for player in get_tree().get_nodes_in_group(LOCAL_PLAYERS):
		_release_player(player)
	await get_tree().create_timer(0.12, true, false, true).timeout
	get_tree().quit(exit_code)


func _stop_players() -> void:
	for tween: Tween in _mix_tweens.values():
		if tween.is_valid():
			tween.kill()
	for collection: Array in [_score, _ambience, _ui, _positional]:
		for player in collection:
			_release_player(player)
	_release_player(_preview)
	_samples.clear()


func _release_player(player: Node) -> void:
	if is_instance_valid(player):
		player.stop()
		player.stream = null


func get_volume(bus: StringName) -> float:
	var fallback := float(BUSES.get(bus, ["", 1.0])[1])
	var value: Variant = _settings.get_value("volumen", String(bus), fallback)
	if (value is float or value is int) and is_finite(float(value)):
		return clampf(float(value), 0.0, 1.0)
	return fallback


func set_volume(bus: StringName, value: float) -> void:
	if not BUSES.has(bus) or not is_finite(value):
		return
	value = clampf(value, 0.0, 1.0)
	if is_equal_approx(get_volume(bus), value):
		return
	_settings.set_value("volumen", String(bus), value)
	_apply_volume(bus, value)
	_dirty = true
	_settings_timer.start(0.22)


func flush_settings() -> void:
	if not _dirty:
		return
	var result := _settings.save(SETTINGS)
	if result == OK:
		_dirty = false
	else:
		push_warning("Audio: no se guardó la configuración (%s)." % error_string(result))


func _apply_volume(bus: StringName, value: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index >= 0:
		AudioServer.set_bus_mute(index, is_zero_approx(value))
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))


func _sample(folder: String, event: StringName, looped: bool = false) -> AudioStream:
	var path := "res://audio/%s/%s.wav" % [folder, event]
	if folder == "interfaz" and event == &"interruptor":
		path = "res://audio/terceros/brackeys/tap.wav"
	if not _samples.has(path):
		var sample := load(path) as AudioStreamWAV
		if sample != null and looped:
			sample.loop_mode = AudioStreamWAV.LOOP_FORWARD
			sample.loop_begin = 0
			sample.loop_end = roundi(sample.get_length() * sample.mix_rate)
		_samples[path] = sample
	return _samples[path] as AudioStream


func _new_player(bus: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus
	add_child(player)
	return player


func _accept(event: StringName, source: int, interval: float) -> bool:
	var now := Time.get_ticks_msec()
	if now - _last_cleanup > 3000:
		_last_cleanup = now
		for key: String in _last.keys():
			if now - int(_last[key]) > 3000:
				_last.erase(key)
	var id := "%s:%s" % [source, event]
	if now - int(_last.get(id, -3000)) < roundi(interval * 1000.0):
		return false
	_last[id] = now
	return true


func _audible(bus: StringName) -> bool:
	return not _closing and get_volume(&"Master") > 0.0 and get_volume(bus) > 0.0


func play_at(event: StringName, point: Vector2, source: int = 0,
		pitch: float = 1.0, volume: float = -9.0, interval: float = 0.065) -> void:
	if not _audible(&"Efectos"):
		return
	var camera := get_viewport().get_camera_2d()
	if camera != null and camera.get_screen_center_position().distance_squared_to(point) > HEARING_DISTANCE * HEARING_DISTANCE:
		return
	if not _accept(event, source, interval):
		return
	var player: AudioStreamPlayer2D
	for candidate: AudioStreamPlayer2D in _positional:
		if not candidate.playing:
			player = candidate
			break
	if player == null:
		if _positional.size() >= POSITIONAL_LIMIT:
			return
		player = AudioStreamPlayer2D.new()
		player.bus = &"Efectos"
		player.max_distance = HEARING_DISTANCE
		player.attenuation = 1.45
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(player)
		_positional.append(player)
	player.global_position = point
	player.stream = _sample("efectos", event)
	if player.stream == null:
		return
	player.pitch_scale = pitch * _rng.randf_range(0.94, 1.06)
	player.volume_db = volume
	player.play()
	evento_reproducido.emit(event, &"Efectos")


func for_actor(event: StringName, actor: Node2D, pitch: float = 1.0,
		volume: float = -9.0, interval: float = 0.065) -> void:
	var current := get_tree().current_scene
	if is_instance_valid(current) and (current == actor or current.is_ancestor_of(actor)):
		play_at(event, actor.global_position, actor.get_instance_id(), pitch, volume, interval)


func enemy_event(action: String, actor: Node2D) -> void:
	var profile := Catalogo.enemy_profile(actor.scene_file_path)
	var pitch := float(profile[1])
	var interval := 0.125 if action == "dano" else 0.052
	for_actor(StringName("enemigos/%s_%s" % [profile[0], action]), actor, pitch, -12.0, interval)


func effect_loop(actor: Node2D, event: StringName) -> AudioStreamPlayer2D:
	var player := AudioStreamPlayer2D.new()
	player.bus = &"Efectos"
	player.max_distance = HEARING_DISTANCE
	player.volume_db = -17.0
	player.stream = _sample("efectos", event, true)
	player.add_to_group(LOCAL_PLAYERS)
	actor.add_child(player)
	return player


func interface_event(event: StringName) -> void:
	if not _audible(&"Interfaz") or not _accept(event, 0, 0.075):
		return
	var player: AudioStreamPlayer
	for candidate: AudioStreamPlayer in _ui:
		if not candidate.playing:
			player = candidate
			break
	if player == null:
		if _ui.size() >= UI_LIMIT:
			return
		player = _new_player(&"Interfaz")
		_ui.append(player)
	player.stream = _sample("interfaz", event)
	if player.stream == null:
		return
	player.volume_db = -11.0
	player.play()
	evento_reproducido.emit(event, &"Interfaz")


func preview(bus: StringName) -> void:
	if not _audible(bus) or not _accept(&"muestra", 0, 0.12):
		return
	if bus in [&"Master", &"Interfaz", &"Musica", &"Ambiente"]:
		interface_event(&"ajuste")
		return
	if _preview == null:
		_preview = _new_player(bus)
	_preview.stop()
	_preview.bus = bus
	_preview.stream = _sample("dialogos", &"clara") if bus == &"Dialogos" else _sample("efectos", &"paso")
	_preview.volume_db = -11.0
	_preview.play()


func vocalize(player: AudioStreamPlayer, profile: Array, letter: String) -> void:
	if not _audible(&"Dialogos"):
		return
	player.stream = _sample("dialogos", StringName(profile[0]))
	player.pitch_scale = float(profile[1]) * (0.91 + float(posmod(letter.unicode_at(0), 11)) * 0.018)
	player.volume_db = -13.0
	player.play()
	evento_reproducido.emit(&"vocalizacion", &"Dialogos")


func _register_control(node: Node) -> void:
	var button := node as BaseButton
	if button != null:
		button.pressed.connect(_control_pressed.bind(button))
	var control := node as Control
	if control != null and (button != null or control is HSlider):
		control.focus_entered.connect(interface_event.bind(&"seleccion"))


func _control_pressed(button: BaseButton) -> void:
	if button.name == &"Reanudar":
		return # PauseMenu emite el mismo aviso para botón, mando y teclado.
	if button is CheckButton or button is CheckBox:
		interface_event(&"interruptor")
		return
	var cancel := button.name in [&"Volver", &"Cancelar", &"Salir", &"MenuPrincipal"]
	interface_event(&"cancelar" if cancel else &"confirmar")


func encounter_started(owner: Node, track: String) -> void:
	var id := owner.get_instance_id()
	if _encounters.has(id):
		return
	_encounters[id] = track
	if not owner.tree_exiting.is_connected(_finish_encounter.bind(id)):
		owner.tree_exiting.connect(_finish_encounter.bind(id), CONNECT_ONE_SHOT)
	_refresh_music()


func encounter_finished(owner: Node) -> void:
	_finish_encounter(owner.get_instance_id())


func _finish_encounter(id: int) -> void:
	if _encounters.erase(id):
		# Al salir de la escena, scene_changed ya elige la pista de destino.
		var scene := get_tree().current_scene
		if is_instance_valid(scene) and scene.is_inside_tree() and not scene.is_queued_for_deletion():
			_refresh_music()


func _scene_audio_changed() -> void:
	var scene := get_tree().current_scene
	if not is_instance_valid(scene):
		return
	_last.clear()
	_encounters.clear()
	for player: AudioStreamPlayer2D in _positional:
		player.stop()
	_zone = Catalogo.zone(scene.scene_file_path)
	_refresh_music()
	var ambient_track := "" if _zone in ["menu", "introduccion"] else _zone
	_crossfade(_ambience, "ambiente", ambient_track, -13.5)


func _refresh_music() -> void:
	if _closing:
		return
	var track := _zone
	if "jefe_abismo" in _encounters.values():
		track = "jefe_abismo"
	elif "jefe" in _encounters.values():
		track = "jefe"
	elif "arena" in _encounters.values():
		track = "arena"
	var level := -21.0 if track == "introduccion" else -11.0
	_crossfade(_score, "musica", track, level)


func _crossfade(pair: Array[AudioStreamPlayer], folder: String, track: String, level: float) -> void:
	if String(_requested_tracks.get(folder, "")) == track:
		return
	_requested_tracks[folder] = track
	var previous: Tween = _mix_tweens.get(folder)
	if previous != null and previous.is_valid():
		previous.kill()
	var stream: AudioStream = null if track.is_empty() else _sample(folder, StringName(track), true)
	var incoming: AudioStreamPlayer
	if stream != null:
		for player: AudioStreamPlayer in pair:
			if player.playing and player.stream == stream:
				incoming = player
				break
		if incoming == null:
			for player: AudioStreamPlayer in pair:
				if not player.playing:
					incoming = player
					break
			if incoming == null:
				incoming = pair[0] if pair[0].volume_db <= pair[1].volume_db else pair[1]
			incoming.stop()
			incoming.stream = stream
			incoming.volume_db = SILENCE
			incoming.play()
	var tween := create_tween().set_parallel(true).set_ignore_time_scale(true)
	_mix_tweens[folder] = tween
	for player: AudioStreamPlayer in pair:
		var end := level if player == incoming else SILENCE
		tween.tween_method(_blend_volume.bind(player), db_to_linear(player.volume_db), db_to_linear(end), FADE)
		if player != incoming:
			tween.tween_callback(player.stop).set_delay(FADE)


func _blend_volume(gain: float, player: AudioStreamPlayer) -> void:
	player.volume_db = linear_to_db(maxf(gain, 0.0001))

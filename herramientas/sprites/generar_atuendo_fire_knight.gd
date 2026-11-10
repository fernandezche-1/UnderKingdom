extends Node
## Genera escenas/atuendos/fire_knight.tres, el SpriteFrames del atuendo E5
## (P68), con los PNG sueltos del paquete Fire Knight (288x128 por cuadro, a
## escala 1: miden lo mismo en pantalla que las hojas IA de los harapos a 1/3).
##
## Uso, desde la raíz del proyecto:
##   godot --headless res://herramientas/sprites/generar_atuendo_fire_knight.tscn
## (escena y no "-s": player.tscn usa los autoloads, que "-s" no carga).
##
## Reglas:
## - Los tajos con perfil por cuadro en ATTACK_PROFILES de player.gd ("attack",
##   "attack 2", "air attack") llevan los mismos cuadros y velocidad que los
##   harapos: se eligen cuadros del paquete para que el golpe caiga en el cuadro
##   del perfil.
## - El resto lleva todos los cuadros del paquete, con la velocidad ajustada
##   para durar lo mismo que en los harapos (las acciones esperan su duración).
## - "roll", "defende", "defese idle 3 golpes", "attack ultimate" y "jump" ya
##   eran del Fire Knight en player.tscn: se copian tal cual.
## - "escaleras" no existe en el paquete: el Player la toma de los harapos.

const FK_DIR := "res://assets/terceros/Elementals_fire_knight_FREE_v1.1/png/fire_knight/"
const OUTPUT_PATH := "res://escenas/atuendos/fire_knight.tres"
const PLAYER_SCENE := "res://escenas/player.tscn"
const COPIED_ANIMATIONS: Array[StringName] = [
	&"roll", &"defende", &"defese idle 3 golpes", &"attack ultimate", &"jump",
]
## animación -> [carpeta, prefijo, cuadros (1 = el primero) o [] para todos]
const PICKED_ANIMATIONS: Dictionary = {
	&"idle": ["01_idle", "idle", []],
	&"run": ["02_run", "run", []],
	&"jump up": ["03_jump_up", "jump_up", []],
	&"jump down": ["03_jump_down", "jump_down", []],
	&"attack": ["05_1_atk", "1_atk", [4, 5, 8]],
	&"attack 2": ["06_2_atk", "2_atk", [10, 13, 15]],
	&"air attack": ["air_atk", "air_atk", [3, 4, 5, 7, 8]],
	&"take hit": ["10_take_hit", "take_hit", []],
	&"death": ["11_death", "death", []],
}


func _ready() -> void:
	var player_scene := load(PLAYER_SCENE) as PackedScene
	var reference := _reference_frames(player_scene.get_state())
	if reference == null:
		push_error("No se encontró el SpriteFrames de los harapos en player.tscn.")
		get_tree().quit(1)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation: StringName in COPIED_ANIMATIONS:
		_copy_animation(reference, frames, animation)
	for animation: StringName in PICKED_ANIMATIONS:
		_build_animation(reference, frames, animation, PICKED_ANIMATIONS[animation])
	# Escala de dibujo por animación (la lee el Player); todas a 1.
	frames.set_meta(&"animation_scales", {})
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir()))
	var error := ResourceSaver.save(frames, OUTPUT_PATH)
	print("fire_knight.tres: ", error_string(error), " (", frames.get_animation_names().size(), " animaciones)")
	get_tree().quit(0 if error == OK else 1)


## Lee el recurso sin instanciar player.tscn.
func _reference_frames(state: SceneState) -> SpriteFrames:
	for node_index in state.get_node_count():
		if state.get_node_name(node_index) != &"AnimatedSprite2D":
			continue
		for property_index in state.get_node_property_count(node_index):
			if state.get_node_property_name(node_index, property_index) == &"sprite_frames":
				return state.get_node_property_value(node_index, property_index) as SpriteFrames
	return null


func _copy_animation(source: SpriteFrames, target: SpriteFrames, animation: StringName) -> void:
	target.add_animation(animation)
	target.set_animation_speed(animation, source.get_animation_speed(animation))
	target.set_animation_loop(animation, source.get_animation_loop(animation))
	for index in source.get_frame_count(animation):
		target.add_frame(animation, source.get_frame_texture(animation, index), source.get_frame_duration(animation, index))


func _build_animation(reference: SpriteFrames, target: SpriteFrames, animation: StringName, spec: Array) -> void:
	var folder := String(spec[0])
	var prefix := String(spec[1])
	var picked: Array = spec[2]
	var indices: Array[int] = []
	if picked.is_empty():
		var index := 1
		while ResourceLoader.exists("%s%s/%s_%d.png" % [FK_DIR, folder, prefix, index]):
			indices.append(index)
			index += 1
	else:
		for value: Variant in picked:
			indices.append(int(value))
	var reference_count := reference.get_frame_count(animation)
	var reference_speed := reference.get_animation_speed(animation)
	var reference_duration := 0.0
	for index in reference_count:
		reference_duration += reference.get_frame_duration(animation, index) / reference_speed
	target.add_animation(animation)
	target.set_animation_loop(animation, reference.get_animation_loop(animation))
	# Misma duración total que los harapos.
	target.set_animation_speed(animation, snappedf(float(indices.size()) / reference_duration, 0.001))
	for index: int in indices:
		var texture := load("%s%s/%s_%d.png" % [FK_DIR, folder, prefix, index]) as Texture2D
		target.add_frame(animation, texture)

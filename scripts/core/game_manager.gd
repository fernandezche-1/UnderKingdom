extends Node
class_name UnderkingdomGameManager

## Estado global mínimo. Continúa siendo deliberadamente pequeño, pero ahora
## conserva el progreso obligatorio del primer jefe de Mundo 1.

signal world1_boss_defeated_changed(defeated: bool)
signal world1_boss_key_changed(has_key: bool)
signal coins_changed(coins: int)
signal potions_changed(potions: int)
signal cthulhu_revealed_changed(revealed: bool)
signal w2_knight_defeated_changed(defeated: bool)
signal cinematic_seen(cinematic_id: String)
signal encounter_completed(encounter_id: String)
signal key_changed(key_id: String, has_key: bool)
signal upgrades_changed
signal ability_unlocked(ability_id: String)
signal player_name_changed(player_name: String)
signal save_slots_changed
signal sword_mission_changed(started: bool, completed: bool)
signal sword_equipment_changed(has_sword: bool)

var pending_spawn_id: StringName = &""
var previous_scene_path: String = ""
var current_scene_path: String = ""
var player_name: String = "Guerrero"
var active_save_slot: int = 0
var last_checkpoint_id: String = ""
var pending_save_restore: Dictionary = {}
var last_save_error: String = ""
## Sin guardado activo, se inicia como prisionero desarmado.
## Al cargar, el progreso guardado restaura el equipo recuperado.
var has_sword: bool = false
var sword_mission_started: bool = false
var sword_mission_completed: bool = false
var sword_guard_defeated: bool = false
var castle_equipment_recovered: bool = false
const SWORD_MISSION_TITLE := "Recuperar la espada"
const SWORD_MISSION_DESCRIPTION := "Encuentra la llave de la armería y recupera tu armadura y espada."

const SAVE_DIRECTORY := "user://saves"
## 2: las habilidades se guardan como "abilities" (ABILITY_DEFINITIONS) en vez
## de los "skills" del alma fragmentada de la 0.04.049.
const SAVE_FORMAT_VERSION := 2
const SAVE_SLOT_COUNT := 3
const PRISON_SCENE_PATH := "res://escenas/mapas/prologo_prision/camara_sellado_alma.tscn"
const CASTLE_SCENE_PATH := "res://escenas/mapas/tiles_castillo_combate.tscn"
const CEMETERY_SCENE_PATH := "res://escenas/mapas/tiles_cementerio_combate.tscn"
const PRISON_CINEMATIC_ID := "prison_opening"
const PRISON_CINEMATIC_META_KEY := "underkingdom_camara_sellado_alma_completada"

var world1_boss_defeated: bool = false
var world1_boss_key_collected: bool = false
var coins: int = 0
var potions: int = 0
var cthulhu_revealed: bool = false
var w2_knight_defeated: bool = false
var cinematics_seen: Dictionary = {}
## Encuentros de arena (oleadas + jefe) ya superados, por encounter_id. Se
## conservan al morir para que el combate no se repita al recargar el mapa.
var completed_encounters: Dictionary = {}
## Llaves de jefe recogidas, por key_id (la de Mundo 1 sigue aparte, arriba).
var collected_keys: Dictionary = {}
var upgrade_levels: Dictionary = {
	"max_health": 0,
	"lifesteal": 0,
	"ultimate_cooldown": 0,
}

const UPGRADE_DEFINITIONS := {
	"max_health": {
		"name": "Vida máxima", "max_level": 2,
		"costs": [5, 10], "base": 4.0, "step": 1.0, "unit": "corazones",
	},
	## La curación sigue siendo de un cuarto de corazón: la mejora baja el daño
	## que hay que hacer para ganarlo (Player.lifesteal_damage_required).
	"lifesteal": {
		"name": "Robo de vida", "max_level": 3,
		"costs": [8, 16, 24], "base": 2.0, "step": -0.25, "unit": "daño",
	},
	"ultimate_cooldown": {
		"name": "Enfriamiento de Ultimate", "max_level": 3,
		"costs": [10, 15, 20], "base": 6.0, "step": -0.5, "unit": "segundos",
	},
}

## Habilidades del Player que se ganan jugando: reliquias del mapa
## (UnderkingdomAbilityPickup), jefes (BossArena.ability_reward) o la tienda.
## "hint" es la tecla o la forma de usarla; sale en el aviso al conseguirla.
const ABILITY_DEFINITIONS := {
	"roll": {"name": "Rodar", "hint": "Shift: esquiva y atraviesa enemigos"},
	"combo_2": {"name": "Ráfaga", "hint": "Ataca otra vez durante el primer golpe"},
	"combo_3": {"name": "Golpe final", "hint": "Tercer ataque seguido del combo"},
	"air_attack": {"name": "Tajo aéreo", "hint": "Ataca en el aire"},
	"parry": {"name": "Parry", "hint": "Cúbrete [Q] justo antes del golpe"},
	"ultimate": {"name": "Ultimate", "hint": "E"},
	"lifesteal": {"name": "Robo de vida", "hint": "Golpear te cura"},
	"adrenaline": {"name": "Adrenalina", "hint": "Con media vida o menos atacas más rápido"},
}
## Con las que empieza una partida nueva. Las que todavía no tienen dónde
## conseguirse (minijefe del tajo aéreo, reliquia de la adrenalina, tienda de
## parry y robo de vida) siguen aquí hasta que se coloque su fuente.
const STARTING_ABILITIES: Array[String] = ["air_attack", "parry", "lifesteal", "adrenaline"]

## Solo una partida empezada desde "Nueva partida" exige desbloquear. Al abrir
## un mapa directo desde el editor (o el Mundo 1 viejo) el Player tiene todo.
var abilities_locked: bool = false
var unlocked_abilities: Dictionary = {}

## Muerte: el mapa se recarga y el Player reaparece en el último punto de
## reaparición (entrada del mapa o checkpoint). Enemigos y jefes no derrotados
## vuelven a su estado inicial; el progreso de arriba se conserva.
var respawn_scene_path: String = ""
var respawn_position: Vector2 = Vector2.ZERO
## Cofres abiertos y objetos rotos ("escena|ruta del nodo"), para que no
## vuelvan a soltar botín al recargar el mapa.
var consumed_objects: Dictionary = {}
## Pociones bebidas desde el último punto de reaparición. Al morir se devuelven
## para reaparecer con las mismas que se tenían al pasar por él.
var potions_used_since_respawn: int = 0

const DEATH_FADE_IN := 0.6
const DEATH_HOLD := 0.7
const DEATH_FADE_OUT := 0.5

var _respawning_after_death: bool = false
var _death_respawn_pending: bool = false
var _death_layer: CanvasLayer
var _death_fade: ColorRect
var _death_label: Label
var _autosave_pending: bool = false
var _autosave_location: Dictionary = {}
var _autosave_elapsed: float = 0.0
var _backup_serial: int = 0


func _process(delta: float) -> void:
	if not _autosave_pending:
		return
	_autosave_elapsed += delta
	if _autosave_elapsed < 0.75:
		return
	_autosave_elapsed = 0.0
	if not has_active_save_slot():
		_autosave_pending = false
		return
	if save_active_game(_autosave_location):
		_autosave_pending = false
		_autosave_location.clear()
	elif last_save_error != "unsafe":
		_autosave_pending = false


func set_transition(target_spawn_id: StringName) -> void:
	pending_spawn_id = target_spawn_id

	var current_scene := get_tree().current_scene
	if current_scene != null:
		previous_scene_path = current_scene.scene_file_path


func normalize_player_name(raw_name: String) -> String:
	var normalized := raw_name.strip_edges()
	while normalized.contains("  "):
		normalized = normalized.replace("  ", " ")
	if normalized.length() < 1 or normalized.length() > 16:
		return ""
	var valid_name := RegEx.new()
	if valid_name.compile("^[\\p{L}][\\p{L} '\\-]{0,15}$") != OK:
		return ""
	return normalized if valid_name.search(normalized) != null else ""


func get_player_display_name() -> String:
	return player_name.to_upper()


func set_player_name(value: String) -> bool:
	var normalized := normalize_player_name(value)
	if normalized.is_empty():
		return false
	player_name = normalized
	player_name_changed.emit(player_name)
	return true


func has_active_save_slot() -> bool:
	return active_save_slot >= 1 and active_save_slot <= SAVE_SLOT_COUNT


func has_any_valid_save_slot() -> bool:
	for slot_id in range(1, SAVE_SLOT_COUNT + 1):
		if bool(get_save_slot_info(slot_id).get("valid", false)):
			return true
	return false


func get_save_slot_info(slot_id: int) -> Dictionary:
	var result := _read_save_slot(slot_id)
	if not bool(result.get("exists", false)):
		return {"slot_id": slot_id, "exists": false, "valid": false}
	if not bool(result.get("valid", false)):
		return {
			"slot_id": slot_id,
			"exists": true,
			"valid": false,
			"error": String(result.get("error", "Archivo inválido")),
		}
	var data: Dictionary = result.data
	var state: Dictionary = data.state
	return {
		"slot_id": slot_id,
		"exists": true,
		"valid": true,
		"player_name": String(data.profile.player_name),
		"region": region_name_for_scene(String(state.scene_path)),
		"saved_at": String(data.saved_at),
	}


func delete_save_slot(slot_id: int) -> bool:
	if slot_id < 1 or slot_id > SAVE_SLOT_COUNT:
		last_save_error = "Ranura invalida."
		return false
	var save_path := _save_slot_path(slot_id)
	var temp_path := save_path + ".tmp"
	var files_to_remove: Array[String] = []
	var directory := DirAccess.open(SAVE_DIRECTORY)
	if directory != null:
		var backup_prefix := "slot_%d_" % slot_id
		for file_name in directory.get_files():
			if not file_name.begins_with(backup_prefix) or not file_name.ends_with(".bak"):
				continue
			var components := file_name.trim_prefix(backup_prefix).trim_suffix(".bak").split("_")
			if components.size() == 2 and components[0].is_valid_int() and components[1].is_valid_int():
				files_to_remove.append("%s/%s" % [SAVE_DIRECTORY, file_name])
	if FileAccess.file_exists(temp_path):
		files_to_remove.append(temp_path)
	for path in files_to_remove:
		var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		if error != OK:
			last_save_error = "No se pudo eliminar un archivo de respaldo (%d)." % error
			return false
	if FileAccess.file_exists(save_path):
		var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
		if error != OK:
			last_save_error = "No se pudo eliminar la partida (%d)." % error
			return false
	if active_save_slot == slot_id:
		cancel_pending_autosave()
		active_save_slot = 0
		pending_save_restore.clear()
	last_save_error = ""
	save_slots_changed.emit()
	return true


func region_name_for_scene(scene_path: String) -> String:
	if scene_path.contains("prologo_prision"):
		return "Cámara del Sellado"
	if scene_path.contains("tiles_castillo"):
		return "Castillo"
	if scene_path.contains("cementerio"):
		return "Cementerio"
	if scene_path.contains("mundo_1"):
		return "Mundo 1"
	return scene_path.get_file().get_basename().replace("_", " ").capitalize()


func create_new_profile(slot_id: int, requested_name: String, overwrite_confirmed: bool = false) -> bool:
	var normalized := normalize_player_name(requested_name)
	if slot_id < 1 or slot_id > SAVE_SLOT_COUNT or normalized.is_empty():
		last_save_error = "Perfil o nombre inválido."
		return false
	var existing := _read_save_slot(slot_id)
	if bool(existing.get("exists", false)) and not overwrite_confirmed:
		last_save_error = "La ranura ya contiene datos; confirma antes de reemplazarla."
		return false
	var old_name := player_name
	var old_slot := active_save_slot
	player_name = normalized
	active_save_slot = slot_id
	player_name_changed.emit(player_name)
	var initial_location := {
		"scene_path": PRISON_SCENE_PATH,
		"spawn_id": "PrisonStart",
		"clear_position": true,
	}
	var data := _make_save_data(slot_id, initial_location, null)
	if not _write_save_slot(slot_id, data, overwrite_confirmed):
		player_name = old_name
		active_save_slot = old_slot
		player_name_changed.emit(player_name)
		return false
	pending_spawn_id = &""
	return true


func load_save_slot(slot_id: int) -> bool:
	var result := _read_save_slot(slot_id)
	if not bool(result.get("valid", false)):
		last_save_error = String(result.get("error", "No existe una partida válida."))
		return false
	var data: Dictionary = result.data
	var state: Dictionary = data.state
	var scene_path := String(state.scene_path)
	if not ResourceLoader.exists(scene_path):
		last_save_error = "La escena guardada ya no existe."
		return false
	active_save_slot = slot_id
	player_name = String(data.profile.player_name)
	_restore_game_state(state)
	pending_spawn_id = StringName(String(state.spawn_id))
	pending_save_restore = state.duplicate(true)
	var prison_complete := has_seen_cinematic(PRISON_CINEMATIC_ID)
	get_tree().set_meta(PRISON_CINEMATIC_META_KEY, prison_complete)
	player_name_changed.emit(player_name)
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		pending_save_restore.clear()
		last_save_error = "No se pudo cargar la escena guardada (%d)." % error
		return false
	last_save_error = ""
	return true


func _restore_game_state(state: Dictionary) -> void:
	coins = maxi(0, int(state.get("coins", 0)))
	potions = maxi(0, int(state.get("potions", 0)))
	potions_used_since_respawn = 0
	world1_boss_defeated = bool(state.get("world1_boss_defeated", false))
	world1_boss_key_collected = bool(state.get("world1_boss_key_collected", false))
	w2_knight_defeated = bool(state.get("w2_knight_defeated", false))
	cthulhu_revealed = bool(state.get("cthulhu_revealed", false))
	abilities_locked = bool(state.get("abilities_locked", true))
	unlocked_abilities.clear()
	var saved_abilities: Dictionary = state.get("abilities", {})
	for ability_id: String in ABILITY_DEFINITIONS:
		if bool(saved_abilities.get(ability_id, false)):
			unlocked_abilities[ability_id] = true
	upgrade_levels.clear()
	var saved_upgrades: Dictionary = state.get("upgrades", {})
	for upgrade_id in UPGRADE_DEFINITIONS:
		upgrade_levels[upgrade_id] = clampi(int(saved_upgrades.get(upgrade_id, 0)), 0, int(UPGRADE_DEFINITIONS[upgrade_id].max_level))
	cinematics_seen = state.get("cinematics_seen", {}).duplicate(true)
	completed_encounters = state.get("completed_encounters", {}).duplicate(true)
	collected_keys = state.get("collected_keys", {}).duplicate(true)
	consumed_objects = state.get("consumed_objects", {}).duplicate(true)
	respawn_scene_path = String(state.get("respawn_scene_path", ""))
	var saved_respawn: Variant = state.get("respawn_position", [0.0, 0.0])
	if saved_respawn is Array and saved_respawn.size() == 2:
		respawn_position = Vector2(float(saved_respawn[0]), float(saved_respawn[1]))
	last_checkpoint_id = String(state.get("last_checkpoint_id", ""))
	# Los perfiles anteriores a la misión no registraban la derrota del guardia.
	# No se concede la espada implícitamente al migrarlos al sistema nuevo.
	sword_guard_defeated = bool(state.get("sword_guard_defeated", false))
	castle_equipment_recovered = bool(state.get("castle_equipment_recovered", false))
	# La derrota de un guardia ya no concede equipo. Solo se restaura el estado
	# armado si el guardado registra que se recuperó en la armería.
	has_sword = bool(state.get("has_sword", false)) and castle_equipment_recovered
	sword_mission_started = bool(state.get("sword_mission_started", false)) and not has_sword
	sword_mission_completed = bool(state.get("sword_mission_completed", false)) and has_sword
	sword_mission_changed.emit(sword_mission_started, sword_mission_completed)
	sword_equipment_changed.emit(has_sword)
	current_scene_path = String(state.get("scene_path", ""))
	world1_boss_defeated_changed.emit(world1_boss_defeated)
	world1_boss_key_changed.emit(world1_boss_key_collected)
	coins_changed.emit(coins)
	potions_changed.emit(potions)
	cthulhu_revealed_changed.emit(cthulhu_revealed)
	w2_knight_defeated_changed.emit(w2_knight_defeated)
	upgrades_changed.emit()


func consume_pending_save_restore(scene_path: String) -> Dictionary:
	if pending_save_restore.is_empty():
		return {}
	if String(pending_save_restore.get("scene_path", "")) != scene_path:
		return {}
	var result := pending_save_restore.duplicate(true)
	pending_save_restore.clear()
	return result


func restore_saved_player(player: Node, state: Dictionary, restore_position: bool = true) -> void:
	if not is_instance_valid(player):
		return
	apply_upgrades_to_player(player, false)
	if restore_position and player is Node2D:
		var location: Variant = state.get("position")
		if location is Array and location.size() == 2:
			(player as Node2D).global_position = Vector2(float(location[0]), float(location[1]))
	if player.get("max_health") != null:
		player.set("max_health", float(state.get("max_health", player.get("max_health"))))
	if player.get("current_health") != null:
		player.set("current_health", clampf(
			float(state.get("health", player.get("current_health"))),
			0.0,
			float(player.get("max_health"))
		))
	if player.get("controls_locked") != null:
		player.set("controls_locked", false)
	if player.get("cinematic_invulnerable") != null:
		player.set("cinematic_invulnerable", false)
	if player is CharacterBody2D:
		(player as CharacterBody2D).velocity = Vector2.ZERO
	if player.has_signal("health_changed"):
		player.emit_signal("health_changed", float(player.get("current_health")), float(player.get("max_health")))
	if player.has_method("set_sword_equipped"):
		player.call("set_sword_equipped", has_sword)
	if player.has_method("set_spawn_point") and restore_position and player is Node2D:
		player.call("set_spawn_point", (player as Node2D).global_position)


func save_active_game(location_override: Dictionary = {}, player_override: Node = null) -> bool:
	last_save_error = ""
	if not has_active_save_slot():
		last_save_error = "No hay perfil activo."
		return false
	var existing := _read_save_slot(active_save_slot)
	if not bool(existing.get("valid", false)):
		last_save_error = "El archivo activo no es válido; se conserva sin sobrescribirlo."
		return false
	var player := player_override
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if not _is_player_safe_to_save(player):
		last_save_error = "unsafe"
		return false
	var current_scene := get_tree().current_scene
	var location := location_override.duplicate(true)
	if not location.has("scene_path") and current_scene != null:
		location.scene_path = current_scene.scene_file_path
	var data := _make_save_data(active_save_slot, location, player)
	if not _write_save_slot(active_save_slot, data, true):
		return false
	last_save_error = ""
	return true


func request_autosave(location_override: Dictionary = {}) -> void:
	if not has_active_save_slot():
		return
	_autosave_pending = true
	_autosave_location = location_override.duplicate(true)
	_autosave_elapsed = 0.0


func cancel_pending_autosave() -> void:
	_autosave_pending = false
	_autosave_location.clear()
	_autosave_elapsed = 0.0


## Mundos en los que se autoguarda al entrar (escena _combate o la base generada).
func is_autosave_region(scene_path: String) -> bool:
	for region_path: String in [CASTLE_SCENE_PATH, CEMETERY_SCENE_PATH]:
		if scene_path == region_path or scene_path == region_path.replace("_combate.tscn", ".tscn"):
			return true
	return false


func autosave_region_entry(player: Node, scene_path: String, spawn_id: StringName) -> void:
	if not is_autosave_region(scene_path):
		return
	request_autosave({
		"scene_path": scene_path,
		"spawn_id": String(spawn_id),
		"clear_position": true,
	})


func save_checkpoint(player: Node, checkpoint_id: String, position: Vector2) -> void:
	last_checkpoint_id = checkpoint_id
	request_autosave({
		"scene_path": get_tree().current_scene.scene_file_path,
		"spawn_id": "checkpoint:" + checkpoint_id,
		"position": position,
	})


func _is_player_safe_to_save(player: Node) -> bool:
	if not is_instance_valid(player) or _respawning_after_death:
		return false
	if bool(player.get("dead")) or bool(player.get("controls_locked")) or bool(player.get("cinematic_invulnerable")):
		return false
	if player.has_method("is_on_floor") and not bool(player.call("is_on_floor")):
		return false
	var player_sprite := player.get("sprite") as AnimatedSprite2D
	if player_sprite != null and player_sprite.animation in [
		&"attack", &"attack 2", &"attack 3", &"air attack", &"attack ultimate", &"roll", &"hurt"
	]:
		return false
	if player is Node2D:
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if is_instance_valid(enemy) and enemy is Node2D and enemy.visible:
				if (enemy as Node2D).global_position.distance_to((player as Node2D).global_position) < 112.0:
					return false
	return true


func _make_save_data(slot_id: int, location: Dictionary, player: Node) -> Dictionary:
	var scene_path := String(location.get("scene_path", current_scene_path))
	var spawn_id := String(location.get("spawn_id", "SavedPosition"))
	var saved_position: Variant = null
	if not bool(location.get("clear_position", false)):
		if location.has("position"):
			var supplied_position: Variant = location.position
			if supplied_position is Vector2:
				saved_position = [supplied_position.x, supplied_position.y]
			elif supplied_position is Array:
				saved_position = supplied_position.duplicate()
		elif is_instance_valid(player) and player is Node2D:
			var player_position := (player as Node2D).global_position
			saved_position = [player_position.x, player_position.y]
	var max_health := float(get_upgrade_info("max_health").value)
	var health := max_health
	if is_instance_valid(player):
		max_health = float(player.get("max_health"))
		health = float(player.get("current_health"))
	var abilities: Dictionary = {}
	for ability_id: String in ABILITY_DEFINITIONS:
		abilities[ability_id] = is_ability_unlocked(ability_id)
	var upgrades: Dictionary = {}
	for upgrade_id in UPGRADE_DEFINITIONS:
		upgrades[String(upgrade_id)] = int(upgrade_levels.get(upgrade_id, 0))
	var respawn_position_data: Array = [respawn_position.x, respawn_position.y]
	var respawn_scene := respawn_scene_path
	if respawn_scene.is_empty():
		respawn_scene = scene_path
	return {
		"format_version": SAVE_FORMAT_VERSION,
		"slot_id": slot_id,
		"saved_at": Time.get_datetime_string_from_system(true),
		"profile": {"player_name": player_name},
		"state": {
			"scene_path": scene_path,
			"spawn_id": spawn_id,
			"position": saved_position,
			"health": health,
			"max_health": max_health,
			"coins": coins,
			"potions": potions,
			"world1_boss_defeated": world1_boss_defeated,
			"world1_boss_key_collected": world1_boss_key_collected,
			"w2_knight_defeated": w2_knight_defeated,
			"cthulhu_revealed": cthulhu_revealed,
			"abilities_locked": abilities_locked,
			"abilities": abilities,
			"upgrades": upgrades,
			"cinematics_seen": _string_key_dictionary(cinematics_seen),
			"completed_encounters": _string_key_dictionary(completed_encounters),
			"collected_keys": _string_key_dictionary(collected_keys),
			"consumed_objects": _string_key_dictionary(consumed_objects),
			"respawn_scene_path": respawn_scene,
			"respawn_position": respawn_position_data,
			"last_checkpoint_id": last_checkpoint_id,
			"has_sword": has_sword,
			"sword_mission_started": sword_mission_started,
			"sword_mission_completed": sword_mission_completed,
			"sword_guard_defeated": sword_guard_defeated,
			"castle_equipment_recovered": castle_equipment_recovered,
		},
	}


func _string_key_dictionary(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key in source:
		result[String(key)] = source[key]
	return result


func _validate_save_data(data: Dictionary, slot_id: int) -> String:
	if int(data.get("format_version", -1)) != SAVE_FORMAT_VERSION:
		return "Versión de guardado no compatible."
	if int(data.get("slot_id", -1)) != slot_id:
		return "El identificador de ranura no coincide."
	var profile: Variant = data.get("profile")
	var state: Variant = data.get("state")
	if not (profile is Dictionary) or not (state is Dictionary):
		return "Faltan datos del perfil o de la partida."
	if normalize_player_name(String(profile.get("player_name", ""))) != String(profile.get("player_name", "")):
		return "El nombre guardado no es válido."
	var scene_path := String(state.get("scene_path", ""))
	if not scene_path.begins_with("res://") or not ResourceLoader.exists(scene_path):
		return "La escena guardada no existe."
	if not (state.get("spawn_id", "") is String):
		return "El punto de aparición no es válido."
	var position: Variant = state.get("position")
	if position != null:
		if not position is Array or position.size() != 2:
			return "La posición guardada no es válida."
		for coordinate in position:
			if typeof(coordinate) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(coordinate)) or absf(float(coordinate)) > 100000.0:
				return "La posición guardada está fuera de rango."
	if not (state.get("abilities") is Dictionary) or not (state.get("upgrades") is Dictionary):
		return "El progreso de habilidades o mejoras está dañado."
	for field in ["cinematics_seen", "completed_encounters", "collected_keys", "consumed_objects"]:
		if not (state.get(field, {}) is Dictionary):
			return "El progreso de historia u objetos está dañado."
	var respawn_position_data: Variant = state.get("respawn_position", [0.0, 0.0])
	if not (respawn_position_data is Array) or respawn_position_data.size() != 2:
		return "El punto de reaparición no es válido."
	for coordinate in respawn_position_data:
		if typeof(coordinate) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(coordinate)) or absf(float(coordinate)) > 100000.0:
			return "El punto de reaparición está fuera de rango."
	for field in ["health", "max_health", "coins", "potions"]:
		var value: Variant = state.get(field, 0)
		if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)):
			return "Los valores del personaje están dañados."
	return ""


func _read_save_slot(slot_id: int) -> Dictionary:
	if slot_id < 1 or slot_id > SAVE_SLOT_COUNT:
		return {"exists": false, "valid": false, "error": "Ranura inválida."}
	var path := _save_slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return {"exists": false, "valid": false}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": true, "valid": false, "error": "No se pudo leer el archivo."}
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not parser.data is Dictionary:
		return {"exists": true, "valid": false, "error": "El archivo está dañado."}
	var data: Dictionary = parser.data
	var error := _validate_save_data(data, slot_id)
	if not error.is_empty():
		return {"exists": true, "valid": false, "error": error}
	return {"exists": true, "valid": true, "data": data}


func _save_slot_path(slot_id: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIRECTORY, slot_id]


func _ensure_save_directory() -> bool:
	var absolute_directory := ProjectSettings.globalize_path(SAVE_DIRECTORY)
	if DirAccess.dir_exists_absolute(absolute_directory):
		return true
	var error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	return error == OK or DirAccess.dir_exists_absolute(absolute_directory)


func _write_save_slot(slot_id: int, data: Dictionary, overwrite_confirmed: bool) -> bool:
	if slot_id < 1 or slot_id > SAVE_SLOT_COUNT or not _ensure_save_directory():
		last_save_error = "No se pudo preparar la carpeta de guardados."
		return false
	var validation_error := _validate_save_data(data, slot_id)
	if not validation_error.is_empty():
		last_save_error = validation_error
		return false
	var final_path := _save_slot_path(slot_id)
	var temp_path := final_path + ".tmp"
	var final_absolute := ProjectSettings.globalize_path(final_path)
	var temp_absolute := ProjectSettings.globalize_path(temp_path)
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		last_save_error = "No se pudo crear el archivo temporal."
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		last_save_error = "Falló la escritura temporal del guardado."
		return false
	var temp_file := FileAccess.open(temp_path, FileAccess.READ)
	if temp_file == null:
		last_save_error = "No se pudo verificar el archivo temporal."
		return false
	var temp_parser := JSON.new()
	var temp_parse_error := temp_parser.parse(temp_file.get_as_text())
	temp_file.close()
	if temp_parse_error != OK or not temp_parser.data is Dictionary or not _validate_save_data(temp_parser.data, slot_id).is_empty():
		last_save_error = "El guardado temporal no pasó la validación."
		return false
	var backup_absolute := ""
	if FileAccess.file_exists(final_path):
		if not overwrite_confirmed:
			last_save_error = "La ranura ya está ocupada."
			return false
		_backup_serial += 1
		var backup_path := "%s/slot_%d_%d_%d.bak" % [SAVE_DIRECTORY, slot_id, int(Time.get_unix_time_from_system()), _backup_serial]
		backup_absolute = ProjectSettings.globalize_path(backup_path)
		var backup_error := DirAccess.rename_absolute(final_absolute, backup_absolute)
		if backup_error != OK:
			last_save_error = "No se pudo conservar una copia del guardado anterior."
			return false
	var replace_error := DirAccess.rename_absolute(temp_absolute, final_absolute)
	if replace_error != OK:
		if not backup_absolute.is_empty():
			DirAccess.rename_absolute(backup_absolute, final_absolute)
		last_save_error = "No se pudo completar el guardado; se restauró el archivo anterior."
		return false
	last_save_error = ""
	save_slots_changed.emit()
	return true


func consume_spawn_id() -> StringName:
	var result := pending_spawn_id
	pending_spawn_id = &""
	return result


func remember_current_scene() -> void:
	var current_scene := get_tree().current_scene
	if current_scene != null:
		current_scene_path = current_scene.scene_file_path


func set_respawn_point(world_position: Vector2) -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return
	respawn_scene_path = current_scene.scene_file_path
	respawn_position = world_position
	potions_used_since_respawn = 0


## Devuelve true una sola vez tras recargar el mapa por una muerte, si hay
## punto de reaparición guardado para este mapa.
func consume_death_respawn() -> bool:
	if not _death_respawn_pending:
		return false
	_death_respawn_pending = false
	var current_scene := get_tree().current_scene
	return current_scene != null and current_scene.scene_file_path == respawn_scene_path


## Fundido a negro, recarga del mapa actual y fundido de vuelta.
func respawn_after_death() -> void:
	if _respawning_after_death:
		return
	_respawning_after_death = true
	_ensure_death_screen()

	_death_layer.visible = true
	_death_fade.color.a = 0.0
	_death_label.modulate.a = 0.0
	var fade_in := create_tween().set_parallel(true)
	fade_in.tween_property(_death_fade, "color:a", 1.0, DEATH_FADE_IN)
	fade_in.tween_property(_death_label, "modulate:a", 1.0, DEATH_FADE_IN)
	await fade_in.finished
	await get_tree().create_timer(DEATH_HOLD).timeout

	_restore_potions_used_since_respawn()
	_death_respawn_pending = true
	get_tree().reload_current_scene()
	# El SpawnController coloca al Player un frame después de cargar.
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var fade_out := create_tween().set_parallel(true)
	fade_out.tween_property(_death_fade, "color:a", 0.0, DEATH_FADE_OUT)
	fade_out.tween_property(_death_label, "modulate:a", 0.0, DEATH_FADE_OUT * 0.5)
	await fade_out.finished
	_death_layer.visible = false
	_respawning_after_death = false


func _restore_potions_used_since_respawn() -> void:
	if potions_used_since_respawn <= 0:
		return
	potions += potions_used_since_respawn
	potions_used_since_respawn = 0
	potions_changed.emit(potions)
	request_autosave()


func is_respawning_after_death() -> bool:
	return _respawning_after_death


func _ensure_death_screen() -> void:
	if _death_layer != null:
		return
	_death_layer = CanvasLayer.new()
	_death_layer.layer = 100
	_death_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_death_layer)

	_death_fade = ColorRect.new()
	_death_fade.color = Color(0, 0, 0, 0)
	_death_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_death_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_death_layer.add_child(_death_fade)

	_death_label = Label.new()
	_death_label.text = "HAS CAÍDO"
	_death_label.add_theme_font_size_override("font_size", 16)
	_death_label.add_theme_color_override("font_color", Color(0.78, 0.16, 0.16))
	_death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_death_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_death_layer.add_child(_death_label)


func object_key(node: Node) -> String:
	# El owner es la raíz del mapa que contiene el nodo; ya está asignado en _ready.
	var map_root := node.owner
	if map_root == null or map_root.scene_file_path.is_empty():
		return ""
	return "%s|%s" % [map_root.scene_file_path, map_root.get_path_to(node)]


func mark_object_consumed(node: Node) -> void:
	var key := object_key(node)
	if not key.is_empty():
		consumed_objects[key] = true
		request_autosave()


func is_object_consumed(node: Node) -> bool:
	var key := object_key(node)
	return not key.is_empty() and consumed_objects.has(key)


func mark_world1_boss_defeated() -> void:
	if world1_boss_defeated:
		return
	world1_boss_defeated = true
	world1_boss_defeated_changed.emit(true)
	request_autosave()


func grant_world1_boss_key() -> void:
	if world1_boss_key_collected:
		return
	world1_boss_key_collected = true
	world1_boss_key_changed.emit(true)
	request_autosave()


func has_world1_boss_key() -> bool:
	return world1_boss_key_collected


func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	coins_changed.emit(coins)
	request_autosave()


func can_spend_coins(amount: int) -> bool:
	return amount > 0 and (DevMode.infinite_coins or coins >= amount)


func try_spend_coins(amount: int) -> bool:
	if not can_spend_coins(amount):
		return false
	if DevMode.infinite_coins:
		return true
	coins -= amount
	coins_changed.emit(coins)
	request_autosave()
	return true


func get_upgrade_info(upgrade_id: String) -> Dictionary:
	if not UPGRADE_DEFINITIONS.has(upgrade_id):
		return {}
	var definition: Dictionary = UPGRADE_DEFINITIONS[upgrade_id]
	var level := int(upgrade_levels.get(upgrade_id, 0))
	var max_level := int(definition.max_level)
	var value := float(definition.base) + float(definition.step) * level
	var next_value := value
	var cost := -1
	if level < max_level:
		next_value = value + float(definition.step)
		cost = int(definition.costs[level])
	return {
		"id": upgrade_id,
		"name": String(definition.name),
		"level": level,
		"max_level": max_level,
		"value": value,
		"next_value": next_value,
		"cost": cost,
		"unit": String(definition.unit),
		"at_max": level >= max_level,
	}


func purchase_upgrade(upgrade_id: String) -> bool:
	if upgrade_id == "ultimate_cooldown" and not has_ability("ultimate"):
		return false
	var info := get_upgrade_info(upgrade_id)
	if info.is_empty() or bool(info.at_max):
		return false
	var cost := int(info.cost)
	if not try_spend_coins(cost):
		return false
	upgrade_levels[upgrade_id] = int(info.level) + 1
	var player := get_tree().get_first_node_in_group("player") as UnderkingdomPlayer
	if is_instance_valid(player):
		apply_upgrades_to_player(player, true)
	upgrades_changed.emit()
	return true


func apply_upgrades_to_player(player: UnderkingdomPlayer, heal_max_health_increase: bool = false) -> void:
	if not is_instance_valid(player):
		return
	var old_max: float = player.max_health
	var new_max: float = float(get_upgrade_info("max_health").value)
	var old_cooldown: float = player.ultimate_cooldown
	var ready_ratio: float = player.get_ultimate_ready_ratio()

	player.max_health = new_max
	player.lifesteal_damage_required = float(get_upgrade_info("lifesteal").value)
	player.ultimate_cooldown = float(get_upgrade_info("ultimate_cooldown").value)

	if old_cooldown > 0.0:
		player.set_ultimate_cooldown_progress(ready_ratio)
	if heal_max_health_increase and new_max > old_max:
		player.current_health = minf(player.current_health + new_max - old_max, new_max)
		player.health_changed.emit(player.current_health, player.max_health)


func reset_upgrades_for_new_game() -> void:
	for upgrade_id in UPGRADE_DEFINITIONS.keys():
		upgrade_levels[upgrade_id] = 0
	upgrades_changed.emit()


func add_potions(amount: int) -> void:
	if amount <= 0:
		return
	potions += amount
	potions_changed.emit(potions)
	request_autosave()


func use_potion() -> bool:
	if potions <= 0:
		return false
	potions -= 1
	potions_used_since_respawn += 1
	potions_changed.emit(potions)
	request_autosave()
	return true


func mark_w2_knight_defeated() -> void:
	if w2_knight_defeated:
		return
	w2_knight_defeated = true
	w2_knight_defeated_changed.emit(true)
	request_autosave()


func has_w2_knight_been_defeated() -> bool:
	return w2_knight_defeated


func reveal_cthulhu() -> void:
	if cthulhu_revealed:
		return
	cthulhu_revealed = true
	cthulhu_revealed_changed.emit(true)
	request_autosave()


func hide_cthulhu() -> void:
	if not cthulhu_revealed:
		return
	cthulhu_revealed = false
	cthulhu_revealed_changed.emit(false)


func is_cthulhu_revealed() -> bool:
	return cthulhu_revealed


func mark_cinematic_seen(cinematic_id: String) -> void:
	if cinematic_id.is_empty():
		return
	if cinematics_seen.get(cinematic_id, false):
		return
	cinematics_seen[cinematic_id] = true
	cinematic_seen.emit(cinematic_id)
	request_autosave()


func has_seen_cinematic(cinematic_id: String) -> bool:
	if cinematic_id.is_empty():
		return false
	return bool(cinematics_seen.get(cinematic_id, false))


func mark_encounter_completed(encounter_id: String) -> void:
	if encounter_id.is_empty():
		return
	if completed_encounters.get(encounter_id, false):
		return
	completed_encounters[encounter_id] = true
	encounter_completed.emit(encounter_id)
	request_autosave()


func is_encounter_completed(encounter_id: String) -> bool:
	if encounter_id.is_empty():
		return false
	return bool(completed_encounters.get(encounter_id, false))


func grant_key(key_id: String) -> void:
	if key_id.is_empty() or has_key(key_id):
		return
	collected_keys[key_id] = true
	key_changed.emit(key_id, true)
	request_autosave()


func has_key(key_id: String) -> bool:
	if key_id.is_empty():
		return false
	return bool(collected_keys.get(key_id, false))


## Para el HUD: cualquier llave de jefe, incluida la de Mundo 1.
func has_any_key() -> bool:
	return world1_boss_key_collected or not collected_keys.is_empty()


## Si el Player puede usar la habilidad ahora (siempre, fuera de una partida).
func has_ability(ability_id: String) -> bool:
	return not abilities_locked or is_ability_unlocked(ability_id)


## Si ya se consiguió en esta partida; las reliquias lo usan para no reaparecer.
func is_ability_unlocked(ability_id: String) -> bool:
	return bool(unlocked_abilities.get(ability_id, false))


func unlock_ability(ability_id: String) -> void:
	if not ABILITY_DEFINITIONS.has(ability_id):
		push_warning("GameManager: habilidad desconocida '%s'." % ability_id)
		return
	if is_ability_unlocked(ability_id):
		return
	unlocked_abilities[ability_id] = true
	ability_unlocked.emit(ability_id)
	request_autosave()


func get_ability_name(ability_id: String) -> String:
	return String(ABILITY_DEFINITIONS.get(ability_id, {}).get("name", ability_id))


func get_ability_hint(ability_id: String) -> String:
	return String(ABILITY_DEFINITIONS.get(ability_id, {}).get("hint", ""))


func reset_abilities_for_new_game() -> void:
	abilities_locked = true
	unlocked_abilities.clear()
	for ability_id: String in STARTING_ABILITIES:
		unlocked_abilities[ability_id] = true


func reset_cinematics_for_new_game() -> void:
	cinematics_seen.clear()


## Partida nueva desde el menú principal; nunca se llama en respawn. Toda
## variable de progreso nueva se reinicia aquí.
func reset_for_new_game() -> void:
	pending_spawn_id = &""
	previous_scene_path = ""
	current_scene_path = ""
	world1_boss_defeated = false
	world1_boss_key_collected = false
	coins = 0
	potions = 0
	potions_used_since_respawn = 0
	cthulhu_revealed = false
	w2_knight_defeated = false
	completed_encounters.clear()
	collected_keys.clear()
	respawn_scene_path = ""
	respawn_position = Vector2.ZERO
	consumed_objects.clear()
	reset_cinematics_for_new_game()
	reset_abilities_for_new_game()
	reset_upgrades_for_new_game()
	last_checkpoint_id = ""
	has_sword = false
	sword_mission_started = false
	sword_mission_completed = false
	sword_guard_defeated = false
	castle_equipment_recovered = false
	sword_equipment_changed.emit(false)
	sword_mission_changed.emit(false, false)
	active_save_slot = 0
	pending_save_restore.clear()
	cancel_pending_autosave()
	world1_boss_defeated_changed.emit(false)
	world1_boss_key_changed.emit(false)
	coins_changed.emit(coins)
	potions_changed.emit(potions)
	cthulhu_revealed_changed.emit(false)
	w2_knight_defeated_changed.emit(false)


func start_sword_mission() -> void:
	if has_sword or sword_mission_completed or sword_mission_started:
		return
	sword_mission_started = true
	sword_mission_changed.emit(true, false)
	request_autosave()


func recover_sword(player: Node = null) -> bool:
	if has_sword or not sword_guard_defeated:
		return false
	has_sword = true
	sword_mission_started = true
	sword_mission_completed = true
	if is_instance_valid(player) and player.has_method("set_sword_equipped"):
		player.call("set_sword_equipped", true)
	sword_equipment_changed.emit(true)
	sword_mission_changed.emit(true, true)
	request_autosave()
	return true


func recover_castle_equipment(player: Node = null) -> bool:
	if castle_equipment_recovered or has_sword:
		return false
	castle_equipment_recovered = true
	has_sword = true
	sword_mission_started = true
	sword_mission_completed = true
	if is_instance_valid(player) and player.has_method("set_sword_equipped"):
		player.call("set_sword_equipped", true)
	sword_equipment_changed.emit(true)
	sword_mission_changed.emit(true, true)
	request_autosave()
	return true


func mark_sword_guard_defeated() -> void:
	if sword_guard_defeated:
		return
	sword_guard_defeated = true
	request_autosave()

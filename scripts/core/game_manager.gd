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

var pending_spawn_id: StringName = &""
var previous_scene_path: String = ""
var current_scene_path: String = ""

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

## Muerte: el mapa se recarga y el Player reaparece en el último punto de
## reaparición (entrada del mapa o checkpoint). Enemigos y jefes no derrotados
## vuelven a su estado inicial; el progreso de arriba se conserva.
var respawn_scene_path: String = ""
var respawn_position: Vector2 = Vector2.ZERO
## Cofres abiertos y objetos rotos ("escena|ruta del nodo"), para que no
## vuelvan a soltar botín al recargar el mapa.
var consumed_objects: Dictionary = {}

const DEATH_FADE_IN := 0.6
const DEATH_HOLD := 0.7
const DEATH_FADE_OUT := 0.5

var _respawning_after_death: bool = false
var _death_respawn_pending: bool = false
var _death_layer: CanvasLayer
var _death_fade: ColorRect
var _death_label: Label


func set_transition(target_spawn_id: StringName) -> void:
    pending_spawn_id = target_spawn_id

    var current_scene := get_tree().current_scene
    if current_scene != null:
        previous_scene_path = current_scene.scene_file_path


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


func is_object_consumed(node: Node) -> bool:
    var key := object_key(node)
    return not key.is_empty() and consumed_objects.has(key)


func mark_world1_boss_defeated() -> void:
    if world1_boss_defeated:
        return
    world1_boss_defeated = true
    world1_boss_defeated_changed.emit(true)


func grant_world1_boss_key() -> void:
    if world1_boss_key_collected:
        return
    world1_boss_key_collected = true
    world1_boss_key_changed.emit(true)


func has_world1_boss_key() -> bool:
    return world1_boss_key_collected


func add_coins(amount: int) -> void:
    if amount <= 0:
        return
    coins += amount
    coins_changed.emit(coins)


func try_spend_coins(amount: int) -> bool:
    if amount <= 0 or coins < amount:
        return false
    coins -= amount
    coins_changed.emit(coins)
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


func use_potion() -> bool:
    if potions <= 0:
        return false
    potions -= 1
    potions_changed.emit(potions)
    return true


func mark_w2_knight_defeated() -> void:
    if w2_knight_defeated:
        return
    w2_knight_defeated = true
    w2_knight_defeated_changed.emit(true)


func has_w2_knight_been_defeated() -> bool:
    return w2_knight_defeated


func reveal_cthulhu() -> void:
    if cthulhu_revealed:
        return
    cthulhu_revealed = true
    cthulhu_revealed_changed.emit(true)


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


func is_encounter_completed(encounter_id: String) -> bool:
    if encounter_id.is_empty():
        return false
    return bool(completed_encounters.get(encounter_id, false))


func grant_key(key_id: String) -> void:
    if key_id.is_empty() or has_key(key_id):
        return
    collected_keys[key_id] = true
    key_changed.emit(key_id, true)


func has_key(key_id: String) -> bool:
    if key_id.is_empty():
        return false
    return bool(collected_keys.get(key_id, false))


## Para el HUD: cualquier llave de jefe, incluida la de Mundo 1.
func has_any_key() -> bool:
    return world1_boss_key_collected or not collected_keys.is_empty()


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
    cthulhu_revealed = false
    w2_knight_defeated = false
    completed_encounters.clear()
    collected_keys.clear()
    respawn_scene_path = ""
    respawn_position = Vector2.ZERO
    consumed_objects.clear()
    reset_cinematics_for_new_game()
    reset_upgrades_for_new_game()
    world1_boss_defeated_changed.emit(false)
    world1_boss_key_changed.emit(false)
    coins_changed.emit(coins)
    potions_changed.emit(potions)
    cthulhu_revealed_changed.emit(false)
    w2_knight_defeated_changed.emit(false)

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


## Para una futura opción de Partida nueva; nunca se llama en respawn.
func reset_cinematics_for_new_game() -> void:
    cinematics_seen.clear()

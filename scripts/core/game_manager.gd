extends Node
class_name UnderkingdomGameManager

## Estado global mínimo. Continúa siendo deliberadamente pequeño, pero ahora
## conserva el progreso obligatorio del primer jefe de Mundo 1.

signal world1_boss_defeated_changed(defeated: bool)
signal world1_boss_key_changed(has_key: bool)

var pending_spawn_id: StringName = &""
var previous_scene_path: String = ""
var current_scene_path: String = ""

var world1_boss_defeated: bool = false
var world1_boss_key_collected: bool = false


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

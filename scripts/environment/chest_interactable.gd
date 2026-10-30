extends AnimatedSprite2D
class_name UnderkingdomChest

## Cofre de dos estados: frame 0 cerrado, frame 1 abierto.
## E abre/cierra visualmente. El loot solo sale en la primera apertura.

const COIN_SCENE: PackedScene = preload("res://escenas/objetos/coin_pickup.tscn")
const POTION_SCENE: PackedScene = preload("res://escenas/objetos/potion_pickup.tscn")

@export_category("Interaccion")
@export_range(16.0, 160.0, 1.0) var interaction_radius: float = 54.0

@export_category("Loot")
@export_range(0, 20, 1) var coin_count: int = 0
@export_range(0, 20, 1) var potion_count: int = 0
@export var coin_offsets: PackedVector2Array = PackedVector2Array()
@export var potion_offsets: PackedVector2Array = PackedVector2Array()

var is_open: bool = false
var loot_given: bool = false
var _opening: bool = false
var _used_loot_x: Array[float] = []


func _ready() -> void:
    stop()
    # Si ya se abriÃ³, conserva el frame y vuelve a mostrar solo el botÃ­n pendiente.
    var chest_key := _persistent_chest_key()
    loot_given = GameManager.consumed_objects.has(chest_key) if not chest_key.is_empty() else GameManager.is_object_consumed(self)
    is_open = loot_given
    frame = 1 if is_open else 0
    frame_progress = 0.0
    add_to_group("interactable")
    if loot_given:
        call_deferred("_spawn_loot")


func can_interact(player: Node) -> bool:
    if not (player is Node2D):
        return false
    return global_position.distance_to((player as Node2D).global_position) <= interaction_radius


func interact(player: Node) -> bool:
    if not can_interact(player):
        return false
    _toggle_chest()
    return true


func _toggle_chest() -> void:
    if _opening:
        return
    if is_open:
        is_open = false
        stop()
        frame = 0
        frame_progress = 0.0
        return

    is_open = true
    stop()
    frame = 0
    frame_progress = 0.0
    if loot_given:
        frame = 1
        return

    loot_given = true
    var chest_key := _persistent_chest_key()
    if chest_key.is_empty():
        GameManager.mark_object_consumed(self)
    else:
        GameManager.consumed_objects[chest_key] = true
        GameManager.request_autosave()
    _opening = true
    if sprite_frames != null and sprite_frames.has_animation(animation) and sprite_frames.get_frame_count(animation) > 1:
        play()
        await animation_finished
    stop()
    frame = 1
    frame_progress = 0.0
    _opening = false
    _spawn_loot()


func _spawn_loot() -> void:
    _used_loot_x.clear()
    var total_loot := coin_count + potion_count
    var slot_index := 0
    for index in range(coin_count):
        var offset := _offset_for_index(coin_offsets, index, total_loot, 16.0, Vector2(0, 8), slot_index)
        offset = _separate_loot_offset(offset, slot_index, total_loot, 16.0)
        _spawn_drop(COIN_SCENE, offset, "coin", index)
        slot_index += 1

    for index in range(potion_count):
        var offset := _offset_for_index(potion_offsets, index, total_loot, 16.0, Vector2(0, 8), slot_index)
        offset = _separate_loot_offset(offset, slot_index, total_loot, 16.0)
        _spawn_drop(POTION_SCENE, offset, "potion", index)
        slot_index += 1


func _spawn_drop(scene: PackedScene, offset: Vector2, loot_type: String, loot_index: int) -> void:
    var parent := get_parent() as Node2D
    if scene == null or parent == null:
        return

    var chest_key := _persistent_chest_key()
    var loot_key := "%s|loot_%s_%d" % [chest_key, loot_type, loot_index] if not chest_key.is_empty() else ""
    if not loot_key.is_empty() and GameManager.consumed_objects.has(loot_key):
        return

    var spawn_global := _loot_spawn_position()
    var landing_global := _find_landing_position(spawn_global + offset)
    var launch_global := spawn_global + Vector2(offset.x * 0.2, -14.0)
    var drop := scene.instantiate()
    if drop is Node2D:
        # Asigna coordenadas locales antes de add_child: el _ready del pickup
        # crea su Tween inmediatamente al entrar en el árbol.
        (drop as Node2D).position = parent.to_local(launch_global)
        if drop.has_method("configure_chest_ejection"):
            drop.call("configure_chest_ejection", landing_global, loot_key)
    parent.add_child(drop)


func _persistent_chest_key() -> String:
    var chest_key := GameManager.object_key(self)
    if chest_key.is_empty():
        var current_scene := get_tree().current_scene
        if current_scene != null:
            chest_key = "%s|%s" % [current_scene.scene_file_path, current_scene.get_path_to(self)]
    return chest_key


func _loot_spawn_position() -> Vector2:
    var marker := get_node_or_null("LootSpawnPoint") as Marker2D
    return marker.global_position if marker != null else global_position


func _find_landing_position(candidate: Vector2) -> Vector2:
    var query := PhysicsRayQueryParameters2D.create(
        candidate + Vector2(0.0, -40.0),
        candidate + Vector2(0.0, 64.0),
        1
    )
    var excluded: Array[RID] = []
    for player in get_tree().get_nodes_in_group("player"):
        if player is CollisionObject2D:
            excluded.append((player as CollisionObject2D).get_rid())
    query.exclude = excluded
    var hit := get_world_2d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return candidate
    # El pickup tiene un radio de 7 px; dejar su centro justo sobre la superficie.
    return Vector2(candidate.x, float(hit.position.y) - 7.0)


func _offset_for_index(
    offsets: PackedVector2Array,
    index: int,
    count: int,
    spacing: float,
    base: Vector2,
    slot_index: int
) -> Vector2:
    if index < offsets.size():
        return offsets[index]

    var center := (float(count) - 1.0) * 0.5
    return base + Vector2((float(slot_index) - center) * spacing, 0.0)


func _separate_loot_offset(offset: Vector2, slot_index: int, count: int, spacing: float) -> Vector2:
    var desired_x := offset.x
    var default_center := (float(count) - 1.0) * 0.5
    var default_x := (float(slot_index) - default_center) * spacing
    if _loot_x_is_free(desired_x, spacing):
        _used_loot_x.append(desired_x)
        return offset

    for radius in range(1, count + 2):
        var left_x := desired_x - float(radius) * spacing
        var right_x := desired_x + float(radius) * spacing
        var candidates := [left_x, right_x]
        if absf(right_x - default_x) < absf(left_x - default_x):
            candidates = [right_x, left_x]
        for candidate_x in candidates:
            if _loot_x_is_free(candidate_x, spacing):
                offset.x = candidate_x
                _used_loot_x.append(candidate_x)
                return offset

    offset.x = default_x
    _used_loot_x.append(default_x)
    return offset


func _loot_x_is_free(candidate_x: float, spacing: float) -> bool:
    for used_x in _used_loot_x:
        if absf(candidate_x - used_x) < spacing:
            return false
    return true

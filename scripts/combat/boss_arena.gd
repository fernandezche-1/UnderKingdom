extends Node2D
class_name UnderkingdomBossArena

## Sala de jefe: al entrar el Player en el Activador se cierran las Puertas y
## aparece el jefe. Al derrotarlo se abren las Puertas y los Atajos, y cae la
## llave en PuntoLlave. El resultado queda guardado en GameManager, así que al
## morir o volver al mapa la sala sigue abierta y el jefe no reaparece; si la
## llave no se recogió, vuelve a estar en su sitio.
##
## Hijos esperados:
##   Activador (Area2D)        zona que inicia el combate
##   Puertas/*                 UnderkingdomArenaBarrier: abiertas, se cierran durante el combate
##   Atajos/*                  UnderkingdomArenaBarrier: cerrados hasta derrotar al jefe
##   PuntosJefe/* (Marker2D)   el jefe sale en el más lejano al Player
##   PuntoLlave (Marker2D)     donde cae la llave
##   UI/Aviso (Label)          opcional: avisos de jefe y victoria

signal combat_started
signal boss_spawned(boss: Node2D)
signal boss_defeated
signal encounter_completed(encounter_id: String)
signal key_dropped(key: Node2D)

enum State { IDLE, BOSS_INTRO, BOSS, COMPLETED }

## Identificador de la sala en GameManager. Vacío = ruta de la escena + nodo.
@export var encounter_id: String = ""
@export var player_group: StringName = &"player"
## Nodo donde se agregan el jefe y la llave (normalmente "Enemigos" del mapa).
@export var spawn_parent_path: NodePath = ^"../../Enemigos"

@export_category("Jefe")
## Escena empaquetada del jefe; se reutiliza tal cual (stats, IA y fases).
@export var boss_scene: PackedScene
## Propiedades que se aplican al jefe antes de añadirlo al árbol.
@export var boss_overrides: Dictionary[String, Variant] = {}
@export_range(0.0, 5.0, 0.1) var boss_intro_delay: float = 1.2

@export_category("Recompensa")
## Escena de la llave (UnderkingdomBossKeyPickup); se le asigna key_id.
@export var key_scene: PackedScene
@export var key_id: String = ""

@export_category("Avisos")
@export var boss_message: String = "CAPITÁN"
@export var victory_message: String = "HAS VENCIDO"
@export_range(0.2, 5.0, 0.1) var message_time: float = 1.6

@onready var trigger: Area2D = $Activador
@onready var doors_root: Node = $Puertas
@onready var shortcuts_root: Node = get_node_or_null("Atajos")
@onready var boss_points_root: Node = $PuntosJefe
@onready var key_point: Node2D = get_node_or_null("PuntoLlave") as Node2D
@onready var notice: Label = get_node_or_null("UI/Aviso") as Label

var state: State = State.IDLE
var boss: Node2D = null

var _notice_tween: Tween = null


func _ready() -> void:
    if encounter_id.is_empty():
        encounter_id = GameManager.object_key(self)
    if notice != null:
        notice.visible = false

    _set_closed(doors_root, false, false)
    if GameManager.is_encounter_completed(encounter_id):
        state = State.COMPLETED
        _set_closed(shortcuts_root, false, false)
        trigger.monitoring = false
        # Murió o salió del mapa sin recoger la llave: vuelve a estar ahí.
        call_deferred("_drop_key")
        return

    _set_closed(shortcuts_root, true, false)
    trigger.body_entered.connect(_on_trigger_body_entered)


func _on_trigger_body_entered(body: Node2D) -> void:
    if state != State.IDLE or not body.is_in_group(player_group):
        return
    # Diferido: estamos dentro de una señal de física y se van a crear cuerpos.
    call_deferred("_start_combat")


func _start_combat() -> void:
    if state != State.IDLE:
        return
    state = State.BOSS_INTRO
    trigger.set_deferred("monitoring", false)
    _set_closed(doors_root, true)
    combat_started.emit()
    _show_notice(boss_message)
    _after(boss_intro_delay, _spawn_boss)


func _spawn_boss() -> void:
    if boss_scene == null:
        push_warning("BossArena %s: falta boss_scene; se da por completada." % name)
        _complete()
        return

    boss = _spawn_at(boss_scene, _boss_spawn_position(), boss_overrides)
    # Un jefe puede retirarse solo en su _ready (p. ej. si ya fue derrotado).
    if boss == null or boss.is_queued_for_deletion():
        _complete()
        return

    state = State.BOSS
    if boss.has_signal(&"died"):
        boss.connect(&"died", _on_boss_died, CONNECT_ONE_SHOT)
    # La sala se abre al terminar la animación de muerte.
    if boss.has_signal(&"death_finished"):
        boss.connect(&"death_finished", _complete, CONNECT_ONE_SHOT)
    else:
        boss.tree_exiting.connect(_complete, CONNECT_ONE_SHOT)
    boss_spawned.emit(boss)


func _on_boss_died() -> void:
    boss_defeated.emit()


func _complete() -> void:
    if state == State.COMPLETED:
        return
    state = State.COMPLETED
    GameManager.mark_encounter_completed(encounter_id)
    _set_closed(doors_root, false)
    _set_closed(shortcuts_root, false)
    _show_notice(victory_message)
    _drop_key()
    encounter_completed.emit(encounter_id)


func _drop_key() -> void:
    if key_scene == null or key_id.is_empty() or GameManager.has_key(key_id):
        return
    var key_position := key_point.global_position if key_point != null else global_position
    var key := _spawn_at(key_scene, key_position, {"key_id": key_id})
    if key != null:
        key_dropped.emit(key)


func _spawn_at(scene: PackedScene, world_position: Vector2, overrides: Dictionary[String, Variant] = {}) -> Node2D:
    var node := scene.instantiate() as Node2D
    if node == null:
        push_warning("BossArena %s: %s no es un Node2D." % [name, scene.resource_path])
        return null
    for property in overrides:
        node.set(property, overrides[property])

    var parent := _spawn_parent()
    # La posición se fija antes de entrar al árbol: los enemigos guardan su
    # punto de origen en _ready.
    node.position = parent.to_local(world_position) if parent is Node2D else world_position
    parent.add_child(node)
    if not node.is_queued_for_deletion():
        UnderkingdomCombatFX.spawn_puff(node)
    return node


func _spawn_parent() -> Node:
    var parent := get_node_or_null(spawn_parent_path)
    return parent if parent != null else self


func _boss_spawn_position() -> Vector2:
    var points: Array[Node2D] = []
    for child in boss_points_root.get_children():
        if child is Node2D:
            points.append(child as Node2D)
    if points.is_empty():
        return global_position

    var player := get_tree().get_first_node_in_group(player_group) as Node2D
    if player == null:
        return points[0].global_position

    var farthest := points[0]
    for point in points:
        if point.global_position.distance_squared_to(player.global_position) > farthest.global_position.distance_squared_to(player.global_position):
            farthest = point
    return farthest.global_position


## Llama a callback tras delay segundos. La conexión se pierde sola si la sala
## se libera antes (p. ej. el mapa se recarga al morir).
func _after(delay: float, callback: Callable) -> void:
    if delay <= 0.0:
        callback.call()
        return
    get_tree().create_timer(delay).timeout.connect(callback)


func _set_closed(root: Node, value: bool, animated: bool = true) -> void:
    if root == null:
        return
    for child in root.get_children():
        var barrier := child as UnderkingdomArenaBarrier
        if barrier != null:
            barrier.set_closed(value, animated)


func _show_notice(text: String) -> void:
    if notice == null or text.is_empty():
        return
    if _notice_tween != null:
        _notice_tween.kill()
    notice.text = text
    notice.visible = true
    notice.modulate.a = 1.0
    _notice_tween = create_tween()
    _notice_tween.tween_interval(message_time)
    _notice_tween.tween_property(notice, "modulate:a", 0.0, 0.4)
    _notice_tween.tween_callback(notice.hide)

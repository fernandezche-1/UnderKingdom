extends Node2D
class_name UnderkingdomArenaEncounter

## Encuentro de arena: al entrar el Player en el Activador se cierran las
## barreras y salen las oleadas en orden; al caer el último enemigo de la última
## oleada aparece el jefe. Al derrotarlo se abren las barreras y el encuentro
## queda completado para toda la partida (GameManager), así que no se repite al
## morir y recargar el mapa ni al volver desde el mapa siguiente.
##
## Hijos esperados:
##   Activador (Area2D)            zona que inicia el combate
##   Barreras/*                    UnderkingdomArenaBarrier
##   Oleadas/OleadaN/*             UnderkingdomArenaSpawnPoint (una oleada por nodo, en orden)
##   PuntosJefe/* (Marker2D)       el jefe sale en el más lejano al Player
##   UI/Aviso (Label, opcional)    avisos de oleada, jefe y victoria
##
## El progreso solo se lleva por señales: cada enemigo instanciado avisa con
## `died` (o al salir del árbol, por si desaparece sin morir) y el encuentro
## no conoce nada más de él.

signal combat_started
signal wave_started(wave_number: int, wave_count: int)
signal wave_cleared(wave_number: int, wave_count: int)
signal boss_spawned(boss: Node2D)
signal boss_defeated
signal encounter_completed(encounter_id: String)

enum State { IDLE, WAVES, BETWEEN_WAVES, BOSS_INTRO, BOSS, COMPLETED }

## Identificador del encuentro en GameManager. Vacío = ruta de la escena + nodo.
@export var encounter_id: String = ""
@export var player_group: StringName = &"player"
## Nodo donde se agregan los enemigos y el jefe (normalmente "Enemigos" del mapa).
@export var spawn_parent_path: NodePath = ^"../../Enemigos"

@export_category("Jefe")
## Escena empaquetada del jefe; se reutiliza tal cual (stats, IA y fases).
@export var boss_scene: PackedScene
## Propiedades que se aplican al jefe antes de añadirlo al árbol.
@export var boss_overrides: Dictionary[String, Variant] = {}

@export_category("Ritmo")
@export_range(0.0, 5.0, 0.1) var first_wave_delay: float = 0.6
@export_range(0.0, 5.0, 0.1) var delay_between_waves: float = 1.2
@export_range(0.0, 5.0, 0.1) var boss_intro_delay: float = 1.6

@export_category("Avisos")
## %d se reemplaza por la oleada actual y el total.
@export var wave_message: String = "OLEADA %d / %d"
@export var boss_message: String = "¡CAPITÁN!"
@export var victory_message: String = "ZONA DESPEJADA"
@export_range(0.2, 5.0, 0.1) var message_time: float = 1.6

@onready var trigger: Area2D = $Activador
@onready var barriers_root: Node = $Barreras
@onready var waves_root: Node = $Oleadas
@onready var boss_points_root: Node = $PuntosJefe
@onready var notice: Label = get_node_or_null("UI/Aviso") as Label

var state: State = State.IDLE
var current_wave: int = -1
var boss: Node2D = null

var _alive: Dictionary[int, bool] = {}
var _notice_tween: Tween = null


func _ready() -> void:
    if encounter_id.is_empty():
        encounter_id = GameManager.object_key(self)
    if notice != null:
        notice.visible = false

    if GameManager.is_encounter_completed(encounter_id):
        state = State.COMPLETED
        _set_barriers_closed(false, false)
        trigger.monitoring = false
        return

    _set_barriers_closed(false, false)
    trigger.body_entered.connect(_on_trigger_body_entered)


func wave_count() -> int:
    return _waves().size()


func _on_trigger_body_entered(body: Node2D) -> void:
    if state != State.IDLE or not body.is_in_group(player_group):
        return
    # Diferido: estamos dentro de una señal de física y se van a crear cuerpos.
    call_deferred("_start_combat")


func _start_combat() -> void:
    if state != State.IDLE:
        return
    state = State.WAVES
    trigger.set_deferred("monitoring", false)
    _set_barriers_closed(true)
    combat_started.emit()
    _after(first_wave_delay, _start_wave.bind(0))


func _start_wave(index: int) -> void:
    var waves := _waves()
    if index >= waves.size():
        # Sin oleadas configuradas: el jefe sale directamente.
        _start_boss_intro()
        return

    current_wave = index
    state = State.WAVES
    _show_notice(wave_message % [index + 1, waves.size()])
    wave_started.emit(index + 1, waves.size())

    for point in waves[index].get_children():
        var spawn_point := point as UnderkingdomArenaSpawnPoint
        if spawn_point == null or spawn_point.enemy_scene == null:
            continue
        var enemy := _spawn_at(spawn_point.enemy_scene, spawn_point.global_position)
        if enemy != null:
            _track_enemy(enemy)

    # Una oleada vacía o mal configurada no debe dejar al Player encerrado.
    if _alive.is_empty():
        push_warning("ArenaEncounter %s: la oleada %d no tiene enemigos." % [name, index + 1])
        _check_wave_cleared()


func _track_enemy(enemy: Node2D) -> void:
    var enemy_id := enemy.get_instance_id()
    _alive[enemy_id] = true
    if enemy.has_signal(&"died"):
        enemy.connect(&"died", _on_tracked_enemy_gone.bind(enemy_id), CONNECT_ONE_SHOT)
    enemy.tree_exiting.connect(_on_tracked_enemy_gone.bind(enemy_id), CONNECT_ONE_SHOT)


func _on_tracked_enemy_gone(enemy_id: int) -> void:
    if not _alive.erase(enemy_id):
        return
    # Diferido: si el mapa se está descargando, la llamada se descarta sola.
    call_deferred("_check_wave_cleared")


func _check_wave_cleared() -> void:
    if state != State.WAVES or not _alive.is_empty():
        return

    # Cada muerte deja una comprobación diferida: solo la primera que encuentra
    # la oleada vacía avanza, las demás ya ven otro estado.
    state = State.BETWEEN_WAVES
    var waves_total := wave_count()
    wave_cleared.emit(current_wave + 1, waves_total)
    if current_wave + 1 >= waves_total:
        _start_boss_intro()
    else:
        _after(delay_between_waves, _start_wave.bind(current_wave + 1))


func _start_boss_intro() -> void:
    state = State.BOSS_INTRO
    _show_notice(boss_message)
    _after(boss_intro_delay, _spawn_boss)


func _spawn_boss() -> void:
    if boss_scene == null:
        push_warning("ArenaEncounter %s: falta boss_scene; se da por completado." % name)
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
    _set_barriers_closed(false)
    _show_notice(victory_message)
    encounter_completed.emit(encounter_id)


func _spawn_at(scene: PackedScene, world_position: Vector2, overrides: Dictionary[String, Variant] = {}) -> Node2D:
    var node := scene.instantiate() as Node2D
    if node == null:
        push_warning("ArenaEncounter %s: %s no es un Node2D." % [name, scene.resource_path])
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


## Llama a callback tras delay segundos. La conexión se pierde sola si el
## encuentro se libera antes (p. ej. el mapa se recarga al morir).
func _after(delay: float, callback: Callable) -> void:
    if delay <= 0.0:
        callback.call()
        return
    get_tree().create_timer(delay).timeout.connect(callback)


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


func _waves() -> Array[Node]:
    var waves: Array[Node] = []
    for child in waves_root.get_children():
        waves.append(child)
    return waves


func _set_barriers_closed(value: bool, animated: bool = true) -> void:
    for child in barriers_root.get_children():
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

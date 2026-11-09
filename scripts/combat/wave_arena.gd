extends Node2D
class_name UnderkingdomWaveArena

## Arena cerrada con oleadas (coliseo de los condenados y salón de los
## verdugos del infierno, coliseo de ceniza de las profundidades; P67). Al
## entrar el Player en el Activador se cierran las Puertas y empieza la primera
## oleada. Cada oleada es un nodo hijo de Oleadas con sus enemigos: quedan
## fuera del árbol (no se ven, no colisionan ni procesan) hasta que su oleada
## empieza, y entonces aparecen donde se colocaron, con una nube de humo.
## Vencidos todos los de una oleada, la siguiente sale tras wave_delay. Al
## vencer la última se abren las Puertas y los Atajos y se marca encounter_id
## en GameManager.completed_encounters (lo pueden escuchar barreras, sellos y
## encounter_visibility.gd).
##
## Al morir, el mapa se recarga y la arena vuelve a empezar entera: puertas
## abiertas y oleadas desde la primera (I2). Superada, se queda abierta y sin
## enemigos.
##
## Hijos esperados:
##   Activador (Area2D)    zona que inicia el combate
##   Puertas/*             UnderkingdomArenaBarrier: abiertas, se cierran durante el combate
##   Atajos/*              opcional; UnderkingdomArenaBarrier cerrados hasta superar la arena
##   Oleadas/<n>/*         un nodo por oleada, en orden, con sus enemigos colocados
##   UI/Aviso (Label)      opcional: avisos de oleada y victoria

signal combat_started
signal wave_started(wave_index: int, wave_count: int)
signal wave_cleared(wave_index: int)
signal encounter_completed(encounter_id: String)

enum State { IDLE, STARTING, WAVE, BETWEEN_WAVES, COMPLETED }

## Identificador en GameManager. Vacío = ruta de la escena + nodo. Puede ser
## una marca con nombre que escuchan otras zonas (infierno_animas_liberadas).
@export var encounter_id: String = ""
@export var player_group: StringName = &"player"

@export_category("Ritmo")
## Espera entre cerrarse las puertas y salir la primera oleada.
@export_range(0.0, 5.0, 0.1) var start_delay: float = 0.8
## Espera entre vencer una oleada y salir la siguiente (I1).
@export_range(0.0, 5.0, 0.1) var wave_delay: float = 1.5
## Espera entre vencer la última oleada y abrirse la arena.
@export_range(0.0, 5.0, 0.1) var finish_delay: float = 1.0

@export_category("Avisos")
## Se muestra al empezar cada oleada; %d = número de oleada y total. Vacío = nada.
@export var wave_message: String = "OLEADA %d/%d"
@export var victory_message: String = "ARENA SUPERADA"
@export_range(0.2, 5.0, 0.1) var message_time: float = 1.6

@onready var trigger: Area2D = $Activador
@onready var doors_root: Node = $Puertas
@onready var shortcuts_root: Node = get_node_or_null("Atajos")
@onready var waves_root: Node = $Oleadas
@onready var notice: Label = get_node_or_null("UI/Aviso") as Label

var state: State = State.IDLE
var current_wave: int = -1

## Por oleada: [nodo padre, enemigos guardados fuera del árbol].
var _waves: Array[Dictionary] = []
var _alive: Array[Node] = []
var _notice_tween: Tween = null


func _ready() -> void:
	if encounter_id.is_empty():
		encounter_id = GameManager.object_key(self)
	if notice != null:
		notice.visible = false

	_collect_waves()
	_set_closed(doors_root, false, false)
	if GameManager.is_encounter_completed(encounter_id):
		state = State.COMPLETED
		_set_closed(shortcuts_root, false, false)
		trigger.monitoring = false
		_free_stored_enemies()
		return

	_set_closed(shortcuts_root, true, false)
	trigger.body_entered.connect(_on_trigger_body_entered)


func _notification(what: int) -> void:
	# Los enemigos que nunca salieron no están en el árbol: se liberan a mano.
	if what == NOTIFICATION_PREDELETE:
		_free_stored_enemies()


func get_wave_count() -> int:
	return _waves.size()


func is_completed() -> bool:
	return state == State.COMPLETED


## Enemigos de la oleada en curso que siguen vivos.
func get_alive_enemies() -> Array[Node]:
	return _alive.duplicate()


## Saca los enemigos de cada oleada del árbol. Su _ready ya corrió (los hijos
## están listos antes que la arena), así que guardan su punto de origen.
func _collect_waves() -> void:
	for wave in waves_root.get_children():
		var enemies: Array[Node] = []
		for child in wave.get_children():
			enemies.append(child)
		for enemy in enemies:
			wave.remove_child(enemy)
		_waves.append({"parent": wave, "enemies": enemies})


func _free_stored_enemies() -> void:
	for wave in _waves:
		var enemies: Array[Node] = wave["enemies"]
		for enemy in enemies:
			if is_instance_valid(enemy) and not enemy.is_inside_tree():
				enemy.free()
		enemies.clear()


func _on_trigger_body_entered(body: Node2D) -> void:
	if state != State.IDLE or not body.is_in_group(player_group):
		return
	# Diferido: estamos dentro de una señal de física y se van a añadir cuerpos.
	call_deferred("_start_combat")


func _start_combat() -> void:
	if state != State.IDLE:
		return
	state = State.STARTING
	trigger.set_deferred("monitoring", false)
	_set_closed(doors_root, true)
	combat_started.emit()
	_after(start_delay, _start_next_wave)


func _start_next_wave() -> void:
	if state == State.COMPLETED:
		return
	current_wave += 1
	if current_wave >= _waves.size():
		_after(finish_delay, _complete)
		return

	state = State.WAVE
	var wave: Dictionary = _waves[current_wave]
	var parent: Node = wave["parent"]
	var enemies: Array[Node] = wave["enemies"]
	_alive.clear()
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		parent.add_child(enemy)
		if enemy.is_queued_for_deletion():
			continue
		_alive.append(enemy)
		if enemy is Node2D:
			UnderkingdomCombatFX.spawn_puff(enemy as Node2D)
		if enemy.has_signal(&"died"):
			enemy.connect(&"died", _on_enemy_defeated.bind(enemy), CONNECT_ONE_SHOT)
		# Respaldo: un enemigo que sale del árbol sin morir (cae a una kill zone
		# que lo libera, o no es un enemigo con vida) también cuenta.
		enemy.tree_exiting.connect(_on_enemy_defeated.bind(enemy), CONNECT_ONE_SHOT)
	enemies.clear()

	if not wave_message.is_empty():
		_show_notice(wave_message % [current_wave + 1, _waves.size()] if wave_message.contains("%d") else wave_message)
	wave_started.emit(current_wave, _waves.size())
	if _alive.is_empty():
		_on_wave_cleared()


func _on_enemy_defeated(enemy: Node) -> void:
	if state != State.WAVE or not _alive.has(enemy):
		return
	_alive.erase(enemy)
	if _alive.is_empty():
		_on_wave_cleared()


func _on_wave_cleared() -> void:
	state = State.BETWEEN_WAVES
	wave_cleared.emit(current_wave)
	var is_last := current_wave >= _waves.size() - 1
	if is_last:
		_after(finish_delay, _complete)
	else:
		_after(wave_delay, _start_next_wave)


func _complete() -> void:
	if state == State.COMPLETED:
		return
	state = State.COMPLETED
	GameManager.mark_encounter_completed(encounter_id)
	_set_closed(doors_root, false)
	_set_closed(shortcuts_root, false)
	_show_notice(victory_message)
	encounter_completed.emit(encounter_id)


## Llama a callback tras delay segundos. La conexión se pierde sola si la
## arena se libera antes (el mapa se recarga al morir).
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

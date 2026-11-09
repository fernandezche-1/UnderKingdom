extends Node2D
class_name UnderkingdomCollapse

## Suelo que se hunde y secuencia de derrumbe y huida (`[!5]` de la mazmorra,
## P64). Una sola pieza genérica:
##
## 1. Arranca cuando GameManager marca `trigger_encounter` (la sala de la
##    Reina) o al llamar a `start()`. Si `wait_for_ability` no está vacío,
##    espera a que el Player recoja esa habilidad (la reliquia flota y no cae
##    con el suelo).
## 2. TEMBLOR (`tremor_time`): la cámara tiembla, el suelo vibra y las
##    barreras de `sealed_barriers` (la trampilla de entrada) se cierran.
## 3. HUNDIMIENTO: el suelo (`floor_width_tiles` x `floor_height_tiles`
##    piezas, origen arriba a la izquierda de este nodo) se rompe a trozos, del
##    centro hacia fuera, y cae. Se marca `collapse_id`.
## 4. HUIDA, sin tiempo límite: la cámara tiembla un poco y caen escombros en
##    los `Marker2D` hijos de `Escombros`, con un aviso de polvo antes. Cada
##    escombro quita 0.5. Acaba al entrar el Player en `exit_area_path`, que
##    marca `collapse_id + "_huida"`.
##
## Se recuerda en `completed_encounters` (sin cambiar el formato de guardado):
## con el derrumbe marcado el suelo ya no existe y las barreras empiezan
## cerradas; con la huida marcada ya no tiembla ni caen escombros.
##
## El suelo es un StaticBody2D propio: en la zona hay que dejar el hueco en el
## trazado y rellenarlo con esta pieza (ver docs/P64_DERRUMBE_Y_HUIDA.md).
## Hijos opcionales: `Escombros` (Marker2D, donde caen las piedras).

signal tremor_started
signal collapsed
signal escape_finished

const TILE: float = 16.0
const OVERLAY_LAYER: int = 9

enum Phase { IDLE, WAITING, TREMOR, CRUMBLING, ESCAPE, DONE }

## Encuentro que lo dispara, normalmente el `encounter_id` de la BossArena.
@export var trigger_encounter: String = ""
## Habilidad (id de GameManager.ABILITY_DEFINITIONS) que hay que haber recogido
## antes de que empiece el temblor. Vacío = empieza en cuanto se dispara.
@export var wait_for_ability: String = ""
## Marca que deja el hundimiento. La huida marca este id + "_huida".
@export var collapse_id: String = "derrumbe"
## Barreras que se cierran al empezar y no se vuelven a abrir (la trampilla de
## entrada de la sala). Rutas a nodos UnderkingdomArenaBarrier.
@export var sealed_barriers: Array[NodePath] = []
## Zona (Area2D) cuya entrada da por terminada la huida.
@export var exit_area_path: NodePath = ^""

@export_category("Suelo")
@export_range(1, 64, 1) var floor_width_tiles: int = 15
@export_range(1, 4, 1) var floor_height_tiles: int = 1
## Pieza del suelo (a escala 1, 16 x 16). Sin ella, una piedra provisional.
@export var piece_texture: Texture2D = null
@export var piece_tint: Color = Color.WHITE

@export_category("Temblor y hundimiento")
@export_range(0.2, 5.0, 0.1) var tremor_time: float = 1.5
## Segundos entre el hundimiento de una pieza y la siguiente fila hacia fuera.
@export_range(0.0, 0.5, 0.01) var crumble_stagger: float = 0.06
@export_range(0.0, 1.0, 0.05) var crumble_shake_time: float = 0.3
@export_range(0.0, 8.0, 1.0) var tremor_shake_strength: float = 3.0
@export var collapse_message: String = "TODO SE DERRUMBA"

@export_category("Huida")
@export_range(0.5, 6.0, 0.1) var rubble_interval: float = 1.6
@export_range(0.2, 2.0, 0.1) var rubble_warning_time: float = 0.8
## Altura sobre el punto de caída desde la que sale el escombro.
@export_range(32.0, 400.0, 16.0) var rubble_fall_height: float = 128.0
@export_range(0.25, 4.0, 0.25) var rubble_damage: float = 0.5
## Solo caen escombros en los puntos a menos de esta distancia horizontal del
## Player, para no gastarlos fuera de pantalla.
@export_range(32.0, 640.0, 16.0) var rubble_range: float = 240.0
@export_range(0.0, 4.0, 1.0) var escape_shake_strength: float = 1.0

var phase: Phase = Phase.IDLE

var _floor: StaticBody2D = null
var _pieces: Array[Sprite2D] = []
var _shapes: Array[CollisionShape2D] = []
var _rubble_points: Array[Marker2D] = []
var _rubble_cursor: int = 0
var _rubble_timer: float = 0.0
var _shake_timer: float = 0.0
var _vibrate: bool = false
var _label: Label = null
var _label_tween: Tween = null


func _ready() -> void:
	var points_root := get_node_or_null("Escombros")
	if points_root != null:
		for child in points_root.get_children():
			if child is Marker2D:
				_rubble_points.append(child as Marker2D)

	var exit_area := get_node_or_null(exit_area_path) as Area2D
	if exit_area != null:
		exit_area.body_entered.connect(_on_exit_body_entered)

	if GameManager.is_encounter_completed(escape_id()):
		phase = Phase.DONE
		_seal_barriers_now()
		return
	if GameManager.is_encounter_completed(collapse_id):
		# Volvió o recargó a mitad de la huida: el suelo ya no está.
		phase = Phase.ESCAPE
		_seal_barriers_now()
		_rubble_timer = rubble_interval
		return

	_build_floor()
	if GameManager.is_encounter_completed(trigger_encounter):
		call_deferred("start")
	elif not trigger_encounter.is_empty():
		GameManager.encounter_completed.connect(_on_encounter_completed)


func _process(delta: float) -> void:
	if _vibrate:
		for piece in _pieces:
			if is_instance_valid(piece) and piece.visible:
				var rest_x: float = piece.get_meta(&"rest_x")
				piece.position.x = rest_x + float(randi_range(-1, 1))

	if phase != Phase.ESCAPE:
		return
	_shake_timer -= delta
	if _shake_timer <= 0.0:
		_shake_timer = 0.5
		_shake_camera(escape_shake_strength, 0.5)
	_rubble_timer -= delta
	if _rubble_timer <= 0.0:
		_rubble_timer = rubble_interval
		_next_rubble()


func escape_id() -> String:
	return collapse_id + "_huida"


## Empieza la secuencia. Público para probarla o dispararla desde otro script.
func start() -> void:
	if phase != Phase.IDLE:
		return
	phase = Phase.WAITING
	if (
		not wait_for_ability.is_empty()
		and not GameManager.is_ability_unlocked(wait_for_ability)
	):
		GameManager.ability_unlocked.connect(_on_ability_unlocked)
		return
	_begin_tremor()


## Da la huida por terminada (la salida de la zona). Público por lo mismo.
func finish_escape() -> void:
	if phase != Phase.ESCAPE:
		return
	phase = Phase.DONE
	GameManager.mark_encounter_completed(escape_id())
	escape_finished.emit()


func _on_encounter_completed(encounter_id: String) -> void:
	if encounter_id == trigger_encounter:
		start()


func _on_ability_unlocked(ability_id: String) -> void:
	if ability_id != wait_for_ability or phase != Phase.WAITING:
		return
	GameManager.ability_unlocked.disconnect(_on_ability_unlocked)
	_begin_tremor()


func _on_exit_body_entered(body: Node2D) -> void:
	if phase == Phase.ESCAPE and body.is_in_group(&"player"):
		finish_escape()


func _begin_tremor() -> void:
	phase = Phase.TREMOR
	tremor_started.emit()
	_show_message(collapse_message)
	_set_barriers_closed(true, true)
	_shake_camera(tremor_shake_strength, tremor_time)
	_vibrate = true
	for index in _pieces.size():
		if index % 3 == 0:
			dust_burst(self, _pieces[index].global_position + Vector2(TILE * 0.5, 0.0), 3, 0.6)
	get_tree().create_timer(tremor_time).timeout.connect(_crumble)


func _crumble() -> void:
	if phase != Phase.TREMOR:
		return
	phase = Phase.CRUMBLING
	GameManager.mark_encounter_completed(collapse_id)
	_shake_camera(tremor_shake_strength, 0.6)

	# Del centro hacia fuera: cada columna espera según su distancia al centro.
	var center := (floor_width_tiles - 1) * 0.5
	var longest := 0.0
	for index in _pieces.size():
		@warning_ignore("integer_division")
		var column: int = index / floor_height_tiles
		var delay := absf(float(column) - center) * crumble_stagger
		longest = maxf(longest, delay + crumble_shake_time + 0.7)
		_drop_piece(index, delay)
	get_tree().create_timer(longest).timeout.connect(_on_crumbled)


func _drop_piece(index: int, delay: float) -> void:
	var piece := _pieces[index]
	var shape := _shapes[index]
	var tween := create_tween()
	tween.tween_interval(delay + crumble_shake_time)
	tween.tween_callback(func() -> void:
		shape.set_deferred("disabled", true)
		dust_burst(self, piece.global_position + Vector2(TILE * 0.5, TILE * 0.5), 3, 0.5)
	)
	tween.set_parallel(true)
	tween.tween_property(piece, "position:y", piece.position.y + 160.0, 0.7).set_ease(Tween.EASE_IN)
	tween.tween_property(piece, "modulate:a", 0.0, 0.7)
	tween.set_parallel(false)
	tween.tween_callback(piece.hide)


func _on_crumbled() -> void:
	_vibrate = false
	if is_instance_valid(_floor):
		_floor.queue_free()
		_floor = null
	_pieces.clear()
	_shapes.clear()
	phase = Phase.ESCAPE
	_rubble_timer = rubble_interval
	collapsed.emit()


# Escombros ------------------------------------------------------------------

func _next_rubble() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if player == null or _rubble_points.is_empty():
		return
	# Siguiente punto, en orden, que esté cerca del Player.
	for step in _rubble_points.size():
		var point := _rubble_points[(_rubble_cursor + step) % _rubble_points.size()]
		if absf(point.global_position.x - player.global_position.x) <= rubble_range:
			_rubble_cursor = (_rubble_cursor + step + 1) % _rubble_points.size()
			_drop_rubble(point.global_position)
			return


## Aviso de polvo arriba y, pasado rubble_warning_time, cae la piedra.
func _drop_rubble(landing: Vector2) -> void:
	var top := landing - Vector2(0.0, rubble_fall_height)
	dust_burst(self, top, 5, rubble_warning_time)
	var timer := get_tree().create_timer(rubble_warning_time)
	timer.timeout.connect(func() -> void:
		if phase != Phase.ESCAPE or not is_inside_tree():
			return
		var rubble := UnderkingdomFallingRubble.new()
		rubble.landing_y = landing.y
		rubble.damage_amount = rubble_damage
		add_child(rubble)
		rubble.global_position = top
	)


# Suelo y barreras -----------------------------------------------------------

func _build_floor() -> void:
	_floor = StaticBody2D.new()
	_floor.name = "Suelo"
	add_child(_floor)
	var texture := piece_texture if piece_texture != null else _default_texture()
	for column in floor_width_tiles:
		for row in floor_height_tiles:
			var origin := Vector2(column, row) * TILE
			var shape := CollisionShape2D.new()
			var rect := RectangleShape2D.new()
			rect.size = Vector2(TILE, TILE)
			shape.shape = rect
			shape.position = origin + Vector2(TILE, TILE) * 0.5
			_floor.add_child(shape)
			_shapes.append(shape)

			var piece := Sprite2D.new()
			piece.texture = texture
			piece.centered = false
			piece.position = origin
			piece.modulate = piece_tint
			piece.set_meta(&"rest_x", origin.x)
			_floor.add_child(piece)
			_pieces.append(piece)


func _set_barriers_closed(value: bool, animated: bool) -> void:
	for path in sealed_barriers:
		var barrier := get_node_or_null(path) as UnderkingdomArenaBarrier
		if barrier != null:
			barrier.set_closed(value, animated)


## Al cargar con el derrumbe ya marcado. Diferido: la BossArena abre sus
## puertas en su propio _ready y esto tiene que ir después.
func _seal_barriers_now() -> void:
	call_deferred("_set_barriers_closed", true, false)


static func _default_texture() -> Texture2D:
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.3, 0.26, 0.33))
	for x in 16:
		image.set_pixel(x, 0, Color(0.46, 0.41, 0.5))
		image.set_pixel(x, 15, Color(0.17, 0.14, 0.2))
	for y in 16:
		image.set_pixel(0, y, Color(0.17, 0.14, 0.2))
		image.set_pixel(15, y, Color(0.17, 0.14, 0.2))
	return ImageTexture.create_from_image(image)


# Efectos --------------------------------------------------------------------

func _shake_camera(strength: float, duration: float) -> void:
	if strength <= 0.0:
		return
	var camera := get_viewport().get_camera_2d()
	if camera != null and camera.has_method("shake"):
		camera.call("shake", strength, duration)


func _show_message(text: String) -> void:
	if text.is_empty():
		return
	if _label == null:
		var layer := CanvasLayer.new()
		layer.layer = OVERLAY_LAYER
		add_child(layer)
		_label = Label.new()
		_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
		_label.offset_top = 40.0
		_label.offset_bottom = 60.0
		_label.add_theme_font_size_override("font_size", 16)
		_label.add_theme_color_override("font_outline_color", Color.BLACK)
		_label.add_theme_constant_override("outline_size", 4)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		layer.add_child(_label)
	if _label_tween != null:
		_label_tween.kill()
	_label.text = text
	_label.modulate.a = 1.0
	_label.visible = true
	_label_tween = create_tween()
	_label_tween.tween_interval(1.6)
	_label_tween.tween_property(_label, "modulate:a", 0.0, 0.4)
	_label_tween.tween_callback(_label.hide)


## Polvo: cuadrados de 2 x 2 que suben y se apagan (a escala entera).
static func dust_burst(parent: Node, at: Vector2, count: int, lifetime: float) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	for index in count:
		var speck := ColorRect.new()
		speck.size = Vector2(2.0, 2.0)
		speck.color = Color(0.62, 0.57, 0.66, 0.9)
		speck.z_index = 25
		parent.add_child(speck)
		speck.global_position = at + Vector2(float(randi_range(-8, 8)), float(randi_range(-4, 4)))
		var target := speck.position + Vector2(float(randi_range(-6, 6)), float(randi_range(-14, -4)))
		var tween := speck.create_tween()
		tween.set_parallel(true)
		tween.tween_property(speck, "position", Vector2(roundf(target.x), roundf(target.y)), lifetime)
		tween.tween_property(speck, "modulate:a", 0.0, lifetime)
		tween.set_parallel(false)
		tween.tween_callback(speck.queue_free)

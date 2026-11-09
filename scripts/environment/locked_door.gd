extends UnderkingdomArenaBarrier
class_name UnderkingdomLockedDoor

## Puerta con llave: bloquea el paso hasta que el Player llega a ella con la
## llave key_id de GameManager. Una vez abierta queda abierta para toda la
## partida (se guarda como objeto consumido, igual que los cofres).
##
## Dos maneras de abrirla (P57):
##  - sola, al acercarse con la llave (por defecto, las puertas de siempre);
##  - con E delante (`require_interact`): velas, hielo de [P6], hielo negro.
## `open_effect` cambia cómo se ve al abrirse; el dibujo son las piezas del
## barrier (`piece_*`) y `piece_tint`. Detalle en docs/P57_PUERTA_CON_OTRO_DIBUJO.md.

enum OpenEffect { FADE, CANDLES, MELT }

@export var key_id: String = ""
## Se abre al llegar con espada, en vez de con la llave.
@export var requires_sword: bool = false
@export var player_group: StringName = &"player"
## Distancia a cada lado de la puerta a la que se detecta al Player.
@export_range(0.0, 64.0, 1.0) var detect_margin: float = 20.0
@export var locked_message: String = "NECESITAS UNA LLAVE"
@export var opened_message: String = "PUERTA ABIERTA"

@export_category("Interaccion")
## Con true, la puerta no se abre al acercarse: hace falta pulsar E delante
## (la misma acción que npc.gd). Sin la llave, E saca `locked_message`.
@export var require_interact: bool = false
@export var prompt_text: String = "E  Abrir"
@export_range(8.0, 64.0, 1.0) var interact_margin: float = 24.0

@export_category("Dibujo y efecto")
## FADE: se desvanece (como siempre). CANDLES: las velas se encienden y se
## apaga la puerta entre chispas. MELT: el hielo se derrite hacia abajo, con gotas.
@export var open_effect: OpenEffect = OpenEffect.FADE
## Color que multiplica a cada pieza (hielo negro, velas...). Blanco = sin cambio.
@export var piece_tint: Color = Color.WHITE
@export_range(0.1, 3.0, 0.05) var effect_time: float = 0.9

var _message: Label = null
var _message_tween: Tween = null
var _prompt: Label = null
var _effect_tween: Tween = null


func _ready() -> void:
    start_closed = not GameManager.is_object_consumed(self)
    super._ready()
    for piece in _pieces.get_children():
        (piece as CanvasItem).modulate = piece_tint
    if not closed:
        return
    if require_interact:
        add_to_group("interactable")
        _build_prompt()
    else:
        _build_detector()


func _process(_delta: float) -> void:
    if _prompt == null:
        return
    var player := get_tree().get_first_node_in_group(player_group) as Node2D
    _prompt.visible = closed and player != null and can_interact(player)


func can_interact(player: Node) -> bool:
    if not require_interact or not closed or not (player is Node2D):
        return false
    var rect := collision.shape as RectangleShape2D
    if rect == null:
        return false
    var local := (player as Node2D).global_position - to_global(collision.position)
    return absf(local.x) <= rect.size.x * 0.5 + interact_margin \
        and absf(local.y) <= rect.size.y * 0.5 + 32.0


func interact(player: Node) -> bool:
    if not can_interact(player):
        return false
    _try_open(signf((player as Node2D).global_position.x - global_position.x))
    return true


func _build_detector() -> void:
    var rect := collision.shape as RectangleShape2D
    if rect == null:
        return
    var detector := Area2D.new()
    detector.name = "Detector"
    detector.collision_layer = 0
    detector.collision_mask = 1
    detector.monitorable = false
    var shape := CollisionShape2D.new()
    var area_rect := RectangleShape2D.new()
    area_rect.size = rect.size + Vector2(detect_margin * 2.0, 0.0)
    shape.shape = area_rect
    shape.position = collision.position
    detector.add_child(shape)
    add_child(detector)
    detector.body_entered.connect(_on_detector_body_entered)


func _on_detector_body_entered(body: Node2D) -> void:
    if not closed or not body.is_in_group(player_group):
        return
    _try_open(signf(body.global_position.x - global_position.x))


func _try_open(side: float) -> void:
    # El mensaje sale hacia el lado del Player: así no se corta cuando la
    # puerta está junto al borde del mapa.
    var unlocked := GameManager.has_sword if requires_sword else GameManager.has_key(key_id)
    if not unlocked:
        _show_message(locked_message, side)
        return
    GameManager.mark_object_consumed(self)
    open()
    _show_message(opened_message, side)


func _show_message(text: String, side: float = 0.0) -> void:
    if text.is_empty():
        return
    if _message == null:
        _message = Label.new()
        _message.add_theme_font_size_override("font_size", 8)
        _message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _message.size = Vector2(160, 12)
        _message.z_index = 20
        add_child(_message)
    if _message_tween != null:
        _message_tween.kill()

    var top := collision.position.y - (collision.shape as RectangleShape2D).size.y * 0.5
    _message.text = text
    var half_width := _message.size.x * 0.5
    _message.position = Vector2(-half_width + side * (half_width - 8.0), top - 20.0)
    _message.modulate.a = 1.0
    _message.visible = true
    _message_tween = _message.create_tween()
    _message_tween.tween_interval(1.4)
    _message_tween.tween_property(_message, "modulate:a", 0.0, 0.4)
    _message_tween.tween_callback(_message.hide)


func _build_prompt() -> void:
    var rect := collision.shape as RectangleShape2D
    _prompt = Label.new()
    _prompt.add_theme_font_size_override("font_size", 8)
    _prompt.add_theme_color_override("font_outline_color", Color.BLACK)
    _prompt.add_theme_constant_override("outline_size", 3)
    _prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _prompt.size = Vector2(64, 12)
    _prompt.z_index = 30
    _prompt.text = prompt_text
    _prompt.position = Vector2(collision.position.x - 32.0, collision.position.y - rect.size.y * 0.5 - 14.0)
    _prompt.visible = false
    add_child(_prompt)


func set_closed(value: bool, animated: bool = true) -> void:
    if _effect_tween != null:
        _effect_tween.kill()
    var with_effect := not value and animated and open_effect != OpenEffect.FADE and _pieces != null and _pieces.visible
    if value:
        _pieces.scale = Vector2.ONE
        _pieces.position = Vector2.ZERO
    if not with_effect:
        super.set_closed(value, animated)
        return
    if _prompt != null:
        _prompt.visible = false
    var saved_fade := fade_time
    fade_time = maxf(fade_time, effect_time)
    super.set_closed(value, animated)
    fade_time = saved_fade
    match open_effect:
        OpenEffect.CANDLES:
            _play_candles()
        OpenEffect.MELT:
            _play_melt()


func _play_candles() -> void:
    # Las piezas se encienden (más claras y cálidas) antes de apagarse.
    _effect_tween = create_tween().set_parallel(true)
    for piece in _pieces.get_children():
        _effect_tween.tween_property(piece, "modulate", Color(1.8, 1.4, 0.8), effect_time * 0.4)
    _burst(Color(1.0, 0.75, 0.25), Vector2(0.0, -40.0))


func _play_melt() -> void:
    # El bloque se encoge hacia su base mientras caen gotas.
    var rect := collision.shape as RectangleShape2D
    var pivot := collision.position.y + (rect.size.y * 0.5 if rect != null else 0.0)
    _effect_tween = create_tween()
    _effect_tween.tween_method(func(s: float) -> void:
        _pieces.scale = Vector2(1.0, s)
        _pieces.position = Vector2(0.0, pivot * (1.0 - s)),
        1.0, 0.0, effect_time)
    _burst(Color(0.6, 0.85, 1.0), Vector2(0.0, 160.0))


func _burst(color: Color, gravity: Vector2) -> void:
    var rect := collision.shape as RectangleShape2D
    if rect == null:
        return
    var particles := CPUParticles2D.new()
    particles.position = collision.position
    particles.z_index = 15
    particles.amount = 14
    particles.lifetime = effect_time
    particles.one_shot = true
    particles.explosiveness = 0.2
    particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
    particles.emission_rect_extents = rect.size * 0.5
    particles.direction = Vector2.UP if gravity.y < 0.0 else Vector2.DOWN
    particles.spread = 40.0
    particles.initial_velocity_min = 4.0
    particles.initial_velocity_max = 20.0
    particles.gravity = gravity
    particles.scale_amount_min = 2.0
    particles.scale_amount_max = 2.0
    particles.color = color
    add_child(particles)
    particles.emitting = true
    get_tree().create_timer(effect_time + 0.5).timeout.connect(particles.queue_free)

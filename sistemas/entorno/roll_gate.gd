extends UnderkingdomArenaBarrier
class_name UnderkingdomRollGate

## Reja baja que solo se pasa rodando ([H2] del castillo y el pasillo del filo
## del infierno). Es una barrera vertical sólida de arena_barrier.gd que
## empieza cerrada: el Player no la cruza salvo mientras rueda. Si la rodada
## termina con el Player dentro de la reja, se le empuja hacia el lado del que
## vino (K1). Los enemigos nunca la cruzan: no tienen excepción de colisión.
## Con `open_on_encounter` también se puede abrir del todo, como cualquier
## barrera.

## Separación extra, en px, al empujar al Player fuera de la reja.
@export_range(0.0, 8.0, 0.5) var push_margin: float = 1.0

var _player: Node2D = null
var _player_shape: CollisionShape2D = null
## Lado por el que el Player llegó: -1 a la izquierda de la reja, 1 a la derecha.
var _entry_side: float = 0.0
var _passing: bool = false


func _init() -> void:
    start_closed = true
    # Antes que el Player, para que la excepción ya valga en el cuadro en que
    # empieza la rodada y se quite antes de que se mueva al acabarla.
    process_physics_priority = -10


func _physics_process(_delta: float) -> void:
    if not closed:
        if _passing:
            _set_passing(false)
        return
    if not _find_player():
        return

    var rolling := _player.has_method("is_rolling") and bool(_player.call("is_rolling"))
    if rolling:
        if not _passing:
            _set_passing(true)
        return

    if _passing:
        _set_passing(false)
        if _player_overlaps_gate():
            _push_player_out()
    if not _player_overlaps_gate():
        _entry_side = _side_of_player()


func _find_player() -> bool:
    if is_instance_valid(_player) and is_instance_valid(_player_shape):
        return true
    _player = get_tree().get_first_node_in_group("player") as Node2D
    _player_shape = null
    if _player == null:
        return false
    for child in _player.get_children():
        if child is CollisionShape2D:
            _player_shape = child as CollisionShape2D
            break
    return _player_shape != null


func _set_passing(value: bool) -> void:
    _passing = value
    var body := _player as PhysicsBody2D
    if body == null:
        return
    if value:
        body.add_collision_exception_with(self)
        add_collision_exception_with(body)
    else:
        body.remove_collision_exception_with(self)
        remove_collision_exception_with(body)


func _gate_rect() -> Rect2:
    var rect := collision.shape as RectangleShape2D
    var size := rect.size if rect != null else Vector2(TILE, TILE)
    return Rect2(collision.global_position - size * 0.5, size)


func _player_rect() -> Rect2:
    var rect := _player_shape.shape as RectangleShape2D
    var size := rect.size if rect != null else Vector2(20.0, 40.0)
    return Rect2(_player_shape.global_position - size * 0.5, size)


func _player_overlaps_gate() -> bool:
    return _gate_rect().intersects(_player_rect())


func _side_of_player() -> float:
    return -1.0 if _player_shape.global_position.x < collision.global_position.x else 1.0


func _push_player_out() -> void:
    var side := _entry_side
    if is_zero_approx(side):
        side = _side_of_player()
    var gate := _gate_rect()
    var half_width := _player_rect().size.x * 0.5
    var target_x := gate.get_center().x + side * (gate.size.x * 0.5 + half_width + push_margin)
    _player.global_position.x += target_x - _player_shape.global_position.x
    _player_shape.force_update_transform()
    if _player is CharacterBody2D:
        (_player as CharacterBody2D).velocity.x = 0.0

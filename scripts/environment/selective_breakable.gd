extends UnderkingdomBreakableObject
class_name UnderkingdomSelectiveBreakable

## Rompible que solo acepta un tipo de golpe (docs/P56_ROMPIBLE_SELECTIVO.md).
## El tipo correcto lo rompe de una vez; cualquier otro golpe (tajos normales,
## puños, bola de fuego) no hace daño, suelta una chispa metálica y, la primera
## vez, muestra un aviso. Hereda de breakable_object.gd: mismos cuadros,
## escombros, botín y recuerdo de "ya roto". Usa la AnimatableBody2D de la pared
## agrietada, porque la AttackHitbox no detecta StaticBody2D (P48).

enum HitType {
    ## Tajo ascendente con la habilidad Golpe final (combo_3): losa de la cripta.
    FINAL_BLOW,
    ## La Ultimate (E): estatua de la Reina.
    ULTIMATE,
}

@export_category("Golpe aceptado")
@export var accepted_hit: HitType = HitType.FINAL_BLOW
## Aviso la primera vez que se le pega mal (en esta escena cargada).
@export var wrong_hit_message: String = "RESISTE EL GOLPE"
@export var show_wrong_hit_message: bool = true
## Pausa mínima entre chispas, para que un tajo de varias ventanas no las repita.
@export_range(0.05, 1.0, 0.05) var spark_cooldown: float = 0.3

var _message_shown: bool = false
var _spark_left: float = 0.0
var _message: Label = null
var _message_tween: Tween = null


func _process(delta: float) -> void:
    _spark_left = maxf(_spark_left - delta, 0.0)


## Lo llama el Player en un golpe con empuje (con el nombre de su animación).
func take_player_attack_from(
    _source_global_position: Vector2,
    _amount: float,
    animation_name: StringName,
    _sequence_id: int = 0
) -> bool:
    return _receive_hit(animation_name)


## Lo llama el Player en los golpes intermedios de una ráfaga.
func take_player_continuous_attack_from(
    _source_global_position: Vector2,
    _amount: float,
    animation_name: StringName,
    _sequence_id: int = 0
) -> bool:
    return _receive_hit(animation_name)


## Cualquier otra fuente (sin nombre de animación) no sirve.
func take_damage_from(_source_global_position: Vector2, _amount: float) -> bool:
    return _receive_hit(&"")


func take_continuous_damage_from(_source_global_position: Vector2, _amount: float) -> bool:
    return _receive_hit(&"")


## Devuelve si el golpe de esa animación es el que este objeto acepta.
func accepts_animation(animation_name: StringName) -> bool:
    match accepted_hit:
        HitType.ULTIMATE:
            return animation_name == &"attack ultimate"
        HitType.FINAL_BLOW:
            return animation_name == &"attack 2" and GameManager.has_ability("combo_3")
    return false


func _receive_hit(animation_name: StringName) -> bool:
    if is_destroyed:
        return false
    if accepts_animation(animation_name):
        return take_damage(max_health)
    _reject_hit()
    return false


func _reject_hit() -> void:
    if _spark_left > 0.0:
        return
    _spark_left = spark_cooldown
    UnderkingdomCombatFX.block_spark(self, sprite)
    if show_wrong_hit_message and not _message_shown:
        _message_shown = true
        _show_message(wrong_hit_message)


func _show_message(text: String) -> void:
    if text.is_empty():
        return
    if _message == null:
        _message = Label.new()
        _message.add_theme_font_size_override("font_size", 8)
        _message.add_theme_color_override("font_outline_color", Color.BLACK)
        _message.add_theme_constant_override("outline_size", 3)
        _message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _message.size = Vector2(160.0, 12.0)
        _message.z_index = 30
        var rect := collision_shape.shape.get_rect() if collision_shape.shape != null else Rect2(-8, -8, 16, 16)
        _message.position = collision_shape.position + Vector2(-80.0, rect.position.y - 14.0)
        add_child(_message)
    if _message_tween != null:
        _message_tween.kill()
    _message.text = text
    _message.modulate.a = 1.0
    _message.visible = true
    _message_tween = _message.create_tween()
    _message_tween.tween_interval(1.4)
    _message_tween.tween_property(_message, "modulate:a", 0.0, 0.4)
    _message_tween.tween_callback(_message.hide)

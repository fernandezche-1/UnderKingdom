extends Node2D
class_name UnderkingdomEnemyHealthBar

## Barra de vida pequeña sobre un enemigo normal (los jefes usan
## UnderkingdomBossHealthBar). Oculta con la vida llena; aparece al recibir un
## golpe y se desvanece unos segundos después. El tramo perdido baja con un
## pequeño retraso en color claro para que se vea cuánto quitó cada golpe.
## Usa los mismos colores que la barra de vida del Player (imagem vidas, tipo3).

@export_range(8, 64, 1) var bar_width: int = 24
@export_range(2, 8, 1) var bar_height: int = 4
@export_range(0.5, 10.0, 0.5) var visible_time: float = 3.0
@export_range(0.05, 1.0, 0.05) var fade_time: float = 0.4
@export_range(0.0, 1.0, 0.05) var trail_delay: float = 0.35
## Fracción de la barra que baja por segundo el tramo retrasado.
@export_range(0.1, 10.0, 0.1) var trail_speed: float = 1.5

const OUTLINE_COLOR := Color8(6, 6, 8)
const EMPTY_COLOR := Color8(59, 23, 37)
const FILL_COLOR := Color8(180, 32, 42)
const TRAIL_COLOR := Color8(255, 214, 160)

var _ratio: float = 1.0
var _trail: float = 1.0
var _trail_wait: float = 0.0
var _show_left: float = 0.0


func _ready() -> void:
    z_index = 30
    modulate.a = 0.0
    var enemy := get_parent()
    if enemy.has_signal("health_changed"):
        enemy.connect("health_changed", _on_health_changed)
    if enemy.has_signal("died"):
        enemy.connect("died", _on_died)


func _on_health_changed(current_health: float, max_health: float) -> void:
    var ratio := clampf(current_health / maxf(max_health, 0.01), 0.0, 1.0)
    if ratio < _ratio:
        # Daño: el tramo claro se queda un momento donde estaba.
        if _trail_wait <= 0.0:
            _trail_wait = trail_delay
    else:
        _trail = ratio
    _ratio = ratio
    _show_left = visible_time if ratio < 1.0 else 0.0
    modulate.a = 1.0 if ratio < 1.0 else 0.0
    queue_redraw()


func _on_died() -> void:
    _show_left = 0.0
    modulate.a = 0.0
    set_process(false)


func _process(delta: float) -> void:
    if _trail > _ratio:
        if _trail_wait > 0.0:
            _trail_wait = maxf(_trail_wait - delta, 0.0)
        else:
            _trail = maxf(_trail - trail_speed * delta, _ratio)
        queue_redraw()

    if _show_left > 0.0:
        _show_left = maxf(_show_left - delta, 0.0)
        modulate.a = clampf(_show_left / fade_time, 0.0, 1.0)


func _draw() -> void:
    var left := -bar_width / 2
    draw_rect(Rect2(left - 1, -1, bar_width + 2, bar_height + 2), OUTLINE_COLOR)
    draw_rect(Rect2(left, 0, bar_width, bar_height), EMPTY_COLOR)

    var trail_px := roundi(_trail * bar_width)
    if trail_px > 0:
        draw_rect(Rect2(left, 0, trail_px, bar_height), TRAIL_COLOR)

    # Con vida por encima de 0 siempre queda al menos un píxel rojo.
    var fill_px := maxi(roundi(_ratio * bar_width), 1 if _ratio > 0.0 else 0)
    if fill_px > 0:
        draw_rect(Rect2(left, 0, fill_px, bar_height), FILL_COLOR)

extends CanvasLayer
class_name UnderkingdomBossHealthBar

## Barra de vida grande para jefes. Va como hijo del jefe (cualquier
## UnderkingdomEnemyBase) y lee sus señales; sirve igual para bosses posteriores.

@export var boss_name: String = "JEFE"
## Si está activo, la barra solo se muestra mientras el jefe persigue al Player.
@export var show_only_with_aggro: bool = true
@export var phase_flash_color: Color = Color(1.0, 0.82, 0.25)
@export_range(0.05, 2.0, 0.05) var phase_flash_time: float = 0.6
@export var phase_mark_color: Color = Color(0.024, 0.024, 0.031, 0.85)

## Zona útil de la textura de relleno, en píxeles de la textura.
const FILL_RECT := Rect2(8.0, 24.0, 144.0, 12.0)

@onready var health_bar: TextureProgressBar = $Raiz/BarraVida
@onready var name_label: Label = $Raiz/Nombre

var _boss: Node = null
var _boss_dead: bool = false


func _ready() -> void:
    _boss = get_parent()
    visible = false
    name_label.text = boss_name

    if _boss == null:
        return

    if _boss.has_signal("health_changed"):
        _boss.connect("health_changed", _on_health_changed)
    if _boss.has_signal("aggro_changed"):
        _boss.connect("aggro_changed", _on_aggro_changed)
    if _boss.has_signal("died"):
        _boss.connect("died", _on_boss_died)
    if _boss.has_signal("phase_changed"):
        _boss.connect("phase_changed", _on_phase_changed)

    # El jefe fija su vida en su propio _ready, que corre después de este.
    call_deferred("_sync_from_boss")


func _sync_from_boss() -> void:
    if not is_instance_valid(_boss) or _boss.is_queued_for_deletion():
        return

    var max_value: Variant = _boss.get("max_health")
    var current_value: Variant = _boss.get("current_health")
    if max_value != null:
        health_bar.max_value = float(max_value)
    if current_value != null:
        health_bar.value = float(current_value)

    _build_phase_marks()

    if not show_only_with_aggro:
        visible = true


func _build_phase_marks() -> void:
    for property_name in [&"phase_2_health_ratio", &"phase_3_health_ratio"]:
        var ratio: Variant = _boss.get(property_name)
        if ratio == null:
            continue

        var mark := ColorRect.new()
        mark.name = "Marca_%s" % property_name
        mark.color = phase_mark_color
        mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
        mark.position = Vector2(
            FILL_RECT.position.x + FILL_RECT.size.x * float(ratio) - 0.5,
            FILL_RECT.position.y
        )
        mark.size = Vector2(1.0, FILL_RECT.size.y)
        health_bar.add_child(mark)


func _on_health_changed(current_health: float, max_health: float) -> void:
    health_bar.max_value = max_health
    health_bar.value = current_health


func _on_aggro_changed(active: bool) -> void:
    if show_only_with_aggro and not _boss_dead:
        visible = active


func _on_boss_died() -> void:
    _boss_dead = true
    visible = false


func _on_phase_changed(_new_phase: int) -> void:
    name_label.modulate = phase_flash_color
    var tween := create_tween()
    tween.tween_property(name_label, "modulate", Color.WHITE, phase_flash_time)

extends CanvasLayer
class_name UnderkingdomPlayerHUD

## HUD del Player: vida, Ultimate, llave, contadores de inventario y el aviso
## de habilidad nueva.
## Va como hijo del Player y lee sus señales; no guarda estado propio.

@export_range(0.0, 1.0, 0.05) var ultimate_charging_alpha: float = 0.55
@export_range(0.5, 10.0, 0.1) var ability_notice_time: float = 3.0

@onready var health_bar: TextureProgressBar = $Raiz/BarraVida
@onready var ultimate_bar: TextureProgressBar = $Raiz/BarraUltimate
@onready var key_icon: TextureRect = $Raiz/IconoLlave
@onready var coins_label: Label = $Inventario/MonedasTexto
@onready var potions_label: Label = $Inventario/PocionesTexto

var _player: Node = null
var _ability_notice: Label = null
var _ability_notice_tween: Tween = null


func _ready() -> void:
    _player = get_parent()

    if _player != null and _player.has_signal("health_changed"):
        _player.connect("health_changed", _on_health_changed)

    GameManager.world1_boss_key_changed.connect(_on_key_changed)
    GameManager.key_changed.connect(_on_named_key_changed)
    key_icon.visible = GameManager.has_any_key()
    GameManager.coins_changed.connect(_on_coins_changed)
    GameManager.potions_changed.connect(_on_potions_changed)
    _on_coins_changed(GameManager.coins)
    _on_potions_changed(GameManager.potions)
    GameManager.ability_unlocked.connect(_on_ability_unlocked)
    _build_ability_notice()


func _process(_delta: float) -> void:
    if not is_instance_valid(_player) or not _player.has_method("get_ultimate_ready_ratio"):
        return

    ultimate_bar.visible = GameManager.has_ability("ultimate")
    var ratio := float(_player.call("get_ultimate_ready_ratio"))
    ultimate_bar.value = ratio
    ultimate_bar.modulate.a = 1.0 if ratio >= 1.0 else ultimate_charging_alpha


func _on_health_changed(current_health: float, max_health: float) -> void:
    health_bar.max_value = max_health
    health_bar.value = current_health


func _on_key_changed(_has_key: bool) -> void:
    key_icon.visible = GameManager.has_any_key()


func _on_named_key_changed(_key_id: String, _has_key: bool) -> void:
    key_icon.visible = GameManager.has_any_key()


func _on_coins_changed(value: int) -> void:
    coins_label.text = "Monedas: %d" % value


func _on_potions_changed(value: int) -> void:
    potions_label.text = "Pociones: %d [C]" % value


func _on_ability_unlocked(ability_id: String) -> void:
    if _ability_notice_tween != null:
        _ability_notice_tween.kill()
    _ability_notice.text = "NUEVA HABILIDAD: %s\n%s" % [
        GameManager.get_ability_name(ability_id).to_upper(),
        GameManager.get_ability_hint(ability_id),
    ]
    _ability_notice.visible = true
    _ability_notice.modulate.a = 1.0
    _ability_notice_tween = create_tween()
    _ability_notice_tween.tween_interval(ability_notice_time)
    _ability_notice_tween.tween_property(_ability_notice, "modulate:a", 0.0, 0.5)
    _ability_notice_tween.tween_callback(_ability_notice.hide)


func _build_ability_notice() -> void:
    _ability_notice = Label.new()
    _ability_notice.name = "AvisoHabilidad"
    _ability_notice.visible = false
    _ability_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _ability_notice.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
    _ability_notice.grow_horizontal = Control.GROW_DIRECTION_BOTH
    _ability_notice.offset_top = 64.0
    _ability_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _ability_notice.add_theme_font_size_override("font_size", 8)
    _ability_notice.add_theme_color_override("font_color", Color(0.62, 0.86, 1.0))
    _ability_notice.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
    _ability_notice.add_theme_constant_override("outline_size", 3)
    add_child(_ability_notice)

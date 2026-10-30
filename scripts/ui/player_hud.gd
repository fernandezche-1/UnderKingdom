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
var _mission_panel: PanelContainer
var _mission_label: Label


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
    GameManager.sword_mission_changed.connect(_on_sword_mission_changed)
    _build_ability_notice()
    _build_mission_panel()
    _on_sword_mission_changed(GameManager.sword_mission_started, GameManager.sword_mission_completed)


func _process(_delta: float) -> void:
    if not is_instance_valid(_player) or not _player.has_method("get_ultimate_ready_ratio"):
        return

    ultimate_bar.visible = GameManager.has_sword and GameManager.has_ability("ultimate")
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
    coins_label.text = str(value)


func _on_potions_changed(value: int) -> void:
    potions_label.text = "%d  [C]" % value


func _on_ability_unlocked(ability_id: String) -> void:
    if _ability_notice_tween != null:
        _ability_notice_tween.kill()
    show_story_notice("NUEVA HABILIDAD: %s" % GameManager.get_ability_name(ability_id).to_upper(), GameManager.get_ability_hint(ability_id))


func show_story_notice(title: String, body: String) -> void:
    if _ability_notice == null:
        _build_ability_notice()
    if _ability_notice_tween != null:
        _ability_notice_tween.kill()
    _ability_notice.text = "%s\n%s" % [title, body]
    _ability_notice.visible = true
    _ability_notice.modulate.a = 1.0
    _ability_notice_tween = create_tween()
    _ability_notice_tween.tween_interval(3.2)
    _ability_notice_tween.tween_property(_ability_notice, "modulate:a", 0.0, 0.5)
    _ability_notice_tween.tween_callback(_ability_notice.hide)


func _on_sword_mission_changed(started: bool, completed: bool) -> void:
    if _mission_panel == null:
        return
    _mission_panel.visible = started and not completed
    if _mission_label != null:
        _mission_label.text = "%s\n%s" % [GameManager.SWORD_MISSION_TITLE, GameManager.SWORD_MISSION_DESCRIPTION]


func _build_mission_panel() -> void:
    _mission_panel = PanelContainer.new()
    _mission_panel.name = "ObjetivoPrincipal"
    _mission_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _mission_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
    _mission_panel.position = Vector2(6.0, 30.0)
    _mission_panel.size = Vector2(198.0, 56.0)
    _mission_panel.custom_minimum_size = Vector2(190.0, 0.0)
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color(0.015, 0.02, 0.035, 0.78)
    panel_style.content_margin_left = 5.0
    panel_style.content_margin_right = 5.0
    panel_style.content_margin_top = 3.0
    panel_style.content_margin_bottom = 3.0
    _mission_panel.add_theme_stylebox_override("panel", panel_style)
    _mission_label = Label.new()
    _mission_label.name = "Texto"
    _mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _mission_label.add_theme_font_size_override("font_size", 7)
    _mission_label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.68))
    _mission_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
    _mission_label.add_theme_constant_override("outline_size", 2)
    _mission_panel.add_child(_mission_label)
    add_child(_mission_panel)


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

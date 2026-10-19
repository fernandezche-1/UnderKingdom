extends CanvasLayer
class_name UnderkingdomDevMode

## Modo dev para probar el juego (autoload `DevMode`): vida, pociones, monedas
## y Ultimate sin límite, y atajos para curar y dar objetos. Solo funciona en
## builds de depuración (editor y exportaciones debug); en una exportación
## release queda apagado. Los ajustes duran la sesión: no se guardan y
## "Nueva partida" no los cambia.
##
## Tecla º (debajo de Esc; ` en teclado inglés): abre o cierra el panel.
## Con el panel abierto, las teclas 1-8 o un clic activan cada opción.

## Llaves de jefe de la ruta de tiles. Añadir aquí la de cada mundo nuevo.
const BOSS_KEY_IDS: Array[String] = ["cementerio_capitan", "minas_caballero"]
const COINS_PER_GRANT: int = 100
const POTIONS_PER_GRANT: int = 5
const FONT_SIZE: int = 8
const COLOR_ON := Color(0.55, 1.0, 0.55)
const COLOR_OFF := Color(0.75, 0.75, 0.8)
const COLOR_ACTION := Color(1.0, 0.85, 0.45)

## "flag": variable que se alterna. "action": método que se llama una vez.
const OPTIONS: Array[Dictionary] = [
    {"text": "Vida infinita", "flag": "infinite_health", "badge": "vida"},
    {"text": "Pociones infinitas", "flag": "infinite_potions", "badge": "pociones"},
    {"text": "Monedas infinitas", "flag": "infinite_coins", "badge": "monedas"},
    {"text": "Ultimate sin enfriamiento", "flag": "no_ultimate_cooldown", "badge": "ultimate"},
    {"text": "Curar al máximo", "action": "_heal_player"},
    {"text": "+%d monedas" % COINS_PER_GRANT, "action": "_grant_coins"},
    {"text": "+%d pociones" % POTIONS_PER_GRANT, "action": "_grant_potions"},
    {"text": "Dar llaves de jefe", "action": "_grant_boss_keys"},
]

var available: bool = false
## El Player no pierde vida. Caer a un vacío o a una kill zone lo devuelve al
## último punto de reaparición sin recargar el mapa.
var infinite_health: bool = false
var infinite_potions: bool = false
## Comprar mejoras no gasta monedas.
var infinite_coins: bool = false
var no_ultimate_cooldown: bool = false

var _panel: PanelContainer
var _badge: Label
var _buttons: Array[Button] = []


func _ready() -> void:
    layer = 120
    process_mode = Node.PROCESS_MODE_ALWAYS
    available = OS.is_debug_build()
    if not available:
        set_process_input(false)
        return
    _build_ui()
    _refresh()


func _input(event: InputEvent) -> void:
    var key_event := event as InputEventKey
    if key_event == null or not key_event.pressed or key_event.echo:
        return

    if key_event.physical_keycode == KEY_QUOTELEFT:
        _panel.visible = not _panel.visible
        _refresh()
        get_viewport().set_input_as_handled()
        return

    if not _panel.visible:
        return
    var index: int = int(key_event.physical_keycode) - int(KEY_1)
    if index >= 0 and index < OPTIONS.size():
        _activate(index)
        get_viewport().set_input_as_handled()


func _activate(index: int) -> void:
    var option: Dictionary = OPTIONS[index]
    if option.has("flag"):
        var flag: String = option.flag
        set(flag, not bool(get(flag)))
        _on_flag_changed(flag)
    else:
        call(String(option.action))
    _refresh()


func _on_flag_changed(flag: String) -> void:
    match flag:
        "infinite_health":
            if infinite_health:
                _heal_player()
        "infinite_coins":
            # El menú de pausa recalcula qué mejoras se pueden comprar.
            GameManager.coins_changed.emit(GameManager.coins)
        "no_ultimate_cooldown":
            var player := _player()
            if no_ultimate_cooldown and player != null:
                player.set_ultimate_cooldown_progress(1.0)


func _player() -> UnderkingdomPlayer:
    return get_tree().get_first_node_in_group("player") as UnderkingdomPlayer


func _heal_player() -> void:
    var player := _player()
    if player != null:
        player.heal(player.max_health - player.current_health)


func _grant_coins() -> void:
    GameManager.add_coins(COINS_PER_GRANT)


func _grant_potions() -> void:
    GameManager.add_potions(POTIONS_PER_GRANT)


func _grant_boss_keys() -> void:
    for key_id in BOSS_KEY_IDS:
        GameManager.grant_key(key_id)


func _build_ui() -> void:
    _panel = PanelContainer.new()
    _panel.visible = false
    _panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    _panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    # Debajo del inventario del HUD (esquina superior derecha, hasta y = 45).
    _panel.offset_left = -5.0
    _panel.offset_right = -5.0
    _panel.offset_top = 50.0
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.04, 0.04, 0.07, 0.88)
    style.border_color = Color(0.55, 1.0, 0.55, 0.6)
    style.set_border_width_all(1)
    style.set_content_margin_all(4.0)
    _panel.add_theme_stylebox_override("panel", style)
    add_child(_panel)

    var list := VBoxContainer.new()
    list.add_theme_constant_override("separation", 0)
    _panel.add_child(list)

    var title := _make_label("MODO DEV   [º] cerrar")
    title.add_theme_color_override("font_color", COLOR_ON)
    list.add_child(title)

    var empty := StyleBoxEmpty.new()
    for index in OPTIONS.size():
        var button := Button.new()
        # Sin foco: si no, Espacio (saltar) activaría el último botón pulsado.
        button.focus_mode = Control.FOCUS_NONE
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.add_theme_font_size_override("font_size", FONT_SIZE)
        for state in ["normal", "hover", "pressed", "disabled", "focus"]:
            button.add_theme_stylebox_override(state, empty)
        button.pressed.connect(_activate.bind(index))
        list.add_child(button)
        _buttons.append(button)

    _badge = _make_label("")
    _badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    _badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    _badge.offset_left = -5.0
    _badge.offset_right = -5.0
    _badge.offset_top = 47.0
    _badge.add_theme_color_override("font_color", COLOR_ON)
    _badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_badge)


func _make_label(text: String) -> Label:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", FONT_SIZE)
    label.add_theme_color_override("font_outline_color", Color.BLACK)
    label.add_theme_constant_override("outline_size", 2)
    return label


func _refresh() -> void:
    var active: PackedStringArray = []
    for index in OPTIONS.size():
        var option: Dictionary = OPTIONS[index]
        var button: Button = _buttons[index]
        var text: String = "%d  %s" % [index + 1, option.text]
        var color: Color = COLOR_ACTION
        if option.has("flag"):
            var on: bool = bool(get(String(option.flag)))
            text += ": SÍ" if on else ": no"
            color = COLOR_ON if on else COLOR_OFF
            if on:
                active.append(String(option.badge))
        button.text = text
        for state in ["font_color", "font_hover_color", "font_pressed_color"]:
            button.add_theme_color_override(state, color)

    _badge.text = "DEV: " + ", ".join(active)
    _badge.visible = not _panel.visible and not active.is_empty()

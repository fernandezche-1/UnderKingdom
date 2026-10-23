extends TextureRect
class_name UnderkingdomMenuSelector
## Flecha que se pone a la izquierda del botón con el foco dentro de las listas
## que vigila. Con el ratón, pasar por encima de un botón le da el foco, así la
## flecha marca siempre lo que se va a elegir con teclado, mando o clic.

const SELECTOR_TEXTURE := preload("res://escenas/ui/texturas/selector.png")
const GAP: float = 4.0
const BOB_AMPLITUDE: float = 1.0
const BOB_SPEED: float = 5.0

var _lists: Array[Control] = []
var _time: float = 0.0


func _ready() -> void:
	texture = SELECTOR_TEXTURE
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


## Vigila los botones de una lista. Se puede llamar otra vez si cambian.
func watch(list: Control) -> void:
	if not _lists.has(list):
		_lists.append(list)
	for child: Node in list.get_children():
		var button := child as BaseButton
		if button != null and not button.mouse_entered.is_connected(_on_button_hovered.bind(button)):
			button.mouse_entered.connect(_on_button_hovered.bind(button))


func _process(delta: float) -> void:
	var target := _focused_button()
	if target == null:
		visible = false
		return
	_time += delta
	var bob: float = roundf(sin(_time * BOB_SPEED) * BOB_AMPLITUDE)
	var rect := target.get_global_rect()
	var y: float = rect.position.y + floorf((rect.size.y - size.y) * 0.5)
	global_position = Vector2(roundf(rect.position.x - size.x - GAP + bob), roundf(y))
	visible = true


func _focused_button() -> BaseButton:
	var focused := get_viewport().gui_get_focus_owner()
	if focused == null or not focused.is_visible_in_tree():
		return null
	for list: Control in _lists:
		if is_instance_valid(list) and focused.get_parent() == list:
			return focused as BaseButton
	return null


func _on_button_hovered(button: BaseButton) -> void:
	if button.is_visible_in_tree() and not button.disabled and button.focus_mode != Control.FOCUS_NONE:
		button.grab_focus()

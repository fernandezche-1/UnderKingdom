extends Node
## Registra las acciones de entrada del juego: teclado, ratón y mando.
## Se registran por código para que el mapa de controles viva en un solo archivo.

const STICK_DEADZONE: float = 0.5


func _init() -> void:
	_add_action("move_left", [_key(KEY_A), _key(KEY_LEFT), _axis(JOY_AXIS_LEFT_X, -1.0), _button(JOY_BUTTON_DPAD_LEFT)])
	_add_action("move_right", [_key(KEY_D), _key(KEY_RIGHT), _axis(JOY_AXIS_LEFT_X, 1.0), _button(JOY_BUTTON_DPAD_RIGHT)])
	_add_action("move_up", [_key(KEY_W), _key(KEY_UP), _axis(JOY_AXIS_LEFT_Y, -1.0), _button(JOY_BUTTON_DPAD_UP)])
	_add_action("move_down", [_key(KEY_S), _key(KEY_DOWN), _axis(JOY_AXIS_LEFT_Y, 1.0), _button(JOY_BUTTON_DPAD_DOWN)])
	# Saltar con el stick hacia arriba chocaría con trepar: en mando solo el botón A.
	_add_action("jump", [_key(KEY_SPACE), _key(KEY_W), _key(KEY_UP), _button(JOY_BUTTON_A)])
	_add_action("attack", [_key(KEY_F), _key(KEY_Z), _mouse(MOUSE_BUTTON_LEFT), _button(JOY_BUTTON_X), _axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)])
	_add_action("roll", [_key(KEY_SHIFT), _button(JOY_BUTTON_B)])
	_add_action("interact", [_key(KEY_E), _button(JOY_BUTTON_Y)])
	_add_action("defend", [_key(KEY_Q), _mouse(MOUSE_BUTTON_RIGHT), _button(JOY_BUTTON_LEFT_SHOULDER), _axis(JOY_AXIS_TRIGGER_LEFT, 1.0)])
	_add_action("potion", [_key(KEY_C), _button(JOY_BUTTON_RIGHT_SHOULDER)])
	_add_action("fireball", [_key(KEY_X), _button(JOY_BUTTON_RIGHT_STICK)])
	_add_action("pause", [_key(KEY_ESCAPE), _button(JOY_BUTTON_START)])
	_add_action("toggle_fullscreen", [_key(KEY_F11)])
	_add_action("dialogue_advance", [_key(KEY_E), _key(KEY_ENTER), _key(KEY_SPACE), _button(JOY_BUTTON_A), _button(JOY_BUTTON_Y)])


func _add_action(action: StringName, events: Array[InputEvent]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, STICK_DEADZONE)
	for event: InputEvent in events:
		InputMap.action_add_event(action, event)


func _key(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	return event


func _mouse(button: MouseButton) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	return event


func _button(button: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	return event


func _axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	return event

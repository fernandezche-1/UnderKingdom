extends VBoxContainer
class_name UnderkingdomAudioControls

var include_master := true
var _sliders: Dictionary = {}
var _values: Dictionary = {}


func _ready() -> void:
	add_theme_constant_override("separation", 2)
	for bus: StringName in GameAudio.BUSES:
		if bus == &"Master" and not include_master:
			continue
		var row := HBoxContainer.new()
		row.name = String(bus)
		row.add_theme_constant_override("separation", 5)
		var caption := Label.new()
		caption.text = String(GameAudio.BUSES[bus][0])
		caption.custom_minimum_size.x = 53.0
		row.add_child(caption)
		var slider := HSlider.new()
		slider.name = "Volumen"
		slider.custom_minimum_size = Vector2(20.0, 12.0)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(slider)
		var value := Label.new()
		value.name = "Valor"
		value.theme_type_variation = &"TextoTenue"
		value.custom_minimum_size.x = 27.0
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(value)
		add_child(row)
		bind_bus(bus, slider, value)


func bind_bus(bus: StringName, slider: HSlider, label: Label) -> void:
	_sliders[bus] = slider
	_values[bus] = label
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value_changed.connect(_changed.bind(bus))
	_sync(bus)


func refresh() -> void:
	for bus: StringName in _sliders:
		_sync(bus)


func focus_master() -> void:
	(_sliders[&"Master"] as HSlider).grab_focus()


func _sync(bus: StringName) -> void:
	var value := GameAudio.get_volume(bus)
	(_sliders[bus] as HSlider).set_value_no_signal(value)
	(_values[bus] as Label).text = "%d%%" % roundi(value * 100.0)


func _changed(value: float, bus: StringName) -> void:
	GameAudio.set_volume(bus, value)
	(_values[bus] as Label).text = "%d%%" % roundi(value * 100.0)
	GameAudio.preview(bus)

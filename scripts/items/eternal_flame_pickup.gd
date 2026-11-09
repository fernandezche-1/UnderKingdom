extends UnderkingdomAbilityPickup
class_name UnderkingdomEternalFlamePickup

## Llama eterna (P65): antorcha que se recoge en el altar de la ruina. Da la llave
## genérica `key_id` ("antorcha") y funciona sola, sin equiparla (R1): derrite el
## hielo de [P6] (`locked_door.gd` con `open_effect` MELT y esa misma llave) y
## alumbra las zonas de `dark_zone.gd`. Una vez recogida no vuelve a aparecer.
## Detalle en docs/P65_LLAMA_ETERNA.md.

const FLAME_TEXTURE: Texture2D = preload("res://sprites/trampas/fuego_rojo.png")
const FLAME_FRAMES: Array[int] = [256, 320, 384, 320]

@export var key_id: String = "antorcha"
@export var pickup_message: String = "LLAMA ETERNA"
## Tinte provisional de la llama (arte pendiente): blanca y azulada, para no
## confundirla con el fuego normal ni con el infernal.
@export var flame_tint: Color = Color(0.7, 1.1, 1.5)


func _ready() -> void:
	super._ready()
	if is_queued_for_deletion():
		return
	_build_flame()


func _already_owned() -> bool:
	return key_id.is_empty() or GameManager.has_key(key_id)


func _grant() -> void:
	GameManager.grant_key(key_id)
	_show_message()


func _build_flame() -> void:
	var frames := SpriteFrames.new()
	frames.set_animation_speed(&"default", 8.0)
	for x: int in FLAME_FRAMES:
		var atlas := AtlasTexture.new()
		atlas.atlas = FLAME_TEXTURE
		atlas.region = Rect2(x, 0, 64, 64)
		frames.add_frame(&"default", atlas)
	var flame := AnimatedSprite2D.new()
	flame.name = "Llama"
	flame.sprite_frames = frames
	flame.modulate = flame_tint
	flame.z_index = 10
	flame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flame.position = Vector2(0.0, -15.0)
	add_child(flame)
	flame.play(&"default")


## El aviso cuelga de la escena, no del objeto, que se libera al recogerlo.
func _show_message() -> void:
	if pickup_message.is_empty() or not is_inside_tree():
		return
	var label := Label.new()
	label.text = pickup_message
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(120.0, 12.0)
	label.z_index = 60
	var host: Node = get_parent()
	host.add_child(label)
	label.global_position = global_position + Vector2(-60.0, -36.0)
	var tween: Tween = label.create_tween()
	tween.tween_interval(1.4)
	tween.tween_property(label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(label.queue_free)

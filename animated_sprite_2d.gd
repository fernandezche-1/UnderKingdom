
extends AnimatedSprite2D

const HOJA = preload(
    "res://prueba/dungeon_sidescroller-Raou/spr_torch.png"
)

func _ready() -> void:
	var animaciones = SpriteFrames.new()
	animaciones.add_animation("fuego")
	animaciones.set_animation_speed("fuego", 6.0)
	animaciones.set_animation_loop("fuego", true)

	for i in range(3):
		var recorte = AtlasTexture.new()
		recorte.atlas = HOJA
		recorte.region = Rect2(
			18 + i * 20,
			110,
			20,
			20
		)

		animaciones.add_frame("fuego", recorte)

	sprite_frames = animaciones
	play("fuego")

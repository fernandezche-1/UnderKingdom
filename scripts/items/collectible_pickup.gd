extends Area2D
class_name UnderkingdomCollectiblePickup

## Pickup reutilizable para monedas y pociones físicas del mapa.
## Aparece con un pequeño salto visual y luego puede recogerlo el Player.

@export_enum("coin", "potion") var pickup_type: String = "coin"
@export_range(0.25, 4.0, 0.25) var amount: float = 1.0
@export_range(0.0, 1.0, 0.05) var pickup_delay: float = 0.20

var _can_pickup: bool = false


func _ready() -> void:
	# Colocado en el mapa y ya recogido antes de recargarlo (muerte): no vuelve.
	# Los que sueltan cofres y objetos rotos no tienen owner y no se registran.
	if GameManager.is_object_consumed(self):
		queue_free()
		return

	monitoring = false
	monitorable = true

	var original_position := position
	var original_scale := scale
	position += Vector2(0.0, 7.0)
	scale = original_scale * 0.75

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position", original_position, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if pickup_delay > 0.0:
		await get_tree().create_timer(pickup_delay).timeout

	_can_pickup = true
	monitoring = true


func _physics_process(_delta: float) -> void:
	if not _can_pickup:
		return

	for body in get_overlapping_bodies():
		if body != null and body.is_in_group("player"):
			if _try_collect(body):
				GameManager.mark_object_consumed(self)
				queue_free()
				return


func _try_collect(player: Node) -> bool:
	match pickup_type:
		"coin":
			if GameManager.has_method("add_coins"):
				GameManager.add_coins(maxi(1, int(round(amount))))
			return true

		"potion":
			# La poción pasa al inventario; el Player la toma con C.
			GameManager.add_potions(maxi(1, int(round(amount))))
			return true

	return false

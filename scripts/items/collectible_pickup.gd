extends Area2D
class_name UnderkingdomCollectiblePickup

## Pickup reutilizable para monedas y pociones físicas del mapa.
## Aparece con un pequeño salto visual y luego puede recogerlo el Player.

@export_enum("coin", "potion") var pickup_type: String = "coin"
@export_range(0.25, 4.0, 0.25) var amount: float = 1.0
@export_range(0.0, 1.0, 0.05) var pickup_delay: float = 0.20

var _can_pickup: bool = false
var persistent_loot_key: String = ""
var _chest_landing_global: Vector2 = Vector2.ZERO
var _has_chest_ejection: bool = false


func configure_chest_ejection(landing_global: Vector2, loot_key: String) -> void:
	_chest_landing_global = landing_global
	_has_chest_ejection = true
	persistent_loot_key = loot_key


func _ready() -> void:
	if not persistent_loot_key.is_empty() and GameManager.consumed_objects.has(persistent_loot_key):
		queue_free()
		return
	# Los pickups colocados en el mapa no vuelven si ya se recogieron.
	# El botín dinámico de cofres usa una clave persistente explícita.
	if GameManager.is_object_consumed(self):
		queue_free()
		return

	monitoring = false
	monitorable = true

	var original_position := position
	var original_scale := scale
	if _has_chest_ejection and get_parent() is Node2D:
		var landing_local := (get_parent() as Node2D).to_local(_chest_landing_global)
		var launch_position := original_position
		scale = original_scale * 0.75
		var tween := create_tween().set_parallel(true)
		tween.tween_method(
			func(progress: float) -> void:
				position = (launch_position.lerp(landing_local, progress) + Vector2(0.0, -sin(progress * PI) * 18.0)).round(),
			0.0,
			1.0,
			0.42
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", original_scale, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		position += Vector2(0.0, 7.0)
		scale = original_scale * 0.75
		var tween := create_tween().set_parallel(true)
		tween.tween_property(self, "position", original_position, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", original_scale, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var effective_pickup_delay := maxf(pickup_delay, 0.45) if _has_chest_ejection else pickup_delay
	if effective_pickup_delay > 0.0:
		await get_tree().create_timer(effective_pickup_delay).timeout

	_can_pickup = true
	monitoring = true


func _physics_process(_delta: float) -> void:
	if not _can_pickup:
		return

	for body in get_overlapping_bodies():
		if body != null and body.is_in_group("player"):
			if _try_collect(body):
				if persistent_loot_key.is_empty():
					GameManager.mark_object_consumed(self)
				else:
					GameManager.consumed_objects[persistent_loot_key] = true
					GameManager.request_autosave()
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

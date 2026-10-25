extends SceneTree

func _initialize() -> void:
	call_deferred("_run_probe")

func _run_probe() -> void:
	set_meta("underkingdom_camara_sellado_alma_completada", true)
	var error := change_scene_to_file("res://escenas/mapas/prologo_prision/camara_sellado_alma.tscn")
	if error != OK:
		print("PROBE scene_error=", error)
		quit(1)
		return
	for i in 8:
		await physics_frame
	var actor := get_first_node_in_group("player") as CharacterBody2D
	if actor == null:
		print("PROBE missing_player")
		quit(2)
		return
	var sprite := actor.get_node("AnimatedSprite2D") as AnimatedSprite2D
	var collision := actor.get_node("CollisionShape2D") as CollisionShape2D
	for anim in [&"idle", &"run", &"puch"]:
		sprite.play(anim)
		for frame_index in sprite.sprite_frames.get_frame_count(anim):
			sprite.set_frame_and_progress(frame_index, 0.0)
			await physics_frame
			var floor_y := collision.global_position.y + (collision.shape as RectangleShape2D).size.y * 0.5
			print("PROBE anim=", anim, " frame=", frame_index, " root=", actor.global_position, " sprite=", sprite.global_position, " collision_bottom=", floor_y, " on_floor=", actor.is_on_floor(), " vy=", actor.velocity.y)
	quit()

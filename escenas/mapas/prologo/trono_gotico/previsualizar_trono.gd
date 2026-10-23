extends SceneTree


func _initialize() -> void:
	call_deferred("preview")


func preview() -> void:
	Engine.max_fps=60
	root.size=Vector2i(1152,448)
	root.content_scale_size=Vector2i(1152,448)
	change_scene_to_file("res://escenas/mapas/prologo/trono_gotico/castillo_trono_gotico.tscn")
	await create_timer(0.4).timeout
	var player := get_first_node_in_group("player")
	player.get_node("Camera2D").enabled=false
	player.get_node("PlayerHUD").visible=false
	var camera := Camera2D.new()
	camera.position=Vector2(576,224)
	current_scene.add_child(camera)
	camera.make_current()
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://escenas/mapas/prologo/trono_gotico/vista_general.png")
	if error!=OK:
		push_error("Unable to save room preview")
	print("PREVIEW: editable room rendered as individual tiles")
	quit(0 if error==OK else 1)

extends SceneTree


func _initialize() -> void:
	call_deferred("preview")


func capture(label: String) -> void:
	await create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("res://edwin_preview_" + label + ".png")
	if result != OK:
		push_error("Could not save menu preview")
	print("CAPTURE: " + label)


func preview() -> void:
	if not OS.get_user_data_dir().contains("UnderkingdomIntegrationValidation_"):
		quit(1)
		return
	Engine.max_fps = 60
	change_scene_to_file("res://escenas/menu/menu_principal.tscn")
	await process_frame
	await capture("main")
	current_scene.call("_show_new_profiles")
	await capture("profiles")
	var gm := root.get_node("GameManager")
	gm.call("mark_cinematic_seen", "cementerio_intro_recuerdo")
	change_scene_to_file(gm.CEMETERY_SCENE_PATH)
	await create_timer(0.5).timeout
	var pause := root.get_node("PauseMenu")
	var event := InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	pause.call("_input", event)
	await capture("pause")
	var overlay := pause.get("_overlay") as Node
	if overlay != null:
		overlay.call("_show_tab", "skills")
		await capture("abilities")
		overlay.call("_on_ability_selected", "parry")
		overlay.get_node("Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Extra_parry").grab_focus()
		await capture("abilities_extra")
	quit()

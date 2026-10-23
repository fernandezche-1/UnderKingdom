extends SceneTree

var failures := 0
var checks := 0


func _initialize() -> void:
	call_deferred("validate")


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("VALIDATION: " + message)
	else:
		print("PASS: " + message)


func frames(count: int = 4) -> void:
	for i in count:
		await process_frame
	await physics_frame
	await process_frame


func enter(path: String) -> Node:
	check(change_scene_to_file(path) == OK, "Open " + path)
	await frames()
	return current_scene


func validate() -> void:
	# Refuse to run save/delete tests against the actual player's data.
	if not OS.get_user_data_dir().contains("UnderkingdomIntegrationValidation_"):
		push_error("Run with tools/run_integration_validation.py to isolate real saves.")
		quit(1)
		return
	var gm := root.get_node("GameManager")
	var pause := root.get_node("PauseMenu")
	var settings := root.get_node("UserSettings")
	var resources: Array = JSON.parse_string(FileAccess.get_file_as_string("res://validation_resources.json"))
	for path in resources:
		if String(path).begins_with("res://tools/"):
			continue
		check(load(path) != null, "Load " + path)
	var menu := await enter("res://escenas/menu/menu_principal.tscn")
	check(menu.get("_continue_button").disabled, "Continue disabled without a save")
	menu.call("_show_options")
	settings.call("set_fullscreen", true)
	var config := ConfigFile.new()
	check(config.load("user://settings.cfg") == OK, "Display preferences saved")
	check(bool(config.get_value("display", "fullscreen", false)), "Fullscreen preference persists")
	check(menu.get("_options_panel").get_node("PantallaCompleta").button_pressed, "Fullscreen checkbox synchronized")
	settings.call("set_fullscreen", false)
	menu.call("_on_new_game_pressed")
	menu.get("_profile_name").text = "Prueba Alma"
	menu.call("_start_new_profile", 1, false)
	await frames()
	check(current_scene.scene_file_path == gm.PRISON_SCENE_PATH, "New game opens Soul Sealing Chamber")
	check(gm.player_name == "Prueba Alma", "Custom profile name retained")
	check(not gm.has_ability("combo_2") and not gm.has_ability("ultimate"), "Soul fragmentation preserved")
	check(gm.has_ability("roll"), "Existing roll remains available")
	var player := get_first_node_in_group("player")
	check(player != null and player.controls_locked, "Prison cinematic locks player")
	var deadline := Time.get_ticks_msec() + 50000
	Engine.time_scale = 8.0
	while not gm.has_seen_cinematic(gm.PRISON_CINEMATIC_ID) and Time.get_ticks_msec() < deadline:
		var dialogue := current_scene.get("_dialogue") as Node
		if is_instance_valid(dialogue) and bool(dialogue.get("_active")) and not bool(dialogue.get("_pause_advance")):
			dialogue.call("_advance")
		await create_timer(0.05, true, false, true).timeout
	Engine.time_scale = 1.0
	check(gm.has_seen_cinematic(gm.PRISON_CINEMATIC_ID), "Prison cinematic completes")
	player = get_first_node_in_group("player")
	check(not player.controls_locked and player.is_physics_processing(), "Player control restored after cinematic")
	check(current_scene.get_node("SalidaPrision").enabled, "Prison exit enabled")
	var event := InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	pause.call("_input", event)
	check(paused, "Pause opens")
	var overlay := pause.get("_overlay") as Node
	check(overlay.get_node("Interfaz/PaginaHabilidades") != null, "v4 skill tab retained")
	overlay.call("show_options")
	pause.call("_input", event)
	check(paused and not overlay.call("is_options_open"), "Pause backs out of options")
	pause.call("_input", event)
	check(not paused, "Pause closes")
	pause.call("open_shop", "EL BARQUERO")
	check(paused and overlay.get_node("Interfaz/PaginaMejoras").visible, "Merchant opens existing upgrade shop")
	pause.call("resume_game")
	gm.call("unlock_ability", "combo_2")
	check(gm.is_skill_unlocked(&"attack_2"), "Relic unlocks v4 skill")
	gm.call("grant_soul_fragment", [&"ultimate"] as Array[StringName])
	check(gm.has_ability("ultimate"), "Soul fragment unlocks Edwin ability API")
	gm.call("add_coins", 50)
	check(gm.purchase_upgrade("max_health"), "Existing upgrade purchase works")
	check(is_equal_approx(player.max_health, 5.0), "Upgrade applied to player")
	check(gm.save_active_game({}, player), "Integrated progress saves")
	var saved: Dictionary = gm.call("_read_save_slot", 1)
	check(bool(saved.get("valid", false)), "Save is valid in v4 format")
	gm.call("reset_soul_progress")
	gm.coins = 0
	check(gm.load_save_slot(1), "Continue loads saved slot")
	await frames()
	player = get_first_node_in_group("player")
	check(not player.controls_locked, "Continue skips completed prison cinematic")
	check(gm.has_ability("combo_2") and gm.has_ability("ultimate"), "Ability progress restored from v4 skills")
	check(int(gm.upgrade_levels.max_health) == 1 and gm.coins == 45, "Inventory and upgrades restored")
	gm.active_save_slot = 0
	gm.call("cancel_pending_autosave")
	var health_before: float = player.current_health
	player.call("take_damage", 0.25)
	check(player.current_health < health_before, "Player receives combat damage")
	check(is_equal_approx(player.get_node("PlayerHUD/Raiz/BarraVida").value, player.current_health), "HUD follows health signal")
	gm.call("grant_key", "integration_test_key")
	check(player.get_node("PlayerHUD/Raiz/IconoLlave").visible, "HUD follows acquired keys")
	for enemy_path in ["res://escenas/enemigos/esqueleto.tscn", "res://escenas/enemigos/esqueleto_tumba.tscn", "res://escenas/enemigos/murcielago.tscn", "res://escenas/jefes/capitan.tscn", "res://escenas/jefes/reina_jefe.tscn", "res://escenas/jefes/guardian_hielo.tscn", "res://escenas/jefes/demon_slime_jefe.tscn", "res://escenas/jefes/cthulhu_jefe.tscn"]:
		var enemy := load(enemy_path).instantiate() as Node2D
		enemy.position = player.global_position + Vector2(4000, 0)
		current_scene.add_child(enemy)
		await frames()
		var health: float = enemy.get("current_health")
		if enemy_path.ends_with("esqueleto_tumba.tscn"):
			player.call("_damage_target_once", enemy, 1.0, false)
			check(is_equal_approx(float(enemy.get("current_health")), health), "Buried skeleton rejects damage while dormant")
			enemy.call("_wake", 1.0)
			await create_timer(2.0).timeout
		player.call("_damage_target_once", enemy, 1.0, false)
		check(float(enemy.get("current_health")) < health, "Player damages " + enemy_path)
		enemy.queue_free()
		await frames()
	for path in resources:
		if not String(path).ends_with(".tscn") or not String(path).begins_with("res://escenas/mapas/"):
			continue
		if String(path).contains("backup") or String(path).contains("before_editable"):
			continue
		var map := await enter(path)
		for transition in map.find_children("*", "Area2D", true, false):
			if transition.get_script() == null or transition.get_script().resource_path != "res://scripts/transitions/map_transition.gd":
				continue
			if transition.target_scene_path.is_empty():
				continue
			var target := load(transition.target_scene_path).instantiate() as Node
			var found := false
			for marker in target.find_children("*", "Marker2D", true, false):
				if marker.get("spawn_id") == transition.target_spawn_id:
					found = true
				elif marker.name == transition.target_spawn_id:
					found = true
			# Legacy test maps create these markers in WorldTestRoute._ready().
			for route in target.find_children("*", "Node", true, false):
				if route.get_script() != null and route.get_script().resource_path == "res://scripts/transitions/world_test_route.gd":
					if route.enabled and transition.target_spawn_id in [&"SpawnInicio", &"SpawnEntrada", &"SpawnSalida"]:
						found = true
			check(found, "Transition spawn exists: " + String(path) + " -> " + transition.target_scene_path + " / " + String(transition.target_spawn_id))
			target.free()
		player = get_first_node_in_group("player")
		if player != null:
			check(player.global_position.is_finite(), "Finite player spawn: " + String(path))
			var controller := map.find_child("SpawnController", true, false)
			if controller != null and String(path).contains("/tiles_"):
				check(not controller.call("_is_safe_landing", player, Vector2(-50000, -50000)), "Unsafe spawn rejected: " + String(path))
	menu = await enter("res://escenas/menu/menu_principal.tscn")
	check(not menu.get("_continue_button").disabled, "Continue enabled with existing save")
	menu.call("_show_delete_profiles")
	menu.call("_on_profile_slot_pressed", 1, gm.get_save_slot_info(1))
	check(menu.get("_delete_confirmation").visible and gm.has_any_valid_save_slot(), "Delete requires confirmation")
	menu.call("_cancel_delete_confirmation")
	check(gm.has_any_valid_save_slot(), "Cancel deletion preserves save")
	menu.call("_on_profile_slot_pressed", 1, gm.get_save_slot_info(1))
	menu.call("_confirm_delete_slot")
	check(not gm.has_any_valid_save_slot(), "Confirmed deletion removes save")
	print("INTEGRATION RESULT: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)

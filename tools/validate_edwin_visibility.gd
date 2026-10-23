extends SceneTree

var failures := 0
var checks := 0


func _initialize() -> void:
	call_deferred("validate")


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("VISIBILITY: " + message)
	else:
		print("PASS: " + message)


func frames() -> void:
	for index in 4:
		await process_frame
	await physics_frame
	await physics_frame
	await process_frame


func enter(path: String) -> Node:
	check(change_scene_to_file(path) == OK, "Open " + path)
	await frames()
	return current_scene


func validate() -> void:
	if not OS.get_user_data_dir().contains("UnderkingdomIntegrationValidation_"):
		push_error("Use run_integration_validation.py --visibility; real saves are protected.")
		quit(1)
		return
	var gm := root.get_node("GameManager")
	var pause := root.get_node("PauseMenu")
	var settings := root.get_node("UserSettings")
	var menu := await enter("res://escenas/menu/menu_principal.tscn")
	check(menu.theme.resource_path.ends_with("tema_underkingdom.tres"), "Edwin theme scoped to main menu")
	check(menu.get_node("Titulo").get_theme_font("font").resource_path.ends_with("Jacquard12-Regular.ttf"), "Jacquard title is active")
	check(menu.has_node("AnimasEdwin") and menu.has_node("AdornoEdwin") and menu.has_node("SelectorEdwin"), "Animated wisps, ornament and selector connected")
	check(menu.get_node("BotonesPrincipales").position.x == 40, "Edwin left layout with v4 controls")
	for name in ["NuevaPartida", "Continuar", "EliminarPartida", "Opciones", "Salir"]:
		check(menu.get_node("BotonesPrincipales/" + name).get_signal_connection_list("pressed").size() > 0, "Functional main button: " + name)
	menu.call("_show_new_profiles")
	check(menu.get("_profile_slots").get_child_count() == 3, "Three profile slots retained")
	menu.get("_profile_name").text = "Alma Visible"
	menu.call("_start_new_profile", 1, false)
	await frames()
	check(current_scene.scene_file_path == gm.PRISON_SCENE_PATH, "New game still starts in prison")
	check(gm.player_name == "Alma Visible", "Personalized protagonist retained")
	var prisoner := get_first_node_in_group("player")
	check(prisoner.controls_locked and current_scene.get("queen") != null, "Prison cinematic and Water Queen retained")
	# Other cinematic phases were already validated; do not replay the full sequence.
	gm.call("cancel_pending_autosave")
	gm.call("mark_cinematic_seen", "cementerio_intro_recuerdo")
	var cemetery := await enter(gm.CEMETERY_SCENE_PATH)
	var player := get_first_node_in_group("player")
	check(get_nodes_in_group("player").size() == 1, "One player after entering cemetery")
	for name in ["EsqueletoEdwin", "TumbaEdwin", "MurcielagoEdwin"]:
		var enemy := cemetery.get_node("Enemigos/" + name) as Node2D
		check(enemy != null and enemy.is_in_group("enemy"), "New playable enemy: " + name)
		var health: float = enemy.get("current_health")
		if name == "TumbaEdwin":
			player.call("_damage_target_once", enemy, 0.25, false)
			check(is_equal_approx(health, enemy.get("current_health")), "Tomb enemy preserves dormant protection")
			enemy.call("_wake", 1.0)
			await create_timer(2.0).timeout
		player.call("_damage_target_once", enemy, 0.25, false)
		check(float(enemy.get("current_health")) < health, "Combat works for " + name)
	for name in ["Anciano", "Barquero"]:
		var npc := cemetery.get_node("Personajes/" + name)
		check(npc.is_in_group("interactable"), "NPC connected: " + name)
		check(not npc.call("_load_lines").is_empty(), "NPC dialogue available: " + name)
	check(cemetery.has_node("Ambientacion"), "Playable cemetery ambience attached")
	var event := InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	pause.call("_input", event)
	check(paused, "Pause opens after visual changes")
	var overlay := pause.get("_overlay") as Node
	if overlay == null:
		quit(1)
		return
	check(overlay.get_node("Interfaz").theme.resource_path.ends_with("tema_underkingdom.tres"), "Edwin theme scoped to pause")
	for name in ["Reanudar", "Guardar", "Opciones", "MenuPrincipal", "Salir"]:
		check(overlay.get_node("Interfaz/BotonesPausa/" + name).get_signal_connection_list("pressed").size() > 0, "Functional pause button: " + name)
	for tab in ["stats", "keys", "upgrades", "skills"]:
		overlay.call("_show_tab", tab)
	check(overlay.get_node("Interfaz/PaginaHabilidades").visible, "All four pause tabs retained")
	for id in ["roll", "parry", "lifesteal", "adrenaline"]:
		var label := overlay.get_node("Interfaz/PaginaHabilidades/HabilidadesScroll/ListaHabilidades/Extra_" + id) as Button
		check(label.text.contains("DISPONIBLE") == gm.has_ability(id), "Supplemental ability uses GameManager: " + id)
		label.pressed.emit()
		check(overlay.get_node("Interfaz/PaginaHabilidades/DetalleHabilidad").text.contains(gm.get_ability_hint(id)), "Supplemental ability detail works: " + id)
	settings.call("set_fullscreen", true)
	check(overlay.get_node("Interfaz/ControlesOpciones/PantallaCompleta").button_pressed, "Fullscreen controls synchronize in styled pause")
	settings.call("set_fullscreen", false)
	pause.call("resume_game")
	pause.call("open_shop", "EL BARQUERO")
	check(paused and overlay.get_node("Interfaz/PaginaMejoras").visible, "Barquero shop retains upgrade tab")
	gm.call("add_coins", 50)
	check(gm.call("purchase_upgrade", "max_health"), "Shop purchase survives visual adaptation")
	pause.call("resume_game")
	# Verify the actual arena drop and pickup, not just the presence of a tscn.
	gm.call("mark_cinematic_seen", "cementerio_reencuentro_capitan")
	for region in ["cementerio", "mineria", "mazmorra", "profundidades", "jefe"]:
		var combat_map := await enter("res://escenas/mapas/tiles_" + region + "_combate.tscn")
		var combat_arena := combat_map.get_node("SistemasMapa/SalaJefe")
		combat_arena.boss_intro_delay = 0.0
		combat_arena.get_node("Activador").body_entered.emit(get_first_node_in_group("player"))
		await frames()
		check(is_instance_valid(combat_arena.boss), "Arena trigger spawns actual boss: " + region)
		check(combat_arena.state == 2, "Arena enters combat: " + region)
	var ruins := await enter("res://escenas/mapas/tiles_ruina_combate.tscn")
	var arena := ruins.get_node("SistemasMapa/SalaJefe")
	check(arena.ability_reward == "air_attack", "Guardian grants aerial soul fragment")
	check(not gm.has_ability("air_attack"), "Aerial attack starts locked")
	arena.call("_complete")
	await frames()
	var relic: Node = null
	for child in ruins.find_children("*", "Area2D", true, false):
		if child.get("ability_id") == "air_attack":
			relic = child
	check(relic != null, "Guardian actually drops aerial relic")
	if relic != null:
		relic.call("_collect")
	check(gm.has_ability("air_attack") and gm.is_skill_unlocked(&"air_attack"), "Relic and soul fragment share one unlock state")
	player = get_first_node_in_group("player")
	player.controls_locked = false
	check(gm.save_active_game({}, player), "New relic progress saves in existing format")
	gm.call("reset_soul_progress")
	check(gm.load_save_slot(1), "Existing continue loads new reward")
	await frames()
	check(gm.has_ability("air_attack"), "Aerial reward restored")
	gm.call("cancel_pending_autosave")
	menu = await enter("res://escenas/menu/menu_principal.tscn")
	check(not menu.get("_continue_button").disabled, "Styled continue detects save")
	menu.call("_show_delete_profiles")
	menu.call("_on_profile_slot_pressed", 1, gm.get_save_slot_info(1))
	check(menu.get("_delete_confirmation").visible, "Styled deletion still requires confirmation")
	menu.call("_cancel_delete_confirmation")
	check(gm.has_any_valid_save_slot(), "Cancel still protects save")
	menu.call("_on_profile_slot_pressed", 1, gm.get_save_slot_info(1))
	menu.call("_confirm_delete_slot")
	check(not gm.has_any_valid_save_slot(), "Confirmed deletion works after styling")
	print("VISIBILITY RESULT: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)

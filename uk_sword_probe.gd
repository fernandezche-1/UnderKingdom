extends Node

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("PROBE_START")
	_mark("PROBE_START")
	GameManager.reset_for_new_game()
	get_tree().current_scene = null
	var castle_scene := load("res://escenas/mapas/tiles_castillo.tscn") as PackedScene
	var castle := castle_scene.instantiate()
	get_tree().root.add_child(castle)
	get_tree().current_scene = castle
	print("PROBE_SCENE_REQUESTED")
	_mark("PROBE_SCENE_REQUESTED")
	for _frame in 8:
		await get_tree().physics_frame
	var player := get_tree().get_first_node_in_group("player") as UnderkingdomPlayer
	var guard := get_tree().current_scene.get_node_or_null("Enemigos/Guardia6") as UnderkingdomEnemyBase
	var mission := get_tree().current_scene.get_node_or_null("Enemigos/MisionRecuperarEspada") as UnderkingdomPrisonGuardMission
	print("PROBE_SCENE_READY")
	_mark("PROBE_SCENE_READY")
	if player == null or guard == null or mission == null:
		_fail("Falta el jugador, el guardia existente o el controlador de mision")
		return
	if GameManager.has_sword or not GameManager.sword_mission_started:
		_fail("La partida nueva no empezo desarmada")
		return
	if guard.max_health != 2.0 or guard.defense_enabled:
		_fail("El guardia de mision no esta configurado para recibir golpes de punos")
		return
	var state_a: Dictionary = GameManager._make_save_data(1, {"scene_path": get_tree().current_scene.scene_file_path}, player).state
	var ground := mission._find_floor_position(guard.global_position)
	var body_collision := player.get_node("CollisionShape2D") as CollisionShape2D
	var player_foot := body_collision.position.y + (body_collision.shape as RectangleShape2D).size.y * 0.5
	player.global_position = Vector2(guard.global_position.x - 42.0, ground.y - player_foot)
	for _frame in 4:
		await get_tree().physics_frame
	var guard_health := guard.current_health
	player.request_attack()
	if player.sprite.animation != &"puch":
		_fail("El ataque desarmado no inicio la animacion puch")
		return
	for _frame in 40:
		await get_tree().physics_frame
	if guard.current_health >= guard_health:
		_fail("El puñetazo no dano al guardia")
		return
	print("PROBE_FISTS_OK damage=", guard_health - guard.current_health)
	_mark("PROBE_FISTS_OK")
	var death_hit_landed := false
	for _attempt in 30:
		if guard.take_damage(10.0, player.global_position, false):
			death_hit_landed = true
			break
		await get_tree().physics_frame
	if not death_hit_landed:
		_fail("No se pudo aplicar el ultimo golpe al guardia")
		return
	print("PROBE_GUARD_DIED_OK health=", guard.current_health)
	_mark("PROBE_GUARD_DIED_OK")
	var sword := mission.get_node_or_null("EspadaRecuperable") as UnderkingdomSwordRecovery
	if sword == null or not sword.visible:
		_fail("La espada recuperable no aparecio")
		return
	var sword_floor := mission._find_floor_position(guard.global_position)
	if absf((sword.global_position.y + 34.0) - sword_floor.y) > 1.5:
		_fail("La espada no quedo apoyada en el suelo fisico")
		return
	var state_b: Dictionary = GameManager._make_save_data(1, {"scene_path": get_tree().current_scene.scene_file_path}, player).state
	_restore_and_reload(state_a)
	player = get_tree().get_first_node_in_group("player") as UnderkingdomPlayer
	guard = get_tree().current_scene.get_node_or_null("Enemigos/Guardia6") as UnderkingdomEnemyBase
	if player == null or guard == null or GameManager.has_sword or GameManager.sword_guard_defeated:
		_fail("El guardado A no restauro el combate pendiente")
		return
	if get_tree().current_scene.get_node_or_null("Enemigos/MisionRecuperarEspada/EspadaRecuperable") != null:
		_fail("El guardado A mostro una recompensa antes de derrotar al guardia")
		return
	print("PROBE_SAVE_A_OK guard_pending=true armed=false")
	_mark("PROBE_SAVE_A_OK")
	_restore_and_reload(state_b)
	player = get_tree().get_first_node_in_group("player") as UnderkingdomPlayer
	mission = get_tree().current_scene.get_node("Enemigos/MisionRecuperarEspada") as UnderkingdomPrisonGuardMission
	sword = mission.get_node_or_null("EspadaRecuperable") as UnderkingdomSwordRecovery
	if player == null or get_tree().current_scene.get_node_or_null("Enemigos/Guardia6") != null or sword == null:
		_fail("El guardado B no restauro una sola recompensa pendiente")
		return
	print("PROBE_SAVE_B_OK guard_absent=true pending_sword=1")
	_mark("PROBE_SAVE_B_OK")
	_restore_and_reload(state_b)
	mission = get_tree().current_scene.get_node("Enemigos/MisionRecuperarEspada") as UnderkingdomPrisonGuardMission
	if mission.get_children().filter(func(node: Node) -> bool: return node is UnderkingdomSwordRecovery).size() != 1:
		_fail("El guardado B duplico la recompensa al cargar otra vez")
		return
	player = get_tree().get_first_node_in_group("player") as UnderkingdomPlayer
	mission = get_tree().current_scene.get_node("Enemigos/MisionRecuperarEspada") as UnderkingdomPrisonGuardMission
	sword = mission.get_node("EspadaRecuperable") as UnderkingdomSwordRecovery
	player.global_position = sword.global_position + Vector2(0.0, -29.0)
	for _frame in 2:
		await get_tree().physics_frame
	var feet_before := _visible_foot_y(player.sprite)
	var root_before := player.global_position
	if not sword.interact(player):
		_fail("No se pudo recoger la espada mediante interact")
		return
	await get_tree().create_timer(0.55).timeout
	if not GameManager.has_sword or not GameManager.sword_mission_completed:
		_fail("La recogida no completo la mision y el estado del arma")
		return
	if absf(player.global_position.x - root_before.x) > 1.0 or absf(player.global_position.y - root_before.y) > 1.0:
		_fail("Recoger la espada cambio la posicion del CharacterBody2D")
		return
	var feet_after := _visible_foot_y(player.sprite)
	if absf(feet_after - feet_before) > 1.0:
		_fail("Los pies visuales cambiaron al equipar: %s -> %s" % [feet_before, feet_after])
		return
	if not player.sprite.sprite_frames.has_animation(&"attack") or player.sprite.animation != &"idle":
		_fail("El conjunto armado no reinicio en idle o no tiene ataques")
		return
	var state_c: Dictionary = GameManager._make_save_data(1, {"scene_path": get_tree().current_scene.scene_file_path}, player).state
	player.velocity.x = 100.0
	player._update_animation(1.0)
	if player.sprite.animation != &"run":
		_fail("La animacion run armada no se selecciono")
		return
	player.velocity = Vector2.ZERO
	player._update_animation(0.0)
	player.request_attack()
	if player.sprite.animation != &"attack" or int(player.get("_action")) != 1:
		_fail("El ataque armado no inicio")
		return
	Input.action_press("move_right")
	player._try_cancel_attack_by_movement()
	Input.action_release("move_right")
	if int(player.get("_action")) != 1:
		_fail("Caminar cancelo el ataque armado")
		return
	var hitbox_shape := player.attack_hitbox.get_node("CollisionShape2D") as CollisionShape2D
	player.sprite.frame = 0
	player._update_attack_damage_window()
	await get_tree().process_frame
	if not hitbox_shape.disabled:
		_fail("La hitbox se activo fuera de la ventana del tajo")
		return
	player.sprite.frame = 4
	player._update_attack_damage_window()
	await get_tree().process_frame
	if hitbox_shape.disabled:
		_fail("La hitbox no se activo durante la ventana del tajo")
		return
	print("PROBE_ARMED_COMBAT_OK idle=true run=true attack=true hitbox_window=true feet_delta=", feet_after - feet_before)
	_mark("PROBE_ARMED_COMBAT_OK")
	_restore_and_reload(state_c)
	player = get_tree().get_first_node_in_group("player") as UnderkingdomPlayer
	mission = get_tree().current_scene.get_node("Enemigos/MisionRecuperarEspada") as UnderkingdomPrisonGuardMission
	if player == null or not GameManager.has_sword or get_tree().current_scene.get_node_or_null("Enemigos/Guardia6") != null:
		_fail("El guardado C no restauro la partida armada")
		return
	if mission.get_node_or_null("EspadaRecuperable") != null or not player.sprite.sprite_frames.has_animation(&"attack"):
		_fail("El guardado C reaparecio la recompensa o cargo frames incorrectos")
		return
	print("PROBE_SAVE_C_OK armed=true guard_absent=true pending_sword=false")
	_mark("PROBE_SAVE_C_OK")
	get_tree().quit(0)


func _restore_and_reload(state: Dictionary) -> void:
	GameManager._restore_game_state(state)
	var old_scene := get_tree().current_scene
	old_scene.queue_free()
	get_tree().current_scene = null
	await get_tree().process_frame
	var castle_scene := load("res://escenas/mapas/tiles_castillo.tscn") as PackedScene
	var castle := castle_scene.instantiate()
	get_tree().root.add_child(castle)
	get_tree().current_scene = castle
	for _frame in 8:
		await get_tree().physics_frame


func _visible_foot_y(sprite: AnimatedSprite2D) -> float:
	var texture := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var image := texture.get_image()
	if texture is AtlasTexture:
		var atlas := texture as AtlasTexture
		image = image.get_region(Rect2i(atlas.region.position, atlas.region.size))
	var used := image.get_used_rect()
	return sprite.global_position.y + (float(used.position.y + used.size.y) - texture.get_height() * 0.5 + sprite.offset.y) * sprite.scale.y


func _fail(message: String) -> void:
	push_error("SWORD_PROBE_FAIL: " + message)
	_mark("SWORD_PROBE_FAIL: " + message)
	get_tree().quit(1)


func _mark(message: String) -> void:
	var path := "res://.godot/sword-probe-results.txt"
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_line(message)
	file.close()

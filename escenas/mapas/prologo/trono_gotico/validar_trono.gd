extends SceneTree

const MAP := "res://escenas/mapas/prologo/trono_gotico/castillo_trono_gotico.tscn"
var failures := 0
var checks := 0
var contacts := 0
var player: Node2D


func _initialize() -> void:
	call_deferred("validate")


func check(ok: bool, text: String) -> void:
	checks += 1
	if ok:
		print("PASS: " + text)
	else:
		failures += 1
		push_error("THRONE: " + text)


func physics_frames(count: int) -> void:
	for i in count:
		await physics_frame
	await process_frame


func feet() -> float:
	return player.global_position.y + 63.0


func jump_between(start: Vector2, destination_x: float, landing_y: float, label: String) -> void:
	player.global_position = Vector2(start.x,start.y-63.0)
	player.set("velocity",Vector2.ZERO)
	await physics_frames(5)
	check(player.call("is_on_floor"), label + " starts on a physical surface")
	player.set("_jump_requested",true)
	Input.action_press("move_right")
	var minimum_feet := feet()
	for i in 85:
		await physics_frame
		minimum_feet = minf(minimum_feet,feet())
		if player.global_position.x >= destination_x:
			Input.action_release("move_right")
		if bool(player.get("dead")):
			break
	Input.action_release("move_right")
	check(not bool(player.get("dead")) and player.call("is_on_floor") and absf(feet()-landing_y)<2.0, label + " lands using actual player physics")
	check(minimum_feet < start.y-40.0, label + " produces a real jump arc")


func validate() -> void:
	if not OS.get_user_data_dir().contains("UnderkingdomGothicThroneValidation_"):
		push_error("Use pipeline.py: tests must not access real save data")
		quit(1)
		return
	check(change_scene_to_file(MAP)==OK,"Saved tscn opens")
	await physics_frames(8)
	player = get_first_node_in_group("player")
	check(player != null and get_nodes_in_group("player").size()==1,"One current player spawned")
	check(current_scene.get_script()==null,"Map has no runtime generation script")
	for name in ["FondoAtmosfera","MuroFondo","Arquitectura","Terreno","Plataformas","Decoracion","ElementosInteractivos","Peligros"]:
		var layer := current_scene.get_node(name) as TileMapLayer
		check(layer != null and layer.get_used_cells().size()>0,"Persistent editable painted layer: " + name)
	check(player.call("is_on_floor"),"Entrance is supported by terrain")
	var ray := PhysicsRayQueryParameters2D.create(Vector2(48,350),Vector2(48,400),1)
	ray.exclude = [player.get_rid()]
	var hit: Dictionary = player.get_world_2d().direct_space_state.intersect_ray(ray)
	check(not hit.is_empty() and absf(hit.position.y-384.0)<1.0,"Terrain collision matches painted floor")
	check(current_scene.get_node("SistemasMapa/MapBounds").get("right")==1152,"Camera has explicit room bounds")
	await jump_between(Vector2(224,336),304,288,"Dais to left gallery")
	await jump_between(Vector2(368,288),456,208,"Left gallery to central balcony")
	await jump_between(Vector2(680,208),768,240,"Central balcony to middle perch")
	await jump_between(Vector2(784,240),896,192,"Middle perch to right balcony")
	await jump_between(Vector2(488,384),584,320,"Ground to bridge over spike pit")
	if failures>0:
		print("THRONE RESULT: %d checks, %d failures" % [checks,failures])
		quit(1)
		return
	player.global_position = Vector2(576,257)
	player.set("velocity",Vector2.ZERO)
	await physics_frames(5)
	var ladder := current_scene.get_node("ElementosInteractivos/EscaleraCentral")
	check(ladder.get_overlapping_bodies().has(player),"Climb detector overlaps player at ladder foot")
	var old_y := player.global_position.y
	Input.action_press("move_up")
	await physics_frames(38)
	Input.action_release("move_up")
	check(player.call("is_climbing") and player.global_position.y<old_y-40,"Existing climbing system moves player upward")
	player.global_position=Vector2(576,137)
	player.set("velocity",Vector2.ZERO)
	await physics_frames(3)
	Input.action_press("move_down")
	await physics_frames(40)
	Input.action_release("move_down")
	check(player.call("is_climbing") and feet()>240,"Ladder descends through its balcony opening")
	player.call("set_climb_zone",ladder,false)
	player.global_position = Vector2(496,145)
	player.set("velocity",Vector2.ZERO)
	await physics_frames(5)
	var chest := current_scene.get_node("ElementosInteractivos/CofreBalcon")
	check(chest.call("can_interact",player),"Chest is within player interaction range on balcony")
	check(chest.call("interact",player),"Existing chest interaction opens the chest")
	await create_timer(2.2).timeout
	check(bool(chest.get("loot_given")) and bool(chest.get("is_open")),"Chest grants its existing one-time loot")
	player.global_position = Vector2(1100,321)
	player.set("velocity",Vector2.ZERO)
	await physics_frames(5)
	var exit := current_scene.get_node("SistemasMapa/SalidaDerecha")
	check(exit.get("_player_inside")==player,"Player can physically enter the exit")
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	exit.call("_unhandled_input",event)
	await physics_frames(6)
	check(current_scene.scene_file_path=="res://escenas/mapas/prologo/castillo_oscuro.tscn","Exit performs a real transition to existing castle")
	change_scene_to_file(MAP)
	await physics_frames(8)
	player = get_first_node_in_group("player")
	var spikes := current_scene.get_node("Peligros/PinchosLetales")
	spikes.connect("lethal_contact",func(_body: Node) -> void: contacts+=1)
	player.global_position = Vector2(584,344)
	player.set("velocity",Vector2.ZERO)
	await physics_frames(4)
	check(contacts>0 and bool(player.get("dead")),"Entering painted spikes triggers actual player death")
	await create_timer(4.0).timeout
	player = get_first_node_in_group("player")
	check(player!=null and not bool(player.get("dead")) and player.global_position.x<100,"Death respawns at safe room entrance")
	print("THRONE RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)

extends UnderkingdomBossKeyPickup

func _collect() -> void:
	if _collected:
		return
	print("[ARMORY_KEY] collected pickup=%s key_id=%s position=%s" % [get_path(), key_id, global_position])
	super._collect()
	var player := get_tree().get_first_node_in_group(player_group)
	var hud := player.get_node_or_null("PlayerHUD") if player != null else null
	if hud != null and hud.has_method("show_story_notice"):
		hud.call("show_story_notice", "LLAVE OBTENIDA", "Llave de la armería")

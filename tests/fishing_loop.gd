extends SceneTree

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run() -> void:
	var manager := root.get_node("GameManager")
	check(manager.dayLength == 70.0 and manager.quota == 3.0, "Day lasts seventy seconds with three quota wins")
	manager.score = 0
	manager.dayKillCount = 0
	manager.totalKillCount = 0
	manager.dayTimer = 25.0
	var quota_hud := (load("res://scenes/qouta.tscn") as PackedScene).instantiate()
	manager.add_child(quota_hud)
	manager.quota_display = quota_hud
	# Dialogue presentation is covered by the game; keep these loop checks deterministic.
	quota_hud.events.clear()
	check(quota_hud is CanvasLayer and quota_hud.layer == 6, "Quota is fixed on screen above minigame HUD")
	check(quota_hud.label.text == "QUOTA WINS: 0 / 3", "Quota starts at zero of three")
	var fishing := (load("res://scenes/exploration.tscn") as PackedScene).instantiate()
	root.add_child(fishing)
	current_scene = fishing
	var lure := fishing.get_node("Player/PlayerBody/LureBody") as CharacterBody2D
	var camera := fishing.get_node("Player/Camera2D") as Camera2D
	camera.make_current()
	for win in range(1, 8):
		var ship_body: Node2D = null
		for child in fishing.get_children():
			if child.has_node("EnemyBody"):
				ship_body = child.get_node("EnemyBody")
		check(is_instance_valid(ship_body), "Fishing has a ship for encounter %d" % win)
		if not is_instance_valid(ship_body):
			break
		var ship_root := ship_body.get_parent()
		ship_body.get_node("Area2D").body_entered.emit(lure)
		await process_frame
		var round_node: Node2D = null
		for child in fishing.get_children():
			if child.has_node("HUD/LivesLabel"):
				round_node = child
		check(is_instance_valid(round_node) and manager.isMinigame, "Lure can enter encounter %d" % win)
		if not is_instance_valid(round_node):
			break
		round_node.set_process(false)
		check(round_node.get_node("Player").lives == 3, "New round replenishes three lives")
		check(quota_hud.visible and quota_hud.label.is_visible_in_tree(), "Quota remains visible during minigame")
		if win == 1:
			var player := round_node.get_node("Player") as Area2D
			for i in range(3):
				player.invulnerability_time = 0.0
				var bullet := Area2D.new()
				bullet.add_to_group("bullets")
				root.add_child(bullet)
				player._on_area_entered(bullet)
			await process_frame
			await process_frame
			check(not is_instance_valid(round_node) and not paused, "Lost round returns to fishing without game over")
			check(is_instance_valid(ship_root) and is_instance_valid(ship_body), "Lost encounter is still available")
			check(manager.score == 0 and manager.totalKillCount == 0, "Loss awards no quota or ship")
			check(fishing.can_process() and not manager.isMinigame, "Fishing resumes after loss")
			ship_body.get_node("Area2D").body_entered.emit(lure)
			await process_frame
			for child in fishing.get_children():
				if child.has_node("HUD/LivesLabel"):
					round_node = child
			check(is_instance_valid(round_node), "Same encounter can be entered again after loss")
			if not is_instance_valid(round_node):
				break
			round_node.set_process(false)
			check(round_node.get_node("Player").lives == 3, "Retry starts with three lives")
		round_node._process(10.0)
		await process_frame
		await process_frame
		check(not is_instance_valid(round_node) and not is_instance_valid(ship_root), "Finished round and whole ship are removed")
		check(current_scene == fishing and fishing.can_process() and not manager.isMinigame, "Fishing resumes after encounter %d" % win)
		check(root.get_viewport().get_camera_2d() == camera, "Fishing camera is restored")
		check(manager.score == mini(win, 3), "Quota increases once and caps at three")
		check(quota_hud.label.text == "QUOTA WINS: %d / 3" % mini(win, 3), "Quota is updated immediately")
		check(quota_hud.label.is_visible_in_tree(), "Quota remains visible in fishing")
	check(manager.totalKillCount == 7 and manager.dayKillCount == 7, "Ships sunk still track all wins")
	check(manager.dayTimer == 25.0, "Round transitions preserve the day timer")
	# Starting a fresh run resets both the displayed count and quota event progress.
	quota_hud.nextEvent = 3
	manager.score = 0
	quota_hud.start()
	check(quota_hud.nextEvent == 0 and quota_hud.label.text == "QUOTA WINS: 0 / 3", "New run resets the quota HUD")
	print("Fishing loop: %d failure(s)" % failures)
	quit(failures)

extends SceneTree

var failures := 0
var game_manager: Node
var world: Node2D

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func make_round() -> Node2D:
	var round_scene := load("res://scenes/minigame/minigameMain.tscn") as PackedScene
	var round_node := round_scene.instantiate() as Node2D
	world.add_child(round_node)
	# Drive elapsed time explicitly for deterministic boundary checks.
	round_node.set_process(false)
	for child in round_node.get_children():
		if child != round_node.get_node("Player"):
			child.set_process(false)
	return round_node

func hit(player: Area2D) -> void:
	var bullet := Area2D.new()
	bullet.add_to_group("bullets")
	world.add_child(bullet)
	player._on_area_entered(bullet)

func run() -> void:
	game_manager = root.get_node("GameManager")
	world = Node2D.new()
	root.add_child(world)
	current_scene = world
	var camera := Camera2D.new()
	world.add_child(camera)
	camera.make_current()
	game_manager.score = 0
	game_manager.dayKillCount = 0
	game_manager.totalKillCount = 0
	game_manager.dayTimer = 27.0
	var round_node := make_round()
	var player := round_node.get_node("Player") as Area2D
	check(game_manager.minigameTimer == 10.0, "Round starts at ten seconds")
	check(player.lives == 3, "Round starts with three lives")
	check(not world.can_process() and round_node.can_process(), "Only exploration stops")
	check(round_node.get_node_or_null("HUD/HealthBar") == null, "Health bar removed")
	paused = true
	check(not round_node.can_process(), "Pause stops round processing")
	paused = false
	round_node._process(2.0)
	hit(player)
	check(game_manager.minigameTimer == 13.0 and player.lives == 2, "Hit adds five seconds")
	hit(player)
	check(player.lives == 2 and game_manager.minigameTimer == 13.0, "Invulnerability ignores repeat hits")
	player.invulnerability_time = 0.0
	hit(player)
	check(player.lives == 1 and game_manager.minigameTimer == 18.0, "Second hit adds five seconds")
	# A win removes the source ship and restores this same exploration instance.
	var ship := Node2D.new()
	world.add_child(ship)
	round_node.source_ship = ship
	round_node._process(18.0)
	round_node._process(1.0)
	await process_frame
	await process_frame
	check(not is_instance_valid(round_node) and not is_instance_valid(ship), "Win cleans up minigame and ship")
	check(game_manager.score == 1 and game_manager.dayKillCount == 1 and game_manager.totalKillCount == 1, "Win rewards exactly one ship")
	check(world.can_process() and not game_manager.isMinigame, "Exploration resumes")
	check(root.get_viewport().get_camera_2d() == camera, "Exploration camera restored")
	check(game_manager.dayTimer == 27.0, "Win preserves global timer")
	round_node = make_round()
	player = round_node.get_node("Player") as Area2D
	for i in range(3):
		player.invulnerability_time = 0.0
		hit(player)
	await process_frame
	check(player.lives == 0 and paused, "Third hit pauses on game over")
	check(round_node.get_node("Death/UI/PauseText").text == "GAME OVER", "Game over screen is shown")
	check(game_manager.score == 1, "Loss gives no reward")
	paused = false
	round_node.queue_free()
	await process_frame
	check(not game_manager.isMinigame and world.can_process(), "Cleanup restores exploration")
	print("Minigame flow: %d failure(s)" % failures)
	quit(failures)

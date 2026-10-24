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
	for result_score in [0, 2, 3]:
		var fishing := (load("res://scenes/exploration.tscn") as PackedScene).instantiate()
		root.add_child(fishing)
		current_scene = fishing
		manager.begin_play()
		manager.timer.events.clear()
		manager.quota_display.events.clear()
		manager.score = result_score
		var round_node: Node2D = null
		if result_score != 0:
			round_node = (load("res://scenes/minigame/minigameMain.tscn") as PackedScene).instantiate()
			fishing.add_child(round_node)
			round_node.set_process(false)
		manager.timer._process(69.6)
		check(manager.timer.label.text == "1" and not manager.run_ended, "One second shown until actual expiry")
		manager.timer._process(1.0)
		check(manager.timer.label.text == "0" and manager.dayTimer == 70.0, "Timer clamps at zero")
		check(manager.run_ended and paused and not manager.timer.running, "Expiry freezes gameplay")
		if is_instance_valid(round_node):
			round_node._finish_win()
		manager.record_minigame_win()
		check(manager.score == result_score, "No rewards can arrive after expiry")
		manager._on_day_finished()
		await process_frame
		var screen := fishing.get_node_or_null("Victory" if result_score >= 3 else "Death")
		check(screen != null, "Timer expiry opens the end screen")
		if screen == null:
			quit(1)
			return
		var expected := "You win!" if result_score >= 3 else "GAME OVER"
		check(screen.get_node("UI/PauseText").text == expected, "Result reflects quota at expiry")
		check(screen.get_node("UI/Skull").visible == (result_score < 3), "Losing art only appears on loss")
		check(not screen.get_node("UI/ContinueButton").visible, "End screen cannot resume finished play")
		var screen_count := 0
		for child in fishing.get_children():
			if child is CanvasLayer and child.has_node("UI/PauseText"):
				screen_count += 1
		check(screen_count == 1, "Repeated expiry produces only one screen")
		if result_score == 3:
			var previous_day: int = manager.dayCount
			var lifetime_total: int = manager.totalKillCount
			check(screen.get_node("UI/RestartButton").text == "Next Day", "Victory offers the next day")
			screen.onRestart()
			manager.timer.events.clear()
			manager.quota_display.events.clear()
			await process_frame
			await process_frame
			check(not paused and not manager.run_ended and manager.score == 0, "Next Day starts a fresh run")
			check(manager.dayCount == previous_day + 1 and manager.totalKillCount == lifetime_total, "Next Day advances the day and preserves lifetime ships")
			check(manager.quota_display.label.text == "QUOTA WINS: 0 / 3", "Next Day resets the quota")
			check(manager.timer.label.text == "70" and manager.timer.running, "Restart restores seventy seconds")
			check(current_scene.get_node_or_null("Victory") == null, "Restart removes the result screen")
			manager.end_play()
			current_scene.queue_free()
		else:
			manager.end_play()
			paused = false
			fishing.queue_free()
		await process_frame
	print("Timer results: %d failure(s)" % failures)
	quit(failures)

extends CanvasLayer


func _ready() -> void:
	var title := get_node_or_null("UI/PauseText")
	if title != null:
		title.text = "GAME OVER"
	var cont := get_node_or_null("UI/ContinueButton")
	if cont != null:
		cont.visible = false


func onRestart() -> void:
	get_tree().paused = false
	GameManager.begin_play()
	get_tree().reload_current_scene()


func onExit() -> void:
	get_tree().paused = false
	GameManager.end_play()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

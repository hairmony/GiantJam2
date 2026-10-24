extends CanvasLayer

@export var won: bool = false


func _ready() -> void:
	var title := get_node_or_null("UI/PauseText")
	if title != null:
		title.text = "You win!" if won else "GAME OVER"
	var skull := get_node_or_null("UI/Skull")
	if skull != null:
		skull.visible = not won
	var restart := get_node_or_null("UI/RestartButton")
	if restart != null:
		restart.text = "Next Day" if won else "Restart"
	var cont := get_node_or_null("UI/ContinueButton")
	if cont != null:
		cont.visible = false


func onRestart() -> void:
	get_tree().paused = false
	if won:
		GameManager.begin_next_day()
	else:
		GameManager.begin_play()
	get_tree().reload_current_scene()


func onExit() -> void:
	get_tree().paused = false
	GameManager.end_play()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

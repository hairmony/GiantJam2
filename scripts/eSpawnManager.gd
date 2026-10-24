extends Node

@export var eSpawnScene: PackedScene

var eSpawnLimit = 4;
var eSpawnCount = 0

func _ready():
	new_game()

func new_game():
	$StartTimer.start()
	
func _on_start_timer_timeout():
	$eSpawnTimer.start()

func _on_e_spawn_timer_timeout():
	if(eSpawnCount == eSpawnLimit):
		return
	var e = eSpawnScene.instantiate()
	var eSpawnLocation = $ePath/eSpawnLocation
	eSpawnLocation.progress_ratio = randf()
	
	e.position = eSpawnLocation.position
	
	#add movement logic here if necessary
	
	add_child(e)
	eSpawnCount += 1

extends CharacterBody2D

var value: float = 1.0
var skillScalar: float = 1.0 # defines enemy difficulty/level
var damage: float = 1.0
var enemyName: String = "enemy"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("lure") and not GameManager.isMinigame:
		GameManager.isMinigame = true
		# Instantiation changes processing and collision state outside physics callbacks.
		load_sub_scene.call_deferred("res://scenes/minigame/minigameMain.tscn")

func load_sub_scene(scene_path: String) -> void:
	var new_scene_packed: PackedScene = load(scene_path)
	var new_scene_instance: Node = new_scene_packed.instantiate()
	new_scene_instance.source_ship = self
	# Ownership by the exploration scene also cleans up overlays on restart/exit.
	get_tree().current_scene.add_child(new_scene_instance)

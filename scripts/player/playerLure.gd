extends CharacterBody2D

enum lureType {DEFAULT, FISH1}
var lurePower: float = 1.0
var lureLength: float = 1.0
var lureSpeed: float = 1.0
var moveState: bool = false # if the lure is controllable currently.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(moveState):
		pass
	
func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		var collision_point = collision_info.get_position()
	pass

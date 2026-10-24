extends CharacterBody2D
var MOVE_SCALE: int = 3000
var lurePower: float = 1.0
var lureLength: float = 1.0
var lureSpeed: float = 1.0 * MOVE_SCALE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var canMove: bool = GameManager.moveState == GameManager.LureMoveState
	if canMove:
		velocity = GameManager.playerVelocity * lureSpeed
		move_and_slide()
	pass

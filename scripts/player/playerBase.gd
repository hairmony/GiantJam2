extends CharacterBody2D

var hp: float = 100
var playerSpeed: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var canMove: bool = GameManager.moveState == GameManager.playerMoveState
	if canMove:
		velocity = GameManager.playerVelocity * playerSpeed * 10000
		move_and_slide()
	pass
	
func _physics_process(delta: float) -> void:
	#var collision_info = move_and_collide(GameManager.playerVelocity * playerSpeed)
	#if collision_info:
		#var collision_point = collision_info.get_position()
	pass

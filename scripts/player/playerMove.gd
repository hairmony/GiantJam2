extends Node2D

var screen_size

func toggleMoveState(): 
	# toggles between player and lure movement on spacebar press.
	if GameManager.moveState == GameManager.playerMoveState:
		GameManager.moveState = GameManager.LureMoveState
	else: GameManager.moveState = GameManager.playerMoveState
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("toggle_move_state"):
		toggleMoveState()
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized()
		# $AnimatedSprite2D.play()
	else:
		pass
		# $AnimatedSprite2D.stop()
		
	GameManager.playerVelocity = velocity * delta
	# position += velocity * delta
	# position = position.clamp(Vector2.ZERO, screen_size)

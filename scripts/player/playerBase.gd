extends CharacterBody2D

const MOVE_SPEED := 200.0
var hp: float = 100

@onready var sprite: Sprite2D = $AnimatedSprite2D
var _sprite_scale := Vector2.ONE
var _face_left := false

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	if sprite != null:
		_sprite_scale = sprite.scale

func _physics_process(delta: float) -> void:
	if GameManager.moveState != GameManager.playerMoveState:
		velocity = Vector2.ZERO
		return
	var movement: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed := MOVE_SPEED
	var camera := get_viewport().get_camera_2d()
	if camera != null and camera.zoom.x != 0.0:
		speed /= camera.zoom.x
	velocity = movement * speed
	move_and_slide()
	if movement != Vector2.ZERO and sprite != null:
		if movement.x < 0.0:
			_face_left = true
		elif movement.x > 0.0:
			_face_left = false
		var target := (-movement).angle() if _face_left else movement.angle()
		var blend := 1.0 - exp(-12.0 * delta)
		sprite.rotation = lerp_angle(sprite.rotation, target, blend)
		sprite.scale.x = -_sprite_scale.x if _face_left else _sprite_scale.x
		sprite.scale.y = _sprite_scale.y

extends Area2D

signal health_changed(health: int)

const speed = 200
const max_health = 3
var health = max_health
var invulnerability_time = 0.0

@onready var sprite: Sprite2D = $Sprite2D

var _sprite_scale := Vector2.ONE
var _face_left := false

func _ready() -> void:
	if sprite != null:
		_sprite_scale = sprite.scale


func _process(delta: float) -> void:
	invulnerability_time = maxf(0.0, invulnerability_time - delta)
	modulate = Color(1, 0.3, 0.3) if invulnerability_time > 0.0 else Color.WHITE
	var movement: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
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
	position += movement * speed * delta
	var bounds = get_viewport_rect().grow(-16.0)
	position = position.clamp(bounds.position, bounds.end)

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("bullets") or health <= 0:
		return
	area.queue_free()
	if invulnerability_time > 0.0:
		return
	health = maxi(health - 1, 0)
	invulnerability_time = 0.5
	health_changed.emit(health)

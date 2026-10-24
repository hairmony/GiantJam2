extends Area2D

var speed = 220.0
var direction = Vector2.DOWN
var lifetime = 0.0

func _process(delta: float) -> void:
	position += direction * speed * delta
	lifetime += delta
	# Keep new bullets alive outside the edge until they enter the screen.
	# Read the current viewport so resizing does not use stale bounds.
	if not get_viewport_rect().grow(32.0).has_point(position) or lifetime > 15.0:
		queue_free()

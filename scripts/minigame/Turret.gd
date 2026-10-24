extends Area2D

var bullet_scene = preload("res://scenes/minigame/bullet.tscn")
var timer = 0.0
var fire_rate = 1.2
var edge = 0
var target: Node2D

func _process(delta: float) -> void:
	timer += delta
	if timer < fire_rate:
		return
	timer = 0.0
	if not is_instance_valid(target):
		return
	# Spawn just outside a random point on this edge and aim inward.
	var bounds = get_viewport_rect()
	var spawn_position = Vector2.ZERO
	match edge:
		0:
			spawn_position = Vector2(randf_range(bounds.position.x, bounds.end.x), bounds.position.y - 12.0)
		1:
			spawn_position = Vector2(bounds.end.x + 12.0, randf_range(bounds.position.y, bounds.end.y))
		2:
			spawn_position = Vector2(randf_range(bounds.position.x, bounds.end.x), bounds.end.y + 12.0)
		3:
			spawn_position = Vector2(bounds.position.x - 12.0, randf_range(bounds.position.y, bounds.end.y))
	var bullet = bullet_scene.instantiate()
	bullet.position = spawn_position
	bullet.direction = (target.position - spawn_position).normalized()
	get_parent().add_child(bullet)

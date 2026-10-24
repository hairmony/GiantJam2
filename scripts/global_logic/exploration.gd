extends Node2D

const SHIP_SCENE := preload("res://scenes/Enemy.tscn")
var _spawn_on_right := true

func on_ship_sunk(ship_body: Node2D) -> void:
	if is_instance_valid(ship_body):
		# EnemyBody belongs to the complete encounter scene, including its visuals.
		ship_body.get_parent().queue_free()
	_spawn_next_ship.call_deferred()

func _spawn_next_ship() -> void:
	if is_queued_for_deletion():
		return
	var ship := SHIP_SCENE.instantiate() as Node2D
	var camera := get_viewport().get_camera_2d()
	var center := Vector2.ZERO
	var view_size := get_viewport_rect().size
	if is_instance_valid(camera):
		center = camera.get_screen_center_position()
		view_size /= camera.zoom
	var offset := Vector2(view_size.x * 0.3, -view_size.y * 0.2)
	if not _spawn_on_right:
		offset.x *= -1.0
	_spawn_on_right = not _spawn_on_right
	ship.position = center + offset
	# Avoid starting another round immediately if the lure is at the spawn point.
	var lure := get_node_or_null("Player/PlayerBody/LureBody") as Node2D
	if is_instance_valid(lure) and ship.position.distance_to(lure.global_position) < 30.0:
		ship.position = center - offset
	add_child(ship)

extends Node2D

const HOOK_SCENE := preload("res://scenes/falling_hook.tscn")

enum Phase { ENTER, HOOKS, EXIT }

var _phase := Phase.ENTER
var _speed := 80.0
var _stop_x := 0.0
var _exit_x := 0.0
var _top := 0.0
var _view := Vector2.ZERO
var _hooks_to_spawn := 0
var _hooks_left := 0
var _hook_delay := 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	var center := get_viewport_rect().get_center()
	var view := get_viewport_rect().size
	var camera := get_viewport().get_camera_2d()
	if is_instance_valid(camera):
		center = camera.get_screen_center_position()
		view /= camera.zoom
	_view = view
	_top = center.y - view.y * 0.5
	var size := _sprite_size()
	# Keep the bottom third below the top edge and the rest off screen.
	position = Vector2(center.x - view.x * 0.5 - size.x * 0.5, _top - size.y / 6.0)
	_stop_x = randf_range(center.x - view.x * 0.22, center.x + view.x * 0.12)
	_exit_x = center.x + view.x * 0.5 + size.x * 0.6
	_speed = view.x * 0.55
	_hooks_to_spawn = randi_range(1, 3)


func _process(delta: float) -> void:
	match _phase:
		Phase.ENTER:
			position.x += _speed * delta
			if position.x >= _stop_x:
				position.x = _stop_x
				_phase = Phase.HOOKS
				_hook_delay = randf_range(0.0, 3.0)
		Phase.HOOKS:
			if _hooks_to_spawn > 0:
				_hook_delay -= delta
				if _hook_delay <= 0.0:
					_spawn_hook()
					_hooks_to_spawn -= 1
					_hook_delay = randf_range(0.0, 3.0)
			elif _hooks_left <= 0:
				_phase = Phase.EXIT
		Phase.EXIT:
			position.x += _speed * delta
			if position.x >= _exit_x:
				queue_free()


func _spawn_hook() -> void:
	var size := _sprite_size()
	var origin := position + Vector2(randf_range(-size.x, size.x) * 0.15, randf_range(-size.y, size.y) * 0.1)
	var drop_ratio := randf_range(0.18, 0.42) if randf() < 0.5 else randf_range(0.5, 0.88)
	var hook := HOOK_SCENE.instantiate()
	hook.z_index = z_index - 1
	hook.setup(origin, _view.y * drop_ratio, _top, randf_range(18.0, 34.0), randf_range(0.8, 1.5))
	get_parent().add_child(hook)
	_hooks_left += 1
	hook.tree_exited.connect(_on_hook_gone)


func _on_hook_gone() -> void:
	_hooks_left -= 1


func _sprite_size() -> Vector2:
	if sprite == null or sprite.texture == null:
		return Vector2(40.0, 12.0)
	return sprite.texture.get_size() * sprite.scale

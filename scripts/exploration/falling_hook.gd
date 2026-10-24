extends Node2D

var _speed := 60.0
var _target_y := 0.0
var _despawn_y := 0.0
var _pause := 0.0
var _holding := false
var _rising := false

func _ready() -> void:
	var area := $Hitbox as Area2D
	if not area.body_entered.is_connected(_on_body_entered):
		area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if GameManager.isMinigame or GameManager.run_ended:
		return
	if not body.is_in_group("lure") and body.name != "PlayerBody":
		return
	GameManager.isMinigame = true
	_start_minigame.call_deferred()


func _start_minigame() -> void:
	var packed: PackedScene = load("res://scenes/minigame/minigameMain.tscn")
	if packed == null:
		GameManager.isMinigame = false
		return
	var game := packed.instantiate()
	# The hitbox's parent is this hook, so a win removes the hook only.
	game.source_ship = $Hitbox
	get_tree().current_scene.add_child(game)


func setup(origin: Vector2, drop_distance: float, top_y: float, speed: float, pause_time: float) -> void:
	position = origin
	_speed = speed
	_target_y = origin.y + drop_distance
	_despawn_y = top_y - 24.0
	_pause = pause_time
	_face(Vector2.DOWN)


func _process(delta: float) -> void:
	if not _holding and not _rising:
		position.y = minf(position.y + _speed * delta, _target_y)
		if position.y >= _target_y:
			_holding = true
		return
	if _holding:
		_pause -= delta
		if _pause <= 0.0:
			_holding = false
			_rising = true
			_face(Vector2.UP)
		return
	position.y -= _speed * delta
	if position.y <= _despawn_y:
		queue_free()


func _face(direction: Vector2) -> void:
	# Hook art points down, so offset the angle to aim the point along travel.
	rotation = direction.angle() - Vector2.DOWN.angle()

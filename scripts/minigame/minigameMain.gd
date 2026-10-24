extends Node2D

const ROUND_SECONDS := 10.0
const HIT_PENALTY_SECONDS := 5.0
const TURRET_SCENE := preload("res://scenes/minigame/turret.tscn")
const PAUSE_SCENE := preload("res://scenes/pause.tscn")
const DEATH_SCENE := preload("res://scenes/death.tscn")

var source_ship: Node2D
var _exploration: Node
var _exploration_process_mode: int
var _previous_camera: Camera2D
var _pause: Node = null
var _finished := false

func _enter_tree() -> void:
	# Keep the exploration instance, but stop its movement and spawning.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_exploration = get_tree().current_scene
	if _exploration != self and _exploration != null:
		_exploration_process_mode = _exploration.process_mode
		_exploration.process_mode = Node.PROCESS_MODE_DISABLED
	_previous_camera = get_viewport().get_camera_2d()

func _ready() -> void:
	GameManager.isMinigame = true
	GameManager.minigameTimer = ROUND_SECONDS
	$Player.position = get_viewport_rect().get_center()
	$Player.lives_changed.connect(_on_lives_changed)
	_update_lives($Player.lives)
	for edge in range(4):
		var turret = TURRET_SCENE.instantiate()
		turret.edge = edge
		turret.target = $Player
		turret.fire_rate = 1.2
		turret.timer = edge * 0.3
		add_child(turret)

func _process(delta: float) -> void:
	if _finished:
		return
	GameManager.minigameTimer = maxf(GameManager.minigameTimer - delta, 0.0)
	if GameManager.minigameTimer <= 0.0:
		_finished = true
		_finish_win.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause") or event.is_echo():
		return
	if _finished or (_pause != null and is_instance_valid(_pause)):
		return
	_pause = PAUSE_SCENE.instantiate()
	add_child(_pause)
	get_tree().paused = true
	get_viewport().set_input_as_handled()

func _update_lives(lives: int) -> void:
	$HUD/LivesLabel.text = "LIVES %d / %d" % [lives, $Player.MAX_LIVES]

func _on_lives_changed(lives: int) -> void:
	if _finished:
		return
	GameManager.minigameTimer += HIT_PENALTY_SECONDS
	_update_lives(lives)
	if lives == 0:
		_finished = true
		_show_game_over.call_deferred()

func _show_game_over() -> void:
	GameManager.deathCount += 1
	add_child(DEATH_SCENE.instantiate())
	get_tree().paused = true

func _finish_win() -> void:
	# This is the only reward path; third-hit losses never award a ship.
	GameManager.record_minigame_win()
	if is_instance_valid(_exploration) and _exploration.has_method("on_ship_sunk"):
		_exploration.on_ship_sunk(source_ship)
	elif is_instance_valid(source_ship):
		source_ship.queue_free()
	if _exploration == self:
		# Support running the minigame scene directly in the editor.
		get_tree().change_scene_to_file("res://scenes/exploration.tscn")
	else:
		_restore_exploration()
		queue_free()

func _restore_exploration() -> void:
	GameManager.isMinigame = false
	GameManager.minigameTimer = 0.0
	if is_instance_valid(_exploration) and _exploration != self:
		_exploration.process_mode = _exploration_process_mode
	if is_instance_valid(_previous_camera):
		_previous_camera.make_current()

func _exit_tree() -> void:
	_restore_exploration()

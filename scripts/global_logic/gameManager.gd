extends Node

const dayLength: float = 70

var quota: float = 3
var score: float = 0
var dosh: float = 0
var dayCount: int = 0
var dayKillCount: int = 0
var totalKillCount: int = 0
var deathCount: int = 0
var minigameTimer: float = 0
var dayTimer: float = 0
var isMinigame: bool = false
var run_ended: bool = false
var _run_won: bool = false

# enums
enum MOVE_STATE {PLAYER, LURE}
enum LURE_TYPE {DEFAULT, FISH1}

var playerMoveState = MOVE_STATE.PLAYER
var LureMoveState = MOVE_STATE.LURE
# flags global player state. default as player move.
var moveState = playerMoveState
var playerVelocity: Vector2

const TIMER_SCENE := preload("res://scenes/time_box.tscn")
const LOSS_SCENE := preload("res://scenes/death.tscn")
const WIN_SCENE := preload("res://scenes/victory.tscn")
const QUOTA_SCENE := preload("res://scenes/qouta.tscn")
var timer: TimerBox
var quota_display: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Shows the day timer over whatever scene Play opened.
func begin_play() -> void:
	run_ended = false
	isMinigame = false
	minigameTimer = 0.0
	score = 0
	dayKillCount = 0
	if timer == null:
		timer = TIMER_SCENE.instantiate()
		timer.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(timer)
	else:
		timer.visible = true
		timer.start()
	if not timer.finished.is_connected(_on_day_finished):
		timer.finished.connect(_on_day_finished)
	if quota_display == null:
		quota_display = QUOTA_SCENE.instantiate()
		quota_display.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(quota_display)
	else:
		quota_display.visible = true
		if quota_display.has_method("start"):
			quota_display.start()


## Carry the lifetime total into a fresh day with a new timer and quota.
func begin_next_day() -> void:
	dayCount += 1
	begin_play()


## One successful encounter earns one quota win, capped at the target.
func record_minigame_win() -> void:
	if run_ended:
		return
	score = minf(score + 1.0, quota)
	dayKillCount += 1
	totalKillCount += 1
	if is_instance_valid(quota_display):
		quota_display.update_label()


## Freeze the result at zero, including when a minigame is active.
func _on_day_finished() -> void:
	if run_ended:
		return
	run_ended = true
	_run_won = score >= quota
	if is_instance_valid(quota_display):
		quota_display.stop()
	get_tree().paused = true
	_show_end_screen.call_deferred()

func _show_end_screen() -> void:
	if not run_ended:
		return
	var screen := WIN_SCENE.instantiate() if _run_won else LOSS_SCENE.instantiate()
	screen.won = _run_won
	get_tree().current_scene.add_child(screen)


## Hides the day timer when leaving back to the menu.
func end_play() -> void:
	if timer == null:
		return
	timer.stop()
	timer.visible = false
	if quota_display != null:
		if quota_display.has_method("stop"):
			quota_display.stop()
		quota_display.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

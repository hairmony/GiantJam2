extends Node

var quota: float = 0
var score: float = 0
var dosh: float = 0
var dayCount: int = 0
var dayKillCount: int = 0
var totalKillCount: int = 0
var deathCount: int = 0
var minigameTimer: float = 0
var dayTimer: float = 0

# enums
enum MOVE_STATE {PLAYER, LURE}
enum LURE_TYPE {DEFAULT, FISH1}

var playerMoveState = MOVE_STATE.PLAYER
var LureMoveState = MOVE_STATE.LURE
# flags global player state. default as player move.
var moveState = playerMoveState
var playerVelocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

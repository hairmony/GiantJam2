extends CanvasLayer

## Emitted when the timer reaches its limit.
signal finished

## Whether the timer is currently running.
var running: bool = false

## Index of the next event that needs to be triggered.
var  nextEvent: int = 0

var events: Array[QoutaEvent] = []

@export var label: Label

func _ready() -> void:
	events = [
		QoutaEvent.new("first", 1, DialogueScript.run.bind("res://assets/text/dialogue/firstQuota.dialogue")),
		QoutaEvent.new("halfway", (GameManager.quota/2), DialogueScript.run.bind("res://assets/text/dialogue/halfwayQuota.dialogue")),
		QoutaEvent.new("met", GameManager.quota, DialogueScript.run.bind("res://assets/text/dialogue/metQuota.dialogue"))
	]
	
	update_label()
	running = true


func _process(_delta: float) -> void:
	if not running:
		return
	update_label()
	check_events()


## Shows the quota without changing the day timer.
func start() -> void:
	nextEvent = 0
	update_label()
	running = true


## Stops the timer without resetting it.
func stop() -> void:
	running = false


## Resets the timer to 0 without starting it.
func reset() -> void:
	GameManager.dayTimer = 0.0
	nextEvent = 0
	running = false

func update_label() -> void:
	label.text = "QUOTA WINS: %d / %d" % [mini(int(GameManager.score), int(GameManager.quota)), int(GameManager.quota)]

## Checks whether the next event should happen.
func check_events() -> void:
	while nextEvent < events.size():
		var event: QoutaEvent = events[nextEvent]

		if event.trigger_score > GameManager.score:
			break

		event.handler.call()
		nextEvent += 1

extends Node2D

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
		QoutaEvent.new("test", 5.0, DialogueScript.run.bind("res://assets/text/dialogue/boss.dialogue")
		)
	]
	
	update_label()
	
	start()


func _process(delta: float) -> void:
	if not running:
		return

	GameManager.dayTimer += delta
	update_label()
	check_events()

	if GameManager.dayTimer >= GameManager.dayLength:
		running = false
		finished.emit()


## Starts the timer from 0.
func start() -> void:
	GameManager.dayTimer = 0.0
	nextEvent = 0
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
	label.text = "%d/%d" % [GameManager.score, GameManager.quota]

## Checks whether the next event should happen.
func check_events() -> void:
	while nextEvent < events.size():
		var event: QoutaEvent = events[nextEvent]

		if event.trigger_score >= GameManager.score:
			break

		event.handler.call()
		nextEvent += 1

class_name TimerEvent
extends RefCounted

var event_name: String
var trigger_time: float
var handler: Callable

func _init(
	p_event_name: String,
	p_trigger_time: float,
	p_handler: Callable
) -> void:
	event_name = p_event_name
	trigger_time = p_trigger_time
	handler = p_handler

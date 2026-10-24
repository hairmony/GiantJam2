class_name QoutaEvent
extends RefCounted

var event_name: String
var trigger_score: int
var handler: Callable

func _init(
	p_event_name: String,
	p_trigger_score: int,
	p_handler: Callable
) -> void:
	event_name = p_event_name
	trigger_score = p_trigger_score
	handler = p_handler

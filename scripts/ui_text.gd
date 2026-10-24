class_name UiText
extends RefCounted

const PATH := "res://assets/text/menu/menu.json"

static var _data: Dictionary = {}


static func section(name: String) -> Dictionary:
	if _data.is_empty():
		var file := FileAccess.open(PATH, FileAccess.READ)
		if file == null:
			push_error("Missing UI text: " + PATH)
			return {}
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			_data = parsed
	var value = _data.get(name, {})
	if value is Dictionary:
		return value
	return {}

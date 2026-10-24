class_name DialogueScript
extends RefCounted

static func run(dialogue_path: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var dialogue: DialogueResource = load(dialogue_path)

	if dialogue == null:
		push_error("Failed to load dialogue: " + dialogue_path)
		return

	DialogueManager.dialogue_ended.connect(
		_on_dialogue_ended.bind(tree),
		CONNECT_ONE_SHOT
	)

	tree.paused = true
	DialogueManager.show_dialogue_balloon(dialogue, "start")


static func _on_dialogue_ended(
	_resource: DialogueResource,
	tree: SceneTree
) -> void:
	tree.paused = false

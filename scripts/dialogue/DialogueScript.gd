class_name DialogueScript
extends RefCounted

static var _open_balloons := 0
static var _was_paused := false
static var _paused_audio: Array[AudioStreamPlayer] = []


static func run(dialogue_path: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var dialogue: DialogueResource = load(dialogue_path)
	if dialogue == null:
		push_error("Failed to load dialogue: " + dialogue_path)
		return

	var balloon := DialogueManager.show_dialogue_balloon(dialogue, "start")
	if balloon == null:
		return
	balloon.process_mode = Node.PROCESS_MODE_ALWAYS
	balloon.tree_exiting.connect(_on_balloon_gone.bind(tree))
	_pause_for_dialogue(tree)


static func _pause_for_dialogue(tree: SceneTree) -> void:
	if _open_balloons == 0:
		_was_paused = tree.paused
		_paused_audio.clear()
		_pause_audio(tree.root)
	_open_balloons += 1
	tree.paused = true


static func _pause_audio(node: Node) -> void:
	if node is AudioStreamPlayer and node.playing and not node.stream_paused:
		node.stream_paused = true
		_paused_audio.append(node)
	for child in node.get_children():
		_pause_audio(child)


static func _on_balloon_gone(tree: SceneTree) -> void:
	_open_balloons = maxi(_open_balloons - 1, 0)
	if _open_balloons > 0:
		return
	for player in _paused_audio:
		if is_instance_valid(player):
			player.stream_paused = false
	_paused_audio.clear()
	if not _was_paused:
		tree.paused = false

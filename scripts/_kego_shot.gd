extends SceneTree

var _frames := 0

func _initialize() -> void:
	root.size = Vector2i(1152, 648)
	change_scene_to_file("res://scenes/exploration_kego.tscn")
	process_frame.connect(_shot)


func _shot() -> void:
	_frames += 1
	if _frames < 4:
		return
	var img := root.get_texture().get_image()
	var path := ProjectSettings.globalize_path("res://kego_check.png")
	img.save_png(path)
	print("KEGO_SHOT ", img.get_width(), "x", img.get_height(), " ", path)
	quit()

extends Node2D

var turret_scene = preload("res://turret.tscn")

func _ready() -> void:
	$Player.position = get_viewport_rect().get_center()
	$HUD/HealthBar.max_value = $Player.max_health
	$Player.health_changed.connect(_on_health_changed)
	_on_health_changed($Player.health)
	# One turret for each edge: top, right, bottom, left.
	for edge in range(4):
		var turret = turret_scene.instantiate()
		turret.edge = edge
		turret.target = $Player
		turret.fire_rate = 1.2
		turret.timer = edge * 0.3
		add_child(turret)

func _on_health_changed(health: int) -> void:
	$HUD/HealthBar.value = health
	$HUD/HealthLabel.text = "HP %d / %d" % [health, $Player.max_health]
	if health == 0:
		$HUD/HealthLabel.text = "HP 0 / %d - Game over" % $Player.max_health

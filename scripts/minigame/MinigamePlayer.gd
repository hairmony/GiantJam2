extends Area2D

signal health_changed(health: int)

const speed = 200
const max_health = 10
var health = max_health
var invulnerability_time = 0.0

func _process(delta: float) -> void:
	invulnerability_time = maxf(0.0, invulnerability_time - delta)
	modulate = Color(1, 0.3, 0.3) if invulnerability_time > 0.0 else Color.WHITE
	var movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += movement * speed * delta
	var bounds = get_viewport_rect().grow(-16.0)
	position = position.clamp(bounds.position, bounds.end)

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("bullets") or health <= 0:
		return
	area.queue_free()
	if invulnerability_time > 0.0:
		return
	health = maxi(health - 1, 0)
	invulnerability_time = 0.5
	health_changed.emit(health)
	if health == 0:
		get_tree().paused = true

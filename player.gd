extends CharacterBody2D

signal screenExited
signal caughtBlock
var collided = false
var blockOn = null

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("screenExited")


func _process(_delta: float) -> void:
	collided = move_and_slide()
	if collided: 
		if blockOn != get_last_slide_collision().get_collider():
			blockOn = get_last_slide_collision().get_collider()
			emit_signal("caughtBlock")

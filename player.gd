extends Area2D

signal screenExited

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("screenExited")

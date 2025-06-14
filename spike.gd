extends StaticBody2D
var number
@onready var blockArea = $spawnRadius
var deleted = false

func _on_spawn_radius_area_entered(_area: Area2D) -> void:
	if not deleted:
		var areas = $spawnRadius.get_overlapping_areas()
	
		for a in areas:
			if a.get_parent().number < number:
				blockArea.set_collision_mask_value(9,false)
				blockArea.set_collision_layer_value(9,false)
				queue_free()
				print("spike delted")
				deleted = true
				break

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func spikeHit():
	$GPUParticles2D.emitting =true

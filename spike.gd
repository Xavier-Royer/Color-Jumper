extends Node2D
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
	$Spike/GPUParticles2D.emitting =true




func createHitBox(firstPosition,secondPosition,movingObjects):
	var line = Line2D.new()
	self.add_child(line)
	line.add_point(firstPosition - Vector2(0,movingObjects.position.y))
	line.add_point(secondPosition - Vector2(0,movingObjects.position.y))

	$spawnRadius/CollisionShape2D.shape.a = firstPosition - Vector2(0,movingObjects.position.y)
	$spawnRadius/CollisionShape2D.shape.b = secondPosition -Vector2(0,movingObjects.position.y)
	
	var spikePosition = (secondPosition-firstPosition)/2 + firstPosition
	$Spike.global_position = spikePosition
	

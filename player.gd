extends CharacterBody2D
var gameSpeed = 0
signal screenExited
signal caughtBlock
signal collectCoin
var collided = false
var blockOn = null
var died = false
var lastPosition 
var trailLength = 25
@onready var trail = preload("res://TrailParticle.tscn")
@onready var test = preload("res://color_rect.tscn")
var direction  = Vector2.ZERO

var lastRotation = 0
var newTrail = true



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("screenExited")


		

func _process(_delta: float) -> void:
	direction = Vector2(cos(deg_to_rad(rotation+90)),sin(deg_to_rad(rotation+90)))
	$Trail.process_material.direction = Vector3(1*direction.x,1*direction.y ,0)
	$Trail.process_material.gravity = Vector3(0,0,0)
	#$Trail.process_material.gravity = Vector3(0,gameSpeed*2,0)
	
	
	collided = move_and_slide()
	if collided: 
		if  get_last_slide_collision().get_collider().get_collision_layer_value(8):
			if blockOn != get_last_slide_collision().get_collider():
				blockOn = get_last_slide_collision().get_collider()
				
				velocity = Vector2(0,0)
				#blockOn.blockCaught()
				emit_signal("caughtBlock")
		elif get_last_slide_collision().get_collider().get_collision_layer_value(5):
			#play animaition and then los4
				#self.hide()
				#self.self_modulate = Color(1,1,1,0)
				if died == false:
					$GPUParticles2D.emitting = true
				#self.hide()
					$ColorRect.self_modulate = Color(1,1,1,0)
					died = true
					get_last_slide_collision().get_collider().get_parent().spikeHit()
		elif get_last_slide_collision().get_collider().get_collision_layer_value(6):
			emit_signal("collectCoin")
			print("CAUGHT COIN")
			get_last_slide_collision().get_collider().get_parent().coinCaught()
				

			



	

func _on_gpu_particles_2d_finished() -> void:
	emit_signal("screenExited")
	died = false


func deleteParticle(particle):
	particle.queue_free()

extends CharacterBody2D
var oldVelocity = Vector2.ZERO

var gameSpeed = 0
#signals
signal screenExited
signal caughtBlock
signal collectCoin

#player properties
var collided = false
var blockOn = null
var died = false
var direction  = Vector2.ZERO




func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if died == false:
		emit_signal("screenExited")


		

func _process(_delta: float) -> void:
	#make trail 
	direction = Vector2(cos(deg_to_rad(rotation+90)),sin(deg_to_rad(rotation+90)))
	$Trail.process_material.direction = Vector3(1*direction.x,1*direction.y ,0)
	$Trail.process_material.gravity = Vector3(0,0,0)
	#$Trail.process_material.gravity = Vector3(0,gameSpeed*2,0)
	
	oldVelocity = velocity
	collided = move_and_slide()
	if collided: 
		#checks if player landed on a block
		if  get_last_slide_collision().get_collider().get_collision_layer_value(8):
			if blockOn != get_last_slide_collision().get_collider():
				
				blockOn = get_last_slide_collision().get_collider()
				velocity = Vector2(0,0)
				emit_signal("caughtBlock")
		#checks if player hits a spike
		elif get_last_slide_collision().get_collider().get_collision_layer_value(5):
				#if not already dead then play explosion animation
				if died == false:
					velocity = Vector2.ZERO
					get_last_slide_collision().get_collider().get_parent().spikeHit()
					$GPUParticles2D.emitting = true
					$ColorRect.self_modulate = Color(1,1,1,0)
					$Trail.emitting = false
					died = true
					
					#do spike animation
		#checks if player caught a coin
		elif get_last_slide_collision().get_collider().get_collision_layer_value(6):
			#so taht it doesnt get stuckj on a coin
			velocity = oldVelocity
			emit_signal("collectCoin")
			get_last_slide_collision().get_collider().get_parent().coinCaught()



func _on_gpu_particles_2d_finished() -> void:
	#transition to game over screen
	$GPUParticles2D.emitting = false
	emit_signal("screenExited")
	#reset playeres death

func reset():
	show()
	$GPUParticles2D.emitting = false
	$ColorRect.self_modulate.a = 1
	$Trail.emitting = true
	died = false
	oldVelocity = Vector2.ZERO

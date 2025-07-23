extends CharacterBody2D
var gameSpeed = 0
signal screenExited
signal caughtBlock
var collided = false
var blockOn = null
var died = false
var lastPosition 
var trailLength = 25
@onready var trail = preload("res://TrailParticle.tscn")
@onready var test = preload("res://color_rect.tscn")
@onready var trailNode = $Trail2#self.get_parent().get_node("Trail")# $Trail #self.get_parent().get_parent().get_node("Trail")
var direction  = Vector2.ZERO

var lastRotation = 0
var newTrail = true



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("screenExited")

func _ready():
	for i in trailLength:
		var particle =  trail.instantiate()#ColorRect.new() #trail.instantiate()
		trailNode.add_child(particle)
		#particle.global_position = self.global_position
#		particle.process_material.gravity = Vector3(0,(gameSpeed +100.0),0)
		particle.emitting = true
		particle.connect("finished",deleteParticle.bind(particle))
		

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
				

			

func _physics_process(_delta: float) -> void:
	
	var particle = trail.instantiate()

	trailNode.add_child(particle)
	#particle.global_position = self.global_position +Vector2(0,50)
	
	particle.process_material.gravity = Vector3(0,(10*gameSpeed +100.0),0)
	particle.emitting = true
	
	particle.connect("finished",deleteParticle.bind(particle))

	if velocity != Vector2(0,0):
		if newTrail:
			lastRotation = rotation
			direction = Vector2(cos(deg_to_rad(lastRotation+90)),sin(deg_to_rad(lastRotation+90)))
			newTrail = false
			lastPosition = position
		
		for i in 15:
			particle = trail.instantiate()
			trailNode.add_child(particle)
			particle.process_material.gravity = Vector3(0,(10*gameSpeed +100.0),0)
			#particle.global_position = self.global_position - (velocity.normalized() * Vector2(i*10,i*10))
			
			#particle.position = -(velocity.normalized() * Vector2(-10/(i+.000001),(i+.000001)*10))
			
			particle.position = (Vector2(cos(deg_to_rad(lastRotation+90)),sin(deg_to_rad(lastRotation+90))) * Vector2(i*10,i*10))
		
			particle.connect("finished",deleteParticle.bind(particle))
			particle.emitting = true
			
			#if abs((position.x-lastPosition.x) / direction.x - (position.y-lastPosition.y) /direction.y) >0.000001: #0.00000008979889:
				#print("NOT ON COURSE")
			
		#	print(   abs( ((position.x-lastPosition.x) / direction.x) - ((position.y-lastPosition.y) /direction.y))  )
			
		#	print(position  - lastPosition)
		#	print(position.y-lastPosition.y)
			#print(direction)
			
			if velocity == Vector2(0,0):
				print("break")
				break
	else:
		newTrail = true
	#print(trailNode.get_child_count())



func _on_gpu_particles_2d_finished() -> void:
	emit_signal("screenExited")
	died = false


func deleteParticle(particle):
	particle.queue_free()

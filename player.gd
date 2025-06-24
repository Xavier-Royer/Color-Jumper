extends CharacterBody2D

signal screenExited
signal caughtBlock
var collided = false
var blockOn = null
var died = false
var trailLength = 25
@onready var trail = preload("res://TrailParticle.tscn")
@onready var trailNode = $Trail #self.get_parent().get_parent().get_node("Trail")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("screenExited")

func _ready():
	for i in trailLength:
		var particle = trail.instantiate()
		trailNode.add_child(particle)
		particle.global_position = self.global_position
		particle.emitting = true
		

func _process(_delta: float) -> void:
	
	
	
	
	collided = move_and_slide()
	if collided: 
		if  get_last_slide_collision().get_collider().get_collision_layer_value(8):
			if blockOn != get_last_slide_collision().get_collider():
				blockOn = get_last_slide_collision().get_collider()
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
					get_last_slide_collision().get_collider().spikeHit()
				

			

func _physics_process(_delta: float) -> void:
	var particle = trail.instantiate()

	trailNode.add_child(particle)
	particle.global_position = self.global_position
	particle.emitting = true
	#for t in trailNode.get_children():
#		pass
	#	t.position += Vector2(0,50)
	trailNode.get_child(0).queue_free()
	#print(delta)
	


func _on_gpu_particles_2d_finished() -> void:
	emit_signal("screenExited")
	died = false

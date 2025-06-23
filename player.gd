extends CharacterBody2D

signal screenExited
signal caughtBlock
var collided = false
var blockOn = null
var trailLength = 20
@onready var trail = preload("res://TrailParticle.tscn")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("screenExited")

func _ready():
	for i in trailLength:
		var particle = trail.instantiate()
		$Trail.add_child(particle)
		particle.emitting = true
		

func _process(_delta: float) -> void:
	
	var particle = trail.instantiate()
	$Trail.add_child(particle)
	particle.emitting = true
	$Trail.get_child(0).queue_free()
	
	
	collided = move_and_slide()
	if collided: 
		if  get_last_slide_collision().get_collider().get_collision_layer_value(8):
			if blockOn != get_last_slide_collision().get_collider():
				blockOn = get_last_slide_collision().get_collider()
				#blockOn.blockCaught()
				emit_signal("caughtBlock")
		elif get_last_slide_collision().get_collider().get_collision_layer_value(5):
			#play animaition and then lose 
			self.hide()
			get_last_slide_collision().get_collider().spikeHit()
			emit_signal("screenExited")

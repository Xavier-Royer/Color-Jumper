extends CharacterBody2D
@onready var rainbowGradient = preload("res://ParticleCurves/RainbowColorGradient.tres")

var oldVelocity = Vector2.ZERO

var gameSpeed = 0
#signals
signal screenExited
signal caughtBlock
signal collectCoin
signal spikeHit
signal screenExitedWithBlock

#player properties
var collided = false
var blockOn = null
var blockPosition = Vector2.ZERO
var died = false
var direction  = Vector2.ZERO




func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if died == false:
		if blockOn == null:
			emit_signal("screenExited")
		else:
			emit_signal("screenExitedWithBlock")

func _ready() -> void:
	rainbowOff()


func disappear():
	$ColorRect.self_modulate = Color(1,1,1,0)
	$Trail.emitting = false
	$Trail2.emitting = false

func _on_gpu_particles_2d_finished() -> void:
	pass
	#transition to game over screen	
	#$GPUParticles2D.emitting = false
	#emit_signal("screenExited")
	#reset playeres death

func reset():
	$Trail.restart()
	show()
	$GPUParticles2D.emitting = false
	$ColorRect.self_modulate.a = 1
	$Trail.emitting = true
	died = false
	oldVelocity = Vector2.ZERO
	velocity = Vector2.ZERO
	self.rotation =0
	self.modulate.a = 1


func rainbowOff():
	#$Trail.process_material.color_initial_ramp =null
	$Trail.emitting = true
	$Trail2.emitting = false

func rainbowOn():
	setColor(Color(1,1,1,1))
	#$Trail.process_material.color_initial_ramp = rainbowGradient
	$Trail2.emitting = true
	$Trail.emitting = false
	for i in range(4):
		self.set_collision_mask_value(i+1,true)

func setColor(color):
	$ColorRect.self_modulate = color
	$Trail.self_modulate = color

func getColor():
	return($ColorRect.self_modulate)

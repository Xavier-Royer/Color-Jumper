extends Node2D
var number = -1
@onready var blockArea = $spawnRadius
@onready var spikeTexture = load("res://textures/Spike3.png") 
@onready var coinTexture =  load("res://textures/Coin.png")
var item = "SPIKE"
var spikeRotateSpeed = 20
var deleted = false

#func _on_spawn_radius_area_entered(_area: Area2D) -> void:
	#if not deleted:
		#var areas = $spawnRadius.get_overlapping_areas()
	#
		#for a in areas:
			#if a.get_parent().number < number:
				#blockArea.set_collision_mask_value(9,false)
				#blockArea.set_collision_layer_value(9,false)
				#queue_free()
				#print("spike delted")
				#deleted = true
				#break

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func spikeHit():
	$Item/GPUParticles2D.emitting =true




func createHitBox(firstPosition,secondPosition,movingObjects, type):
	var line = Line2D.new()
	self.add_child(line)
	line.add_point(firstPosition - Vector2(0,movingObjects.position.y))
	line.add_point(secondPosition - Vector2(0,movingObjects.position.y))

	$spawnRadius/CollisionShape2D.shape.a = firstPosition - Vector2(0,movingObjects.position.y)
	$spawnRadius/CollisionShape2D.shape.b = secondPosition -Vector2(0,movingObjects.position.y)
	
	var spikePosition = (secondPosition-firstPosition)/2 + firstPosition
	$Item.global_position = spikePosition
	
	if type == "COIN":
		item  = "COIN"
		$Item/TextureRect.texture = coinTexture
		line.modulate = Color(0.5,0.5,0)
		$Item.set_collision_layer_value(5,false)
		$Item.set_collision_layer_value(6,true)
	

func coinCaught():
	$Item.set_collision_layer_value(6,false)
	var fadeOut = create_tween()
	fadeOut.set_ease(Tween.EASE_IN)
	fadeOut.set_trans(Tween.TRANS_BACK)
	fadeOut.tween_property(self, "modulate", Color(0.5,0.5,0,0),.5)

func _process(delta: float) -> void:
	if item == "SPIKE":
		$Item/TextureRect.rotation += spikeRotateSpeed * delta

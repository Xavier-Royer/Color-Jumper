extends Node2D
var number = -1
@onready var blockArea = $spawnRadius
@onready var spikeTexture = load("res://textures/Spike3.png") 
@onready var coinTexture =  load("res://textures/Coin.png")
var item = "SPIKE"
var spikeRotateSpeed = 20
var deleted = false


#stuff for physics:
var pivotPosition = Vector2(0,0)
var endPosition = Vector2(0,0)

var firstPosition = Vector2(0,0)
var secondPosition = Vector2(0,0)

var movingPointIndex = 0
var pivotPointIndex = 0

var angle = 0 
var radius = 0 
var angularVelocity = 0 
var momentOfInertia = 1
var armLength = 1
var gravityForce = 25
var airResistance = 0.999
var linearVelocity
var linearDirection 
var size = 1.0
var state = "STEADY"
var firstBlock
var secondBlock
var line

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
	pass
	#queue_free()

func spikeHit():
	$Item/GPUParticles2D.emitting =true




func createHitBox(firstPosition_,secondPosition_,movingObjects, block1,block2,type):
	
	firstBlock = block1
	secondBlock = block2
	
	#button.connect("pressed",changeColor.bind(button.name))
	block1.connect("deleting",holdingBlockDeleted.bind(block1))
	block2.connect("deleting",holdingBlockDeleted.bind(block2))
	
	firstPosition = firstPosition_ - Vector2(0,movingObjects.position.y)
	secondPosition = secondPosition_ - Vector2(0,movingObjects.position.y)
	
	line = Line2D.new()
	self.add_child(line)
	line.add_point(firstPosition)
	line.add_point(secondPosition)
	
	#update collision shape for the line
	$spawnRadius/CollisionShape2D.shape.a = firstPosition
	$spawnRadius/CollisionShape2D.shape.b = secondPosition	
	
	radius = firstPosition.distance_to(secondPosition)
	$Item.position = (firstPosition +secondPosition)/2.0 #- $Item/TextureRect.pivot_offset


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
	
	if state == "STEADY":
		pass
	elif state == "PIVOTING":
		#I AM PHYSICS
		var torque = gravityForce*armLength*cos(deg_to_rad(angle))
		var angularAcceleratoin = torque * momentOfInertia
		angularVelocity += angularAcceleratoin
		angle -= angularVelocity *delta
		
		setAngle(angle)
		line.points[movingPointIndex] = endPosition
		$Item.position = (pivotPosition +endPosition)/2.0
		#$TextureRect.position = (pivotPosition +endPosition)/2.0 - $TextureRect.pivot_offset
		
	elif state == "DELETING":
		line.position += linearVelocity *delta
		angle -= angularVelocity *delta
		setAngleForCenterRotation(angle)
		line.points[movingPointIndex] = endPosition
		line.points[pivotPointIndex] = pivotPosition
		
		#$TextureRect.position = $Line2D.position
		#$TextureRect.position += (pivotPosition +endPosition)/2.0 - $TextureRect.pivot_offset
		#$TextureRect.scale = Vector2(size,size)
		$Item.position = line.position
		$Item.position += (firstPosition +secondPosition)/2.0
		$Item.scale = Vector2(size,size)
		
		linearVelocity.y += gravityForce
		linearVelocity.x *= airResistance


func getAngle():
	var theta = rad_to_deg(pivotPosition.angle_to_point(endPosition)) *-1
	if theta < 0: 
		theta += 360
	angle  = theta
	

func setAngle(lineAngle):
	#angle = int(angle)%360
	var direction = Vector2(cos(deg_to_rad(lineAngle)) , sin(deg_to_rad(lineAngle))) 
	direction.y *=-1
	endPosition = pivotPosition + radius*direction

func setAngleForCenterRotation(lineAngle):
	var center = (endPosition + pivotPosition) /2.0
	#angle = int(angle)%360
	var direction = Vector2(cos(deg_to_rad(lineAngle)) , sin(deg_to_rad(lineAngle))) 
	direction.y *=-1
	endPosition = center + (radius*direction*0.5*size)
	pivotPosition = center - (radius*direction*0.5*size)



func holdingBlockDeleted(block):
	if state == "STEADY":
		state = "PIVOTING"
		if block == secondBlock:
			pivotPosition = firstPosition
			endPosition = secondPosition
			movingPointIndex = 1
			pivotPointIndex = 0
		else:
			pivotPosition = secondPosition
			endPosition = firstPosition
			movingPointIndex = 0
			pivotPointIndex = 1
		getAngle()
		#set wthich one is pivot
	elif state == "PIVOTING":
		angularVelocity *=2
		var linearSpeed  = armLength * angularVelocity *1
		linearDirection = Vector2(cos(deg_to_rad(angle-90)) , -1* sin(deg_to_rad(angle-90))) 
		linearVelocity = linearDirection*linearSpeed
		state = "DELETING"
		$Item/CollisionShape2D.disabled = true
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "size", 0.0,1.0)
		tween.connect("finished",deleteNode)
func deleteNode():
	queue_free()

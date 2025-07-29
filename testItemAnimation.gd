extends Node2D
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

func _ready() -> void:
	firstPosition = Vector2(randf_range(100,600),randf_range(100,1600))
	secondPosition = Vector2(randf_range(100,600),randf_range(100,800))

	firstPosition = Vector2(300,300)
	secondPosition = Vector2(1200,200)
	
	radius = firstPosition.distance_to(secondPosition)
	$Line2D.add_point(firstPosition)
	$Line2D.add_point(secondPosition)
	
	if randi_range(0,1) ==1:
		pivotPosition = firstPosition
		endPosition = secondPosition
		movingPointIndex = 1
		pivotPointIndex = 0
	else:
		pivotPosition = secondPosition
		endPosition = firstPosition
		movingPointIndex = 0
		pivotPointIndex = 1
	$Pivot.position = pivotPosition 
	$NonPivot.position = endPosition 
	$TextureRect.position = (pivotPosition +endPosition)/2.0 - $TextureRect.pivot_offset
	
	getAngle()

func _process(delta: float) -> void:
	if state == "STEADY":
		pass
	elif state == "PIVOTING":
		#physuics shit
		var torque = gravityForce*armLength*cos(deg_to_rad(angle))
		var angularAcceleratoin = torque * momentOfInertia
		angularVelocity += angularAcceleratoin
		angle -= angularVelocity *delta
		
		setAngle(angle)
		$Line2D.points[movingPointIndex] = endPosition
		
		$TextureRect.position = (pivotPosition +endPosition)/2.0 - $TextureRect.pivot_offset
		
	elif state == "DELETING":
		$Line2D.position += linearVelocity *delta

		angle -= angularVelocity *delta
		setAngleForCenterRotation(angle)
		$Line2D.points[movingPointIndex] = endPosition
		$Line2D.points[pivotPointIndex] = pivotPosition
		
		
		$TextureRect.position = $Line2D.position
		$TextureRect.position += (pivotPosition +endPosition)/2.0 - $TextureRect.pivot_offset
		$TextureRect.scale = Vector2(size,size)
		
		linearVelocity.y += gravityForce
		linearVelocity.x *= airResistance
	
	


func getAngle():
	var theta = rad_to_deg(pivotPosition.angle_to_point(endPosition)) *-1
	if theta < 0: 
		theta += 360
	angle  = theta
	print(theta)

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

	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Tap"):
		if state == "STEADY":
			state = "PIVOTING"
			$NonPivot.hide()
			#set wthich one is pivot
		elif state == "PIVOTING":
			$Pivot.hide()
			angularVelocity *=2
			var linearSpeed  = armLength * angularVelocity *1
			linearDirection = Vector2(cos(deg_to_rad(angle-90)) , -1* sin(deg_to_rad(angle-90))) 
			linearVelocity = linearDirection*linearSpeed
			state = "DELETING"
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(self, "size", 0.0,1.0)

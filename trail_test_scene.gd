extends Node2D


var gameSpeedVelocity = 200
var ejectSpeedVelocity = 50
var playerAngle = 1880
var playerPosition = Vector2(500,500)
@onready var player = $Player
@onready var gravity = $Gravity
@onready var eject = $Eject

func _ready():
	playerAngle = randf_range(0,360)
	playerAngle = 360
	player.rotation = deg_to_rad(playerAngle)
	player.position = playerPosition
	
	var gravityPosition =  playerPosition + Vector2(0,gameSpeedVelocity)
	gravity.position = gravityPosition
	var direction = 270 + -1*(playerAngle) #bc godot has weird origins
	var ejectPosition =  gravityPosition + ejectSpeedVelocity*Vector2(cos(deg_to_rad(direction)),-1*sin(deg_to_rad(direction)))
	eject.position = ejectPosition
	
	#trail velocity magnitude 
	var yComponent = gameSpeedVelocity + (-1*ejectSpeedVelocity*sin(deg_to_rad(direction))) 
	var xComponent = ejectSpeedVelocity*cos(deg_to_rad(direction))
	#xComponent = round(xComponent)
	var trailVelocity = sqrt( pow(yComponent,2)  + pow(xComponent,2) )
	#trail velcoity angle 
	print(yComponent)
	print(xComponent)

	var trailAngle = atan(yComponent / xComponent )
	#if xComponent == 0:
		#trailAngle = deg_to_rad(90)
	if yComponent < 0 and xComponent < 0:
		trailAngle += deg_to_rad(180)
	if yComponent > 0 and xComponent < 0:
		trailAngle += deg_to_rad(180)
		
	print(rad_to_deg(trailAngle))
	print(trailAngle)
	print(sin(trailAngle))
	
	$Line2D.add_point(playerPosition)
	#$Line2D.add_point(playerPosition + Vector2(xComponent, yComponent))
	$Line2D.add_point(playerPosition +  trailVelocity* Vector2( cos(trailAngle),  sin(trailAngle)))

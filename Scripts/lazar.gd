extends Node2D
#var screenSize = Globals.screenSize
@onready var screenSize = get_viewport().get_visible_rect().size
@onready var screenLength = sqrt( pow(screenSize.x,2)      + pow(screenSize.y,2))
var lazarPosition
var state = "SPAWNING"
var lazarsState = "NOTSTARTED"
var totalTime =0 
var speed = 1
var pointPosition = Vector2(0,0)
var pointPosition2 = Vector2(0,0)
var lastRotationPosition

func _ready():
	spawnLazar(6.5,300,"LEFT")

func spawnLazar(time,yPos, side):
	if side == "RIGHT":
		lazarPosition = Vector2(screenSize.x, yPos)
	else:
		lazarPosition = Vector2(-10, yPos)
	global_position = Vector2( lazarPosition.x,screenSize.y + 20)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position",lazarPosition,1)
	
	await tween.finished
	$Timer.wait_time = time
	$Timer.start()
	state = "ACTIVE"

func _process(delta: float) -> void:
	if state == "ACTIVE":
		$ColorRect.rotation = sin(totalTime*speed)/1.5
		totalTime += delta
		
		$ColorRect/Line2D.points[1] = pointPosition
		$ColorRect/Line2D.points[0] = pointPosition2
		print($ColorRect/Line2D.points[1])
		print($ColorRect/Line2D.points[0])
		
		if lazarsState == "NOTSTARTED":
			#$ColorRect/Line2D.add_point(Vector2(0,0))
			#$ColorRect/Line2D.add_point(Vector2(0,0))
			#$ColorRect/Line2D.points[1\]
			var tween = create_tween()
			#tween.set_ease(Tween.EASE_IN)
			#tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(self, "pointPosition",Vector2(screenLength,0),1)
			tween.finished.connect(lazarGrown)
			lazarsState = "GROWING"
		if lazarsState == "SHRINKING":
			$ColorRect/Line2D.global_rotation = lastRotationPosition
		
func lazarGrown(): 
	lazarsState = "GROWN"
	#var tween = create_tween()
	#tween.tween_property(self, "speed",speed+1,1)
	

	


func _on_timer_timeout() -> void:
	lastRotationPosition = $ColorRect.rotation
	var tween = create_tween()
	tween.tween_property(self, "pointPosition2",Vector2(screenLength,0),1)
	tween.finished.connect(lazarShrank)
	#print(pointPosition2)
	lazarsState = "SHRINKING"

func lazarShrank():
	#print(pointPosition2)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position",Vector2( lazarPosition.x,screenSize.y + 20),1)
	await tween.finished
	self.queue_free()
	

extends StaticBody2D
signal blockMissed
var playerOn  = false
signal invalidBlock
signal deleting
@onready var blockArea = $SpawnRadius
var number =999 
var deleted = false
var blockColor
var mouseOnBlock = false
signal nextColor
var onBlock = false
#var spawnComplete = false

func setColor(color):

	$ColorRect.material.set_shader_parameter("rainbow",false)
	$ColorRect.material.set_shader_parameter("speed",2.0)
	
	blockColor = color
	for i in range(4):
		self.set_collision_layer_value(i+1,false)
	
	#setup blocks color and collision layers
	if color == "RED":
		self.modulate = Color(255,0,0)
		self.set_collision_layer_value(1,true)
	elif color == "GREEN":
		self.modulate = Color(0,255,0)
		self.set_collision_layer_value(2,true)
	elif color == "BLUE":
		self.modulate = Color(0,0,255)
		self.set_collision_layer_value(3,true)
	elif color == "PURPLE":
		self.modulate = Color(255,0,255)
		self.set_collision_layer_value(4,true)
	else: # for rainbow set all color collision layers to true
		self.modulate = Color(0,0,0)
		self.set_collision_layer_value(10,true)
		var unique = $ColorRect.material.duplicate(true)
		$ColorRect.material = unique 
		$ColorRect.material.set_shader_parameter("rainbow",true)

		
	#print($ColorRect.material.get_shader_parameter("Rainbow"))
	

func delete():
	emit_signal("deleting")
	$AnimationPlayer.play("blockLeft")


func _on_spawn_radius_area_entered(_area: Area2D) -> void:
	if not deleted and number != -1:
		var areas = $SpawnRadius.get_overlapping_areas()
		for a in areas:
			if a.get_parent().number < number:
				blockArea.set_collision_mask_value(9,false)
				blockArea.set_collision_layer_value(9,false)
				if number != -1:
					queue_free()
				deleted = true
				emit_signal("invalidBlock")
				break


func blockCaught(playerDirection, gameSpeed):
	
	onBlock = true
	if number !=0:
		#$GPUParticles2D.process_material.
		$GPUParticles2D.process_material.direction = Vector3(-1*playerDirection.x,-1*playerDirection.y ,0)
		$GPUParticles2D.process_material.gravity = Vector3(0,gameSpeed*2,0)
		$GPUParticles2D.emitting =true
		$AnimationPlayer.play("CaughtBlock")
		#var tween = create_tween()
		#tween.tween_property(self, "scale", self.scale * 1.4, 0.15).set_ease(Tween.EASE_IN)
		#tween.tween_property(self, "scale", self.scale, 0.15).set_ease(Tween.EASE_OUT)
	



func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "blockLeft":
		queue_free()
		


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("blockMissed")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Dead,"speed_scale",0.25,0.5)
	tween.connect("finished",speedUp)
	$Dead.emitting =true
	
	#queue_free()
func speedUp():
	var tween2 = create_tween()
	tween2.tween_property($Dead,"speed_scale",0.25,0.3)
	await tween2.finished
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Dead,"speed_scale",2,0.5)
	await tween.finished
	#queue_free()



func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if onBlock and (false):
			get_viewport().set_input_as_handled()
			emit_signal("nextColor")
			updateColor()
			

func _on_clicked_mouse_entered() -> void:
	mouseOnBlock = true


func updateColor():
	var colors = ["RED", "GREEN", "BLUE", "PURPLE"]
	var index = colors.find(blockColor)
	setColor(colors[(index+1)%4])


func _on_clicked_mouse_exited() -> void:
	mouseOnBlock = false

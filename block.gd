extends StaticBody2D
signal blockMissed
var playerOn  = false
var tutorial = false
signal invalidBlock
signal caughtBlock
signal leftBlock
signal deleteItem
@onready var blockArea = $SpawnRadius
@onready var rainbowDead = preload("res://RainbowDead.tres")
@onready var rainbowCaught = preload("res://RainbowBlockCaught.tres")
var number =999 
var deleted = false
var blockColor
var mouseOnBlock = false
var onBlock = false
var ghost = false


#var spawnComplete = false

func setColor(color):

	$ColorRect.material.set_shader_parameter("rainbow",false)
	$ColorRect.material.set_shader_parameter("speed",2.0)
	
	blockColor = color
	for i in range(4):
		self.set_collision_layer_value(i+1,false)
	self.set_collision_layer_value(8,true)
	
	#setup blocks color and collision layers
	
	
	if color == "RED":
		self.modulate = Color(1.0,.07,0)
		self.set_collision_layer_value(1,true)
	elif color == "GREEN":
		self.modulate = Color(0,1.0,.05)
		self.set_collision_layer_value(2,true)
	elif color == "BLUE":
		self.modulate = Color(0,.8,1.0)
		self.set_collision_layer_value(3,true)
	elif color == "PURPLE":
		self.modulate = Color(1.0,.1,1.0)
		self.set_collision_layer_value(4,true)
	else: # for rainbow set all color collision layers to true
		self.modulate = Color(255,255,255)
		self.set_collision_layer_value(10,true)
		rainbowCaught = preload("res://RainbowBlockCaught.tres")
		rainbowDead = preload("res://RainbowDead.tres")
		$Dead.process_material = rainbowDead
		$GPUParticles2D.process_material = rainbowCaught
		var unique = $ColorRect.material.duplicate(true)
		$ColorRect.material = unique 
		$ColorRect.material.set_shader_parameter("rainbow",true)
	if ghost:
		self.modulate.a=0

		
	#print($ColorRect.material.get_shader_parameter("Rainbow"))
	

func delete():
	
	deleted = true
	emit_signal("leftBlock")
	$AnimationPlayer.play("blockLeft")


func _on_spawn_radius_area_entered(_area: Area2D) -> void:
	if tutorial:
		return
	if not deleted:
		var areas = $SpawnRadius.get_overlapping_areas()
		for a in areas:
			if (number > -1  and a.get_parent().number < number) or (number < 0 and a.get_parent().number > number and a.get_parent().number < 0 and a.get_parent().number != -999999999999):
				blockArea.set_collision_mask_value(9,false)
				blockArea.set_collision_layer_value(9,false)
				#if number < 0:
				emit_signal("deleteItem")
				
				queue_free()
				deleted = true
				#if number > 0:
				emit_signal("invalidBlock")
				break


func blockCaught(playerDirection, gameSpeed, collisionPosition):
	onBlock = true
	if number !=0:
		#$GPUParticles2D.process_material.
		$GPUParticles2D.process_material.direction = Vector3(-1*playerDirection.x,-1*playerDirection.y ,0)
		$GPUParticles2D.process_material.gravity = Vector3(0,gameSpeed*2,0)
		$GPUParticles2D.emitting =true
		#$GPUParticles2D.global_position = collisionPosition + (playerDirection * 30)
		$AnimationPlayer.play("CaughtBlock")
		emit_signal("caughtBlock")
		#var tween = create_tween()
		#tween.tween_property(self, "scale", self.scale * 1.4, 0.15).set_ease(Tween.EASE_IN)
		#tween.tween_property(self, "scale", self.scale, 0.15).set_ease(Tween.EASE_OUT)
	



func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "blockLeft":
		deleted = true
		if not tutorial:
			queue_free()
		else:
			$VisibleOnScreenNotifier2D.hide()
			hide()
			
		


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if tutorial:
		return
	if deleted == false:
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



#func _input(event: InputEvent) -> void:
	#if event is InputEventScreenTouch and event.pressed:
		#if onBlock and (false):
			#get_viewport().set_input_as_handled()
			#emit_signal("nextColor")
			#updateColor()
			#
#
#func _on_clicked_mouse_entered() -> void:
	#mouseOnBlock = true


func updateColor():
	var colors = ["RED", "GREEN", "BLUE", "PURPLE"]
	var index = colors.find(blockColor)
	if ghost ==false:
		setColor(colors[(index+1)%4])

func setGhost():
	self.modulate.a = 0
	ghost = true
#func _on_clicked_mouse_exited() -> void:
	#mouseOnBlock = false

func spawnBackIn():
	deleted =false
	$AnimationPlayer.stop()
	setColor(blockColor)
	print("SPAWNINGG")
	onBlock = false
	playerOn  = false
	self.scale = Vector2(6,6)
	self.rotation = 0 
	$ColorRect.modulate.a  = 1
	$VisibleOnScreenNotifier2D.show()
	deleted =false
	show()

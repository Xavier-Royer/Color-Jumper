extends Area2D

var playerOn  = false

func setColor(color):
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
		for i in range(4):
			self.set_collision_layer_value(i,true)


func _on_area_entered(area: Area2D) -> void:
	#if two blocks spawn on top of each other, delete both of them
	if area.get_collision_layer_value(8):
		queue_free()
	elif area.get_collision_layer_value(7):
		playerOn = true 

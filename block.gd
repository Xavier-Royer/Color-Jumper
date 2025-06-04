extends Area2D


func setColor(color):
	if color == "RED":
		self.modulate = Color(255,0,0)
		self.set_collision_layer_value(1,true)
	elif color == "GREEN":
		self.modulate = Color(0,255,0)
		self.set_collision_layer_value(1,true)
	elif color == "BLUE":
		self.modulate = Color(0,0,255)
		self.set_collision_layer_value(1,true)
	elif color == "PURPLE":
		self.modulate = Color(255,255,0)
		self.set_collision_layer_value(1,true)
	else:
		for i in range(4):
			self.set_collision_layer_value(i,true)



func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(8):
		queue_free()

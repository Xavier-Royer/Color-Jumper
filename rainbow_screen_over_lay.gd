extends ColorRect
var previousTween = null 


func rainbowStart():
	self.modulate = Color(0,0,0,.5)
	self.show()
	$RainbowFade.start(4.5)



func _on_rainbow_fade_timeout() -> void:
	if previousTween != null:
		previousTween.stop()
	var currentTween = create_tween()
	currentTween.set_ease(Tween.EASE_OUT)
	currentTween.set_trans(Tween.TRANS_CIRC)
	
	currentTween.tween_property(self, "modulate", Color(1,1,1,0) ,0.5)
	
	previousTween = currentTween

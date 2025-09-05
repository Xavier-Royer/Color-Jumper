extends Node
signal timeout

var wait_time: float = 1000.0
var total_time = 0.0
var running = false

func start():
	running = true
	
func stop():
	running = false
	
func _process(delta: float) -> void:
	if running:
		total_time += delta
		if total_time >= wait_time:
			emit_signal("timeout")
			total_time -= wait_time

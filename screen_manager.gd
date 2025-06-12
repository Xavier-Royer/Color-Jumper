extends Node
@onready var currentScreen = $HomeScreen
var onScreenPosition = Vector2(0,0)
@onready var offScreenPosition = Vector2(Globals.screenSize.x,0)


func _ready() -> void:
	$GameScreen.connect("gameOverScreen",next_screen.bind($GameOverScreen))
	for i in get_children():
		if i.name != "HomeScreen":
			i.offset = offScreenPosition


#screen transitioner, waits until finished to return
func next_screen(nextScreen):
	
	var screenTransition = create_tween()
	screenTransition.set_ease(Tween.EASE_IN)
	screenTransition.set_trans(Tween.TRANS_BACK)
	screenTransition.tween_property(currentScreen, "offset", offScreenPosition,.5)
	await screenTransition.finished
	
	currentScreen.visible = false
	nextScreen.visible = true

	screenTransition = create_tween()
	screenTransition.set_ease(Tween.EASE_IN)
	screenTransition.set_trans(Tween.TRANS_BACK)
	screenTransition.tween_property(nextScreen, "offset", onScreenPosition,.5)
	currentScreen = nextScreen
	await screenTransition.finished
	





#when play pressed load in new game
func _on_play_pressed() -> void:
	$GameScreen.loadGame()
	await next_screen($GameScreen)
	$GameScreen.playGame()

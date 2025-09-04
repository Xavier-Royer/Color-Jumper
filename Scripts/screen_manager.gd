extends Node
@onready var currentScreen = $GameScreen
var onScreenPosition = Vector2(0,0)
@onready var offScreenPosition = Vector2(Globals.screenSize.x,0)

var screenOpen = false;



func _ready() -> void:
	#$Background/Control/TextureRect.scale = Vector2(Globals.screenSize.x/1024.0, Globals.screenSize.y/1536.0)
	$SettingsScreen.offset = offScreenPosition
	$LeaderboardScreen.offset = offScreenPosition
	$ShopScreen.offset = offScreenPosition
	$GameScreen.connect("gameOverScreen",gameOver)

func next_screen(nextScreen):
	#screen transition
	var screenTransition = create_tween()
	if screenOpen:
		$SettingsScreen/NoInteractLayer.visible = true
		$LeaderboardScreen/NoInteractLayer.visible = true
		$ShopScreen/NoInteractLayer.visible = true
		screenTransition.set_ease(Tween.EASE_IN)
		screenTransition.set_trans(Tween.TRANS_BACK)
		screenTransition.tween_property(currentScreen, "offset", offScreenPosition,.5)
		var bg_transition = create_tween()
		bg_transition.set_ease(Tween.EASE_IN)
		bg_transition.tween_property($GameScreen/UI/ScreenBG, "modulate:a", 0, 0.5)
		await screenTransition.finished
		$GameScreen/UI/ScreenBG.visible = false
	
	#currentScreen.visible = false
	#nextScreen.visible = true
	if not screenOpen:
		$GameScreen/UI/ScreenBG.visible = true
		screenTransition.set_ease(Tween.EASE_OUT)
		screenTransition.set_trans(Tween.TRANS_BACK)
		screenTransition.tween_property(nextScreen, "offset", onScreenPosition,0.5)
		currentScreen = nextScreen
		var bg_transition = create_tween()
		bg_transition.set_ease(Tween.EASE_OUT)
		bg_transition.tween_property($GameScreen/UI/ScreenBG, "modulate:a", 0.9, 0.5)
		await screenTransition.finished
		$SettingsScreen/NoInteractLayer.visible = false
		$LeaderboardScreen/NoInteractLayer.visible = false
		$ShopScreen/NoInteractLayer.visible = false
	screenOpen = not screenOpen
	





#when play pressed load in new game
func _on_play_pressed() -> void:
	#on play press reset everything
	$GameScreen.loadGame(false)
	$GameScreen.showButtons()
	#$GameScreen/UI/TouchAnywhereText.show()
	#$GameScreen/UI/Logo.modulate.a = 1.0
	#$GameScreen/UI/Settings.modulate.a = 1.0
	#$GameScreen/UI/Settings.disabled = false
	#$GameScreen/UI/Leaderboard.modulate.a = 1.0
	#$GameScreen/UI/Leaderboard.disabled = false
	#$GameScreen/UI/Shop.modulate.a = 1.0
	#$GameScreen/UI/Shop.disabled = false
	#$GameScreen/UI/Settings.mouse_filter = 0 #Stop
	#$GameScreen/UI/Leaderboard.mouse_filter = 0 #Stop
	#$GameScreen/UI/Shop.mouse_filter = 0 #Stop
	#for c in $GameScreen/UI/ColorButtons.get_children():
			#c.disabled = false
	$GameOverScreen.hide()
	$GameScreen.show()
	#$GameScreen.show()
	
	


func _on_settings_pressed() -> void:
	$SettingsScreen.loadSettings()
	next_screen($SettingsScreen)
	
func _on_home_pressed():
	next_screen($GameScreen)
	_on_play_pressed()
	
func _on_leaderboard_pressed() -> void:
	$LeaderboardScreen.loadLeaderboard()
	next_screen($LeaderboardScreen)
	
func _on_shop_pressed() -> void:
	next_screen($ShopScreen)

func gameOver():
	$GameOverScreen.show()
	#$GameOverScreen/UI/VBoxContainer/Button.disabled  = true
	$GameOverScreen.offset = Vector2(0,-1*Globals.screenSize.y)
	var screenTransition = create_tween()
	screenTransition.set_ease(Tween.EASE_OUT)
	screenTransition.set_trans(Tween.TRANS_BACK)
	screenTransition.tween_property($GameOverScreen, "offset", onScreenPosition,.5)
	#await screenTransition.finished
	#$GameOverScreen/UI/VBoxContainer/Button.disabled  = false

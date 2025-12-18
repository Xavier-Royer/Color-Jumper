extends Node
var difficulty = "CLASSIC"
var highScore = [0,0,0,0]
var tutorial = true
var sound_enabled = true
var coins = 0


var owned = [
	"spaceship",
	"defaulttrail",
	"defaulttheme"
]


func _ready():
	loadSettings()
	loadHighScore()
	loadCoins()

func setDifficulty(newDifficulty):
	difficulty = newDifficulty
	saveSettings()
	
func setAudioEnabled(audioEnabled):
	sound_enabled = audioEnabled
	saveSettings()

func setHighScore(score,index):
	highScore[index]= score
	saveHighScore()
	

func saveSettings():
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	file.store_var(difficulty)
	file.store_var(sound_enabled)
	file.close()
	
func loadSettings():
	var file = FileAccess.open("user://settings.dat", FileAccess.READ)
	if FileAccess.file_exists("user://settings.dat"):
		difficulty = file.get_var()
		sound_enabled = file.get_var()
		file.close()


func saveHighScore():
	var file = FileAccess.open("user://highScore.dat", FileAccess.WRITE)
	file.store_var(highScore)
	file.close()
	
func loadHighScore():
	var file = FileAccess.open("user://highScore.dat", FileAccess.READ)
	if FileAccess.file_exists("user://highScore.dat"):
		highScore = file.get_var()
		file.close()


func saveTutorial():
	var file = FileAccess.open("user://tutorial.dat", FileAccess.WRITE)
	file.store_var(false)
	file.close()

func loadTutorial():
	var file = FileAccess.open("user://tutorial.dat", FileAccess.READ)
	if FileAccess.file_exists("user://tutorial.dat"):
		tutorial = file.get_var()
		file.close()

func loadCoins():
	var file = FileAccess.open("user://coins.dat", FileAccess.READ)
	if FileAccess.file_exists("user://coins.dat"):
		coins = file.get_var()
		if coins == null:
			coins = 0
			saveCoins() 
		file.close()
	else:
		saveCoins()


func saveCoins():
	var file = FileAccess.open("user://coins.dat", FileAccess.WRITE)
	file.store_var(coins)
	file.close()


func loadOwned():
	var file = FileAccess.open("user://owned.dat", FileAccess.READ)
	if FileAccess.file_exists("user://owned.dat"):
		owned = file.get_var()
		file.close()


func saveOwned():
	var file = FileAccess.open("user://owned.dat", FileAccess.WRITE)
	file.store_var(owned)
	file.close()

func saveCurrentCollectibles():
	var file = FileAccess.open("user://current.dat", FileAccess.WRITE)
	file.store_var(CollectibleDB.CURRENT)
	file.close()
	

func loadCurrentCollectibles():
	var file = FileAccess.open("user://current.dat", FileAccess.READ)
	if FileAccess.file_exists("user://current.dat"):
		var data = file.get_var()
		CollectibleDB.CURRENT = data
		file.close()

extends Node
var difficulty = "EASY"
var highScore = [0,0,0,0]


func _ready():
	loadSettings()

func setDifficulty(newDifficulty):
	difficulty = newDifficulty
	saveSettings()

func setHighScore(score,index):
	highScore[index]= score
	saveHighScore()
	

func saveSettings():
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	file.store_var(difficulty)
	file.close()
	
func loadSettings():
	var file = FileAccess.open("user://settings.dat", FileAccess.READ)
	if FileAccess.file_exists("user://settings.dat"):
		difficulty = file.get_var()
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

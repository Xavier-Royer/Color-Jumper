extends CanvasLayer
var difficulties = ["EASY", "CLASSIC" , "COLORFUL", "RAINBOW"]
var difficultyTexts = [
	"slower speeds and\nless color change.\ngreat for everyone!",
	"fast-paced with\nless color change\nto challenge your\nreaction time.",
	"slowed down with\nmore color change.\ncan your brain keep\nup?",
	"super fast in\npermanent rainbow\nmode. no color\nswitching required!"
]

func _on_menu_button_item_selected(index: int) -> void:
	FileManager.setDifficulty(difficulties[index])
	$InfoLabel.text = difficultyTexts[index]


func loadSettings():
	var index = difficulties.find(FileManager.difficulty)
	$Difficulty.select(index)
	$InfoLabel.text = difficultyTexts[index]


func _on_resetscores_button_pressed() -> void:
	$ConfirmationDialog.size = Vector2i(Globals.screenSize.x * 0.75, Globals.screenSize.y * 0.15)
	$ConfirmationDialog.popup_centered()



func _on_confirmed():
	var index = difficulties.find(FileManager.difficulty)
	FileManager.setHighScore(0, index)

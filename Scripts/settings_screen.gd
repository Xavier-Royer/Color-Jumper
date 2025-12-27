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
	$ChangeName/HBoxContainer/NameInput.text = LL_StateData.GetCachedPlayerName()


func _on_resetscores_button_pressed() -> void:
	$"..".buttonClick()
	$ConfirmationDialog.size = Vector2i(Globals.screenSize.x * 0.75, Globals.screenSize.y * 0.15)
	$ConfirmationDialog.popup_centered()



func _on_confirmed():
	$"..".buttonClick()
	var index = difficulties.find(FileManager.difficulty)
	FileManager.setHighScore(0, index)


func _on_confirmation_dialog_confirmed() -> void:
	$"..".buttonClick()
	
func _on_submit_name_button_pressed() -> void:
	$"..".buttonClick()
	
	var setname_response = await LL_Players.SetPlayerName.new($ChangeName/HBoxContainer/NameInput.text).send()
	if !(setname_response.success):
		printerr(setname_response.error_data)
	pass # Replace with function body.


func _on_toc_and_pp_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_online_toggle_toggled(toggled_on: bool) -> void:
	FileManager.setIsOnline(toggled_on)

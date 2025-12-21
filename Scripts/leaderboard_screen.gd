extends CanvasLayer

var loading = false
var refreshLeaderboardTime = Time.get_unix_time_from_system()
var stored_responses = []
var stored_player_responses = []
@onready var scrollcontainers := [$LeaderboardTabs/Easy/Easy, $LeaderboardTabs/Classic/Classic, $LeaderboardTabs/Colorful/Colorful, $LeaderboardTabs/Rainbow/Rainbow]
var scoreScene: PackedScene = preload("res://Scenes/score_row.tscn")
var scoreText = '''
[u]High Scores[/u]
'''
'''
[color=gold]easy
[color=white]11,000,000

[color=orange]classic
[color=white]11,000,000

[color=red]colorful
[color=white]11,000,000

[color=purple]rainbow
[color=white]11,000,000
'''
func comma_format(num_stra: int) -> String:
	var num_str = str(num_stra)
	var result := ""
	var count := 0
	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	return result
	

var responses
var playerResponses
func loadLeaderboard():
	$NameInput.text = LL_StateData.GetCachedPlayerName()
	if loading:
		return
	loading = true
	$Loading.visible = true
	for lb in scrollcontainers:
		for i in lb.get_children():
			i.queue_free()

	if Time.get_unix_time_from_system() > refreshLeaderboardTime:
		var easyResponse := await LL_Leaderboards.GetScoreList.new("easy").send()
		if !(easyResponse.success):
			printerr(easyResponse.error_data)
			
		var classicResponse := await LL_Leaderboards.GetScoreList.new("classic").send()
		if !(classicResponse.success):
			printerr(classicResponse.error_data)
			
		var colorfulResponse := await LL_Leaderboards.GetScoreList.new("colorful").send()
		if !(colorfulResponse.success):
			printerr(colorfulResponse.error_data)
			
		var rainbowResponse := await LL_Leaderboards.GetScoreList.new("rainbow").send()
		if !(rainbowResponse.success):
			printerr(rainbowResponse.error_data)
			
		var player_id = str(LL_StateData.GetCachedPlayerLegacyID())
		print(player_id)
		var playerEasyResponse = await LL_Leaderboards.GetMemberRank.new("easy", player_id).send()
		if !(playerEasyResponse.success):
			printerr(playerEasyResponse.error_data)
			
		var playerClassicResponse = await LL_Leaderboards.GetMemberRank.new("classic", player_id).send()
		if !(playerClassicResponse.success):
			printerr(playerClassicResponse.error_data)
			
		var playerColorfulResponse = await LL_Leaderboards.GetMemberRank.new("colorful", player_id).send()
		if !(playerColorfulResponse.success):
			printerr(playerColorfulResponse.error_data)
			
		var playerRainbowRespnose = await LL_Leaderboards.GetMemberRank.new("rainbow", player_id).send()
		if !(playerRainbowRespnose.success):
			printerr(playerRainbowRespnose.error_data)
		
		responses = [easyResponse, classicResponse, colorfulResponse, rainbowResponse]
		playerResponses = [playerEasyResponse, playerClassicResponse, playerColorfulResponse, playerRainbowRespnose]
		stored_responses = responses
		stored_player_responses = playerResponses
		refreshLeaderboardTime = Time.get_unix_time_from_system() + 30
		print("got the new ones")
	else:
		responses = stored_responses
		playerResponses = stored_player_responses
		print("got the old ones")
	for lb in range(4):
		
		for j in range(10):
			var label = scoreScene.instantiate()
			if j >= len(responses[lb].items):
				label.set_text(j+1, "None", 0)
			else:
				label.set_text(j+1, responses[lb].items[j].player.name, responses[lb].items[j].score)
				
			scrollcontainers[lb].add_child(label)
	var tab = $LeaderboardTabs.current_tab
	var theplayerresponse = playerResponses[tab]
	if theplayerresponse.player == null:
		$YouRow.set_text(0, LL_StateData.GetCachedPlayerName(), 0)
	else:
		$YouRow.set_text(theplayerresponse.rank, theplayerresponse.player.name, theplayerresponse.score)
	$Loading.visible = false
	loading = false
	#TODO: fix ts it doesnt add labels or something or maybe the load leaderboard func doesnt even run
	#$ScoreText.text = "[u]High Scores[/u]\n\n[color=gold]easy\n[color=white]{easy}\n\n[color=orange]classic\n[color=white]{classic}\n\n[color=red]colorful\n[color=white]{colorful}\n\n[color=purple]rainbow\n[color=white]{rainbow}".format({"easy": comma_format(FileManager.highScore[0]), "classic": comma_format(FileManager.highScore[1]), "colorful": comma_format(FileManager.highScore[2]), "rainbow": comma_format(FileManager.highScore[3])})


func _on_submit_name_button_pressed() -> void:
	$"..".buttonClick()
	var setname_response = await LL_Players.SetPlayerName.new($NameInput.text).send()
	if !(setname_response.success):
		printerr(setname_response.error_data)
	pass # Replace with function body.


func _on_leaderboard_tabs_tab_changed(tab: int) -> void:
	if playerResponses == null:
		return
	var theplayerresponse = playerResponses[tab]
	print(LL_StateData.GetCachedPlayerIdentifier())
	print(theplayerresponse)
	if theplayerresponse.player == null:
		$YouRow.set_text(0, LL_StateData.GetCachedPlayerName(), 0)
	else:
		$YouRow.set_text(theplayerresponse.rank, theplayerresponse.player.name, theplayerresponse.score)

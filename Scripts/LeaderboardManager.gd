extends Node
func _ready() -> void:

	var id = await get_or_create_player_identifier()
	var guestLoginResponse = await LL_Authentication.GuestSession.new(id[0]).send()
	if (!guestLoginResponse.success):
		printerr("Guest login failed with reason: " + guestLoginResponse.error_data.to_string())
		get_tree().current_scene.find_child("CanvasLayer").find_child("OUTPUT").text = guestLoginResponse.error_data.to_string()
		return
	else:
		get_tree().current_scene.find_child("CanvasLayer").find_child("OUTPUT").text = "worked fine"
	if id[1]:
		#create a new name for the new player
		#TODO: if players name is already taken
		var end = randi_range(1000, 99999)
		var setname_response = await LL_Players.SetPlayerName.new("Player" + str(end)).send()
		if !(setname_response.success):
			printerr(setname_response.error_data)
		print("created new name for player")
		
	print(guestLoginResponse.player_name)
	print("Guest user was successfully signed in to LootLocker")
	#var changeNameResponse = await LL_Players.SetPlayerName.new(playerName).send()
	#if (!changeNameResponse.success):
		#printerr("Guest login failed with reason: " + changeNameResponse.error_data.to_string())
		#return
	#print("successfully changed name")

#if created a new player, return true
static func get_or_create_player_identifier() -> Array:
	#return ["testingplayerid", false]
	var file = FileAccess.open("user://player_id.data", FileAccess.READ)
	if file:
		var id = file.get_as_text().strip_edges()
		return [id, false]
	else:
		# Generate a new random unique identifier
		var new_id = uuid.v4()
		file = FileAccess.open("user://player_id.data", FileAccess.WRITE)
		file.store_string(new_id)
		file.close()
		
		
		
		pass # Replace with function body.
		return [new_id, true]

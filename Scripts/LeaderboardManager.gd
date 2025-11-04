extends Node

var playerName = "testingplayer17"

func _ready() -> void:

	
	var guestLoginResponse = await LL_Authentication.GuestSession.new(get_or_create_player_identifier()).send()
	if (!guestLoginResponse.success):
		printerr("Guest login failed with reason: " + guestLoginResponse.error_data.to_string())
		return
	print(guestLoginResponse.player_name)
	print("Guest user was successfully signed in to LootLocker")
	
	#var changeNameResponse = await LL_Players.SetPlayerName.new(playerName).send()
	#if (!changeNameResponse.success):
		#printerr("Guest login failed with reason: " + changeNameResponse.error_data.to_string())
		#return
	#print("successfully changed name")

func get_or_create_player_identifier() -> String:
	var file = FileAccess.open("user://player_id.data", FileAccess.READ)
	if file:
		var id = file.get_as_text().strip_edges()
		return id
	else:
		# Generate a new random unique identifier
		var new_id = uuid.gd.v4()
		file = FileAccess.open("user://player_id.data", FileAccess.WRITE)
		file.store_string(new_id)
		file.close()
		return new_id

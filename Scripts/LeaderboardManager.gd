extends Node

var difficulties = ["EASY", "CLASSIC" , "COLORFUL", "RAINBOW"]

var adjectives = [
	"Able", "Acid", "Apex", "Blue", "Bold", "Busy", "Calm", "Cold", 
	"Dark", "Dear", "Deep", "Dull", "Easy", "Epic", "Fair", "Fast", 
	"Fine", "Free", "Glad", "Gold", "Good", "Grey", "Hard", "High", 
	"Holy", "Icy", "Just", "Kind", "Loud", "Lush", "Mega", "Mild", 
	"Neon", "Nice", "Open", "Pale", "Pure", "Rare", "Real", "Rich", 
	"Safe", "Slim", "Soft", "Sour", "Tall", "Tame", "Tiny", "Vast", 
	"Wild", "Wise"
]

var nouns = [
	"Atom", "Bear", "Bird", "Bolt", "Boss", "Cake", "Chef", "Club", 
	"Dino", "Duck", "Duke", "Echo", "Edge", "Fire", "Fish", "Frog", 
	"Gear", "Goat", "Hawk", "Hero", "Jade", "King", "Leaf", "Lion", 
	"Mage", "Mars", "Moon", "Neon", "Nova", "Onyx", "Pear", "Dawg", 
	"Puma", "Rain", "Rock", "Ship", "Star", "Taco", "Tank", "Tent", 
	"Tree", "Twin", "Unit", "Vase", "Volt", "Wave", "Wolf", "Yeti", 
	"Zeus", "Zinc"
]

func set_first_username():
	var attempts = 0
	var max_attempts = 10
	
	while attempts < max_attempts:
		var adj = adjectives.pick_random()
		var noun = nouns.pick_random()
		var num = randi() % 100
		var potential_name = "%s%s%02d" % [adj, noun, num]
		
		if await attempt_username_change(potential_name):
			return
		
		attempts += 1
	
	attempt_username_change("User" + str(Time.get_unix_time_from_system()).right(6))

func attempt_username_change(username: String) -> bool:
	var setname_response = await LL_Players.SetPlayerName.new(username).send()
	return setname_response.success


func _ready() -> void:

	var id = await get_or_create_player_identifier()
	var guestLoginResponse = await LL_Authentication.GuestSession.new(id[0]).send()
	if (!guestLoginResponse.success):
		printerr("Guest login failed with reason: " + guestLoginResponse.error_data.to_string())
		return
	if id[1]:
		set_first_username()
		print("created new name for player")
		
	print(guestLoginResponse.player_name)
	print("Guest user was successfully signed in to LootLocker")
	
	print("Possibly updating scores")
	for i in range(4):
		if FileManager.highScore[i] != 0:
			upload_score(difficulties[i].to_lower(), FileManager.highScore[i])

func upload_score(the_difficulty, the_score):
	var submit_response = await LL_Leaderboards.SubmitScore.new(the_difficulty, the_score, LL_StateData.GetCachedPlayerIdentifier()).send()
	if !(submit_response.success):
		printerr(submit_response.error_data)

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

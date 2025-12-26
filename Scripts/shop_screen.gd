extends CanvasLayer
var current_collectible = null
var coins = 0 

func _on_selection_changed(item: ShopSlot, _index: int) -> void:
	var collectible: Collectible = item.data
	current_collectible = collectible
	$SkinBuySection/SkinCost.text = ("$" + str(current_collectible.price))
	match collectible.type:
		"skin":
			CollectibleDB.CURRENT["skin"] = CollectibleDB.COLLECTIBLES.find(collectible)
			current_collectible = collectible
			$Player/ColorRect.texture = collectible.icon
			$Player.resetAnimation()
			if collectible.id not in CollectibleDB.OWNED:
				$SkinBuySection/SkinCost.visible = true
				$SkinBuySection/SkinBuy.visible = true
				$SkinBuySection/EquippedLabel.visible = false
				if collectible.price <= coins: 
					$SkinBuySection/SkinBuy.disabled = false
				else:
					$SkinBuySection/SkinBuy.disabled = true
			else:
				$SkinBuySection/SkinCost.visible = false
				$SkinBuySection/SkinBuy.visible = false
				$SkinBuySection/EquippedLabel.visible = true
		"trail":
			CollectibleDB.CURRENT["trail"] = CollectibleDB.COLLECTIBLES.find(collectible)
			current_collectible = collectible
			$Player/Trail.texture = collectible.icon
			$Player/Trail2.texture = collectible.icon
			if collectible.id not in CollectibleDB.OWNED:
				$SkinBuySection/SkinCost.visible = true
				$SkinBuySection/SkinBuy.visible = true
				$SkinBuySection/EquippedLabel.visible = false
				if collectible.price <= coins: 
					$SkinBuySection/SkinBuy.disabled = false
				else:
					$SkinBuySection/SkinBuy.disabled = true
			else:
				$SkinBuySection/SkinCost.visible = false
				$SkinBuySection/SkinBuy.visible = false
				$SkinBuySection/EquippedLabel.visible = true
		"theme":
			CollectibleDB.CURRENT["theme"] = CollectibleDB.COLLECTIBLES.find(collectible)
			current_collectible = collectible
			if collectible.id not in CollectibleDB.OWNED:
				$SkinBuySection/SkinCost.visible = true
				$SkinBuySection/SkinBuy.visible = true
				$SkinBuySection/EquippedLabel.visible = false
				if collectible.price <= coins: 
					$SkinBuySection/SkinBuy.disabled = false
				else:
					$SkinBuySection/SkinBuy.disabled = true
			else:
				$SkinBuySection/SkinCost.visible = false
				$SkinBuySection/SkinBuy.visible = false
				$SkinBuySection/EquippedLabel.visible = true
	
func startPlayerAnimation():
	$Player.resetAnimation()

func on_loading_shop_screen():
	startPlayerAnimation()
	FileManager.loadCoins()
	coins = FileManager.coins
	$CoinLabel.text = str(coins) + "[img]res://Textures/Coin.png[/img]"
	$TabContainer/Skins.reset()
	$TabContainer/Trails.reset()
	FileManager.loadCurrentCollectibles()

	$TabContainer/Skins.set_to_item(CollectibleDB.COLLECTIBLES[CollectibleDB.CURRENT["skin"]])
	$TabContainer/Trails.set_to_item(CollectibleDB.COLLECTIBLES[CollectibleDB.CURRENT["trail"]])


func _on_home_pressed() -> void:
	$"..".buttonClick()
	if CollectibleDB.COLLECTIBLES[CollectibleDB.CURRENT["skin"]].id not in CollectibleDB.OWNED:
		CollectibleDB.CURRENT["skin"] = CollectibleDB.get_default_skin()
		$TabContainer/Skins.set_default()
		
	if CollectibleDB.COLLECTIBLES[CollectibleDB.CURRENT["trail"]].id not in CollectibleDB.OWNED:
		CollectibleDB.CURRENT["trail"] = CollectibleDB.get_default_trail()
		$TabContainer/Trails.set_default()
		
		
	$"../GameScreen/Objects/Player/Trail".texture = CollectibleDB.COLLECTIBLES[CollectibleDB.CURRENT["trail"]].icon
	$"../GameScreen/Objects/Player/Trail2".texture = CollectibleDB.COLLECTIBLES[CollectibleDB.CURRENT["trail"]].icon
	$"../GameScreen/Objects/Player/ColorRect".texture = CollectibleDB.COLLECTIBLES[CollectibleDB.CURRENT["skin"]].icon
			
	
	FileManager.saveCurrentCollectibles()
	#set real trail and theme here


func _on_skin_buy_pressed() -> void:
	$"..".buttonClick()
	coins -= current_collectible.price
	FileManager.coins = coins
	FileManager.saveCoins()
	$CoinLabel.text = str(coins) + "[img]res://Textures/Coin.png[/img]"
	$SkinBuySection/SkinCost.visible = false
	$SkinBuySection/SkinBuy.visible = false
	$SkinBuySection/EquippedLabel.visible = true
	
	if current_collectible.type == "skin":
		$TabContainer/Skins.buy_current_node()
	elif current_collectible.type == "trail":
		$TabContainer/Trails.buy_current_node()
	
	#ts does not actaully store data :/
	CollectibleDB.OWNED.append(current_collectible.id)
	FileManager.owned = CollectibleDB.OWNED
	FileManager.saveOwned()
	
	pass # Replace with function body.


func _on_confirmation_dialog_canceled() -> void:
	pass # Replace with function body.

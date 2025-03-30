extends Node2D
@onready var deck_manager: Node2D = $"../Deck"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func purchase_random_card(total_shop_points) -> Dictionary:
	if total_shop_points < 10:
		print("Not enough points to buy a card.")
		return {}

	var roll = randi() % 100
	var tier = 1
	if roll < 80:
		tier = 1
	elif roll < 95:
		tier = 2
	else:
		tier = 3

	var element = deck_manager.possible_elements[randi() % deck_manager.possible_elements.size()]
	var new_card = CardData.new()
	new_card.element = element
	new_card.tier = tier
	new_card.display_name = element

	deck_manager.push_card_to_deck(new_card)

	var roman = ["I", "II", "III"][tier - 1]
	var info_text = "%s %s" % [element, roman]

	print("Purchased card: %s" % info_text)

	return {
		"card": new_card,
		"display": info_text
	}

func upgrade_random_card(total_shop_points) -> Dictionary:
	if total_shop_points < 20:
		print("Not enough points to upgrade a card.")
		return {}

	if deck_manager.player_deck.is_empty():
		print("No cards available to upgrade.")
		return {}

	var index = randi() % deck_manager.player_deck.size()
	var original_card: CardData = deck_manager.player_deck[index]
	# Clone and upgrade
	var upgraded_card = original_card.duplicate(true)
	upgraded_card.tier = min(upgraded_card.tier + 1, 3)

	# Update in deck
	deck_manager.update_card(index, upgraded_card)

	# Also update the original_deck copy (if exists)
	for i in range(deck_manager.original_deck.size()):
		var orig = deck_manager.original_deck[i]
		if orig.element == original_card.element and orig.tier == original_card.tier:
			deck_manager.original_deck[i] = upgraded_card.duplicate(true)
			break

	var roman = ["I", "II", "III"][upgraded_card.tier - 1]
	var info_text = "%s %s" % [upgraded_card.element, roman]
	print("Upgraded card: %s" % info_text)
	return {
		"card": upgraded_card,
		"display": info_text
	}

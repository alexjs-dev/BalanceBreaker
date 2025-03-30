extends Node2D

const CARD_SCENE_PATH = "res://features/card/card.tscn"

var player_deck: Array[CardData] = []
var original_deck: Array[CardData] = []


@export var is_enabled = true
@export var use_random_deck := false
@export var element_counts := {
	"Fire": 5,
	"Water": 5,
	"Earth": 5,
	"Air": 5,
	"Ice": 5,
	"Light": 5,
	"Dark": 5
}

@onready var collision_shape := $Area2D/CollisionShape2D
@onready var sprite := $Sprite2D
@onready var label := $Label
@onready var player_hand_reference: Node2D = $"../PlayerHand"

var possible_elements = ["Fire", "Water", "Earth", "Air", "Ice", "Light", "Dark"]

func _ready() -> void:
	generate_deck()
	player_deck.shuffle()
	label.text = str(player_deck.size())
	
	var label_size = label.get_size()
	label.position = sprite.position - (label_size / 2)

func reset_deck():
	player_deck.clear()
	player_hand_reference.clear_hand()

	# Restore from original_deck
	for card in original_deck:
		player_deck.append(card.duplicate(true))

	player_deck.shuffle()

	collision_shape.disabled = false
	sprite.visible = true
	label.visible = true
	label.text = str(player_deck.size())
	
func create_card(element: String, tier := 1) -> CardData:
	var card = CardData.new()
	card.element = element
	card.tier = tier
	card.display_name = element
	return card
	
func create_random_card() -> CardData:
	var element = possible_elements[randi() % possible_elements.size()]
	var tier = randi_range(1, 1)  # You can adjust this later
	return create_card(element, tier)
	
func update_card(index: int, new_data: CardData):
	if index >= 0 and index < player_deck.size():
		player_deck[index] = new_data.duplicate(true)
		
func push_card_to_deck(card: CardData):
	player_deck.append(card.duplicate(true))
	label.text = str(player_deck.size())
		
func generate_deck():
	player_deck.clear()
	original_deck.clear()

	if use_random_deck:
		var total_cards := 0
		for count in element_counts.values():
			total_cards += count

		for i in range(total_cards):
			var card_data = create_random_card()
			player_deck.append(card_data)
	else:
		for element in element_counts.keys():
			var count = element_counts[element]
			for i in range(count):
				var card_data = create_card(element)
				player_deck.append(card_data)

	# Save a copy of the generated deck for future resets
	for card in player_deck:
		original_deck.append(card.duplicate(true))  # Deep copy


func draw_card() -> void:
	if player_deck.is_empty() or !is_enabled:
		disable_deck_visuals()
		return

	var cards_in_hand = player_hand_reference.player_hand.size()
	if cards_in_hand >= player_hand_reference.max_hand_size:
		return

	var cards_to_draw = min(player_hand_reference.max_hand_size - cards_in_hand, player_deck.size())

	for i in range(cards_to_draw):
		var card_data = player_deck.pop_front()
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		new_card.card_data = card_data

		$"../CardManager".add_child(new_card)
		new_card.setup(false)
		player_hand_reference.add_card_to_hand(new_card)

		label.text = str(player_deck.size())
		await get_tree().create_timer(0.2).timeout

	if player_deck.is_empty():
		disable_deck_visuals()

func disable_deck_visuals():
	collision_shape.disabled = true
	sprite.visible = false
	label.visible = false

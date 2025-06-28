extends Node
class_name GameStateManager

@onready var game_ui: Node2D = $GameUI
@onready var grid_manager: Node2D = $GridManager
@onready var card_manager: Node2D = $CardManager
@onready var deck_manager: Node2D = $Deck
@onready var center_effect_label: Label = $GameUI/VBoxContainer/CenterEffectLabel
@onready var combo_label: Label = $GameUI/ComboLabel

@onready var player_hand_manager: Node2D = $PlayerHand
@onready var menu_game_over: Control = $GameMenuUI/MenuGameOver
@onready var menu_game_welcome: Control = $GameMenuUI/MenuGameWelcome
@onready var menu_game_upgrades: Control = $GameMenuUI/MenuGameUpgrades
@onready var display_value: Node2D = $DisplayValue
@onready var trash_place_sound: AudioStreamPlayer2D = $CardManager/TrashPlaceSound
@onready var card_win_sound: AudioStreamPlayer2D = $CardManager/CardWinSound


var card_scene
const CARD_SCENE_PATH = "res://features/card/card.tscn"
var winning_player_cards: Array = []

const PLAYER_ROW = 1
const ENEMY_ROW = 0
const COLUMNS = 5

var player_points = 0
@export var total_accumulated_player_points = 0
@export var total_shop_points = 0
var round = 0
const STARTING_TARGET_POINTS = 10
var target_points = STARTING_TARGET_POINTS

var awaiting_clear := false
enum GameState { PLAYING, GAME_OVER, PAUSED, UPGRADE_MENU, MAIN_MENU }

@export var game_state: GameState = GameState.MAIN_MENU

func _process(delta):
	if game_state == GameState.GAME_OVER:
		menu_game_over.visible = true
		menu_game_welcome.visible = false
		menu_game_upgrades.visible = false
	if game_state == GameState.PLAYING:
		menu_game_over.visible = false
		menu_game_welcome.visible = false
		menu_game_upgrades.visible = false
		validate_game_over()
	if game_state == GameState.MAIN_MENU:
		menu_game_over.visible = false
		menu_game_welcome.visible = true
		menu_game_upgrades.visible = false
	if game_state == GameState.UPGRADE_MENU:
		menu_game_over.visible = false
		menu_game_welcome.visible = false
		menu_game_upgrades.visible = true
	if is_player_row_filled() and not awaiting_clear:
		awaiting_clear = true
		handle_full_row()


func _ready() -> void:
	card_scene = preload(CARD_SCENE_PATH)
	game_ui.on_set_target_points(STARTING_TARGET_POINTS)
	start_round()

func compare_elements(player_elem: String, enemy_elem: String) -> String:
	var wins = {
		"Fire": ["Ice", "Water"],
		"Water": ["Fire"],
		"Earth": ["Air"],
		"Air": ["Earth"],
		"Ice": ["Fire"],
		"Light": ["Dark"],
		"Dark": ["Light"]
	}

	if player_elem == enemy_elem:
		return "draw"
	elif wins.has(player_elem) and enemy_elem in wins[player_elem]:
		return "win"
	else:
		return "lose"


func get_player_card_results(player_cards: Array, enemy_cards: Array):
	var player_card_results = []

	for i in range(player_cards.size()):
		var player_entry = player_cards[i]
		var enemy_entry = enemy_cards[i]
		var player_card = player_entry.get("card_in_slot")
		var enemy_card = enemy_entry.get("card_in_slot")
		
		if not is_instance_valid(player_card) or not is_instance_valid(enemy_card):
			continue

		var player_elem = player_card.card_data.element
		var enemy_elem = enemy_card.card_data.element

		var state = compare_elements(player_elem, enemy_elem)
		var updated_entry = player_entry.duplicate()
		updated_entry["state"] = state
		updated_entry["column"] = i
		player_card_results.append(updated_entry)

	return { "player_card_results": player_card_results }


func add_winning_points(points: int):
	player_points += points
	total_accumulated_player_points += points
	total_shop_points += points
	game_ui.on_set_player_points(player_points)
	
func validate_winning_combinations():
	var earned_points = 0
	var winning_player_cards = []
	var player_cards = grid_manager.slots[PLAYER_ROW]
	var enemy_cards = grid_manager.slots[ENEMY_ROW]

	var player_card_results = get_player_card_results(player_cards, enemy_cards).player_card_results
	
	print("player_card_results", player_card_results)
	for card_result in player_card_results:
		var card = card_result["card_in_slot"]
		if card_result["state"] == "win":
			var points = card.card_data.tier * 10
			earned_points += points
			winning_player_cards.append(card)
			var column = card_result["column"]
			var destroyed_enemy_card = grid_manager.slots[0][column]
			if destroyed_enemy_card.card_in_slot:
				await animate_card_lose(destroyed_enemy_card.card_in_slot)
				destroyed_enemy_card.card_in_slot.queue_free()
				destroyed_enemy_card.card_in_slot = null

				await get_tree().create_timer(0.05).timeout
				create_enemy_card_for_column(column, true)
			await animate_card_win(card)
			await display_text("+%s" % points)	
		if card_result["state"] == "lose" or card_result["state"] == "draw":
			await animate_card_lose(card)

	
	print("earned_points", earned_points)
	await display_text("Total: %s" % earned_points)
	var multiplier = await detect_combo_effect(winning_player_cards)
	add_winning_points(earned_points * multiplier)
	if is_point_quota_reached():
		next_round()
	
	clear_player_row()
	awaiting_clear = false
		
		
		
func handle_full_row():
	print("Full row trying to count points")
	validate_winning_combinations()
	
func detect_combo_effect(cards: Array):
	print("Detecting combo")
	var element_counts := {}

	for card in cards:
		var element = card.card_data.element
		if element_counts.has(element):
			element_counts[element] += 1
		else:
			element_counts[element] = 1

	# Determine the highest repetition
	var max_count = 0
	for count in element_counts.values():
		if count > max_count:
			max_count = count

	var multiplier = 1
	var label = ""

	match max_count:
		5:
			multiplier = 5
			label = "x5! DOMINATE!"
		4:
			multiplier = 4
			label = "x4! BRUTAL!"
		3:
			multiplier = 3
			label = "x3! SET!"
		2:
			multiplier = 2
			label = "x2 PAIR!"

	# Special case: all unique (rainbow)
	if element_counts.size() == 5 and max_count == 1 and multiplier < 4:
		multiplier = 4
		label = "x4! DIVERSITY!"
		
	if cards.size() == 5 and multiplier == 1:
		multiplier = 2
		label = "x2! Whole row!"


	print("Combo detected:", label)
	await display_combo_text(label)
	return multiplier

func display_text(text: String):
	center_effect_label.text = text
	center_effect_label.show()
	center_effect_label.z_index = 1000
	center_effect_label.modulate = Color.AQUAMARINE
	var settings = LabelSettings.new()
	# settings.outline_size = 2
	# settings.outline_color = Color.BLACK
	settings.shadow_offset = Vector2(2, 2)
	settings.shadow_color = Color.BLACK
	settings.font_size = 64

	center_effect_label.label_settings = settings
	await get_tree().process_frame

	# Center the label (after it gets sized properly)
	var screen_size = Vector2(get_viewport().size)
	var label_size = center_effect_label.get_size()
	center_effect_label.position = Vector2(0 - label_size.x / 2, 0)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	# Animate scale from small to normal
	tween.tween_property(center_effect_label, "scale", Vector2(1, 1), 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Animate opacity from 0 to 1, then fade to 0
	tween.tween_property(center_effect_label, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(center_effect_label, "modulate:a", 0.0, 1).set_delay(0.4)

	await tween.finished
	center_effect_label.hide()
	
	
func display_combo_text(text: String):
	combo_label.text = text
	combo_label.show()
	combo_label.z_index = 1000
	combo_label.modulate = Color.DARK_ORANGE
	
	var settings = LabelSettings.new()
	settings.shadow_offset = Vector2(2, 2)
	settings.shadow_color = Color.BLACK
	settings.font_size = 72
	combo_label.label_settings = settings

	await get_tree().process_frame

	var screen_size = Vector2(get_viewport().size)
	var label_size = combo_label.get_size()
	combo_label.position = Vector2(0 - label_size.x / 2, 0 - label_size.y / 2)
	combo_label.scale = Vector2(0.3, 0.3)  # start smaller for more bounce

	var tween = get_tree().create_tween()
	tween.set_parallel(false)  # run sequential for more control

	# Bounce up with elastic
	tween.tween_property(combo_label, "scale", Vector2(1.2, 1.2), 0.35)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Bounce back to 1.0 scale
	tween.tween_property(combo_label, "scale", Vector2(1, 1), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

	# Animate opacity in parallel (fade in and fade out)
	tween.set_parallel(true)
	tween.tween_property(combo_label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(combo_label, "modulate:a", 0.0, 1.0).set_delay(0.6)

	await tween.finished
	combo_label.hide()



func next_round() -> void:
	deck_manager.is_enabled = false
	card_manager.is_enabled = false
	increase_points()
	start_round()
	deck_manager.reset_deck()
	game_state = GameState.UPGRADE_MENU
	deck_manager.is_enabled = true
	card_manager.is_enabled = true


func increase_points():
	if round < 5:
		target_points += 20
	elif round < 10:
		target_points += 50
	else:
		target_points *= 2
	player_points = 0
	game_ui.on_set_player_points(player_points)
	game_ui.on_set_target_points(target_points)


func clear_player_row():
	print("clearing player row")
	for col in range(COLUMNS):
		var slot = grid_manager.slots[PLAYER_ROW][col]
		if slot.card_in_slot:
			slot.blocked = false
			slot.card_in_slot.queue_free()
			slot.card_in_slot = null


func clear_enemy_row():
	print("clearing enemy row")
	for col in range(COLUMNS):
		var slot = grid_manager.slots[ENEMY_ROW][col]
		if slot.card_in_slot:
			slot.card_in_slot.queue_free()
			slot.card_in_slot = null


func generate_elements_with_duplicates(dup_count: int) -> Array:
	var elements = ["Fire", "Water", "Earth", "Air", "Ice", "Light", "Dark"]
	elements.shuffle()

	var result = []
	var base_element = elements[0]
	match dup_count:
		5:
			for i in range(5):
				result.append(base_element)
		4:
			for i in range(4):
				result.append(base_element)
			result.append(elements[1])
		3:
			for i in range(3):
				result.append(base_element)
			result.append(elements[1])
			result.append(elements[2])
		2:
			for i in range(2):
				result.append(base_element)
			result.append(elements[1])
			result.append(elements[2])
			result.append(elements[3])
		0:
			result = elements.slice(0, 5)

	result.shuffle()
	return result


func choose_duplication_pattern() -> Array:
	var patterns = [
		{"count": 5, "chance": 0.10},  # All same
		{"count": 4, "chance": 0.15},
		{"count": 3, "chance": 0.15},
		{"count": 2, "chance": 0.40},
		{"count": 0, "chance": 0.20},  # All unique
	]

	var rand = randf()
	var total = 0.0
	for pattern in patterns:
		total += pattern["chance"]
		if rand <= total:
			return generate_elements_with_duplicates(pattern["count"])
	return generate_elements_with_duplicates(0)


func generate_enemy_card_data_with_element(element: String) -> CardData:
	var data = CardData.new()
	data.element = element
	data.tier = 1
	if round > 3:
		data.tier = 2
	elif round > 6:
		data.tier = 3
	return data


func fill_enemy_cards():
	var selected_elements = choose_duplication_pattern()
	for col in range(COLUMNS):
		var slot = grid_manager.slots[ENEMY_ROW][col]
		var card = card_scene.instantiate()
		card.card_data = generate_enemy_card_data_with_element(selected_elements[col])
		card.is_enemy_card = true
		var width = 128 * COLUMNS
		var height = 190 * 2
		card.position = Vector2((slot.position.x + width / 2) + 4, (slot.position.y + height) / 2 - 24)
		card.z_index = 1
		card.get_node("Area2D/CollisionShape2D").disabled = true
		slot.card_in_slot = card
		grid_manager.add_child(card)
		card.setup(true)

var elements = ["Fire", "Water", "Earth", "Air", "Ice", "Light", "Dark"]

func get_random_element() -> String:
	return elements[randi() % elements.size()]


func choose_element_from_hand_or_deck(enemy_elem: String) -> String:
	var wins = {
		"Fire": ["Ice", "Water"],
		"Water": ["Fire"],
		"Earth": ["Air"],
		"Air": ["Earth"],
		"Ice": ["Fire"],
		"Light": ["Dark"],
		"Dark": ["Light"]
	}

	# Step 1: Build the list of elements that LOSE to enemy_elem
	var losing_elements := []
	for elem in wins.keys():
		if wins.has(elem) and enemy_elem in wins[elem]:
			losing_elements.append(elem)

	# Step 2: Collect all unique elements from hand and deck
	var hand_elements := []
	for card in player_hand_manager.player_hand:
		if card.card_data != null and card.card_data.element not in hand_elements:
			hand_elements.append(card.card_data.element)

	var deck_elements := []
	for card_data in deck_manager.player_deck:
		if card_data.element not in deck_elements:
			deck_elements.append(card_data.element)

	# Step 3: Filter available cards to only those that would LOSE to the enemy
	var use_hand = randf() < 0.5
	var candidate_pool = hand_elements if use_hand else deck_elements

	var losing_candidates := []
	for elem in candidate_pool:
		if elem in losing_elements:
			losing_candidates.append(elem)

	# Step 4: Return a random losing element if available
	if losing_candidates.size() > 0:
		return losing_candidates[randi() % losing_candidates.size()]
	else:
		return "Fire"  # Fallback

func get_random_player_element_from_hand_or_deck() -> String:
	var elements := []
	
	# Collect elements from player's hand
	for card in player_hand_manager.player_hand:
		if card.card_data and card.card_data.element not in elements:
			elements.append(card.card_data.element)
	
	# Collect elements from player's deck
	for card_data in deck_manager.player_deck:
		if card_data.element not in elements:
			elements.append(card_data.element)

	# Pick random if any, fallback to Fire
	if elements.size() > 0:
		return elements[randi() % elements.size()]
	else:
		return "Fire"


func create_enemy_card_for_column(column: int, animate := false) -> void:
	var slot = grid_manager.slots[ENEMY_ROW][column]
	var player_elem = get_random_player_element_from_hand_or_deck()
	var element = choose_element_from_hand_or_deck(player_elem)
	var card = card_scene.instantiate()
	card.card_data = generate_enemy_card_data_with_element(element)
	card.is_enemy_card = true

	var width = 128 * COLUMNS
	var height = 190 * 2
	card.position = Vector2((slot.position.x + width / 2) + 4, (slot.position.y + height) / 2 - 24)
	card.z_index = 1
	card.get_node("Area2D/CollisionShape2D").disabled = true
	slot.card_in_slot = card
	grid_manager.add_child(card)
	card.setup(true)

	if animate:
		card.modulate.a = 0.0
		card.scale = Vector2(0.5, 0.5)
		card.create_tween().tween_property(card, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
		card.create_tween().tween_property(card, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK)

		
func validate_game_over():
	var hand_size = player_hand_manager.player_hand.size()
	var deck_empty = deck_manager.player_deck.is_empty()
	var max_column_size = grid_manager.columns  # Typically 5

	# Count only non-empty slots
	var placed_cards := 0
	for slot in grid_manager.slots[PLAYER_ROW]:
		if slot.card_in_slot != null:
			placed_cards += 1

	var remaining_slots = max_column_size - placed_cards
	var not_enough_cards = deck_empty and hand_size < remaining_slots
	var did_not_reach_target = player_points < target_points

	if not_enough_cards and did_not_reach_target:
		game_state = GameState.GAME_OVER
		print("Game Over — not enough cards and target not reached.")

	
	# max_hand_size
func start_round():
	clear_player_row()
	clear_enemy_row()
	fill_enemy_cards()
	round += 1
	# deck_manager.draw_card()

func set_game_state():
	game_state = GameState.PLAYING
	

func is_player_row_filled() -> bool:
	for col in range(COLUMNS):
		var slot = grid_manager.slots[PLAYER_ROW][col]
		if slot.card_in_slot == null:
			return false
	return true


func is_point_quota_reached() -> bool:
	return player_points >= target_points




func animate_card_draw(card: Node) -> void:
	animate_card_lose(card)

func animate_card_win(card: Node) -> void:
	print("Attempting win for: ", card)
	var tween = get_tree().create_tween()
	card_win_sound.play()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var target_pos = card.position - Vector2(0, 20)
	tween.tween_property(card, "position", target_pos, 0.2)
	await tween.finished

		
		
func animate_card_lose(card: Node) -> void:
	print("Animating lose for: ", card.name)
	var tween = get_tree().create_tween()
	trash_place_sound.play()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var target_scale = Vector2(0.2, 0.2)
	tween.tween_property(card, "scale", target_scale, 0.2)
	await tween.finished



func restart_game():
	# Reset state
	player_points = 0
	total_accumulated_player_points = 0
	target_points = STARTING_TARGET_POINTS
	round = 0
	awaiting_clear = false
	game_state = GameState.PLAYING
	# Reset UI
	game_ui.on_set_player_points(player_points)
	game_ui.on_set_target_points(target_points)
	menu_game_over.visible = false
	display_text("Good luck!")

	# Reset board
	clear_player_row()
	clear_enemy_row()

	# Reset deck
	deck_manager.reset_deck()
	deck_manager.is_enabled = true
	card_manager.is_enabled = true

	# Refill enemies
	fill_enemy_cards()
	deck_manager.draw_card()

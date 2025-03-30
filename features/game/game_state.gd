extends Node
class_name GameStateManager

@onready var game_ui: Node2D = $GameUI
@onready var grid_manager: Node2D = $GridManager
@onready var card_manager: Node2D = $CardManager
@onready var deck_manager: Node2D = $Deck
@onready var center_effect_label: Label = $GameUI/CenterEffectLabel  # Make sure this exists
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
	display_text("Good luck!")


func get_player_card_results(player_cards: Array, enemy_cards: Array) -> Array:
	var results = []
	var wins = {
		"Fire": ["Ice", "Water"],
		"Water": ["Fire"],
		"Earth": ["Air"],
		"Air": ["Earth"],
		"Ice": ["Fire"],
		"Light": ["Dark"],
		"Dark": ["Light"]
	}

	for i in range(player_cards.size()):
		var player_entry = player_cards[i]
		var enemy_entry = enemy_cards[i]
		var player_card = player_entry.get("card_in_slot")
		var enemy_card = enemy_entry.get("card_in_slot")
		
		if not is_instance_valid(player_card) or not is_instance_valid(enemy_card):
			continue

		var player_elem = player_card.card_data.element
		var enemy_elem = enemy_card.card_data.element

		var state = ""
		if player_elem == enemy_elem:
			state = "draw"
		elif wins.has(player_elem) and enemy_elem in wins[player_elem]:
			state = "win"
		else:
			state = "lose"
		var updated_entry = player_entry.duplicate()
		updated_entry["state"] = state
		updated_entry["index"] = i
		results.append(updated_entry)

	return results


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

	var player_card_results = get_player_card_results(player_cards, enemy_cards)
	print("player_card_results", player_card_results)
	for card_result in player_card_results:
		var card = card_result["card_in_slot"]
		if card_result["state"] == "win":
			var points = card.card_data.tier * 10
			earned_points += points
			add_winning_points(points)
			display_value.bounce_value_animation(str(points), card.global_position + Vector2(-32, -72), false)
			await animate_card_win(card)
		if card_result["state"] == "lose":
			await animate_card_lose(card)

	
	print("earned_points", earned_points)
	
	
	if is_point_quota_reached():
		next_round()
	
	clear_player_row()
	awaiting_clear = false
		
		
		
func handle_full_row():
	print("Full row trying to count points")
	validate_winning_combinations()
	
func detect_combo_effect(cards: Array):
	print("Detecting combo")


func display_text(text: String):
	center_effect_label.text = text
	center_effect_label.show()
	center_effect_label.z_index = 20
	center_effect_label.modulate = Color(0, 0, 0, 0)

	await get_tree().process_frame

	# Center the label (after it gets sized properly)
	var screen_size = Vector2(get_viewport().size)
	var label_size = center_effect_label.get_size()
	center_effect_label.position = Vector2(0, 0)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	# Animate scale from small to normal
	# tween.tween_property(center_effect_label, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Animate opacity from 0 to 1, then fade to 0
	tween.tween_property(center_effect_label, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(center_effect_label, "modulate:a", 0.0, 0.8).set_delay(0.4)

	await tween.finished
	center_effect_label.hide()


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


func generate_enemy_card_data() -> CardData:
	var elements = ["Fire", "Water", "Earth", "Air", "Ice", "Light", "Dark"]
	var data = CardData.new()
	data.element = elements[randi() % elements.size()]
	data.tier = 1
	data.display_name = data.element
	return data


func fill_enemy_cards():
	for col in range(COLUMNS):
		var slot = grid_manager.slots[ENEMY_ROW][col]
		var card = card_scene.instantiate()
		card.card_data = generate_enemy_card_data()
		card.is_enemy_card = true
		var width = 128 * COLUMNS
		var height = 190 * 2
		card.position = Vector2((slot.position.x + width / 2) + 4, (slot.position.y + height) / 2 - 24)
		card.z_index = 1
		card.get_node("Area2D/CollisionShape2D").disabled = true
		slot.card_in_slot = card
		grid_manager.add_child(card)
		card.setup(true)
	
		
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
	deck_manager.draw_card()

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
	tween.tween_property(card, "position", target_pos, 0.3)
	await tween.finished

		
		
func animate_card_lose(card: Node) -> void:
	print("Animating lose for: ", card.name)
	var tween = get_tree().create_tween()
	trash_place_sound.play()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var target_scale = Vector2(0.2, 0.2)
	tween.tween_property(card, "scale", target_scale, 0.3)
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

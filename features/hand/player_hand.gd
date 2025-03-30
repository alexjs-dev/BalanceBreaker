extends Node2D

@export var max_hand_size = 6
@export var player_hand = []
var discard_pile = []
var CARD_WIDTH = 128
var CARD_HEIGHT = 190
var GAP = 4
var center_screen_x
var is_align_center = false
@onready var camera: Camera2D = $"../Camera"

const HOVER_SHADER_PATH = "res://features/shaders/hovercard.gdshader"
var hover_shader : Shader
var hover_material : ShaderMaterial
@onready var card_spawn_sound: AudioStreamPlayer2D = $CardSpawnSound

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2

	# Load shader and create a reusable material
	hover_shader = load(HOVER_SHADER_PATH)
	hover_material = ShaderMaterial.new()
	hover_material.shader = hover_shader

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0, card)
		card.scale = Vector2(1, 1)

		var card_sprite = card.get_node("Sprite2D")
		card_sprite.material = hover_material.duplicate() # Use a unique copy if you want per-card tweaking
		card_spawn_sound.play()
		card.get_node("Area2D/CollisionShape2D").disabled = false
		update_hand_positions()
	else:
		animate_card_to_pos(card, card.hand_position)

func animate_card_to_pos(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)
	
	
func calc_y_coord():
	var screen_height = get_viewport().size.y
	var camera_bottom = camera.global_position.y + screen_height
	var y = camera_bottom - CARD_HEIGHT / 2  # puts the card's bottom exactly on the bottom edge
	return y




func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calc_card_pos(i), calc_y_coord())
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_pos(card, new_position)

func clear_hand():
	for card in player_hand:
		card.queue_free()
	player_hand.clear()

func calc_card_pos(index):
	var total_width = player_hand.size() - 1 * CARD_WIDTH
	var x_offset
	if is_align_center:
		x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	else:
		x_offset = CARD_WIDTH + index * CARD_WIDTH - total_width / 2
	return x_offset + GAP

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()

func discard_card(card: Card):
	remove_card_from_hand(card)
	discard_pile.append(card)

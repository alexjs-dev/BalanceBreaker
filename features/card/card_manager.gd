extends Node2D

var dragging_card = null  # Currently dragged card
var rotation_direction = null
var screen_size

var player_hand_reference

@export var COLLIOSION_MARK = 2
@export var COLLISION_MASK_CARD_SLOT = 1
@export var COLLISION_MASK_TRASH = 8
@export var is_enabled = true
@onready var card_place_sound: AudioStreamPlayer2D = $CardPlaceSound
@onready var trash_place_sound: AudioStreamPlayer2D = $TrashPlaceSound

@onready var trash: Node2D = $"../Trash"

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	# subscribe to signal
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	


func start_drag(card):
	if !is_enabled:
		return
	dragging_card = card
	
func on_left_click_released():
	if dragging_card:
		finish_drag()
		
func finish_drag():
	if dragging_card != null:
		var target_rotation = deg_to_rad(0)
		var tween = get_tree().create_tween()
		tween.tween_property(dragging_card, "rotation", target_rotation, 0.1).set_trans(Tween.TRANS_SINE)


		if is_card_over_trash():
			player_hand_reference.remove_card_from_hand(dragging_card)
			dragging_card.queue_free()
			dragging_card = null
			rotation_direction = null
			trash.on_card_discard()
			trash_place_sound.play()
			return
		var grid_manager = $"../GridManager"
		var mouse_pos = get_global_mouse_position()
		var result = grid_manager.get_slot_under_position(mouse_pos)

		if result:
			var slot = result[0]
			var row = result[1]
			var col = result[2]
			# not slot.blocked and 
			if slot == null:
				print("reset to hand")
				reset_card_to_hand()
			if slot != null:
				if slot.blocked:
					reset_card_to_hand()
					return 
				# Valid placement
				card_place_sound.play()
				player_hand_reference.remove_card_from_hand(dragging_card)
				dragging_card.global_position = slot.position
				print("drag release", slot.position)
				dragging_card.scale = Vector2(0.9, 0.9)
				dragging_card.get_node("Sprite2D").material = null
				dragging_card.get_node("Area2D/CollisionShape2D").disabled = true
				dragging_card.z_index = 1  # Keep it below hovered cards
				grid_manager.slots[row][col].card_in_slot = dragging_card
				grid_manager.slots[row][col].blocked = true
				
			else:
				# Blocked or already filled
				card_place_sound.play()
				reset_card_to_hand()
		else:
			# No grid slot under mouse
			card_place_sound.play()
			reset_card_to_hand()

		dragging_card = null
		rotation_direction = null

func reset_card_to_hand():
	dragging_card.z_index = 0
	player_hand_reference.add_card_to_hand(dragging_card)

	
func handle_card_rotation(dragging_card):
	# rotate left/right based on if beyond middle of the screen
	var mouse_x_middle_of_screen = get_global_mouse_position().x < 0
	var current_rotation
	if mouse_x_middle_of_screen:
		current_rotation = "left"
	else:
		current_rotation = "right"
		
		
	if rotation_direction == null or current_rotation != rotation_direction:
		var target_rotation = deg_to_rad(-3)
		if (current_rotation == "left"):
			target_rotation = deg_to_rad(3)
		var tween = get_tree().create_tween()
		tween.tween_property(dragging_card, "rotation", target_rotation, 0.1).set_trans(Tween.TRANS_SINE)
	rotation_direction = current_rotation


var old_mouse_pos = Vector2(0, 0)
func _process(delta: float) -> void:
	if dragging_card != null and dragging_card is Node2D:
		var mouse_pos = get_global_mouse_position()
		var sprite = null
		for card_child in dragging_card.get_children(false):
			if card_child is Sprite2D:
				sprite = card_child
		if sprite:
			var width = sprite.texture.get_width()
			var height = sprite.texture.get_height()
			var scale = 0.3 # sprite scale from original
			var card_size = Vector2(width * scale / 2, height * scale / 2)
			dragging_card.z_index = 10
			handle_card_rotation(dragging_card)
			var drag_coords = mouse_pos - (card_size / 2)
			dragging_card.global_position =  Vector2(clamp(drag_coords.x, (screen_size.x/2*-1)-width/2, (screen_size.x/2)+width/2),
			clamp(drag_coords.y, screen_size.y/2*-1, screen_size.y / 2))



func is_card_over_trash() -> bool:
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = COLLISION_MASK_TRASH
	
	var result = space_state.intersect_point(params)
	for trash in result:
		if trash.collider.is_in_group("trash"):
			return true
	return false

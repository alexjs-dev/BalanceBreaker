extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

@export var COLLIOSION_MARK = 2
@export var COLLISION_MASK_DECK = 4

var card_manager_reference
var deck_reference 


func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	var interaction = space_state.intersect_point(params)
	if interaction.size() > 0:
		var result_collision_mask =	interaction[0].collider.collision_mask
		if result_collision_mask == COLLIOSION_MARK:
			# card click
			var card_found = interaction[0].collider.get_parent()
			if card_found:
				card_manager_reference.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			# deck click
			deck_reference.draw_card()
		

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("left_mouse_button_clicked")
				raycast_at_cursor()
			else:
				emit_signal("left_mouse_button_released")

extends Control

@onready var button: Button = $MarginContainer/VBoxContainer/Button
@onready var sub_label: Label = $MarginContainer/VBoxContainer/SubLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_visibility_changed() -> void:
	if visible:
		var game_state_manager = get_node("/root/Game") # Adjust if needed
		var points = game_state_manager.total_accumulated_player_points
		sub_label.text = "You have earned %s points" % points
		

func _on_button_pressed() -> void:
	var game_state_manager = get_node("/root/Game")
	game_state_manager.restart_game()

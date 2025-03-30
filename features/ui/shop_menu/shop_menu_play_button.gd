extends Button


func _on_pressed() -> void:
	var game_state_manager = get_node("/root/Game")
	game_state_manager.start_round()
	game_state_manager.set_game_state()

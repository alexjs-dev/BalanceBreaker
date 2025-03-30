extends Control

func _on_button_pressed() -> void:
	var game_state_manager = get_node("/root/Game")
	game_state_manager.restart_game()

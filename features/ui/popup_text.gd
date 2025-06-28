extends Node2D

func show_text_popup(message: String = "You have discovered a card!"):
	var game_state = get_node("/root/Game")
	print("game_stat", game_state)
	game_state.display_text(message)

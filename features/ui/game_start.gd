extends Control
@onready var game_start_sound: AudioStreamPlayer2D = $GameStartSound

func _on_button_pressed() -> void:
	var game_state_manager = get_node("/root/Game")
	game_start_sound.play()
	game_state_manager.restart_game()

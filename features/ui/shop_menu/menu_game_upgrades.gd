extends Control

@onready var points_count_label: Label = $MarginContainer/VBoxContainer/PointsCountLabel

func _process(delta: float) -> void:
	var game_state_manager = get_node("/root/Game") # Adjust path if your GameStateManager is not a singleton
	points_count_label.text = "You have %d coins" % game_state_manager.total_shop_points

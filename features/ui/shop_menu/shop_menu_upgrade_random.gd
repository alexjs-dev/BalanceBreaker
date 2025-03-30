extends Button

@onready var popup: Node2D = $"../../../../../Popup"


func _process(delta: float) -> void:
	var game_state_manager = get_node("/root/Game")
	if game_state_manager.total_shop_points < 20:
		self.modulate.a = 0.5  # Set opacity to half
		disabled = true
	else:
		self.modulate.a = 1.0  # Full opacity
		disabled = false

func _on_pressed() -> void:
	var game_state_manager = get_node("/root/Game")
	var points = game_state_manager.total_shop_points
	var shop_manager = get_node("/root/Game/Shop")
	var result = shop_manager.upgrade_random_card(points)
	game_state_manager.total_shop_points -= 20
	if result.has("card"):
		popup.show_text_popup(result["card"], "You have upgraded a card!")

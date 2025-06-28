extends Button

@onready var popup: Node2D = $"../../../../../Popup"
@onready var card_purchase_sound: AudioStreamPlayer2D = $"../../../CardPurchaseSound"


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
	var roman_tiers = ["I", "II", "III"]
	var card_data = result["card"]
	var tier_str = roman_tiers[clamp(card_data.tier - 1, 0, 2)]
	var full_card_text = "%s %s" % [card_data.element, tier_str]
	if result.has("card"):
		card_purchase_sound.play()
		popup.show_text_popup("Upgrade: %s" % full_card_text)

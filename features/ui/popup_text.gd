extends Node2D

func show_text_popup(card_data: CardData, message: String = "You have discovered a card!"):
	var layer = CanvasLayer.new()
	layer.layer = 999
	get_tree().root.add_child(layer)

	# Fullscreen Control
	var popup = Control.new()
	popup.name = "CardRevealPopup"
	popup.anchor_left = 0.0
	popup.anchor_top = 0.0
	popup.anchor_right = 1.0
	popup.anchor_bottom = 1.0
	popup.set_z_as_relative(false)
	popup.z_index = 100
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(popup)

	# Container for animation
	var container = Control.new()
	container.name = "PopupContent"
	container.anchor_left = 0.5
	container.anchor_top = 0.5
	container.anchor_right = 0.5
	container.anchor_bottom = 0.5
	container.position = Vector2(-400, 0)
	container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	container.modulate.a = 1.0
	container.scale = Vector2(0.6, 0.6)
	popup.add_child(container)

	# Format text
	var roman_tiers = ["I", "II", "III"]
	var tier_str = roman_tiers[clamp(card_data.tier - 1, 0, 2)]
	var full_card_text = "%s %s" % [card_data.element, tier_str]

	# Main message
	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_color", Color.BLACK)
	container.add_child(label)

	# Sub message (card)
	var card_label = Label.new()
	card_label.text = full_card_text
	card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_label.add_theme_font_size_override("font_size", 64)
	card_label.add_theme_color_override("font_color", Color.BLACK)
	card_label.position = Vector2(0, 80)
	container.add_child(card_label)

	# Tween animation (scale in + fade out)
	var tween = popup.create_tween()
	tween.tween_property(container, "scale", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(container, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished
	layer.queue_free()
	container.queue_free()
	label.queue_free()
	popup.queue_free()

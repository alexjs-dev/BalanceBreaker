extends Node


func bounce_value_animation(value: String, position: Vector2, is_important: bool = false):
	var number = Label.new()
	number.global_position = position
	number.position = position
	number.text = value
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = '#FFF'
	if is_important:
		color = '#B22'
		number.scale = Vector2(1.5, 1.5)
	else:
		color = "#FFF8"
		
	number.label_settings.font_color = color
	number.label_settings.font_size =  64
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 1
	
	call_deferred("add_child", number)

	# Wait until the label is sized before setting its pivot.
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	# Choose a random horizontal offset between 0 and 16 (randomly left or right).
	var random_x = randf() * 24
	var direction = 1
	if randf() < 0.5:
		direction = -1

	
	# Create a tween to animate both parts in parallel.
	var tween = get_tree().create_tween()
	
	tween.set_parallel(true)
	# Part 2: Animate the container to move down 24 pixels (falling effect) and shrink to zero.
	tween.tween_property(number, "position:y", number.position.y, 0.25).set_ease(Tween.EASE_IN).set_delay(0.1)
	tween.tween_property(number, "position:y", number.position.y * 1.5, 0.25).set_ease(Tween.EASE_IN).set_delay(0.2)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	# When the tween finishes, remove the container (and the label within it).
	await tween.finished
	number.queue_free()
	call_deferred("remove_child", number)

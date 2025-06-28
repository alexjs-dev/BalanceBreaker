extends Node2D
class_name Card

@export var card_data: CardData
@export var is_enemy_card: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var trash_button: TextureButton = $TrashButton
@onready var burn_shader: MeshInstance2D = $BurnShader
@export var is_being_destroyed = false

@onready var title: Label = $Title
var hand_position

func set_burn_shader_percent(percentage: float) -> void:
	burn_shader.material.set_shader_parameter('percentage', percentage)


func _config_entries(tier: int, is_hero: bool=false) -> Array:
	var proto := CardData.new()
	return proto.config.filter(func(c):
		return c.tier == tier and c.is_hero == is_hero
	)
	
func _random_element() -> String:
	var elements = ["Fire", "Water", "Earth", "Air", "Ice", "Light", "Dark"]
	return elements[randi() % elements.size()]
	
func set_card_tint(color: Color):
	print("Setting card tint to:", color)
	if sprite_2d.material is ShaderMaterial:
		var shader_material := sprite_2d.material as ShaderMaterial
		shader_material.set_shader_parameter("tint_strength", 0.3)
		shader_material.set_shader_parameter("tint_color", color)
	
func reset_card_tint():
	if sprite_2d.material is ShaderMaterial:
		var shader_material := sprite_2d.material as ShaderMaterial
		shader_material.set_shader_parameter("tint_strength", 0.0)
		
			
func apply_burn_shader_effect():
	if card_data:
		var element = card_data.element
		var tier = card_data.tier
		var node_name = get_element_node_name(element, tier)
		var node = get_node_or_null(node_name)
		if node:
			node.visible = false

	var tween = create_tween()
	is_being_destroyed = true
	on_disable_trash()
	sprite_2d.visible = false
	tween.tween_method(set_burn_shader_percent, 0.0, 1.0, 0.3)
	await tween.finished

func on_enable_trash():
	trash_button.visible = true
	
func on_disable_trash():
	trash_button.visible = false
	
func tier_to_roman(tier: int) -> String:
	match tier:
		1: return "I"
		2: return "II"
		3: return "III"
		4: return "IV"
		_: return str(tier) # fallback for future expansion
		
func get_element_node_name(element: String, tier: int) -> String:
	return "Element%s%d" % [element, tier]

func _ready() -> void:
	on_disable_trash()
	if card_data:
		title.add_theme_color_override("font_color", Color.BLACK)
		var roman_tier = tier_to_roman(card_data.tier)
		title.text = "%s %s" % [card_data.display_name, roman_tier]
		print("card_data", card_data.element)

		var element = card_data.element
		var tier = card_data.tier
		var node_name = get_element_node_name(element, tier)

		var node = get_node_or_null(node_name)
		if node:
			node.visible = true


		
func setup(is_enemy: bool):
	is_enemy_card = is_enemy
	if is_enemy:
		on_disable_trash()
	if sprite_2d.material is ShaderMaterial:
		var shader_material := sprite_2d.material as ShaderMaterial
		if is_enemy:
			shader_material.set_shader_parameter("tint_strength", 0.3)
			shader_material.set_shader_parameter("tint_color", Color(0.6, 0.0, 1.0))
		else:
			shader_material.set_shader_parameter("tint_strength", 0.0)
			
			
func generate_enemy_card_data() -> CardData:
	var choices = _config_entries(1, false)
	if choices.empty():
		push_error("No tier-1 non-hero configs found!")
		return CardData.new()

	var entry = choices[randi() % choices.size()]
	var data  = CardData.new()
	# explicitly call setters so _update_from_config runs correctly
	data.set_hero(false)
	data.set_tier(entry.tier)
	data.set_element(_random_element())
	# override archetype/display_name to match this exact entry
	data.archetype    = entry.name
	data.display_name = "%s of %s" % [entry.content.name.en, data.element]
	return data

# New: generate a starting deck of N cards
func generate_starting_deck(deck_size: int = 10) -> Array:
	var deck := []
	var choices = _config_entries(1, false)
	if choices.empty():
		push_error("No tier-1 non-hero configs found!")
		return deck

	for i in range(deck_size):
		var entry = choices[randi() % choices.size()]
		var data  = CardData.new()
		data.set_hero(false)
		data.set_tier(entry.tier)
		data.set_element(_random_element())
		data.archetype    = entry.name
		data.display_name = "%s of %s" % [entry.content.name.en, data.element]
		deck.append(data)

	return deck



func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Card clicked: %s (Tier %d)" % [card_data.element, card_data.tier])


@onready var tween := create_tween()

func _on_area_2d_mouse_entered() -> void:
	on_enable_trash()
	if is_being_destroyed:
		return
	if tween.is_running():
		tween.kill()
		
	z_index = 1
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_exited() -> void:
	on_disable_trash()
	if is_being_destroyed:
		return
	
	if tween.is_running():
		tween.kill()

	z_index = 1
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

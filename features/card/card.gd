extends Node2D
class_name Card

@export var card_data: CardData
@export var is_enemy_card: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var title: Label = $Title
var hand_position

func tier_to_roman(tier: int) -> String:
	match tier:
		1: return "I"
		2: return "II"
		3: return "III"
		_: return str(tier) # fallback for future expansion
		
func _ready() -> void:
	if card_data:
		title.add_theme_color_override("font_color", Color.BLACK)
		var roman_tier = tier_to_roman(card_data.tier)
		title.text = "%s %s" % [card_data.display_name, roman_tier]
		
func setup(is_enemy: bool):
	is_enemy_card = is_enemy
	if sprite_2d.material is ShaderMaterial:
		var shader_material := sprite_2d.material as ShaderMaterial
		if is_enemy:
			shader_material.set_shader_parameter("tint_strength", 0.3)
		else:
			shader_material.set_shader_parameter("tint_strength", 0.0)
			
			
func generate_enemy_card_data() -> CardData:
	var elements = ["Fire", "Water", "Earth", "Air", "Ice", "Light", "Dark"]
	var data = CardData.new()
	data.element = elements[randi() % elements.size()]
	data.tier = 1  # Tier scaling can be based on level
	data.display_name = data.element
	return data


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Card clicked: %s (Tier %d)" % [card_data.element, card_data.tier])


@onready var tween := create_tween()

func _on_area_2d_mouse_entered() -> void:
	if tween.is_running():
		tween.kill()
		
	z_index = 1
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_exited() -> void:
	if tween.is_running():
		tween.kill()

	z_index = 1
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

extends Button
@onready var canvas_layer: CanvasLayer = $Sprite2D/CanvasLayer

@onready var label: Label = $Label
@onready var anim: AnimationPlayer = $AnimationPlayer
var hover_state = false
@export var disabled_state = true
@onready var sprite_2d: Sprite2D = $Sprite2D


var __style_render_required = false

func on_disable():
	disabled_state = true
	apply_styles()
	
func on_enable():
	disabled_state = false
	apply_styles()

func _ready() -> void:
	z_index = 10
	z_as_relative = false
	#canvas_layer.visible = true
	apply_styles()

func apply_styles():
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16

	if hover_state:
		style.bg_color = Color.YELLOW
		label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		style.bg_color = Color.DARK_GRAY
		label.add_theme_color_override("font_color", Color.WHITE)
	
	if disabled_state:
		var shader = Shader.new()
		sprite_2d.modulate = Color(0.3, 0.3, 0.3, 0.5)
		style.bg_color = Color.BLACK
		shader.code = """
			shader_type canvas_item;
			void fragment() {
				COLOR = texture(TEXTURE, UV);
				float gray = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
				COLOR.rgb = vec3(gray);
			}
		"""
		var mat = ShaderMaterial.new()
		mat.shader = shader
		material = mat
	else:
		material = null
	for value in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(value, style)
		
	
		
func _on_mouse_entered() -> void:
	if disabled_state:
		return
	hover_state = true
	apply_styles()
	#canvas_layer.visible = false
	anim.play("hover_in")

func _on_mouse_exited() -> void:
	if disabled_state:
		return
	hover_state = false
	apply_styles()
	#canvas_layer.visible = true
	anim.play("hover_out")

extends TextureButton
@onready var trash: Node2D = $Trash
@onready var trash_icon: Sprite2D = $TrashIcon
@onready var card: Card = $".."

var is_hover = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trash = get_node("/root/Game/Trash")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_down() -> void:
	var parent = get_parent()
	await card.apply_burn_shader_effect()
	trash.put_card_to_trash(parent)

func apply_styles():
	if is_hover:
		var shader = Shader.new()
		shader.code = """
			shader_type canvas_item;
			void fragment() {
				vec4 tex_color = texture(TEXTURE, UV);
				vec3 yellow_tint = vec3(1.0, 1.0, 0.5); // warm yellow
				COLOR.rgb = mix(tex_color.rgb, yellow_tint, 0.4);
				COLOR.a = tex_color.a;
			}
		"""
		var mat = ShaderMaterial.new()
		mat.shader = shader
		trash_icon.material = mat
	else:
		trash_icon.material = null
		
func _on_mouse_entered() -> void:
	is_hover = true
	apply_styles()


func _on_mouse_exited() -> void:
	is_hover = false
	apply_styles()

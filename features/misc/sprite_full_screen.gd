extends Sprite2D

func _ready() -> void:
	if texture:
		var screen_size = get_viewport_rect().size
		var texture_size = texture.get_size()
		scale = screen_size / texture_size

		var camera := get_node("/root/Game/Camera")
		if camera:
			global_position = camera.global_position

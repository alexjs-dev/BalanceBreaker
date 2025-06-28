extends MeshInstance2D

func _ready() -> void:
	if mesh is QuadMesh:
		var screen_size = get_viewport_rect().size
		var quad_mesh := mesh as QuadMesh
		quad_mesh.size = screen_size

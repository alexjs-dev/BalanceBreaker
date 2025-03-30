extends Node

@onready var canvas_layer: CanvasLayer = $"."

func _ready():
	for node in canvas_layer.get_children():
		if node is Control:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE

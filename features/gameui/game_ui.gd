extends Node2D
@onready var points: Label = $Points
@onready var target_points: Label = $TargetPoints


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_set_target_points(value: int):
	target_points.text = str(value)
	
func on_set_player_points(value: int):
	points.text = str(value)

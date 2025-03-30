extends Node2D

@export var columns: int = 5
@export var rows: int = 2
@export var cell_size: Vector2 = Vector2(128, 190)
@export var line_color: Color = Color.BLACK
@export var line_thickness: float = 2.0
@onready var camera: Camera2D = $"../Camera"

var OFFSET_Y = 48
var blocked_rows = [0] # 0 for 1st row
@export var slots = []

func _ready():
	position_grid()
	create_slots()
	queue_redraw()

func _draw():
	for col in range(columns + 1):
		var x = col * cell_size.x
		draw_line(Vector2(x, 0), Vector2(x, rows * cell_size.y), line_color, line_thickness)

	for row in range(rows + 1):
		var y = row * cell_size.y
		var current_color = line_color
		if blocked_rows.has(row):
			current_color = Color.RED  # Optional visual indicator
		draw_line(Vector2(0, y), Vector2(columns * cell_size.x, y), current_color, line_thickness)

func clear_row(row_index: int) -> void:
	var count = 0
	for row in slots:
		for slot in row:
			count += 1
			if count > 5:
				slot.card_in_slot = null
				slot.blocked = false



func position_grid():
	if camera:
		var grid_size = Vector2(columns * cell_size.x, rows * cell_size.y)
		var new_position = camera.global_position - grid_size / 2
		global_position = Vector2(new_position.x, new_position.y - OFFSET_Y)

func create_slots():
	slots.clear()
	for row in range(rows):
		var slot_row = []
		for col in range(columns):
			var slot_position = global_position + Vector2(col * cell_size.x + cell_size.x / 2, row * cell_size.y + cell_size.y / 2)
			slot_row.append({
				"position": slot_position,
				"card_in_slot": null,
				"blocked": blocked_rows.has(row)
			})
		slots.append(slot_row)

func get_slot_under_position(pos):
	for row in range(rows):
		for col in range(columns):
			var slot = slots[row][col]
			var slot_rect = Rect2(slot.position - cell_size / 2, cell_size)
			if slot_rect.has_point(pos):
				return [slot, row, col]
	# If nothing found after all rows
	return [null, -1, -1]

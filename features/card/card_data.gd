extends Resource
class_name CardData

@export_enum("Fire", "Water", "Earth", "Air", "Ice", "Light", "Dark") var element: String = "Fire"
@export_range(1, 3) var tier: int = 1
@export var display_name: String = "Fire"

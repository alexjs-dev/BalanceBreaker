# BuildingData.gd
extends Resource
class_name BuildingData

#── Exposed properties ──────────────────────────────────────────────────────────
@export_enum("peasant_hut", "warrior_t2", "archer_t2", "wizard_t2", "hero_hut")
var building_type: String = "peasant_hut"

@export_enum("crane", "tiger", "xenos", "lotus")
var clan: String = "crane"

@export var health: int = 1

# For training buildings: which archetype names this building can produce
@export var output_archetypes: Array = []

func _init() -> void:
	# Simple health lookup per building_type
	var hv := {
		"peasant_hut": 10,
		"warrior_t2": 20,
		"archer_t2": 20,
		"wizard_t2": 20,
		"hero_hut": 30,
	}
	health = hv[building_type] if hv.has(building_type) else 1

func is_spawner() -> bool:
	return building_type == "peasant_hut"

func is_trainer() -> bool:
	return output_archetypes.size() > 0

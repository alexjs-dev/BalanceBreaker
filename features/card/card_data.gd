# CardData.gd
extends Resource
class_name CardData

#── Exposed properties ──────────────────────────────────────────────────────────

@export_enum("Fire", "Water", "Earth", "Air", "Ice", "Light", "Dark")
var element: String = "Fire"

@export_range(1, 4)
var tier: int = 1

@export
var is_hero: bool = false

@export
var archetype: String = ""

@export
var display_name: String = ""

@export var config := [
	# Tier 1
	{
		"name": "peasant",
		"tier": 1,
		"clan": "dragon",
		"combo_sources": null,
		"is_hero": false,
		"combat_types": ["melee"],
		"stats": {
			"health": 1,
			"damage": 1,
		},
		"content": { "name": { "en": "Peasant" } }
	},

	# Tier 2 — first-order evolutions
	{
		"name": "kensei_trainee",
		"tier": 2,
		"clan": "dragon",
		"combo_sources": ["peasant"],
		"is_hero": false,
		"combat_types": ["melee"],
		"stats": {
			"health": 3,
			"damage": 3,
		},
		"content": { "name": { "en": "Kensei Trainee" } }
	},
	{
		"name": "yumiya_cadet",
		"tier": 2,
		"clan": "dragon",
		"combo_sources": ["peasant"],
		"is_hero": false,
		"combat_types": ["archer"],
		"stats": {
			"health": 1,
			"damage": 2,
			"range": 3
		},
		"content": { "name": { "en": "Yumiya Cadet" } }
	},
	{
		"name": "onmyoji_acolyte",
		"tier": 2,
		"clan": "dragon",
		"combo_sources": ["peasant"],
		"is_hero": false,
		"combat_types": ["magic"],
		"stats": {
			"health": 1,
			"damage": 3,
			"range": 2
		},
		"content": { "name": { "en": "Onmyōji Acolyte" } }
	},
	{
		"name": "geisha_healer",
		"tier": 2,
		"clan": "dragon",
		"combo_sources": ["peasant"],
		"is_hero": false,
		"combat_types": ["melee"],
		"stats": {
			"health": 2,
			"damage": 1,
		},
		"content": { "name": { "en": "Geisha Healer" } }
	},

	# Tier 3 — hybrids of primary paths
	{
		"name": "tsurugi_hayabusa",
		"tier": 3,
		"clan": "dragon",
		"combo_sources": ["kensei_trainee", "yumiya_cadet"],
		"is_hero": false,
		"combat_types": ["melee", "archer"],
		"stats": {
			"health": 4,
			"damage": 3,
			"range": 3
		},
		"content": { "name": { "en": "Tsurugi Hayabusa" } }
	},
	{
		"name": "kokyushi",
		"tier": 3,
		"clan": "dragon",
		"combo_sources": ["yumiya_cadet", "onmyoji_acolyte"],
		"is_hero": false,
		"combat_types": ["archer", "magic"],
		"stats": {
			"health": 2,
			"damage": 3,
			"range": 4
		},
		"content": { "name": { "en": "Kōkyūshi" } }
	},
	{
		"name": "maho_kenshi",
		"tier": 3,
		"clan": "dragon",
		"combo_sources": ["kensei_trainee", "onmyoji_acolyte"],
		"is_hero": false,
		"combat_types": ["melee", "magic"],
		"stats": {
			"health": 4,
			"damage": 4,
			"range": 2
		},
		"content": { "name": { "en": "Mahō Kenshi" } }
	},

	# Tier 4 — ultimate of all three primary paths
	{
		"name": "arcane_warlord",
		"tier": 4,
		"clan": "dragon",
		"combo_sources": ["kensei_trainee", "yumiya_cadet", "onmyoji_acolyte"],
		"is_hero": false,
		"combat_types": ["melee", "archer", "magic"],
		"stats": {
			"health": 7,
			"damage": 7,
			"range": 6
		},
		"content": { "name": { "en": "Arcane Warlord" } }
	},

	# Hero cards (always tier 4)
	{
		"name": "hattori_shadowblade",
		"tier": 4,
		"clan": "dragon",
		"combo_sources": null,
		"is_hero": true,
		"combat_types": ["melee", "magic"],
		"effects": [
			{
				"type": "shadow", # stay in shadows for 3 steps
				"count": 3
			}
		],
		"stats": {
			"health": 8,
			"damage": 8,
			"range": 2
		},
		"content": { "name": { "en": "Hattori the Shadowblade" } }
	},
	{
		"name": "kazemaru_stormcaller",
		"tier": 4,
		"clan": "dragon",
		"combo_sources": null,
		"is_hero": true,
		"combat_types": ["archer", "magic"],
		"effects": [
			{
				"type": "electric_field",
			},
			{
				"type": "electric_arrow",
				"chance": 0.25
			},
		],
		"stats": {
			"health": 4,
			"damage": 8,
			"range": 8
		},
		"content": { "name": { "en": "Kazemaru the Stormcaller" } }
	},
	{
		"name": "ryujin_overlord",
		"tier": 4,
		"clan": "dragon",
		"combo_sources": null,
		"is_hero": true,
		"combat_types": ["melee", "archer", "magic"],
		"effects": [
		{
			"type": "berserk"
		}],
		"stats": {
			"health": 12,
			"damage": 6,
			"range": 4
		},
		"content": { "name": { "en": "Ryūjin Overlord" } }
	}
]


#── Setters & Initialization ───────────────────────────────────────────────────

func set_element(value: String) -> void:
	element = value
	_update_from_config()

func set_tier(value: int) -> void:
	tier = clamp(value, 1, 4)
	_update_from_config()

func set_hero(value: bool) -> void:
	is_hero = value
	if is_hero:
		tier = 4
	_update_from_config()

func _init() -> void:
	_update_from_config()


#── Internal helpers ───────────────────────────────────────────────────────────

func _update_from_config() -> void:
	# Filter config entries by current tier and hero-flag
	var candidates = config.filter(func(c):
		return c.tier == tier and c.is_hero == is_hero
	)
	# Randomly pick one
	if candidates.size() > 0:
		var entry = candidates[randi() % candidates.size()]
		archetype = entry.name
		display_name = "%s" % [entry.content.name.en]
	else:
		# Fallback
		archetype = "unknown"
		display_name = "Unknown of %s" % element

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

@export var clan: = "Crane"

@export
var display_name: String = ""

@export var config := [
	#── Crane Clan ────────────────────────────────────────────────────────────

	# Tier 1 — basic Villager
	{
		"name": "villager",
		"tier": 1,
		"clan": "Crane",
		"combo_sources": null,
		"is_hero": false,
		"combat_types": ["melee"],
		"stats": { "health": 1, "damage": 1 },
		"content": { "name": { "en": "Villager" } }
	},

	# Tier 2 — three specializations + healer
	{
		"name": "blade_guard",
		"tier": 2,
		"clan": "Crane",
		"combo_sources": ["villager"],
		"is_hero": false,
		"combat_types": ["melee"],
		"stats": { "health": 3, "damage": 3 },
		"content": { "name": { "en": "Blade Guard" } }
	},
	{
		"name": "sky_archer",
		"tier": 2,
		"clan": "Crane",
		"combo_sources": ["villager"],
		"is_hero": false,
		"combat_types": ["archer"],
		"stats": { "health": 2, "damage": 2, "range": 4 },
		"content": { "name": { "en": "Sky Archer" } }
	},
	{
		"name": "spirit_weaver",
		"tier": 2,
		"clan": "Crane",
		"combo_sources": ["villager"],
		"is_hero": false,
		"combat_types": ["magic"],
		"stats": { "health": 2, "damage": 3, "range": 3 },
		"content": { "name": { "en": "Spirit Weaver" } }
	},
	{
		"name": "geisha_healer",
		"tier": 2,
		"clan": "Crane",
		"combo_sources": ["villager"],
		"is_hero": false,
		"combat_types": ["melee"],
		"stats": { "health": 3, "damage": 1 },
		"content": { "name": { "en": "Geisha Healer" } }
	},

	# Tier 3 — hybrids of each pair
	{
		"name": "blade_archer",
		"tier": 3,
		"clan": "Crane",
		"combo_sources": ["blade_guard", "sky_archer"],
		"is_hero": false,
		"combat_types": ["melee","archer"],
		"stats": { "health": 5, "damage": 4, "range": 4 },
		"content": { "name": { "en": "Blade Archer" } }
	},
	{
		"name": "mystic_blade",
		"tier": 3,
		"clan": "Crane",
		"combo_sources": ["blade_guard", "spirit_weaver"],
		"is_hero": false,
		"combat_types": ["melee","magic"],
		"stats": { "health": 5, "damage": 5, "range": 3 },
		"content": { "name": { "en": "Mystic Blade" } }
	},
	{
		"name": "arcane_ranger",
		"tier": 3,
		"clan": "Crane",
		"combo_sources": ["sky_archer", "spirit_weaver"],
		"is_hero": false,
		"combat_types": ["archer","magic"],
		"stats": { "health": 4, "damage": 4, "range": 5 },
		"content": { "name": { "en": "Arcane Ranger" } }
	},

	# Tier 4 — ultimate of all three
	{
		"name": "grand_warlord",
		"tier": 4,
		"clan": "Crane",
		"combo_sources": ["blade_guard","sky_archer","spirit_weaver"],
		"is_hero": false,
		"combat_types": ["melee","archer","magic"],
		"stats": { "health": 8, "damage": 7, "range": 6 },
		"content": { "name": { "en": "Grand Warlord" } }
	},

	# Heroes — tier 4, special effects
	{
		"name": "crane_samurai_champion",
		"tier": 4,
		"clan": "Crane",
		"combo_sources": null,
		"is_hero": true,
		"combat_types": ["melee"],
		"effects": [{ "type": "focus_strike", "bonus": 2 }],
		"stats": { "health": 10, "damage": 8 },
		"content": { "name": { "en": "Samurai Champion" } }
	},
	{
		"name": "crane_moon_priestess",
		"tier": 4,
		"clan": "Crane",
		"combo_sources": null,
		"is_hero": true,
		"combat_types": ["magic"],
		"effects": [{ "type": "healing_wave", "radius": 2 }],
		"stats": { "health": 6, "damage": 6, "range": 6 },
		"content": { "name": { "en": "Moon Priestess" } }
	},
	{
		"name": "crane_shadow_blade",
		"tier": 4,
		"clan": "Crane",
		"combo_sources": null,
		"is_hero": true,
		"combat_types": ["melee","archer"],
		"effects": [{ "type": "shadow_step", "stun": 1 }],
		"stats": { "health": 9, "damage": 7, "range": 4 },
		"content": { "name": { "en": "Shadow Blade" } }
	},
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

func get_entry_by_name(name: String) -> Dictionary:
	for e in config:
		if e.name == name:
			return e
	return {}

# Return all valid evolutions from current archetype along a given combat path
func get_evolutions(path_type: String) -> Array:
	return config.filter(func(c):
		return c.combo_sources != null \
			and c.combo_sources.has(archetype) \
			and c.combat_types.has(path_type) \
			and c.clan == clan
	)

# Apply one full entry to this CardData
func apply_entry(entry: Dictionary) -> void:
	tier         = entry.tier
	is_hero      = entry.is_hero
	archetype    = entry.name
	display_name = entry.content.name.en
	# If you want to copy stats/effects:
	# stats   = entry.stats.duplicate()
	# effects = entry.effects.duplicate() if entry.has("effects") else []
	
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

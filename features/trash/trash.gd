extends Node2D

@onready var label: Label = $Label

@export var discarded_cards = 0

func _ready() -> void:
	label.text = "0"


func on_card_discard():
	discarded_cards += 1
	label.text = str(discarded_cards)

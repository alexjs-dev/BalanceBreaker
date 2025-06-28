extends Node2D

@onready var label: Label = $Label
@onready var player_hand_reference: Node2D = $"../PlayerHand"
@onready var trash_place_sound: AudioStreamPlayer2D = $"../CardManager/TrashPlaceSound"

@export var discarded_cards = 0

func _ready() -> void:
	label.text = "0"


func on_card_discard():
	discarded_cards += 1
	label.text = str(discarded_cards)


func put_card_to_trash(card):
	if card == null:
		return
	player_hand_reference.remove_card_from_hand(card)
	on_card_discard()
	trash_place_sound.play()
	card.queue_free()

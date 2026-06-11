class_name LootComponent
extends Node

## Define a chance de drop de itens de um inimigo.

@export var drop_chance: float = 0.3         ## 0.0 a 1.0
@export var possible_drops: Array[ItemData] = []

func roll_drops() -> Array[ItemData]:
	var dropped: Array[ItemData] = []
	if randf() > drop_chance:
		return dropped
	if possible_drops.is_empty():
		return dropped
	dropped.append(possible_drops[randi() % possible_drops.size()])
	return dropped

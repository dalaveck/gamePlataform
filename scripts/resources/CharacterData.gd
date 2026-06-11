class_name CharacterData
extends Resource

enum CharacterClass { WARRIOR, CLERIC, ARCHER }

@export var character_id: String = ""
@export var character_name: String = ""
@export var character_class: CharacterClass = CharacterClass.WARRIOR
@export var level: int = 1
@export var experience: int = 0
@export var experience_to_next: int = 100
@export var attribute_points: int = 0

# ─── Atributos base ────────────────────────────────────────
@export var strength: int = 1       ## Aumenta ATK físico
@export var skill: int = 1          ## Aumenta SP máximo e agilidade
@export var constitution: int = 1   ## Aumenta HP máximo e defesa
@export var spirit: int = 1         ## Aumenta MP máximo e poder mágico

# ─── Equipamentos ──────────────────────────────────────────
@export var equipped_weapon: ItemData = null
@export var equipped_armor: ItemData = null
@export var equipped_accessory: ItemData = null

func get_class_name_string() -> String:
	match character_class:
		CharacterClass.WARRIOR: return "Guerreiro"
		CharacterClass.CLERIC:  return "Clérigo"
		CharacterClass.ARCHER:  return "Arqueiro"
	return "Desconhecido"

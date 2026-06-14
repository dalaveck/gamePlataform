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
@export var strength: int = 1
@export var skill: int = 1
@export var constitution: int = 1
@export var spirit: int = 1

# ─── Slots de equipamento ──────────────────────────────────
@export var equipped_weapon: ItemData = null
@export var equipped_armor: ItemData = null
@export var equipped_helmet: ItemData = null
@export var equipped_boots: ItemData = null
@export var equipped_bracelet: ItemData = null
@export var equipped_necklace: ItemData = null
@export var equipped_ring: ItemData = null

## IDs de itens no inventário (não equipados)
@export var inventory: Array[String] = []

func get_class_name_string() -> String:
	match character_class:
		CharacterClass.WARRIOR: return "Guerreiro"
		CharacterClass.CLERIC:  return "Clérigo"
		CharacterClass.ARCHER:  return "Arqueiro"
	return "Desconhecido"

func get_equipped_in_slot(slot: ItemData.ItemType) -> ItemData:
	match slot:
		ItemData.ItemType.WEAPON:   return equipped_weapon
		ItemData.ItemType.ARMOR:    return equipped_armor
		ItemData.ItemType.HELMET:   return equipped_helmet
		ItemData.ItemType.BOOTS:    return equipped_boots
		ItemData.ItemType.BRACELET: return equipped_bracelet
		ItemData.ItemType.NECKLACE: return equipped_necklace
		ItemData.ItemType.RING:     return equipped_ring
	return null

func set_equipped_in_slot(item: ItemData) -> void:
	match item.item_type:
		ItemData.ItemType.WEAPON:   equipped_weapon   = item
		ItemData.ItemType.ARMOR:    equipped_armor    = item
		ItemData.ItemType.HELMET:   equipped_helmet   = item
		ItemData.ItemType.BOOTS:    equipped_boots    = item
		ItemData.ItemType.BRACELET: equipped_bracelet = item
		ItemData.ItemType.NECKLACE: equipped_necklace = item
		ItemData.ItemType.RING:     equipped_ring     = item

func clear_equipped_in_slot(slot: ItemData.ItemType) -> ItemData:
	var old := get_equipped_in_slot(slot)
	match slot:
		ItemData.ItemType.WEAPON:   equipped_weapon   = null
		ItemData.ItemType.ARMOR:    equipped_armor    = null
		ItemData.ItemType.HELMET:   equipped_helmet   = null
		ItemData.ItemType.BOOTS:    equipped_boots    = null
		ItemData.ItemType.BRACELET: equipped_bracelet = null
		ItemData.ItemType.NECKLACE: equipped_necklace = null
		ItemData.ItemType.RING:     equipped_ring     = null
	return old

func all_equipment_slots() -> Array[ItemData]:
	return [equipped_weapon, equipped_armor, equipped_helmet,
			equipped_boots, equipped_bracelet, equipped_necklace, equipped_ring]

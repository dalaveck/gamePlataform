class_name ItemData
extends Resource

enum ItemType { WEAPON, ARMOR, ACCESSORY, CONSUMABLE }
enum ClassRestriction { ALL, WARRIOR, CLERIC, ARCHER }

@export var item_id: String = ""
@export var item_name: String = ""
@export var item_type: ItemType = ItemType.WEAPON
@export var class_restriction: ClassRestriction = ClassRestriction.ALL
@export var price: int = 0
@export var description: String = ""
@export var icon: Texture2D = null

# ─── Bônus de atributos ────────────────────────────────────
@export var bonus_strength: int = 0
@export var bonus_skill: int = 0
@export var bonus_constitution: int = 0
@export var bonus_spirit: int = 0

# ─── Bônus de stats derivados ──────────────────────────────
@export var bonus_atk: int = 0
@export var bonus_defense: int = 0
@export var bonus_magic_power: int = 0

func can_be_equipped_by(character_class: CharacterData.CharacterClass) -> bool:
	match class_restriction:
		ClassRestriction.ALL:     return true
		ClassRestriction.WARRIOR: return character_class == CharacterData.CharacterClass.WARRIOR
		ClassRestriction.CLERIC:  return character_class == CharacterData.CharacterClass.CLERIC
		ClassRestriction.ARCHER:  return character_class == CharacterData.CharacterClass.ARCHER
	return false

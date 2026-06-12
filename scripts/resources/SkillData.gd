class_name SkillData
extends Resource

enum SkillType { PHYSICAL, MAGICAL, SUPPORT }
enum ResourceCost { SP, MP, NONE }

@export var skill_id: String = ""
@export var skill_name: String = ""
@export var skill_type: SkillType = SkillType.PHYSICAL
@export var cost_type: ResourceCost = ResourceCost.SP
@export var cost_amount: int = 0
@export var cost_type_2: ResourceCost = ResourceCost.NONE
@export var cost_amount_2: int = 0
@export var cooldown: float = 1.0
@export var damage_multiplier: float = 1.0
@export var description: String = ""
@export var icon: Texture2D = null
@export var projectile_scene: PackedScene = null

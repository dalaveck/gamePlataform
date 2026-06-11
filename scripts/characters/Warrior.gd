class_name Warrior
extends BaseCharacter

## Guerreiro: melee, depende de STR e CON.
## Habilidades usam SP. Ataques com espada em hitbox próxima.

@onready var sword_hitbox: Area2D = %SwordHitbox

const SLASH_SP_COST: int   = 0   ## Ataque básico é grátis
const WHIRLWIND_SP_COST: int = 35
const SHIELD_BASH_SP_COST: int = 25

var _whirlwind_data: SkillData = null
var _shield_bash_data: SkillData = null

func _ready() -> void:
	super._ready()
	_setup_skills()

func _setup_skills() -> void:
	_whirlwind_data = SkillData.new()
	_whirlwind_data.skill_id      = "warrior_whirlwind"
	_whirlwind_data.skill_name    = "Redemoinho"
	_whirlwind_data.cost_type     = SkillData.ResourceCost.SP
	_whirlwind_data.cost_amount   = WHIRLWIND_SP_COST
	_whirlwind_data.cooldown      = 4.0
	_whirlwind_data.damage_multiplier = 1.8

	_shield_bash_data = SkillData.new()
	_shield_bash_data.skill_id    = "warrior_shield_bash"
	_shield_bash_data.skill_name  = "Golpe de Escudo"
	_shield_bash_data.cost_type   = SkillData.ResourceCost.SP
	_shield_bash_data.cost_amount = SHIELD_BASH_SP_COST
	_shield_bash_data.cooldown    = 3.0
	_shield_bash_data.damage_multiplier = 1.2

func _perform_attack() -> void:
	if not combat.try_attack():
		return
	if animation:
		animation.play("attack")
	# Ativa hitbox da espada por um frame
	if sword_hitbox:
		sword_hitbox.monitoring = true
		await get_tree().create_timer(0.1).timeout
		sword_hitbox.monitoring = false

func _use_skill_1() -> void:
	## Redemoinho: dano em área ao redor
	if not combat.try_use_skill(_whirlwind_data):
		return
	if animation:
		animation.play("skill_whirlwind")

func _use_skill_2() -> void:
	## Golpe de Escudo: empurra inimigo e atordoa brevemente
	if not combat.try_use_skill(_shield_bash_data):
		return
	if animation:
		animation.play("skill_shield_bash")

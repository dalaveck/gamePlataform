class_name Warrior
extends BaseCharacter

## Guerreiro: melee, depende de STR e CON.
## Habilidades usam SP. Ataques com espada em hitbox próxima.

@onready var sword_hitbox: Area2D = %SwordHitbox

const WHIRLWIND_SP_COST: int = 35
const SHIELD_BASH_SP_COST: int = 25
const WHIRLWIND_RADIUS: float = 90.0
const SHIELD_BASH_RANGE: float = 60.0

var _whirlwind_data: SkillData = null
var _shield_bash_data: SkillData = null
var _current_damage_multiplier: float = 1.0

func _ready() -> void:
	super._ready()
	_setup_skills()
	sword_hitbox.body_entered.connect(_on_sword_hit)

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
	_current_damage_multiplier = 1.0
	_activate_sword_hitbox()

func _activate_sword_hitbox() -> void:
	sword_hitbox.position.x = abs(sword_hitbox.position.x) * movement.facing_direction
	sword_hitbox.monitoring = true
	await get_tree().create_timer(0.12).timeout
	sword_hitbox.monitoring = false

func _on_sword_hit(body: Node2D) -> void:
	if body is BaseEnemy:
		var damage := int(stats.atk * _current_damage_multiplier)
		(body as BaseEnemy).request_damage(damage, peer_id)

func _use_skill_1() -> void:
	## Redemoinho: dano em área ao redor
	if not combat.try_use_skill(_whirlwind_data):
		return
	if animation:
		animation.play("skill_whirlwind")
	var damage := int(stats.atk * _whirlwind_data.damage_multiplier)
	for enemy: Node2D in get_tree().get_nodes_in_group("enemies"):
		if global_position.distance_to(enemy.global_position) <= WHIRLWIND_RADIUS:
			(enemy as BaseEnemy).request_damage(damage, peer_id)

func _use_skill_2() -> void:
	## Golpe de Escudo: dano forte nos inimigos à frente
	if not combat.try_use_skill(_shield_bash_data):
		return
	if animation:
		animation.play("skill_shield_bash")
	var damage := int(stats.atk * _shield_bash_data.damage_multiplier)
	for enemy: Node2D in get_tree().get_nodes_in_group("enemies"):
		var to_enemy := enemy.global_position - global_position
		var in_front = sign(to_enemy.x) == movement.facing_direction
		if in_front and to_enemy.length() <= SHIELD_BASH_RANGE:
			(enemy as BaseEnemy).request_damage(damage, peer_id)

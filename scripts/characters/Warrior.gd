class_name Warrior
extends BaseCharacter

## Guerreiro: melee, depende de STR e CON.
## Skill 1: Ataque Giratório (ambos os lados) — SP + MP
## Skill 2: Super Ataque 3× dano          — SP + MP
## Skill 3: Buff Proteção 10s 50% redução  — apenas MP

@onready var sword_hitbox: Area2D = %SwordHitbox

const ATTACK_SP_COST  : int   = 5
const SPIN_RADIUS     : float = 90.0

# ─── Knockback ─────────────────────────────────────────────
const COMMON_KNOCKBACK : float = 340.0  ## ataque comum: empurra forte os comuns
const SUPER_KNOCKBACK  : float = 230.0  ## super ataque: base menor...
const SUPER_KB_PENETR  : float = 0.25   ## ...porém ignora 75% da resistência (bosses)
const SPIN_KNOCKBACK   : float = 260.0  ## giratório: empurrão radial

var _spin_data   : SkillData = null
var _strike_data : SkillData = null
var _protect_data: SkillData = null

var _current_dmg_mult: float = 1.0
var _current_knockback: float = COMMON_KNOCKBACK
var _current_kb_penetr: float = 1.0

func _ready() -> void:
	super._ready()
	_setup_skills()
	sword_hitbox.body_entered.connect(_on_sword_hit)

func _setup_skills() -> void:
	_spin_data              = SkillData.new()
	_spin_data.skill_id     = "warrior_spin"
	_spin_data.skill_name   = "Ataque Giratório"
	_spin_data.cost_type    = SkillData.ResourceCost.SP
	_spin_data.cost_amount  = 15
	_spin_data.cost_type_2  = SkillData.ResourceCost.MP
	_spin_data.cost_amount_2 = 10
	_spin_data.cooldown     = 5.0
	_spin_data.damage_multiplier = 1.5

	_strike_data              = SkillData.new()
	_strike_data.skill_id     = "warrior_power_strike"
	_strike_data.skill_name   = "Super Ataque"
	_strike_data.cost_type    = SkillData.ResourceCost.SP
	_strike_data.cost_amount  = 20
	_strike_data.cost_type_2  = SkillData.ResourceCost.MP
	_strike_data.cost_amount_2 = 15
	_strike_data.cooldown     = 6.0
	_strike_data.damage_multiplier = 3.0

	_protect_data              = SkillData.new()
	_protect_data.skill_id     = "warrior_protection"
	_protect_data.skill_name   = "Proteção"
	_protect_data.cost_type    = SkillData.ResourceCost.MP
	_protect_data.cost_amount  = 30
	_protect_data.cooldown     = 15.0

func get_skill_datas() -> Array:
	return [_spin_data, _strike_data, _protect_data]

# ─── Ataque básico ─────────────────────────────────────────
func _perform_attack() -> void:
	if not combat.try_attack(SkillData.ResourceCost.SP, ATTACK_SP_COST):
		return
	if animation:
		animation.play("attack")
	_current_dmg_mult  = 1.0
	_current_knockback = COMMON_KNOCKBACK
	_current_kb_penetr = 1.0
	_activate_sword_hitbox()

func _activate_sword_hitbox() -> void:
	sword_hitbox.position.x = abs(sword_hitbox.position.x) * movement.facing_direction
	sword_hitbox.monitoring = true
	await get_tree().create_timer(0.12).timeout
	sword_hitbox.monitoring = false

func _on_sword_hit(body: Node2D) -> void:
	if body is BaseEnemy:
		var enemy := body as BaseEnemy
		var damage := int(stats.atk * _current_dmg_mult)
		enemy.request_damage(damage, peer_id)
		var dir := Vector2(movement.facing_direction, -0.2).normalized()
		enemy.request_knockback(dir, _current_knockback, _current_kb_penetr)

# ─── Skill 1: Ataque Giratório ─────────────────────────────
func _use_skill_1() -> bool:
	if not combat.try_use_skill(_spin_data):
		return false
	if animation:
		animation.play("skill_whirlwind")
	var dmg := int(stats.atk * _spin_data.damage_multiplier)
	# Acerta ambos os lados (360°) dentro do raio e empurra radialmente
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_pos := (enemy as Node2D).global_position
		if global_position.distance_to(enemy_pos) <= SPIN_RADIUS:
			(enemy as BaseEnemy).request_damage(dmg, peer_id)
			var dir := (enemy_pos - global_position).normalized()
			if dir == Vector2.ZERO:
				dir = Vector2(movement.facing_direction, 0.0)
			(enemy as BaseEnemy).request_knockback(dir, SPIN_KNOCKBACK)
	return true

# ─── Skill 2: Super Ataque 3× ──────────────────────────────
func _use_skill_2() -> bool:
	if not combat.try_use_skill(_strike_data):
		return false
	if animation:
		animation.play("skill_shield_bash")
	_current_dmg_mult  = _strike_data.damage_multiplier
	_current_knockback = SUPER_KNOCKBACK
	_current_kb_penetr = SUPER_KB_PENETR
	_activate_sword_hitbox()
	return true

# ─── Skill 3: Buff Proteção ────────────────────────────────
func _use_skill_3() -> bool:
	if not combat.try_use_skill(_protect_data):
		return false
	if animation:
		animation.play("skill_shield_bash")
	_broadcast_protection.rpc()
	return true

@rpc("call_local", "reliable")
func _broadcast_protection() -> void:
	apply_protection_buff(0.5, 10.0)

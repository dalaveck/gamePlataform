class_name Cleric
extends BaseCharacter

## Clérigo: magias de cura e ofensivas, depende de SPI.
## Skill 1: Cura Maior (+30% HP, +50% SP)     — apenas MP
## Skill 2: Bola de Fogo (3× poder, vermelha)  — apenas MP
## Skill 3: Maldição Imperdoável (ricocheteia) — apenas MP

@onready var spell_spawn_point: Marker2D = %SpellSpawnPoint

@export var holy_bolt_scene  : PackedScene = null
@export var fireball_scene   : PackedScene = null
@export var cursed_bolt_scene: PackedScene = null

const ATTACK_MP_COST: int = 5
const HEAL_RADIUS   : float = 200.0  ## alcance da cura em aliados no coop
const HEAL_HP_PCT   : float = 0.30
const HEAL_SP_PCT   : float = 0.50

var _greater_heal_data: SkillData = null
var _fireball_data    : SkillData = null
var _curse_data       : SkillData = null

func _ready() -> void:
	super._ready()
	_setup_skills()

func _setup_skills() -> void:
	_greater_heal_data              = SkillData.new()
	_greater_heal_data.skill_id     = "cleric_greater_heal"
	_greater_heal_data.skill_name   = "Cura Maior"
	_greater_heal_data.cost_type    = SkillData.ResourceCost.MP
	_greater_heal_data.cost_amount  = 40
	_greater_heal_data.cooldown     = 8.0

	_fireball_data              = SkillData.new()
	_fireball_data.skill_id     = "cleric_fireball"
	_fireball_data.skill_name   = "Bola de Fogo"
	_fireball_data.cost_type    = SkillData.ResourceCost.MP
	_fireball_data.cost_amount  = 35
	_fireball_data.cooldown     = 5.0
	_fireball_data.damage_multiplier = 3.0

	_curse_data              = SkillData.new()
	_curse_data.skill_id     = "cleric_curse"
	_curse_data.skill_name   = "Maldição"
	_curse_data.cost_type    = SkillData.ResourceCost.MP
	_curse_data.cost_amount  = 45
	_curse_data.cooldown     = 10.0
	_curse_data.damage_multiplier = 1.2

func get_skill_datas() -> Array:
	return [_greater_heal_data, _fireball_data, _curse_data]

# ─── Ataque básico: raio sagrado ───────────────────────────
func _perform_attack() -> void:
	if not combat.try_attack(SkillData.ResourceCost.MP, ATTACK_MP_COST):
		return
	if animation:
		animation.play("attack")
	_spawn_holy_bolt(1.0)

# ─── Skill 1: Cura Maior ───────────────────────────────────
func _use_skill_1() -> bool:
	if not combat.try_use_skill(_greater_heal_data):
		return false
	if animation:
		animation.play("skill_heal")
	# Cura o próprio clérigo e todos os aliados dentro do raio (coop).
	# Cada alvo recupera a % do próprio máximo (calculado em cada peer).
	for player in get_tree().get_nodes_in_group("players"):
		if global_position.distance_to((player as Node2D).global_position) <= HEAL_RADIUS:
			(player as BaseCharacter).receive_greater_heal.rpc(HEAL_HP_PCT, HEAL_SP_PCT)
	return true

# ─── Skill 2: Bola de Fogo ─────────────────────────────────
func _use_skill_2() -> bool:
	if not combat.try_use_skill(_fireball_data):
		return false
	if animation:
		animation.play("skill_holy_bolt")
	_spawn_fireball()
	return true

# ─── Skill 3: Maldição Imperdoável ─────────────────────────
func _use_skill_3() -> bool:
	if not combat.try_use_skill(_curse_data):
		return false
	if animation:
		animation.play("skill_holy_bolt")
	_spawn_cursed_bolt()
	return true

# ─── Spawn helpers ─────────────────────────────────────────
func _spawn_holy_bolt(dmg_mult: float) -> void:
	if holy_bolt_scene == null:
		return
	var bolt: BouncingHolyBolt = holy_bolt_scene.instantiate()
	get_tree().current_scene.add_child(bolt)
	bolt.global_position = spell_spawn_point.global_position
	var dmg := int((stats.atk * 0.5 + stats.magic_power) * dmg_mult)
	bolt.setup(_get_aim_direction(), dmg, peer_id)

func _spawn_fireball() -> void:
	if fireball_scene == null:
		return
	var fb: Projectile = fireball_scene.instantiate()
	get_tree().current_scene.add_child(fb)
	fb.global_position = spell_spawn_point.global_position
	var dmg := int((stats.atk * 0.5 + stats.magic_power) * _fireball_data.damage_multiplier)
	fb.setup(_get_aim_direction(), dmg, peer_id)

func _spawn_cursed_bolt() -> void:
	if cursed_bolt_scene == null:
		return
	var cb: CursedBolt = cursed_bolt_scene.instantiate()
	get_tree().current_scene.add_child(cb)
	cb.global_position = spell_spawn_point.global_position
	var dmg := int((stats.atk * 0.5 + stats.magic_power) * _curse_data.damage_multiplier)
	cb.setup(_get_aim_direction(), dmg, peer_id)

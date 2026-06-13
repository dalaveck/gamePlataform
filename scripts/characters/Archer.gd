class_name Archer
extends BaseCharacter

## Arqueiro: ranged físico, depende de SKL e STR.
## Skill 1: Flechas Múltiplas (5 rápidas)   — SP + MP
## Skill 2: Flecha Avassaladora (atravessa)  — SP + MP
## Skill 3: Flecha Explosiva (dano em área)  — SP + MP

@onready var arrow_spawn_point: Marker2D = %ArrowSpawnPoint

@export var arrow_scene             : PackedScene = null
@export var penetrating_arrow_scene : PackedScene = null
@export var explosive_arrow_scene   : PackedScene = null

const ATTACK_SP_COST   : int   = 8
const MULTI_ARROW_COUNT: int   = 5
const MULTI_SPREAD_DEG : float = 7.0   ## ângulo entre cada flecha do multi-tiro

var _multi_data    : SkillData = null
var _penetr_data   : SkillData = null
var _explosive_data: SkillData = null

func _ready() -> void:
	super._ready()
	_setup_skills()

func _setup_skills() -> void:
	_multi_data              = SkillData.new()
	_multi_data.skill_id     = "archer_multishot"
	_multi_data.skill_name   = "Flechas Múltiplas"
	_multi_data.cost_type    = SkillData.ResourceCost.SP
	_multi_data.cost_amount  = 20
	_multi_data.cost_type_2  = SkillData.ResourceCost.MP
	_multi_data.cost_amount_2 = 10
	_multi_data.cooldown     = 4.0
	_multi_data.damage_multiplier = 0.75

	_penetr_data              = SkillData.new()
	_penetr_data.skill_id     = "archer_penetrating"
	_penetr_data.skill_name   = "Flecha Avassaladora"
	_penetr_data.cost_type    = SkillData.ResourceCost.SP
	_penetr_data.cost_amount  = 25
	_penetr_data.cost_type_2  = SkillData.ResourceCost.MP
	_penetr_data.cost_amount_2 = 15
	_penetr_data.cooldown     = 5.0
	_penetr_data.damage_multiplier = 1.8

	_explosive_data              = SkillData.new()
	_explosive_data.skill_id     = "archer_explosive"
	_explosive_data.skill_name   = "Flecha Explosiva"
	_explosive_data.cost_type    = SkillData.ResourceCost.SP
	_explosive_data.cost_amount  = 20
	_explosive_data.cost_type_2  = SkillData.ResourceCost.MP
	_explosive_data.cost_amount_2 = 20
	_explosive_data.cooldown     = 6.0
	_explosive_data.damage_multiplier = 1.4

func get_skill_datas() -> Array:
	return [_multi_data, _penetr_data, _explosive_data]

# ─── Ataque básico ─────────────────────────────────────────
func _perform_attack() -> void:
	if not combat.try_attack(SkillData.ResourceCost.SP, ATTACK_SP_COST):
		return
	if animation:
		animation.play("attack")
	_fire_arrow(arrow_scene, 1.0, 0.0)

# ─── Skill 1: Flechas Múltiplas (5 em leque, rápidas) ─────
func _use_skill_1() -> bool:
	if not combat.try_use_skill(_multi_data):
		return false
	if animation:
		animation.play("skill_multishot")
	VFX.special(arrow_spawn_point.global_position, "multishot")
	var total   := MULTI_ARROW_COUNT
	var half    := (total - 1) / 2.0
	var aim_dir := _get_aim_direction()
	for i in total:
		var angle_off := (i - half) * MULTI_SPREAD_DEG
		var rotated   := aim_dir.rotated(deg_to_rad(angle_off))
		var delay     := i * 0.08
		_fire_arrow_delayed(arrow_scene, _multi_data.damage_multiplier, rotated, delay)
	return true

func _fire_arrow_delayed(scene: PackedScene, dmg_mult: float, dir: Vector2, delay: float) -> void:
	if delay <= 0.0:
		_fire_arrow_dir(scene, dmg_mult, dir)
		return
	await get_tree().create_timer(delay).timeout
	if is_inside_tree():
		_fire_arrow_dir(scene, dmg_mult, dir)

# ─── Skill 2: Flecha Avassaladora ─────────────────────────
func _use_skill_2() -> bool:
	if not combat.try_use_skill(_penetr_data):
		return false
	if animation:
		animation.play("skill_rain_arrows")
	VFX.special(arrow_spawn_point.global_position, "penetrate")
	_fire_arrow(penetrating_arrow_scene, _penetr_data.damage_multiplier, 0.0)
	return true

# ─── Skill 3: Flecha Explosiva ─────────────────────────────
func _use_skill_3() -> bool:
	if not combat.try_use_skill(_explosive_data):
		return false
	if animation:
		animation.play("skill_rain_arrows")
	_fire_arrow(explosive_arrow_scene, _explosive_data.damage_multiplier, 0.0)
	return true

# ─── Helpers de disparo ───────────────────────────────────
func _fire_arrow(scene: PackedScene, dmg_mult: float, angle_off_deg: float) -> void:
	if scene == null:
		return
	var aim := _get_aim_direction().rotated(deg_to_rad(angle_off_deg))
	_fire_arrow_dir(scene, dmg_mult, aim)

func _fire_arrow_dir(scene: PackedScene, dmg_mult: float, dir: Vector2) -> void:
	if scene == null:
		return
	var arrow: Projectile = scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = arrow_spawn_point.global_position
	arrow.setup(dir, int(stats.atk * dmg_mult), peer_id)

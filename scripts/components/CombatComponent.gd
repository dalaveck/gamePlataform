class_name CombatComponent
extends Node

signal attack_performed(atk_value: int)
signal skill_used(skill_data: SkillData)

var _stats: StatsComponent
var _attack_cooldown: float = 0.0
var _skill_cooldowns: Dictionary = {}  ## skill_id -> tempo restante

const BASE_ATTACK_COOLDOWN: float = 0.5

func setup(stats: StatsComponent) -> void:
	_stats = stats

func _process(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta
	for key: String in _skill_cooldowns.keys():
		_skill_cooldowns[key] = max(0.0, _skill_cooldowns[key] - delta)

func try_attack(cost_type: SkillData.ResourceCost = SkillData.ResourceCost.NONE, cost_amount: int = 0) -> bool:
	if _attack_cooldown > 0.0:
		return false
	match cost_type:
		SkillData.ResourceCost.SP:
			if not _stats.consume_sp(cost_amount):
				return false
		SkillData.ResourceCost.MP:
			if not _stats.consume_mp(cost_amount):
				return false
	_attack_cooldown = BASE_ATTACK_COOLDOWN
	attack_performed.emit(_stats.atk)
	return true

func try_use_skill(skill_data: SkillData) -> bool:
	if _is_skill_on_cooldown(skill_data.skill_id):
		return false
	# Agrega custo por tipo (evita consumir mais do que o disponível)
	var total_sp := 0
	var total_mp := 0
	if skill_data.cost_type == SkillData.ResourceCost.SP:
		total_sp += skill_data.cost_amount
	elif skill_data.cost_type == SkillData.ResourceCost.MP:
		total_mp += skill_data.cost_amount
	if skill_data.cost_type_2 == SkillData.ResourceCost.SP:
		total_sp += skill_data.cost_amount_2
	elif skill_data.cost_type_2 == SkillData.ResourceCost.MP:
		total_mp += skill_data.cost_amount_2
	# Verifica
	if total_sp > 0 and _stats.current_sp < total_sp:
		return false
	if total_mp > 0 and _stats.current_mp < total_mp:
		return false
	# Consome
	if total_sp > 0:
		_stats.consume_sp(total_sp)
	if total_mp > 0:
		_stats.consume_mp(total_mp)
	_skill_cooldowns[skill_data.skill_id] = skill_data.cooldown
	skill_used.emit(skill_data)
	return true

func _is_skill_on_cooldown(skill_id: String) -> bool:
	return _skill_cooldowns.get(skill_id, 0.0) > 0.0

func get_skill_cooldown_ratio(skill_id: String) -> float:
	return _skill_cooldowns.get(skill_id, 0.0)

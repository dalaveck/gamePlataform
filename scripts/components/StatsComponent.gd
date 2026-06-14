class_name StatsComponent
extends Node

signal hp_changed(current: int, maximum: int)
signal mp_changed(current: int, maximum: int)
signal sp_changed(current: int, maximum: int)
signal stats_recalculated
signal died

# ─── Atributos (vindos do CharacterData) ───────────────────
var strength: int = 1
var skill: int = 1
var constitution: int = 1
var spirit: int = 1

# ─── Stats derivados ───────────────────────────────────────
var max_hp: int = 0
var max_mp: int = 0
var max_sp: int = 0
var atk: int = 0
var defense: int = 0
var magic_power: int = 0
var agility: float = 1.0

# ─── Stats atuais ──────────────────────────────────────────
var current_hp: int = 0
var current_mp: int = 0
var current_sp: int = 0

# ─── Regeneração (só ocorre longe de inimigos) ─────────────
const HP_REGEN_RATE: float = 5.0
const SP_REGEN_RATE: float = 10.0
const MP_REGEN_RATE: float = 2.0

var regen_enabled: bool = true

var _hp_regen_timer: float = 0.0
var _sp_regen_timer: float = 0.0
var _mp_regen_timer: float = 0.0

func _process(delta: float) -> void:
	if not regen_enabled:
		return
	_regenerate_hp(delta)
	_regenerate_sp(delta)
	_regenerate_mp(delta)

func recalculate_from(data: CharacterData) -> void:
	strength     = data.strength
	skill        = data.skill
	constitution = data.constitution
	spirit       = data.spirit
	_apply_equipment_bonuses(data)
	_derive_stats()
	current_hp = max_hp
	current_mp = max_mp
	current_sp = max_sp
	stats_recalculated.emit()
	hp_changed.emit(current_hp, max_hp)
	mp_changed.emit(current_mp, max_mp)
	sp_changed.emit(current_sp, max_sp)

func _derive_stats() -> void:
	max_hp      = 100 + (constitution * 20)
	defense     = 5   + (constitution * 3)
	max_mp      = 50  + (spirit * 15)
	magic_power = spirit * 5
	max_sp      = 80  + (skill * 10)
	agility     = 1.0 + (skill * 0.05)
	atk         = 10  + (strength * 5)

func _apply_equipment_bonuses(data: CharacterData) -> void:
	for item: ItemData in data.all_equipment_slots():
		if item == null:
			continue
		strength     += item.bonus_strength
		skill        += item.bonus_skill
		constitution += item.bonus_constitution
		spirit       += item.bonus_spirit
		atk          += item.bonus_atk
		defense      += item.bonus_defense
		magic_power  += item.bonus_magic_power

# ─── Dano e Cura ───────────────────────────────────────────
func take_damage(amount: int) -> void:
	var mitigated = max(1, amount - defense)
	current_hp = max(0, current_hp - mitigated)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		died.emit()

func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)
	hp_changed.emit(current_hp, max_hp)

func consume_sp(amount: int) -> bool:
	if current_sp < amount:
		return false
	current_sp -= amount
	sp_changed.emit(current_sp, max_sp)
	return true

func consume_mp(amount: int) -> bool:
	if current_mp < amount:
		return false
	current_mp -= amount
	mp_changed.emit(current_mp, max_mp)
	return true

func restore_sp(amount: int) -> void:
	current_sp = min(max_sp, current_sp + amount)
	sp_changed.emit(current_sp, max_sp)

func restore_mp(amount: int) -> void:
	current_mp = min(max_mp, current_mp + amount)
	mp_changed.emit(current_mp, max_mp)

func _regenerate_hp(delta: float) -> void:
	if current_hp <= 0 or current_hp >= max_hp:
		return
	_hp_regen_timer += delta
	if _hp_regen_timer >= 1.0:
		_hp_regen_timer = 0.0
		current_hp = min(max_hp, current_hp + int(HP_REGEN_RATE))
		hp_changed.emit(current_hp, max_hp)

func _regenerate_sp(delta: float) -> void:
	if current_sp >= max_sp:
		return
	_sp_regen_timer += delta
	if _sp_regen_timer >= 1.0:
		_sp_regen_timer = 0.0
		current_sp = min(max_sp, current_sp + int(SP_REGEN_RATE))
		sp_changed.emit(current_sp, max_sp)

func _regenerate_mp(delta: float) -> void:
	if current_mp >= max_mp:
		return
	_mp_regen_timer += delta
	if _mp_regen_timer >= 1.0:
		_mp_regen_timer = 0.0
		current_mp = min(max_mp, current_mp + int(MP_REGEN_RATE))
		mp_changed.emit(current_mp, max_mp)

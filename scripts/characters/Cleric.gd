class_name Cleric
extends BaseCharacter

## Clérigo: magias de cura e ofensivas, depende de SPI.
## Habilidades usam MP.

@onready var spell_spawn_point: Marker2D = %SpellSpawnPoint

var _heal_spell_data: SkillData = null
var _holy_bolt_data: SkillData  = null

func _ready() -> void:
	super._ready()
	_setup_skills()

func _setup_skills() -> void:
	_heal_spell_data = SkillData.new()
	_heal_spell_data.skill_id    = "cleric_heal"
	_heal_spell_data.skill_name  = "Cura Sagrada"
	_heal_spell_data.cost_type   = SkillData.ResourceCost.MP
	_heal_spell_data.cost_amount = 30
	_heal_spell_data.cooldown    = 5.0

	_holy_bolt_data = SkillData.new()
	_holy_bolt_data.skill_id    = "cleric_holy_bolt"
	_holy_bolt_data.skill_name  = "Raio Sagrado"
	_holy_bolt_data.cost_type   = SkillData.ResourceCost.MP
	_holy_bolt_data.cost_amount = 20
	_holy_bolt_data.cooldown    = 1.5
	_holy_bolt_data.damage_multiplier = 1.5

func _perform_attack() -> void:
	## Ataque básico: projétil mágico fraco
	if not combat.try_attack():
		return
	_spawn_projectile(1.0)

func _use_skill_1() -> void:
	## Cura Sagrada: recupera HP próprio
	if not combat.try_use_skill(_heal_spell_data):
		return
	var heal_amount := int(stats.magic_power * 2.5)
	stats.heal(heal_amount)
	if animation:
		animation.play("skill_heal")

func _use_skill_2() -> void:
	## Raio Sagrado: projétil mágico forte
	if not combat.try_use_skill(_holy_bolt_data):
		return
	_spawn_projectile(_holy_bolt_data.damage_multiplier)
	if animation:
		animation.play("skill_holy_bolt")

func _spawn_projectile(damage_multiplier: float) -> void:
	# Placeholder: instancia cena de projétil
	pass

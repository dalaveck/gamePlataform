class_name Cleric
extends BaseCharacter

## Clérigo: magias de cura e ofensivas, depende de SPI.
## Habilidades usam MP.

@onready var spell_spawn_point: Marker2D = %SpellSpawnPoint

@export var holy_bolt_scene: PackedScene = null

const ATTACK_MP_COST: int = 5
const HEAL_RADIUS: float = 160.0

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
	## Ataque básico: projétil mágico fraco (gasta MP)
	if not combat.try_attack(SkillData.ResourceCost.MP, ATTACK_MP_COST):
		return
	if animation:
		animation.play("attack")
	_spawn_projectile(1.0)

func _use_skill_1() -> void:
	## Cura Sagrada: recupera HP próprio e de aliados próximos
	if not combat.try_use_skill(_heal_spell_data):
		return
	if animation:
		animation.play("skill_heal")
	var heal_amount := int(stats.magic_power * 2.5)
	for player: Node2D in get_tree().get_nodes_in_group("players"):
		if global_position.distance_to(player.global_position) <= HEAL_RADIUS:
			(player as BaseCharacter).receive_heal.rpc(heal_amount)

func _use_skill_2() -> void:
	## Raio Sagrado: projétil mágico forte
	if not combat.try_use_skill(_holy_bolt_data):
		return
	if animation:
		animation.play("skill_holy_bolt")
	_spawn_projectile(_holy_bolt_data.damage_multiplier)

func _spawn_projectile(damage_multiplier: float) -> void:
	if holy_bolt_scene == null:
		return
	var bolt: Projectile = holy_bolt_scene.instantiate()
	get_tree().current_scene.add_child(bolt)
	bolt.global_position = spell_spawn_point.global_position
	var damage := int((stats.atk * 0.5 + stats.magic_power) * damage_multiplier)
	bolt.setup(Vector2(movement.facing_direction, 0.0), damage, peer_id)

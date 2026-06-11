class_name Archer
extends BaseCharacter

## Arqueiro: ranged físico, depende de SKL e STR.
## Ataque básico e habilidades usam SP.

@onready var arrow_spawn_point: Marker2D = %ArrowSpawnPoint

@export var arrow_scene: PackedScene = null

var _multishot_data: SkillData  = null
var _rain_arrow_data: SkillData = null

func _ready() -> void:
	super._ready()
	_setup_skills()

func _setup_skills() -> void:
	_multishot_data = SkillData.new()
	_multishot_data.skill_id    = "archer_multishot"
	_multishot_data.skill_name  = "Tiro Múltiplo"
	_multishot_data.cost_type   = SkillData.ResourceCost.SP
	_multishot_data.cost_amount = 25
	_multishot_data.cooldown    = 3.0
	_multishot_data.damage_multiplier = 0.7  ## 3 flechas com 70% cada

	_rain_arrow_data = SkillData.new()
	_rain_arrow_data.skill_id    = "archer_rain_of_arrows"
	_rain_arrow_data.skill_name  = "Chuva de Flechas"
	_rain_arrow_data.cost_type   = SkillData.ResourceCost.SP
	_rain_arrow_data.cost_amount = 40
	_rain_arrow_data.cooldown    = 6.0
	_rain_arrow_data.damage_multiplier = 0.5  ## Várias flechas em área

func _perform_attack() -> void:
	if not combat.try_attack():
		return
	_fire_arrow(1.0)
	if animation:
		animation.play("attack")

func _use_skill_1() -> void:
	## Tiro Múltiplo: 3 flechas em leque
	if not combat.try_use_skill(_multishot_data):
		return
	for i: int in 3:
		_fire_arrow(_multishot_data.damage_multiplier, (i - 1) * 15.0)
	if animation:
		animation.play("skill_multishot")

func _use_skill_2() -> void:
	## Chuva de Flechas: área acima
	if not combat.try_use_skill(_rain_arrow_data):
		return
	if animation:
		animation.play("skill_rain_arrows")

func _fire_arrow(dmg_mult: float, angle_offset_deg: float = 0.0) -> void:
	if arrow_scene == null or arrow_spawn_point == null:
		return
	var arrow: Node2D = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = arrow_spawn_point.global_position
	# Configura direção e dano — implementar em Arrow.gd

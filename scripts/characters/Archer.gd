class_name Archer
extends BaseCharacter

## Arqueiro: ranged físico, depende de SKL e STR.
## Ataque básico e habilidades usam SP.

@onready var arrow_spawn_point: Marker2D = %ArrowSpawnPoint

@export var arrow_scene: PackedScene = null

const RAIN_ARROW_COUNT: int = 6
const RAIN_SPREAD: float = 180.0
const RAIN_HEIGHT: float = 140.0

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
	if animation:
		animation.play("attack")
	_fire_arrow(1.0)

func _use_skill_1() -> void:
	## Tiro Múltiplo: 3 flechas em leque
	if not combat.try_use_skill(_multishot_data):
		return
	if animation:
		animation.play("skill_multishot")
	for i: int in 3:
		_fire_arrow(_multishot_data.damage_multiplier, (i - 1) * 15.0)

func _use_skill_2() -> void:
	## Chuva de Flechas: flechas caem em área à frente
	if not combat.try_use_skill(_rain_arrow_data):
		return
	if animation:
		animation.play("skill_rain_arrows")
	if arrow_scene == null:
		return
	var center_x := global_position.x + movement.facing_direction * (RAIN_SPREAD * 0.8)
	var damage := int(stats.atk * _rain_arrow_data.damage_multiplier)
	for i: int in RAIN_ARROW_COUNT:
		var arrow: Projectile = arrow_scene.instantiate()
		get_tree().current_scene.add_child(arrow)
		var offset_x := (float(i) / float(RAIN_ARROW_COUNT - 1) - 0.5) * RAIN_SPREAD
		arrow.global_position = Vector2(center_x + offset_x, global_position.y - RAIN_HEIGHT)
		arrow.gravity_scale = 0.4
		arrow.setup(Vector2.DOWN, damage, peer_id)

func _fire_arrow(dmg_mult: float, angle_offset_deg: float = 0.0) -> void:
	if arrow_scene == null:
		return
	var arrow: Projectile = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = arrow_spawn_point.global_position
	var direction := Vector2(movement.facing_direction, 0.0)
	direction = direction.rotated(deg_to_rad(angle_offset_deg))
	arrow.setup(direction, int(stats.atk * dmg_mult), peer_id)

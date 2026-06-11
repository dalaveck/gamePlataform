class_name BaseCharacter
extends CharacterBody2D

## Classe base para Warrior, Cleric e Archer.
## Contém toda a lógica comum de plataforma, dash, pulo duplo e wall-jump.

@export var character_data: CharacterData = null

# ─── Componentes ───────────────────────────────────────────
@onready var stats: StatsComponent       = %StatsComponent
@onready var movement: MovementComponent = %MovementComponent
@onready var combat: CombatComponent     = %CombatComponent
@onready var sprite: Sprite2D            = %Sprite2D
@onready var animation: AnimationPlayer  = %AnimationPlayer
@onready var hurtbox: Area2D             = %Hurtbox

var peer_id: int = 0
var _is_local_player: bool = false

func _ready() -> void:
	if character_data != null:
		_initialize()

func _initialize() -> void:
	movement.setup(self, stats)
	combat.setup(stats)
	stats.recalculate_from(character_data)
	stats.died.connect(_on_died)
	_is_local_player = (peer_id == multiplayer.get_unique_id())

func _physics_process(delta: float) -> void:
	if not _is_local_player:
		return
	movement.apply_gravity(delta)
	_handle_input(delta)
	_check_wall_slide()
	move_and_slide()
	_update_animation()

func _handle_input(delta: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	movement.set_running(Input.is_action_pressed("run") if InputMap.has_action("run") else false)
	movement.move(direction, delta)

	if Input.is_action_just_pressed("jump"):
		if movement._is_wall_sliding:
			var wall_normal := get_wall_normal()
			movement.try_wall_jump(wall_normal)
		else:
			movement.try_jump()

	if Input.is_action_just_pressed("dash"):
		movement.try_dash()

	if Input.is_action_just_pressed("attack"):
		_perform_attack()

	if Input.is_action_just_pressed("skill_1"):
		_use_skill_1()

	if Input.is_action_just_pressed("skill_2"):
		_use_skill_2()

func _check_wall_slide() -> void:
	var on_wall := is_on_wall() and not is_on_floor()
	movement.set_wall_sliding(on_wall)

func _update_animation() -> void:
	if animation == null:
		return
	if movement.is_dashing():
		animation.play("dash")
	elif not is_on_floor():
		animation.play("jump")
	elif abs(velocity.x) > 10.0:
		animation.play("run")
	else:
		animation.play("idle")
	sprite.flip_h = movement.facing_direction < 0.0

# ─── Sobrescrever nas subclasses ───────────────────────────
func _perform_attack() -> void:
	pass

func _use_skill_1() -> void:
	pass

func _use_skill_2() -> void:
	pass

# ─── Dano recebido ─────────────────────────────────────────
func receive_damage(amount: int, attacker_peer_id: int) -> void:
	stats.take_damage(amount)
	EventBus.player_damaged.emit(peer_id, amount)

func _on_died() -> void:
	EventBus.player_died.emit(peer_id)
	# Animação de morte e desabilitar input
	set_physics_process(false)
	if animation:
		animation.play("die")

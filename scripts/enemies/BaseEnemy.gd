class_name BaseEnemy
extends CharacterBody2D

## IA roda apenas no servidor; posição é replicada via MultiplayerSynchronizer.
## Dano vem dos clientes através de request_damage (RPC para o host).

enum EnemyState { IDLE, PATROL, CHASE, ATTACK, DEAD }

@export var enemy_data: EnemyData = null

@onready var xp_component: XPComponent   = %XPComponent
@onready var loot_component: LootComponent = %LootComponent
@onready var animation: AnimationPlayer  = %AnimationPlayer
@onready var sprite: Sprite2D            = %Sprite2D
@onready var detection_area: Area2D      = %DetectionArea
@onready var attack_area: Area2D         = %AttackArea
@onready var health_bar: ProgressBar     = %HealthBar

var current_state: EnemyState = EnemyState.IDLE
var current_hp: int = 0:
	set(value):
		current_hp = value
		_update_health_bar()
var _target: CharacterBody2D = null
var _attack_cooldown: float = 0.0

const GRAVITY: float = 980.0

func _ready() -> void:
	add_to_group("enemies")
	if enemy_data == null:
		push_error("EnemyData not set on %s" % name)
		return
	current_hp = enemy_data.max_hp
	xp_component.setup(enemy_data)
	detection_area.body_entered.connect(_on_body_entered_detection)
	detection_area.body_exited.connect(_on_body_exited_detection)
	attack_area.body_entered.connect(_on_body_entered_attack)
	attack_area.body_exited.connect(_on_body_exited_attack)
	_update_health_bar()

func _physics_process(delta: float) -> void:
	if current_state == EnemyState.DEAD:
		return
	if not multiplayer.is_server():
		return
	velocity.y += GRAVITY * delta
	_tick_state(delta)
	move_and_slide()
	_update_animation()

func _tick_state(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta
	match current_state:
		EnemyState.PATROL: _do_patrol(delta)
		EnemyState.CHASE:  _do_chase(delta)
		EnemyState.ATTACK: _do_attack()

func _do_patrol(_delta: float) -> void:
	pass  ## Sobrescrever em subclasses

func _do_chase(_delta: float) -> void:
	if _target == null:
		current_state = EnemyState.PATROL
		return
	var dir := sign(_target.global_position.x - global_position.x)
	velocity.x = dir * enemy_data.move_speed
	sprite.flip_h = dir < 0

func _do_attack() -> void:
	velocity.x = 0.0
	if _attack_cooldown > 0.0:
		return
	_execute_attack()
	_attack_cooldown = 1.5

func _execute_attack() -> void:
	if animation:
		animation.play("attack")
	for body: Node2D in attack_area.get_overlapping_bodies():
		if body is BaseCharacter:
			(body as BaseCharacter).receive_damage.rpc(enemy_data.atk, 0)

# ─── Dano (servidor é autoridade) ──────────────────────────
func request_damage(amount: int, attacker_peer_id: int) -> void:
	if multiplayer.is_server():
		take_damage(amount, attacker_peer_id)
	else:
		_request_damage_rpc.rpc_id(1, amount, attacker_peer_id)

@rpc("any_peer", "call_remote", "reliable")
func _request_damage_rpc(amount: int, attacker_peer_id: int) -> void:
	take_damage(amount, attacker_peer_id)

func take_damage(amount: int, attacker_peer_id: int) -> void:
	if current_state == EnemyState.DEAD:
		return
	var mitigated := max(1, amount - (enemy_data.defense if enemy_data else 0))
	current_hp = max(0, current_hp - mitigated)
	if current_hp == 0:
		_die_synced.rpc(attacker_peer_id)
	elif current_state == EnemyState.IDLE or current_state == EnemyState.PATROL:
		current_state = EnemyState.CHASE

@rpc("authority", "call_local", "reliable")
func _die_synced(killer_peer_id: int) -> void:
	_die(killer_peer_id)

func _die(killer_peer_id: int) -> void:
	current_state = EnemyState.DEAD
	current_hp = 0
	velocity = Vector2.ZERO
	xp_component.distribute_rewards(killer_peer_id)
	EventBus.enemy_killed.emit(enemy_data, killer_peer_id)
	if animation:
		animation.play("die")
		await animation.animation_finished
	queue_free()

func _update_health_bar() -> void:
	if health_bar == null or enemy_data == null:
		return
	health_bar.value = float(current_hp) / float(enemy_data.max_hp) * 100.0

func _update_animation() -> void:
	if animation == null:
		return
	match current_state:
		EnemyState.IDLE, EnemyState.PATROL:
			animation.play("walk" if abs(velocity.x) > 5.0 else "idle")
		EnemyState.CHASE:
			animation.play("walk")
		EnemyState.ATTACK:
			pass  ## Gerenciado em _execute_attack

func _on_body_entered_detection(body: Node2D) -> void:
	if body is BaseCharacter:
		_target = body
		if current_state != EnemyState.ATTACK and current_state != EnemyState.DEAD:
			current_state = EnemyState.CHASE

func _on_body_exited_detection(body: Node2D) -> void:
	if body == _target:
		_target = null
		if current_state != EnemyState.DEAD:
			current_state = EnemyState.PATROL

func _on_body_entered_attack(body: Node2D) -> void:
	if body is BaseCharacter and current_state != EnemyState.DEAD:
		current_state = EnemyState.ATTACK

func _on_body_exited_attack(body: Node2D) -> void:
	if body is BaseCharacter and current_state == EnemyState.ATTACK:
		current_state = EnemyState.CHASE if _target != null else EnemyState.PATROL

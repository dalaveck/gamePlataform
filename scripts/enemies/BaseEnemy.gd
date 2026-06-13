class_name BaseEnemy
extends CharacterBody2D

## IA roda apenas no servidor; posição é replicada via MultiplayerSynchronizer.
## Dano vem dos clientes através de request_damage (RPC para o host).

enum EnemyState { IDLE, PATROL, CHASE, ATTACK, DEAD }

@export var enemy_data: EnemyData = null

@onready var xp_component: XPComponent    = %XPComponent
@onready var loot_component: LootComponent = %LootComponent
@onready var animation: AnimationPlayer   = %AnimationPlayer
@onready var sprite: Sprite2D             = %Sprite2D
@onready var detection_area: Area2D       = %DetectionArea
@onready var attack_area: Area2D          = %AttackArea
@onready var health_bar: ProgressBar      = %HealthBar
@onready var edge_ray: RayCast2D          = get_node_or_null("%EdgeRay")

var current_state: EnemyState = EnemyState.IDLE
var current_hp: int = 0:
	set(value):
		current_hp = value
		_update_health_bar()
var _target: CharacterBody2D = null
var _attack_cooldown: float  = 0.0

# ─── Maldição Imperdoável ──────────────────────────────────
var _curse_timer: float     = 0.0
var _curse_drain_rate: float = 0.0  ## HP/s drenado

# ─── Knockback (empurrão recebido) ─────────────────────────
var _knockback: Vector2 = Vector2.ZERO

const GRAVITY: float = 980.0
const KNOCKBACK_DECAY: float = 1600.0  ## px/s² de desaceleração do empurrão

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
	# Empurrão (somado por cima da velocidade da IA, decai rápido)
	if _knockback != Vector2.ZERO:
		velocity += _knockback
		_knockback = _knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
	# Dreno de maldição (servidor)
	if _curse_timer > 0.0:
		_curse_timer -= delta
		var drain := int(_curse_drain_rate * delta)
		if drain > 0:
			current_hp = max(0, current_hp - drain)
			if current_hp == 0:
				_die_synced.rpc(0)
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
	pass

func _do_chase(_delta: float) -> void:
	if _target == null:
		current_state = EnemyState.PATROL
		return
	var dir := sign(_target.global_position.x - global_position.x)
	sprite.flip_h = dir < 0
	if _would_fall(dir):
		velocity.x = 0.0
		return
	velocity.x = dir * enemy_data.move_speed

func _would_fall(direction: float) -> bool:
	if edge_ray == null or direction == 0.0:
		return false
	# Se já está no ar, trata como "cairia" para parar o movimento horizontal
	if not is_on_floor():
		return true
	edge_ray.position.x = abs(edge_ray.position.x) * direction
	edge_ray.force_raycast_update()
	return not edge_ray.is_colliding()

func _do_attack() -> void:
	velocity.x = 0.0
	if _attack_cooldown > 0.0:
		return
	_execute_attack()
	_attack_cooldown = 1.5

func _execute_attack() -> void:
	if animation:
		animation.play("attack")
	var kb_force := _attack_knockback_force()
	for body: Node2D in attack_area.get_overlapping_bodies():
		if body is BaseCharacter:
			var character := body as BaseCharacter
			character.receive_damage.rpc(enemy_data.atk, 0)
			if kb_force > 0.0:
				var dir := (character.global_position - global_position).normalized()
				dir.y -= 0.35  ## leve componente para cima
				character.receive_knockback.rpc(dir.normalized(), kb_force)

## Força com que o inimigo empurra jogadores ao atacar (só Boss/MiniBoss).
func _attack_knockback_force() -> float:
	if enemy_data == null:
		return 0.0
	match enemy_data.enemy_type:
		EnemyData.EnemyType.BOSS:     return 320.0
		EnemyData.EnemyType.MINIBOSS: return 240.0
		_:                            return 0.0

# ─── Dano ──────────────────────────────────────────────────
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

# ─── Knockback (empurrão) ──────────────────────────────────
## resist_factor: 0.0 ignora a resistência do alvo, 1.0 aplica integralmente.
func request_knockback(direction: Vector2, force: float, resist_factor: float = 1.0) -> void:
	if multiplayer.is_server():
		apply_knockback(direction, force, resist_factor)
	else:
		_request_knockback_rpc.rpc_id(1, direction, force, resist_factor)

@rpc("any_peer", "call_remote", "reliable")
func _request_knockback_rpc(direction: Vector2, force: float, resist_factor: float) -> void:
	apply_knockback(direction, force, resist_factor)

func apply_knockback(direction: Vector2, force: float, resist_factor: float = 1.0) -> void:
	if current_state == EnemyState.DEAD:
		return
	var resistance := _knockback_resistance() * resist_factor
	_knockback = direction.normalized() * force * (1.0 - resistance)

## Quanto o inimigo resiste a ser empurrado (Boss/MiniBoss resistem muito).
func _knockback_resistance() -> float:
	if enemy_data == null:
		return 0.0
	match enemy_data.enemy_type:
		EnemyData.EnemyType.BOSS:     return 0.85
		EnemyData.EnemyType.MINIBOSS: return 0.80
		_:                            return 0.0

# ─── Maldição ──────────────────────────────────────────────
func request_curse(drain_percent: float, duration: float) -> void:
	if multiplayer.is_server():
		apply_curse(drain_percent, duration)
	else:
		_request_curse_rpc.rpc_id(1, drain_percent, duration)

@rpc("any_peer", "call_remote", "reliable")
func _request_curse_rpc(drain_percent: float, duration: float) -> void:
	apply_curse(drain_percent, duration)

func apply_curse(drain_percent: float, duration: float) -> void:
	if enemy_data == null:
		return
	_curse_timer      = duration
	_curse_drain_rate = (enemy_data.max_hp * drain_percent) / duration

# ─── Morte ────────────────────────────────────────────────
@rpc("authority", "call_local", "reliable")
func _die_synced(killer_peer_id: int) -> void:
	_die(killer_peer_id)

func _die(killer_peer_id: int) -> void:
	current_state = EnemyState.DEAD
	current_hp    = 0
	velocity      = Vector2.ZERO
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
			pass

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

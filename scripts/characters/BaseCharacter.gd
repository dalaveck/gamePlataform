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
@onready var camera: Camera2D            = %Camera2D
@onready var name_label: Label           = %NameLabel

const REGEN_SAFE_DISTANCE: float = 280.0
const REGEN_CHECK_INTERVAL: float = 0.5

var peer_id: int = 0
var selected_skill: int = 1  ## 1=ataque, 2=skill1, 3=skill2, 4=skill3

var _is_local_player: bool = false
var _regen_check_timer: float = 0.0
var _damage_reduction: float = 0.0
var _damage_reduction_timer: float = 0.0

func _ready() -> void:
	add_to_group("players")
	if character_data != null:
		_initialize()

func _initialize() -> void:
	movement.setup(self, stats)
	combat.setup(stats)
	stats.recalculate_from(character_data)
	stats.died.connect(_on_died)
	_is_local_player = (peer_id == multiplayer.get_unique_id())
	camera.enabled = _is_local_player
	name_label.text = character_data.character_name

func _process(delta: float) -> void:
	_regen_check_timer -= delta
	if _regen_check_timer <= 0.0:
		_regen_check_timer = REGEN_CHECK_INTERVAL
		stats.regen_enabled = not _is_enemy_nearby()

func _is_enemy_nearby() -> bool:
	for enemy: Node2D in get_tree().get_nodes_in_group("enemies"):
		if global_position.distance_to(enemy.global_position) < REGEN_SAFE_DISTANCE:
			return true
	return false

func _physics_process(delta: float) -> void:
	if not _is_local_player:
		return
	movement.apply_gravity(delta)
	_handle_input(delta)
	_check_wall_slide()
	move_and_slide()
	_update_animation()
	# Tick buff de proteção
	if _damage_reduction_timer > 0.0:
		_damage_reduction_timer -= delta
		if _damage_reduction_timer <= 0.0:
			_damage_reduction = 0.0

func _handle_input(delta: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	movement.set_running(Input.is_action_pressed("run") if InputMap.has_action("run") else false)
	movement.move(direction, delta)

	if Input.is_action_just_pressed("jump"):
		if movement._is_wall_sliding:
			movement.try_wall_jump(get_wall_normal())
		else:
			movement.try_jump()

	if Input.is_action_just_pressed("dash"):
		movement.try_dash()

	# Teclas de seleção rápida (1–4 numpad ou teclado)
	if Input.is_key_pressed(KEY_1): selected_skill = 1
	elif Input.is_key_pressed(KEY_2): selected_skill = 2
	elif Input.is_key_pressed(KEY_3): selected_skill = 3
	elif Input.is_key_pressed(KEY_4): selected_skill = 4

	# Ataque / habilidade selecionada
	if Input.is_action_just_pressed("attack"):
		_execute_selected_skill()

	# Atalhos diretos legados (X, C) + novo V para skill 3
	if Input.is_action_just_pressed("skill_1"):
		if _use_skill_1():
			selected_skill = 1
	if Input.is_action_just_pressed("skill_2"):
		if _use_skill_2():
			selected_skill = 1
	if InputMap.has_action("skill_3") and Input.is_action_just_pressed("skill_3"):
		if _use_skill_3():
			selected_skill = 1

func _execute_selected_skill() -> void:
	match selected_skill:
		1:
			_perform_attack()
		2:
			if _use_skill_1():
				selected_skill = 1
		3:
			if _use_skill_2():
				selected_skill = 1
		4:
			if _use_skill_3():
				selected_skill = 1

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
	# Sprite vira em direção ao mouse (apenas jogador local)
	if _is_local_player:
		var face_right := get_global_mouse_position().x >= global_position.x
		sprite.flip_h = not face_right
		movement.facing_direction = 1.0 if face_right else -1.0
	else:
		sprite.flip_h = movement.facing_direction < 0.0

# ─── Direção de mira (mouse) ───────────────────────────────
func _get_aim_direction() -> Vector2:
	if not _is_local_player:
		return Vector2(movement.facing_direction, 0.0)
	var dir := (get_global_mouse_position() - global_position).normalized()
	return dir if dir.length() > 0.01 else Vector2(movement.facing_direction, 0.0)

# ─── Buff de Proteção ──────────────────────────────────────
func apply_protection_buff(reduction: float, duration: float) -> void:
	_damage_reduction       = reduction
	_damage_reduction_timer = duration

# ─── Sobrescrever nas subclasses ───────────────────────────
func _perform_attack() -> void:
	pass

func _use_skill_1() -> bool:
	return false

func _use_skill_2() -> bool:
	return false

func _use_skill_3() -> bool:
	return false

## Retorna lista de SkillData para a SkillBar (sobrescrever nas subclasses)
func get_skill_datas() -> Array:
	return []

# ─── Dano e cura (executam em todos os peers via call_local) ─
@rpc("any_peer", "call_local", "reliable")
func receive_damage(amount: int, _attacker_peer_id: int) -> void:
	if stats.current_hp <= 0:
		return
	var final := int(amount * (1.0 - _damage_reduction))
	stats.take_damage(final)
	EventBus.player_damaged.emit(peer_id, final)

@rpc("any_peer", "call_local", "reliable")
func receive_heal(amount: int) -> void:
	if stats.current_hp <= 0:
		return
	stats.heal(amount)
	EventBus.player_healed.emit(peer_id, amount)

## Cura percentual (HP e SP) com base no máximo do próprio alvo.
## Usada pela Cura Maior do Clérigo em si e em aliados no coop.
@rpc("any_peer", "call_local", "reliable")
func receive_greater_heal(hp_percent: float, sp_percent: float) -> void:
	if stats.current_hp <= 0:
		return
	var hp_amount := int(stats.max_hp * hp_percent)
	stats.heal(hp_amount)
	if sp_percent > 0.0:
		stats.restore_sp(int(stats.max_sp * sp_percent))
	EventBus.player_healed.emit(peer_id, hp_amount)

func _on_died() -> void:
	EventBus.player_died.emit(peer_id)
	set_physics_process(false)
	hurtbox.set_deferred("monitoring", false)
	if animation:
		animation.play("die")

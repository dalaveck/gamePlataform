class_name MovementComponent
extends Node

# ─── Constantes de movimento ───────────────────────────────
const BASE_SPEED: float       = 200.0
const RUN_SPEED: float        = 320.0
const JUMP_FORCE: float       = -500.0
const GRAVITY: float          = 980.0
const DASH_FORCE: float       = 600.0
const DASH_DURATION: float    = 0.15
const DASH_SP_COST: int       = 20
const RUN_SP_COST_PER_SEC: float = 15.0
const WALL_SLIDE_GRAVITY: float  = 150.0
const WALL_JUMP_FORCE: Vector2   = Vector2(280.0, -420.0)

var _body: CharacterBody2D
var _stats: StatsComponent

var _jump_count: int = 0
var _max_jumps: int = 2

var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_direction: float = 1.0

var _is_running: bool = false
var _is_wall_sliding: bool = false

var facing_direction: float = 1.0

func setup(body: CharacterBody2D, stats: StatsComponent) -> void:
	_body = body
	_stats = stats

func _process(delta: float) -> void:
	if _is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_is_dashing = false

func apply_gravity(delta: float) -> void:
	if _body.is_on_floor():
		_jump_count = 0
		return
	if _is_wall_sliding:
		_body.velocity.y += WALL_SLIDE_GRAVITY * delta
	else:
		_body.velocity.y += GRAVITY * delta

func move(direction: float, delta: float) -> void:
	if _is_dashing:
		return
	if direction != 0.0:
		facing_direction = sign(direction)

	var speed := _get_current_speed()
	_body.velocity.x = direction * speed * _stats.agility

	# Consome SP ao correr
	if _is_running and direction != 0.0:
		_stats.consume_sp(int(RUN_SP_COST_PER_SEC * delta))

func set_running(running: bool) -> void:
	_is_running = running and _stats.current_sp > 0

func try_jump() -> bool:
	if _jump_count < _max_jumps:
		_body.velocity.y = JUMP_FORCE
		_jump_count += 1
		return true
	return false

func try_dash() -> bool:
	if _is_dashing:
		return false
	if not _stats.consume_sp(DASH_SP_COST):
		return false
	_is_dashing = true
	_dash_timer = DASH_DURATION
	_body.velocity.x = facing_direction * DASH_FORCE
	return true

func try_wall_jump(wall_normal: Vector2) -> bool:
	if _jump_count >= _max_jumps:
		return false
	_body.velocity = Vector2(wall_normal.x * WALL_JUMP_FORCE.x, WALL_JUMP_FORCE.y)
	_jump_count += 1
	return true

func set_wall_sliding(sliding: bool) -> void:
	_is_wall_sliding = sliding

func _get_current_speed() -> float:
	if _is_running and _stats.current_sp > 0:
		return RUN_SPEED
	return BASE_SPEED

func is_dashing() -> bool:
	return _is_dashing

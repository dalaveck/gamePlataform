class_name CursedBolt
extends CharacterBody2D

## Maldição Imperdoável: projétil que ricocheteia em paredes (até 5x)
## e aplica dreno gradual de HP ao acertar inimigos.

const MAX_BOUNCES    := 5
const SPEED          := 420.0
const LIFETIME       := 8.0
const DOT_DURATION   := 15.0
const DOT_PERCENT    := 0.30

var _dir: Vector2 = Vector2.RIGHT
var _damage: int   = 0
var _owner_id: int = 0
var _bounces: int  = 0
var _life: float   = 0.0

func setup(dir: Vector2, dmg: int, peer_id: int) -> void:
	_dir      = dir.normalized()
	_damage   = dmg
	_owner_id = peer_id
	velocity  = _dir * SPEED
	rotation  = _dir.angle()

func _ready() -> void:
	modulate = Color(0.55, 0.0, 1.0, 0.92)
	collision_layer = 8
	collision_mask  = 5

func _physics_process(delta: float) -> void:
	_life += delta
	if _life >= LIFETIME:
		queue_free()
		return
	var col := move_and_collide(velocity * delta)
	if col == null:
		return
	var collider := col.get_collider()
	if collider is BaseEnemy:
		(collider as BaseEnemy).request_damage(_damage, _owner_id)
		(collider as BaseEnemy).request_knockback(velocity.normalized(), 70.0)
		(collider as BaseEnemy).request_curse(DOT_PERCENT, DOT_DURATION)
		queue_free()
	elif _bounces < MAX_BOUNCES:
		_bounces += 1
		velocity  = velocity.bounce(col.get_normal())
		rotation  = velocity.angle()
	else:
		queue_free()

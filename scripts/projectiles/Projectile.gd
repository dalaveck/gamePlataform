class_name Projectile
extends Area2D

## Projétil genérico (flechas, magias). Movido pelo peer que o disparou;
## o dano chega aos inimigos via BaseEnemy.request_damage (RPC ao servidor).

@export var speed: float = 500.0
@export var lifetime: float = 3.0
@export var gravity_scale: float = 0.0

var direction: Vector2 = Vector2.RIGHT
var damage: int = 0
var owner_peer_id: int = 0

var _velocity: Vector2 = Vector2.ZERO
var _life_timer: float = 0.0

func setup(dir: Vector2, dmg: int, peer_id: int) -> void:
	direction = dir.normalized()
	damage = dmg
	owner_peer_id = peer_id
	_velocity = direction * speed
	rotation = direction.angle()

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_velocity.y += 980.0 * gravity_scale * delta
	global_position += _velocity * delta
	if gravity_scale > 0.0:
		rotation = _velocity.angle()
	_life_timer += delta
	if _life_timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is BaseEnemy:
		(body as BaseEnemy).request_damage(damage, owner_peer_id)
		queue_free()
	elif body is StaticBody2D or body is TileMap:
		queue_free()

class_name BouncingHolyBolt
extends CharacterBody2D

## Ataque comum do Clérigo: raio sagrado que ricocheteia pelo mapa
## (paredes, chão e teto) em até 5 vezes. Só causa dano a inimigos —
## atravessa-os enquanto ricocheteia apenas no terreno.

const MAX_BOUNCES := 5
const SPEED       := 450.0
const LIFETIME    := 4.0

@onready var enemy_detector: Area2D = $EnemyDetector

var _dir: Vector2  = Vector2.RIGHT
var _damage: int   = 0
var _owner_id: int = 0
var _bounces: int  = 0
var _life: float   = 0.0
var _hit_enemies: Array = []  ## evita dano repetido no mesmo inimigo

func setup(dir: Vector2, dmg: int, peer_id: int) -> void:
	_dir      = dir.normalized()
	_damage   = dmg
	_owner_id = peer_id
	velocity  = _dir * SPEED
	rotation  = _dir.angle()

func _ready() -> void:
	collision_layer = 8
	collision_mask  = 1  ## ricocheteia apenas no terreno
	enemy_detector.body_entered.connect(_on_enemy_entered)

func _physics_process(delta: float) -> void:
	_life += delta
	if _life >= LIFETIME:
		queue_free()
		return
	var col := move_and_collide(velocity * delta)
	if col == null:
		return
	if _bounces < MAX_BOUNCES:
		_bounces += 1
		velocity  = velocity.bounce(col.get_normal())
		rotation  = velocity.angle()
		_hit_enemies.clear()  ## permite reacertar inimigos após mudar de trajetória
	else:
		queue_free()

func _on_enemy_entered(body: Node2D) -> void:
	if body is BaseEnemy and not _hit_enemies.has(body):
		_hit_enemies.append(body)
		(body as BaseEnemy).request_damage(_damage, _owner_id)

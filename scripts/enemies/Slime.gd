class_name Slime
extends BaseEnemy

## Inimigo básico: patrulha andando de um lado para o outro,
## virando ao encontrar parede ou beirada de plataforma.

@onready var edge_ray: RayCast2D = %EdgeRay

var _patrol_direction: float = 1.0

func _ready() -> void:
	super._ready()
	current_state = EnemyState.PATROL

func _do_patrol(_delta: float) -> void:
	if is_on_wall() or (is_on_floor() and not edge_ray.is_colliding()):
		_patrol_direction *= -1.0
	velocity.x = _patrol_direction * enemy_data.move_speed * 0.5
	sprite.flip_h = _patrol_direction < 0.0
	edge_ray.position.x = abs(edge_ray.position.x) * _patrol_direction

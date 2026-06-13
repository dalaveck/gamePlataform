class_name PenetratingArrow
extends Projectile

## Flecha Avassaladora: atravessa paredes/chão, acerta vários inimigos.
## collision_mask no .tscn = 4 (apenas inimigos, sem terreno).

var _hit_enemies: Array = []

func _on_body_entered(body: Node2D) -> void:
	if body is BaseEnemy and not _hit_enemies.has(body):
		_hit_enemies.append(body)
		(body as BaseEnemy).request_damage(damage, owner_peer_id)
		(body as BaseEnemy).request_knockback(_velocity.normalized(), knockback)
	# Não destrói ao tocar em terreno ou inimigos — segue em frente

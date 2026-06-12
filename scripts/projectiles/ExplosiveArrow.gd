class_name ExplosiveArrow
extends Projectile

## Flecha Explosiva: ao tocar qualquer coisa, causa dano em área nos inimigos.

const EXPLOSION_RADIUS := 110.0

var _exploded := false

func _on_body_entered(body: Node2D) -> void:
	if _exploded:
		return
	_exploded = true
	_explode()

func _explode() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if global_position.distance_to((enemy as Node2D).global_position) <= EXPLOSION_RADIUS:
			(enemy as BaseEnemy).request_damage(damage, owner_peer_id)
	queue_free()

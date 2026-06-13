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
		var enemy_pos := (enemy as Node2D).global_position
		if global_position.distance_to(enemy_pos) <= EXPLOSION_RADIUS:
			(enemy as BaseEnemy).request_damage(damage, owner_peer_id)
			var dir := (enemy_pos - global_position).normalized()
			if dir == Vector2.ZERO:
				dir = _velocity.normalized()
			(enemy as BaseEnemy).request_knockback(dir, knockback)
	queue_free()

class_name Boss
extends BaseEnemy

## Boss: múltiplas fases, ataque especial em área.
## Fase 3 (< 33% HP) = modo enraivecido.

const SPECIAL_RADIUS: float = 150.0

var _phase: int = 1
var _special_cooldown: float = 0.0
var _special_interval: float = 8.0
var _enraged: bool = false

func _tick_state(delta: float) -> void:
	if current_state == EnemyState.CHASE or current_state == EnemyState.ATTACK:
		_special_cooldown -= delta
		if _special_cooldown <= 0.0:
			_special_cooldown = _special_interval
			_use_special_attack()
	super._tick_state(delta)

func _use_special_attack() -> void:
	## Onda de choque: dano em área ao redor do boss + empurrão radial forte
	if animation:
		animation.play("attack")
	var damage := int(enemy_data.atk * 1.5)
	for player: Node2D in get_tree().get_nodes_in_group("players"):
		if global_position.distance_to(player.global_position) <= SPECIAL_RADIUS:
			var character := player as BaseCharacter
			character.receive_damage.rpc(damage, 0)
			var dir := (character.global_position - global_position).normalized()
			dir.y -= 0.35
			character.receive_knockback.rpc(dir.normalized(), 380.0)

func take_damage(amount: int, attacker_peer_id: int) -> void:
	super.take_damage(amount, attacker_peer_id)
	_check_phase()

func _check_phase() -> void:
	if enemy_data == null:
		return
	var ratio := float(current_hp) / float(enemy_data.max_hp)
	if _phase == 1 and ratio <= 0.66:
		_phase = 2
		_on_phase_change(2)
	elif _phase == 2 and ratio <= 0.33:
		_phase = 3
		_on_phase_change(3)

func _on_phase_change(new_phase: int) -> void:
	match new_phase:
		2:
			_special_interval = 6.0
			enemy_data.move_speed *= 1.2
		3:
			## Modo enraivecido
			_enraged = true
			_special_interval = 4.0
			enemy_data.move_speed *= 1.4
			_set_enraged_visual.rpc()

@rpc("authority", "call_local", "reliable")
func _set_enraged_visual() -> void:
	sprite.modulate = Color(1.0, 0.5, 0.5)

func _die(killer_peer_id: int) -> void:
	EventBus.boss_defeated.emit(
		SessionData.current_map.map_id if SessionData.current_map else ""
	)
	super._die(killer_peer_id)

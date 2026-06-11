class_name MiniBoss
extends BaseEnemy

## Mini Boss: HP elevado, padrão de ataque em fases.

var _phase: int = 1  ## Fase 1: > 50% HP | Fase 2: <= 50% HP

func _die(killer_peer_id: int) -> void:
	EventBus.miniboss_defeated.emit(
		SessionData.current_map.map_id if SessionData.current_map else ""
	)
	super._die(killer_peer_id)

func take_damage(amount: int, attacker_peer_id: int) -> void:
	super.take_damage(amount, attacker_peer_id)
	_check_phase()

func _check_phase() -> void:
	if enemy_data == null:
		return
	var hp_ratio := float(current_hp) / float(enemy_data.max_hp)
	if _phase == 1 and hp_ratio <= 0.5:
		_phase = 2
		_enter_phase_2()

func _enter_phase_2() -> void:
	## Fase 2: mais agressivo
	if enemy_data:
		enemy_data.move_speed *= 1.4
	_attack_cooldown = max(0.5, _attack_cooldown * 0.6)

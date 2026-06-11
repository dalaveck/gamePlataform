class_name Boss
extends BaseEnemy

## Boss: múltiplas fases, ataques especiais.

var _phase: int = 1
var _special_cooldown: float = 0.0
const SPECIAL_INTERVAL: float = 8.0

func _tick_state(delta: float) -> void:
	_special_cooldown -= delta
	if _special_cooldown <= 0.0:
		_special_cooldown = SPECIAL_INTERVAL
		_use_special_attack()
	super._tick_state(delta)

func _use_special_attack() -> void:
	## Sobrescrever em bosses específicos
	pass

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
	print("Boss entering phase %d" % new_phase)
	## Acelera ataques e muda padrão

func _die(killer_peer_id: int) -> void:
	EventBus.boss_defeated.emit(
		SessionData.current_map.map_id if SessionData.current_map else ""
	)
	super._die(killer_peer_id)

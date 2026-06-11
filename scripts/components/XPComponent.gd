class_name XPComponent
extends Node

## Responsável por distribuir XP e dinheiro quando um inimigo morre.
## Deve ser filho do nó Enemy.

var _enemy_data: EnemyData

func setup(enemy_data: EnemyData) -> void:
	_enemy_data = enemy_data

func distribute_rewards(killer_peer_id: int) -> void:
	if _enemy_data == null:
		return
	# XP vai para o personagem ativo do jogador que matou
	var killer_char_id := _get_character_id_of(killer_peer_id)
	if killer_char_id != "":
		EventBus.xp_gained.emit(killer_char_id, _enemy_data.xp_reward)

	# Dinheiro é da conta (para todos os jogadores da sessão)
	EventBus.money_gained.emit(_enemy_data.money_reward)

func _get_character_id_of(peer_id: int) -> String:
	var char_data: CharacterData = SessionData.active_characters.get(peer_id, null)
	if char_data == null:
		return ""
	return char_data.character_id

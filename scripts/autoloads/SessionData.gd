extends Node

## Dados voláteis da sessão atual (não persistidos em disco).
## Resetado a cada nova sessão de jogo.

var local_peer_id: int = 0
var is_host: bool = false
var current_map: MapData = null
var player_name: String = "Player"

## peer_id -> CharacterData escolhido para esta sessão
var active_characters: Dictionary = {}

## peer_id -> nome do jogador
var player_names: Dictionary = {}

## peer_id -> bool (está pronto no lobby)
var ready_states: Dictionary = {}

func reset() -> void:
	local_peer_id = 0
	is_host = false
	current_map = null
	active_characters.clear()
	player_names.clear()
	ready_states.clear()

func set_player_ready(peer_id: int, is_ready: bool) -> void:
	ready_states[peer_id] = is_ready

func all_players_ready() -> bool:
	if ready_states.is_empty():
		return false
	for state: bool in ready_states.values():
		if not state:
			return false
	return true

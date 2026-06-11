extends Node

enum GameState {
	MAIN_MENU,
	LOBBY,
	MAP_SELECT,
	IN_GAME,
	GAME_OVER,
	VICTORY,
}

var current_state: GameState = GameState.MAIN_MENU

func change_state(new_state: GameState) -> void:
	current_state = new_state
	_on_state_changed(new_state)

func _on_state_changed(state: GameState) -> void:
	match state:
		GameState.MAIN_MENU:
			get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
		GameState.LOBBY:
			get_tree().change_scene_to_file("res://scenes/ui/LobbyRoom.tscn")
		GameState.MAP_SELECT:
			get_tree().change_scene_to_file("res://scenes/ui/MapSelect.tscn")
		GameState.IN_GAME:
			if SessionData.current_map != null:
				get_tree().change_scene_to_file(SessionData.current_map.scene_path)
		GameState.GAME_OVER:
			get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
		GameState.VICTORY:
			get_tree().change_scene_to_file("res://scenes/ui/Victory.tscn")

func go_to_main_menu() -> void:
	SessionData.reset()
	NetworkManager.disconnect_from_game()
	change_state(GameState.MAIN_MENU)

func _ready() -> void:
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.player_died.connect(_on_player_died)

func _on_boss_defeated(_map_id: String) -> void:
	EventBus.map_completed.emit(SessionData.current_map.map_id if SessionData.current_map else "")
	change_state(GameState.VICTORY)

func _on_player_died(_peer_id: int) -> void:
	# Verifica se todos os jogadores morreram
	pass

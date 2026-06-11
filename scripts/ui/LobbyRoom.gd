extends Control

@onready var player_list: VBoxContainer = %PlayerList
@onready var class_option: OptionButton = %ClassOption
@onready var char_name_input: LineEdit  = %CharNameInput
@onready var confirm_button: Button     = %ConfirmButton
@onready var ready_button: Button       = %ReadyButton
@onready var start_button: Button       = %StartButton
@onready var leave_button: Button       = %LeaveButton
@onready var hint_label: Label          = %HintLabel

var _is_ready: bool = false
var _has_character: bool = false

func _ready() -> void:
	class_option.add_item("Guerreiro", CharacterData.CharacterClass.WARRIOR)
	class_option.add_item("Clérigo", CharacterData.CharacterClass.CLERIC)
	class_option.add_item("Arqueiro", CharacterData.CharacterClass.ARCHER)

	confirm_button.pressed.connect(_on_confirm_character)
	ready_button.pressed.connect(_on_toggle_ready)
	start_button.pressed.connect(_on_start)
	leave_button.pressed.connect(_on_leave)

	EventBus.lobby_player_joined.connect(_on_lobby_changed_2)
	EventBus.lobby_player_left.connect(_on_lobby_changed_1)
	EventBus.lobby_ready_changed.connect(_on_ready_changed)
	EventBus.lobby_character_selected.connect(_on_lobby_changed_2s)

	ready_button.disabled = true
	start_button.visible = SessionData.is_host
	start_button.disabled = true
	_refresh_player_list()

func _on_lobby_changed_1(_a: int) -> void:
	_refresh_player_list()

func _on_lobby_changed_2(_a: int, _b: String) -> void:
	_refresh_player_list()

func _on_lobby_changed_2s(_a: int, _b: String) -> void:
	_refresh_player_list()

func _on_ready_changed(_peer_id: int, _ready_state: bool) -> void:
	_refresh_player_list()
	_update_start_button()

func _on_confirm_character() -> void:
	var char_class := class_option.get_selected_id() as CharacterData.CharacterClass
	var char_name := char_name_input.text.strip_edges()
	if char_name.is_empty():
		char_name = "%s de %s" % [_class_label(char_class), SessionData.player_name]

	# Reutiliza personagem existente da mesma classe, senão cria um novo
	var char_data: CharacterData = null
	for c: CharacterData in SaveSystem.characters:
		if c.character_class == char_class:
			char_data = c
			break
	if char_data == null:
		char_data = SaveSystem.create_character(char_name, char_class)

	var local_id := multiplayer.get_unique_id()
	SessionData.active_characters[local_id] = char_data
	if multiplayer.multiplayer_peer != null:
		NetworkManager.sync_character_data.rpc(SaveSystem.serialize_character(char_data))

	_has_character = true
	ready_button.disabled = false
	hint_label.text = "Personagem: %s (Nv. %d %s)" % [
		char_data.character_name, char_data.level, _class_label(char_class)
	]
	_refresh_player_list()

func _on_toggle_ready() -> void:
	if not _has_character:
		return
	_is_ready = not _is_ready
	ready_button.text = "Cancelar" if _is_ready else "Pronto"
	var local_id := multiplayer.get_unique_id()
	SessionData.set_player_ready(local_id, _is_ready)
	EventBus.lobby_ready_changed.emit(local_id, _is_ready)
	if multiplayer.multiplayer_peer != null:
		NetworkManager.sync_ready_state.rpc(_is_ready)

func _on_start() -> void:
	if not SessionData.is_host:
		return
	NetworkManager.go_to_map_select.rpc()

func _on_leave() -> void:
	GameManager.go_to_main_menu()

func _update_start_button() -> void:
	if not SessionData.is_host:
		return
	start_button.disabled = not SessionData.all_players_ready()

func _refresh_player_list() -> void:
	for child: Node in player_list.get_children():
		child.queue_free()
	var peer_ids: Array = SessionData.player_names.keys()
	peer_ids.sort()
	for peer_id: int in peer_ids:
		var label := Label.new()
		var player_name: String = SessionData.player_names.get(peer_id, "Player_%d" % peer_id)
		var char_data: CharacterData = SessionData.active_characters.get(peer_id, null)
		var class_text := char_data.get_class_name_string() if char_data != null else "—"
		var ready_text := "✔" if SessionData.ready_states.get(peer_id, false) else "…"
		label.text = "%s  [%s]  %s" % [player_name, class_text, ready_text]
		player_list.add_child(label)
	_update_start_button()

func _class_label(char_class: CharacterData.CharacterClass) -> String:
	match char_class:
		CharacterData.CharacterClass.WARRIOR: return "Guerreiro"
		CharacterData.CharacterClass.CLERIC:  return "Clérigo"
		CharacterData.CharacterClass.ARCHER:  return "Arqueiro"
	return "?"

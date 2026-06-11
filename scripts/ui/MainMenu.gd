extends Control

@onready var name_input: LineEdit       = %NameInput
@onready var address_input: LineEdit    = %AddressInput
@onready var create_room_button: Button = %CreateRoomButton
@onready var join_room_button: Button   = %JoinRoomButton
@onready var exit_button: Button        = %ExitButton
@onready var status_label: Label        = %StatusLabel
@onready var room_list: VBoxContainer   = %RoomList

const ROOM_TIMEOUT_MS: int = 4000  ## Sala some da lista se parar de anunciar

## address -> { "name": String, "seen": int (ticks ms) }
var _discovered_rooms: Dictionary = {}

func _ready() -> void:
	create_room_button.pressed.connect(_on_create_room)
	join_room_button.pressed.connect(_on_join_room)
	exit_button.pressed.connect(_on_exit)
	NetworkManager.joined_server.connect(_on_joined_server)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.room_discovered.connect(_on_room_discovered)
	NetworkManager.start_room_discovery()
	name_input.text = SaveSystem.account_name
	_refresh_room_list()

func _exit_tree() -> void:
	NetworkManager.stop_room_discovery()

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	var changed := false
	for address: String in _discovered_rooms.keys():
		if now - int(_discovered_rooms[address]["seen"]) > ROOM_TIMEOUT_MS:
			_discovered_rooms.erase(address)
			changed = true
	if changed:
		_refresh_room_list()

func _on_room_discovered(address: String, room_name: String) -> void:
	var is_new: bool = not _discovered_rooms.has(address)
	_discovered_rooms[address] = { "name": room_name, "seen": Time.get_ticks_msec() }
	if is_new:
		_refresh_room_list()

func _refresh_room_list() -> void:
	for child: Node in room_list.get_children():
		child.queue_free()
	if _discovered_rooms.is_empty():
		var label := Label.new()
		label.text = "Nenhuma sala encontrada na rede..."
		room_list.add_child(label)
		return
	for address: String in _discovered_rooms.keys():
		var button := Button.new()
		button.text = "%s  (%s)" % [_discovered_rooms[address]["name"], address]
		button.pressed.connect(_on_join_discovered_room.bind(address))
		room_list.add_child(button)

func _on_join_discovered_room(address: String) -> void:
	_apply_player_name()
	status_label.text = "Conectando a %s..." % address
	join_room_button.disabled = true
	NetworkManager.join_server(address)

func _apply_player_name() -> void:
	var player_name := name_input.text.strip_edges()
	if player_name.is_empty():
		player_name = "Player"
	SessionData.player_name = player_name
	SaveSystem.account_name = player_name
	SaveSystem.save_account()

func _on_create_room() -> void:
	_apply_player_name()
	NetworkManager.create_server()
	GameManager.change_state(GameManager.GameState.LOBBY)

func _on_join_room() -> void:
	_apply_player_name()
	var address := address_input.text.strip_edges()
	if address.is_empty():
		address = "127.0.0.1"
	status_label.text = "Conectando a %s..." % address
	join_room_button.disabled = true
	NetworkManager.join_server(address)

func _on_joined_server() -> void:
	GameManager.change_state(GameManager.GameState.LOBBY)

func _on_connection_failed() -> void:
	status_label.text = "Falha na conexão. Tente novamente."
	join_room_button.disabled = false

func _on_exit() -> void:
	get_tree().quit()

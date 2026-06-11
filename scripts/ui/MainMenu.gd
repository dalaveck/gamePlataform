extends Control

@onready var name_input: LineEdit       = %NameInput
@onready var address_input: LineEdit    = %AddressInput
@onready var create_room_button: Button = %CreateRoomButton
@onready var join_room_button: Button   = %JoinRoomButton
@onready var exit_button: Button        = %ExitButton
@onready var status_label: Label        = %StatusLabel

func _ready() -> void:
	create_room_button.pressed.connect(_on_create_room)
	join_room_button.pressed.connect(_on_join_room)
	exit_button.pressed.connect(_on_exit)
	NetworkManager.joined_server.connect(_on_joined_server)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	name_input.text = SaveSystem.account_name

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

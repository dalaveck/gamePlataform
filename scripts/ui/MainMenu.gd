extends Control

@onready var create_room_button: Button = $VBoxContainer/CreateRoomButton
@onready var join_room_button: Button   = $VBoxContainer/JoinRoomButton
@onready var exit_button: Button        = $VBoxContainer/ExitButton

func _ready() -> void:
	create_room_button.pressed.connect(_on_create_room)
	join_room_button.pressed.connect(_on_join_room)
	exit_button.pressed.connect(_on_exit)

func _on_create_room() -> void:
	NetworkManager.create_server()
	GameManager.change_state(GameManager.GameState.LOBBY)

func _on_join_room() -> void:
	## TODO: abrir popup de input para IP
	var address := "127.0.0.1"  ## Placeholder
	NetworkManager.join_server(address)
	GameManager.change_state(GameManager.GameState.LOBBY)

func _on_exit() -> void:
	get_tree().quit()

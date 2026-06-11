extends Node

const PORT: int = 7777
const MAX_PLAYERS: int = 4

# ─── Descoberta de salas na LAN (broadcast UDP) ────────────
const DISCOVERY_PORT: int = 7778
const DISCOVERY_INTERVAL: float = 1.0
const DISCOVERY_MAGIC: String = "PLATCOOP_V1"

signal server_created
signal joined_server
signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal connection_failed
signal room_discovered(address: String, room_name: String)

var _broadcast_socket: PacketPeerUDP = null
var _listen_socket: PacketPeerUDP = null
var _broadcast_timer: float = 0.0

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func create_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		push_error("Failed to create server: %s" % error)
		return
	multiplayer.multiplayer_peer = peer
	SessionData.is_host = true
	SessionData.local_peer_id = 1
	SessionData.player_names[1] = SessionData.player_name
	stop_room_discovery()
	start_room_broadcast()
	server_created.emit()
	EventBus.lobby_player_joined.emit(1, SessionData.player_name)

func join_server(address: String) -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, PORT)
	if error != OK:
		push_error("Failed to join server: %s" % error)
		connection_failed.emit()
		return
	multiplayer.multiplayer_peer = peer

func disconnect_from_game() -> void:
	multiplayer.multiplayer_peer = null
	SessionData.is_host = false
	stop_room_broadcast()

# ─── Descoberta de salas ───────────────────────────────────
func start_room_broadcast() -> void:
	_broadcast_socket = PacketPeerUDP.new()
	_broadcast_socket.set_broadcast_enabled(true)
	_broadcast_socket.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	_broadcast_timer = 0.0

func stop_room_broadcast() -> void:
	if _broadcast_socket != null:
		_broadcast_socket.close()
		_broadcast_socket = null

func start_room_discovery() -> void:
	if _listen_socket != null:
		return
	_listen_socket = PacketPeerUDP.new()
	if _listen_socket.bind(DISCOVERY_PORT) != OK:
		push_warning("Não foi possível escutar a porta %d (outra instância aberta?)" % DISCOVERY_PORT)
		_listen_socket = null

func stop_room_discovery() -> void:
	if _listen_socket != null:
		_listen_socket.close()
		_listen_socket = null

func _process(delta: float) -> void:
	_process_broadcast(delta)
	_process_discovery()

func _process_broadcast(delta: float) -> void:
	if _broadcast_socket == null:
		return
	# Anuncia a sala apenas enquanto estiver no lobby
	if GameManager.current_state != GameManager.GameState.LOBBY:
		return
	_broadcast_timer -= delta
	if _broadcast_timer > 0.0:
		return
	_broadcast_timer = DISCOVERY_INTERVAL
	var message := "%s|Sala de %s" % [DISCOVERY_MAGIC, SessionData.player_name]
	_broadcast_socket.put_packet(message.to_utf8_buffer())

func _process_discovery() -> void:
	if _listen_socket == null:
		return
	while _listen_socket.get_available_packet_count() > 0:
		var packet := _listen_socket.get_packet().get_string_from_utf8()
		var address := _listen_socket.get_packet_ip()
		var parts := packet.split("|")
		if parts.size() == 2 and parts[0] == DISCOVERY_MAGIC:
			room_discovered.emit(address, parts[1])

# ─── Callbacks internos ────────────────────────────────────
func _on_peer_connected(peer_id: int) -> void:
	player_connected.emit(peer_id)
	EventBus.lobby_player_joined.emit(peer_id, "Player_%d" % peer_id)
	# Reenvia nossos dados para o peer que acabou de entrar
	sync_player_name.rpc_id(peer_id, SessionData.player_name)
	var my_char: CharacterData = SessionData.active_characters.get(multiplayer.get_unique_id(), null)
	if my_char != null:
		sync_character_data.rpc_id(peer_id, SaveSystem.serialize_character(my_char))

func _on_peer_disconnected(peer_id: int) -> void:
	player_disconnected.emit(peer_id)
	SessionData.active_characters.erase(peer_id)
	SessionData.player_names.erase(peer_id)
	SessionData.ready_states.erase(peer_id)
	EventBus.lobby_player_left.emit(peer_id)

func _on_connected_to_server() -> void:
	SessionData.local_peer_id = multiplayer.get_unique_id()
	SessionData.player_names[SessionData.local_peer_id] = SessionData.player_name
	joined_server.emit()
	sync_player_name.rpc(SessionData.player_name)

func _on_connection_failed() -> void:
	connection_failed.emit()

# ─── RPCs ──────────────────────────────────────────────────
@rpc("any_peer", "reliable")
func sync_player_name(player_name: String) -> void:
	var peer_id := multiplayer.get_remote_sender_id()
	SessionData.player_names[peer_id] = player_name
	EventBus.lobby_player_joined.emit(peer_id, player_name)

@rpc("any_peer", "reliable")
func sync_character_data(char_dict: Dictionary) -> void:
	var peer_id := multiplayer.get_remote_sender_id()
	var char_data := SaveSystem.deserialize_character(char_dict)
	SessionData.active_characters[peer_id] = char_data
	EventBus.lobby_character_selected.emit(peer_id, char_data.character_id)

@rpc("any_peer", "reliable")
func sync_ready_state(is_ready: bool) -> void:
	var peer_id := multiplayer.get_remote_sender_id()
	SessionData.set_player_ready(peer_id, is_ready)
	EventBus.lobby_ready_changed.emit(peer_id, is_ready)

@rpc("authority", "call_local", "reliable")
func go_to_map_select() -> void:
	GameManager.change_state(GameManager.GameState.MAP_SELECT)

@rpc("authority", "call_local", "reliable")
func start_game(map_resource_path: String) -> void:
	var map_data: MapData = load(map_resource_path)
	if map_data == null:
		push_error("Invalid map resource: %s" % map_resource_path)
		return
	SessionData.current_map = map_data
	EventBus.lobby_map_selected.emit(map_data)
	GameManager.change_state(GameManager.GameState.IN_GAME)

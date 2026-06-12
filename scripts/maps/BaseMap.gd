class_name BaseMap
extends Node2D

## Cena base de mapa: spawn dos jogadores, killzone e HUD.

const CHARACTER_SCENES: Dictionary = {
	CharacterData.CharacterClass.WARRIOR: "res://scenes/characters/warrior/Warrior.tscn",
	CharacterData.CharacterClass.CLERIC:  "res://scenes/characters/cleric/Cleric.tscn",
	CharacterData.CharacterClass.ARCHER:  "res://scenes/characters/archer/Archer.tscn",
}

const KILLZONE_DAMAGE: int = 25

@export var map_data: MapData = null

@onready var players_container: Node2D = %Players
@onready var spawn_points: Node2D      = %SpawnPoints
@onready var kill_zone: Area2D         = %KillZone
@onready var hud: CanvasLayer          = %HUD

var _local_player: BaseCharacter = null
var _parallax_bg: Node2D         = null
var _parallax_speeds: Array[float] = [0.18, 0.38]

func _ready() -> void:
	if SessionData.current_map == null:
		SessionData.current_map = map_data
	kill_zone.body_entered.connect(_on_kill_zone_entered)
	EventBus.map_started.emit(map_data)
	_parallax_bg = get_node_or_null("ParallaxBG")
	_spawn_players()

func _process(_delta: float) -> void:
	if _parallax_bg == null or _local_player == null:
		return
	var cam_x := _local_player.global_position.x
	var layers := _parallax_bg.get_children()
	for i in min(layers.size(), _parallax_speeds.size()):
		(layers[i] as Node2D).position.x = -cam_x * _parallax_speeds[i]

func _spawn_players() -> void:
	var local_id := multiplayer.get_unique_id()
	if SessionData.active_characters.is_empty():
		SessionData.active_characters[local_id] = _make_debug_character()

	var peer_ids: Array = SessionData.active_characters.keys()
	peer_ids.sort()
	var markers: Array[Node] = spawn_points.get_children()
	var index: int = 0
	for peer_id: int in peer_ids:
		var char_data: CharacterData = SessionData.active_characters[peer_id]
		var scene: PackedScene = load(CHARACTER_SCENES[char_data.character_class])
		var player: BaseCharacter = scene.instantiate()
		player.name = "Player_%d" % peer_id
		player.peer_id = peer_id
		player.character_data = char_data
		player.set_multiplayer_authority(peer_id)
		players_container.add_child(player)
		player.global_position = (markers[index % markers.size()] as Marker2D).global_position
		if peer_id == local_id:
			_local_player = player
			hud.bind(player)
		index += 1

func _make_debug_character() -> CharacterData:
	var data := CharacterData.new()
	data.character_id    = "debug"
	data.character_name  = "Debug"
	data.character_class = CharacterData.CharacterClass.WARRIOR
	data.strength        = 5
	data.skill           = 3
	data.constitution    = 4
	data.spirit          = 1
	return data

func _on_kill_zone_entered(body: Node2D) -> void:
	if body is BaseCharacter:
		var player := body as BaseCharacter
		var markers: Array[Node] = spawn_points.get_children()
		player.global_position = (markers[0] as Marker2D).global_position
		player.velocity = Vector2.ZERO
		if player.peer_id == multiplayer.get_unique_id():
			player.receive_damage.rpc(KILLZONE_DAMAGE + player.stats.defense, 0)

extends Control

const MAP_RESOURCES: Array[String] = [
	"res://data/maps/map01.tres",
]

@onready var map_list: VBoxContainer = %MapList
@onready var info_label: Label       = %InfoLabel

func _ready() -> void:
	if SessionData.is_host:
		info_label.text = "Escolha o mapa:"
		_build_map_buttons()
	else:
		info_label.text = "Aguardando o anfitrião escolher o mapa..."

func _build_map_buttons() -> void:
	for path: String in MAP_RESOURCES:
		var map_data: MapData = load(path)
		if map_data == null:
			continue
		var button := Button.new()
		button.text = "%s  —  %s  (Nv. recomendado: %d)" % [
			map_data.map_name,
			map_data.get_difficulty_string(),
			map_data.recommended_level,
		]
		button.add_theme_color_override("font_color", map_data.get_difficulty_color())
		button.pressed.connect(_on_map_chosen.bind(path))
		map_list.add_child(button)

func _on_map_chosen(path: String) -> void:
	NetworkManager.start_game.rpc(path)

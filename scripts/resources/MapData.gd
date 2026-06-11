class_name MapData
extends Resource

enum Difficulty { EASY, NORMAL, HARD, EXTREME }

@export var map_id: String = ""
@export var map_name: String = ""
@export var difficulty: Difficulty = Difficulty.EASY
@export var scene_path: String = ""
@export var thumbnail: Texture2D = null
@export var recommended_level: int = 1
@export var miniboss_id: String = ""
@export var boss_id: String = ""

func get_difficulty_string() -> String:
	match difficulty:
		Difficulty.EASY:    return "Fácil"
		Difficulty.NORMAL:  return "Normal"
		Difficulty.HARD:    return "Difícil"
		Difficulty.EXTREME: return "Extremo"
	return "?"

func get_difficulty_color() -> Color:
	match difficulty:
		Difficulty.EASY:    return Color.GREEN
		Difficulty.NORMAL:  return Color.YELLOW
		Difficulty.HARD:    return Color.ORANGE
		Difficulty.EXTREME: return Color.RED
	return Color.WHITE

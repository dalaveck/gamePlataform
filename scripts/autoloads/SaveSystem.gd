extends Node

const SAVE_DIR: String = "user://saves/"
const ACCOUNT_FILE: String = "user://saves/account.json"

## Dados da conta (persistidos em disco)
var account_money: int = 0
var account_name: String = "Hero"
var characters: Array[CharacterData] = []

func _ready() -> void:
	_ensure_save_dir()
	load_account()
	EventBus.money_gained.connect(_on_money_gained)
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.level_up.connect(_on_level_up)

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# ─── Conta ─────────────────────────────────────────────────
func save_account() -> void:
	var data := {
		"account_name": account_name,
		"money": account_money,
		"characters": characters.map(_serialize_character),
	}
	var file := FileAccess.open(ACCOUNT_FILE, FileAccess.WRITE)
	if file == null:
		push_error("Cannot open save file for writing")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func load_account() -> void:
	if not FileAccess.file_exists(ACCOUNT_FILE):
		return
	var file := FileAccess.open(ACCOUNT_FILE, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var result := JSON.parse_string(text)
	if result == null:
		push_error("Failed to parse save file")
		return
	var data: Dictionary = result
	account_name = data.get("account_name", "Hero")
	account_money = data.get("money", 0)
	characters.clear()
	for c_dict: Dictionary in data.get("characters", []):
		characters.append(_deserialize_character(c_dict))

# ─── Personagens ───────────────────────────────────────────
func create_character(char_name: String, char_class: CharacterData.CharacterClass) -> CharacterData:
	var data := CharacterData.new()
	data.character_id = _generate_id()
	data.character_name = char_name
	data.character_class = char_class
	_apply_class_base_stats(data)
	characters.append(data)
	save_account()
	return data

func get_character_by_id(id: String) -> CharacterData:
	for c: CharacterData in characters:
		if c.character_id == id:
			return c
	return null

func _apply_class_base_stats(data: CharacterData) -> void:
	match data.character_class:
		CharacterData.CharacterClass.WARRIOR:
			data.strength = 5
			data.skill = 3
			data.constitution = 4
			data.spirit = 1
		CharacterData.CharacterClass.CLERIC:
			data.strength = 2
			data.skill = 2
			data.constitution = 3
			data.spirit = 6
		CharacterData.CharacterClass.ARCHER:
			data.strength = 3
			data.skill = 5
			data.constitution = 2
			data.spirit = 2

# ─── Serialização ──────────────────────────────────────────
func _serialize_character(c: CharacterData) -> Dictionary:
	return {
		"character_id": c.character_id,
		"character_name": c.character_name,
		"character_class": c.character_class,
		"level": c.level,
		"experience": c.experience,
		"experience_to_next": c.experience_to_next,
		"strength": c.strength,
		"skill": c.skill,
		"constitution": c.constitution,
		"spirit": c.spirit,
		"attribute_points": c.attribute_points,
	}

func _deserialize_character(d: Dictionary) -> CharacterData:
	var c := CharacterData.new()
	c.character_id       = d.get("character_id", "")
	c.character_name     = d.get("character_name", "Unknown")
	c.character_class    = d.get("character_class", 0) as CharacterData.CharacterClass
	c.level              = d.get("level", 1)
	c.experience         = d.get("experience", 0)
	c.experience_to_next = d.get("experience_to_next", 100)
	c.strength           = d.get("strength", 1)
	c.skill              = d.get("skill", 1)
	c.constitution       = d.get("constitution", 1)
	c.spirit             = d.get("spirit", 1)
	c.attribute_points   = d.get("attribute_points", 0)
	return c

func _generate_id() -> String:
	return "%d_%d" % [Time.get_unix_time_from_system(), randi()]

# ─── Signal handlers ───────────────────────────────────────
func _on_money_gained(amount: int) -> void:
	account_money += amount
	save_account()

func _on_xp_gained(character_id: String, amount: int) -> void:
	var c := get_character_by_id(character_id)
	if c == null:
		return
	c.experience += amount
	while c.experience >= c.experience_to_next:
		c.experience -= c.experience_to_next
		c.level += 1
		c.experience_to_next = int(c.experience_to_next * 1.2)
		c.attribute_points += 3
		EventBus.level_up.emit(character_id, c.level)
	save_account()

func _on_level_up(character_id: String, new_level: int) -> void:
	print("Level up! Character %s is now level %d" % [character_id, new_level])

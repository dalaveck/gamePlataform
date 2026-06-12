extends CanvasLayer

## HUD do jogador local: barras de HP/MP/SP, nível, dinheiro e barra de habilidades.

@onready var hp_bar: ProgressBar    = %HPBar
@onready var mp_bar: ProgressBar    = %MPBar
@onready var sp_bar: ProgressBar    = %SPBar
@onready var level_label: Label     = %LevelLabel
@onready var money_label: Label     = %MoneyLabel
@onready var skill_bar: SkillBar    = %SkillBar

var _player: BaseCharacter = null

func _ready() -> void:
	EventBus.money_gained.connect(_on_money_gained)
	EventBus.level_up.connect(_on_level_up)
	_update_money()

func bind(player: BaseCharacter) -> void:
	_player = player
	player.stats.hp_changed.connect(_on_hp_changed)
	player.stats.mp_changed.connect(_on_mp_changed)
	player.stats.sp_changed.connect(_on_sp_changed)
	_on_hp_changed(player.stats.current_hp, player.stats.max_hp)
	_on_mp_changed(player.stats.current_mp, player.stats.max_mp)
	_on_sp_changed(player.stats.current_sp, player.stats.max_sp)
	_update_level()
	if skill_bar:
		skill_bar.bind(player)

func _on_hp_changed(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value     = current

func _on_mp_changed(current: int, maximum: int) -> void:
	mp_bar.max_value = maximum
	mp_bar.value     = current

func _on_sp_changed(current: int, maximum: int) -> void:
	sp_bar.max_value = maximum
	sp_bar.value     = current

func _on_money_gained(_amount: int) -> void:
	_update_money()

func _on_level_up(character_id: String, _new_level: int) -> void:
	if _player != null and _player.character_data.character_id == character_id:
		_update_level()

func _update_money() -> void:
	money_label.text = "🪙 %d" % SaveSystem.account_money

func _update_level() -> void:
	if _player == null:
		return
	level_label.text = "%s — Nv. %d" % [
		_player.character_data.character_name,
		_player.character_data.level,
	]

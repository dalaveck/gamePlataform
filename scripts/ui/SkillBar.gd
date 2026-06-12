class_name SkillBar
extends Control

## Barra com 4 slots de habilidade. Clique ou tecla 1-4 para selecionar.
## Slot 1 = ataque básico  |  Slots 2-4 = habilidades especiais

const SLOT_W    := 70
const SLOT_H    := 70
const SLOT_GAP  := 6
const LABEL_H   := 16

var _player: BaseCharacter = null
var _panels:    Array[Control] = []
var _name_lbls: Array[Label]   = []
var _cd_covers: Array[ColorRect] = []
var _skill_datas: Array         = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_slots()

func _build_slots() -> void:
	for i in 4:
		var x := i * (SLOT_W + SLOT_GAP)

		var bg := ColorRect.new()
		bg.name         = "Slot%d" % (i + 1)
		bg.position     = Vector2(x, 0)
		bg.size         = Vector2(SLOT_W, SLOT_H + LABEL_H)
		bg.color        = Color(0.08, 0.08, 0.08, 0.88)
		bg.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(bg)
		_panels.append(bg)

		var idx := i  # capture
		bg.gui_input.connect(func(e: InputEvent) -> void: _on_slot_input(e, idx + 1))

		var num := Label.new()
		num.text     = str(i + 1)
		num.position = Vector2(4, 2)
		num.size     = Vector2(18, 18)
		num.add_theme_font_size_override("font_size", 13)
		bg.add_child(num)

		var nm := Label.new()
		nm.text              = "Ataque" if i == 0 else "---"
		nm.position          = Vector2(2, SLOT_H - 26)
		nm.size              = Vector2(SLOT_W - 4, 40)
		nm.add_theme_font_size_override("font_size", 9)
		nm.autowrap_mode     = TextServer.AUTOWRAP_WORD_SMART
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bg.add_child(nm)
		_name_lbls.append(nm)

		var cover := ColorRect.new()
		cover.color    = Color(0.0, 0.0, 0.0, 0.72)
		cover.position = Vector2(0, 0)
		cover.size     = Vector2(SLOT_W, 0)
		bg.add_child(cover)
		_cd_covers.append(cover)

func bind(player: BaseCharacter) -> void:
	_player      = player
	_skill_datas = player.get_skill_datas()
	for i in 3:
		if i < _skill_datas.size():
			_name_lbls[i + 1].text = (_skill_datas[i] as SkillData).skill_name
		else:
			_name_lbls[i + 1].text = "---"

func _on_slot_input(event: InputEvent, slot: int) -> void:
	if event is InputEventMouseButton and \
	   (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and \
	   (event as InputEventMouseButton).pressed:
		if _player:
			_player.selected_skill = slot

func _process(_delta: float) -> void:
	if _player == null:
		return
	_refresh_selection()
	_refresh_cooldowns()

func _refresh_selection() -> void:
	for i in 4:
		var sel := (i + 1) == _player.selected_skill
		_panels[i].color = Color(0.20, 0.16, 0.02, 0.92) if sel else Color(0.08, 0.08, 0.08, 0.88)
		# Gold border simulation: override num label color
		var num_lbl := _panels[i].get_child(0) as Label
		num_lbl.modulate = Color(1.0, 0.85, 0.0) if sel else Color.WHITE

func _refresh_cooldowns() -> void:
	if _skill_datas.is_empty():
		return
	for i in min(_skill_datas.size(), 3):
		var sd := _skill_datas[i] as SkillData
		var remaining := _player.combat.get_skill_cooldown_ratio(sd.skill_id)
		var ratio     := clamp(remaining / sd.cooldown, 0.0, 1.0) if sd.cooldown > 0.0 else 0.0
		_cd_covers[i + 1].size.y = (SLOT_H + LABEL_H) * ratio

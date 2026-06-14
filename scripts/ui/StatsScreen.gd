class_name StatsScreen
extends Control

var _player: Node = null

var _points_label: Label = null
var _xp_label: Label = null
var _xp_bar: ProgressBar = null
var _attr_value_labels: Dictionary = {}   # attr_key -> Label
var _derived_labels: Dictionary = {}      # key -> Label
var _pending: Dictionary = {"strength": 0, "skill": 0, "constitution": 0, "spirit": 0}

const ATTR_DISPLAY: Array = [
	["strength",    "Forca"],
	["skill",       "Habilidade"],
	["constitution","Constituicao"],
	["spirit",      "Espirito"],
]

const DERIVED_DISPLAY: Array = [
	["atk",         "ATQ"],
	["defense",     "Defesa"],
	["max_hp",      "HP Max"],
	["max_mp",      "MP Max"],
	["max_sp",      "SP Max"],
	["magic_power", "Poder Magico"],
]

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()

func bind(player: Node) -> void:
	_player = player

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("open_stats"):
		if visible:
			_close()
		elif not get_tree().paused:
			_open()
		get_viewport().set_input_as_handled()

func _open() -> void:
	if _player == null:
		return
	_pending = {"strength": 0, "skill": 0, "constitution": 0, "spirit": 0}
	visible = true
	get_tree().paused = true
	_refresh()

func _close() -> void:
	visible = false
	get_tree().paused = false

func _build_ui() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.72)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 0)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Atributos do Personagem"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	_xp_label = Label.new()
	_xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_xp_label)

	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(0, 14)
	_xp_bar.show_percentage = false
	_xp_bar.modulate = Color(0.9, 0.8, 0.15, 1)
	vbox.add_child(_xp_bar)

	vbox.add_child(HSeparator.new())

	_points_label = Label.new()
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_points_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_points_label)

	for entry in ATTR_DISPLAY:
		var key: String  = entry[0]
		var name_: String = entry[1]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var lbl := Label.new()
		lbl.text = name_ + ":"
		lbl.custom_minimum_size = Vector2(140, 0)
		var val_lbl := Label.new()
		val_lbl.custom_minimum_size = Vector2(36, 0)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var btn_plus := Button.new()
		btn_plus.text = "+"
		btn_plus.custom_minimum_size = Vector2(32, 0)
		btn_plus.pressed.connect(func(): _add_point(key))
		var btn_minus := Button.new()
		btn_minus.text = "-"
		btn_minus.custom_minimum_size = Vector2(32, 0)
		btn_minus.pressed.connect(func(): _remove_point(key))
		row.add_child(lbl)
		row.add_child(val_lbl)
		row.add_child(btn_plus)
		row.add_child(btn_minus)
		vbox.add_child(row)
		_attr_value_labels[key] = val_lbl

	vbox.add_child(HSeparator.new())

	var derived_lbl := Label.new()
	derived_lbl.text = "Stats derivados (sem equipamentos)"
	derived_lbl.add_theme_font_size_override("font_size", 14)
	derived_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	vbox.add_child(derived_lbl)

	var derived_grid := GridContainer.new()
	derived_grid.columns = 2
	derived_grid.add_theme_constant_override("h_separation", 20)
	derived_grid.add_theme_constant_override("v_separation", 4)
	vbox.add_child(derived_grid)

	for entry in DERIVED_DISPLAY:
		var key: String   = entry[0]
		var dname: String = entry[1]
		var k_lbl := Label.new()
		k_lbl.text = dname + ":"
		var v_lbl := Label.new()
		v_lbl.text = "—"
		derived_grid.add_child(k_lbl)
		derived_grid.add_child(v_lbl)
		_derived_labels[key] = v_lbl

	vbox.add_child(HSeparator.new())

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)

	var btn_apply := Button.new()
	btn_apply.text = "Aplicar"
	btn_apply.custom_minimum_size = Vector2(100, 0)
	btn_apply.pressed.connect(_apply)
	btn_row.add_child(btn_apply)

	var btn_close := Button.new()
	btn_close.text = "Fechar"
	btn_close.custom_minimum_size = Vector2(100, 0)
	btn_close.pressed.connect(_close)
	btn_row.add_child(btn_close)

func _used_points() -> int:
	var total := 0
	for v in _pending.values():
		total += v
	return total

func _add_point(attr: String) -> void:
	if _player == null:
		return
	if _used_points() >= (_player.character_data as CharacterData).attribute_points:
		return
	_pending[attr] += 1
	_refresh()

func _remove_point(attr: String) -> void:
	if _pending.get(attr, 0) <= 0:
		return
	_pending[attr] -= 1
	_refresh()

func _refresh() -> void:
	if _player == null:
		return
	var cd: CharacterData = _player.character_data
	var remaining := cd.attribute_points - _used_points()
	_points_label.text = "Pontos disponiveis: %d" % remaining

	_xp_bar.max_value = cd.experience_to_next
	_xp_bar.value = cd.experience
	_xp_label.text = "Nivel %d  —  XP: %d / %d" % [cd.level, cd.experience, cd.experience_to_next]

	var str_v := cd.strength    + _pending.get("strength",    0)
	var skl_v := cd.skill       + _pending.get("skill",       0)
	var con_v := cd.constitution+ _pending.get("constitution",0)
	var spr_v := cd.spirit      + _pending.get("spirit",      0)

	_attr_value_labels["strength"].text     = str(str_v)
	_attr_value_labels["skill"].text        = str(skl_v)
	_attr_value_labels["constitution"].text = str(con_v)
	_attr_value_labels["spirit"].text       = str(spr_v)

	_derived_labels["atk"].text         = str(10 + str_v * 5)
	_derived_labels["defense"].text     = str(5  + con_v * 3)
	_derived_labels["max_hp"].text      = str(100 + con_v * 20)
	_derived_labels["max_mp"].text      = str(50  + spr_v * 15)
	_derived_labels["max_sp"].text      = str(80  + skl_v * 10)
	_derived_labels["magic_power"].text = str(spr_v * 5)

func _apply() -> void:
	if _player == null:
		return
	var used := _used_points()
	if used == 0:
		_close()
		return
	var cd: CharacterData = _player.character_data
	cd.strength     += _pending.get("strength",     0)
	cd.skill        += _pending.get("skill",        0)
	cd.constitution += _pending.get("constitution", 0)
	cd.spirit       += _pending.get("spirit",       0)
	cd.attribute_points -= used
	_player.stats.recalculate_from(cd)
	SaveSystem.save_account()
	_close()

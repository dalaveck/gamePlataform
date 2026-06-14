class_name PauseMenu
extends Control

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_close()
		elif not get_tree().paused:
			_open()
		get_viewport().set_input_as_handled()

func _open() -> void:
	visible = true
	get_tree().paused = true

func _close() -> void:
	visible = false
	get_tree().paused = false

func _build_ui() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.72)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 0)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "PAUSA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var audio_section := Label.new()
	audio_section.text = "Audio"
	audio_section.add_theme_font_size_override("font_size", 16)
	vbox.add_child(audio_section)

	_add_slider(vbox, "Volume Geral",
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))),
		_on_master_changed)

	var music_bus := AudioServer.get_bus_index("Music")
	var music_vol := db_to_linear(AudioServer.get_bus_volume_db(music_bus)) if music_bus >= 0 else 1.0
	_add_slider(vbox, "Volume Musica", music_vol, _on_music_changed)

	vbox.add_child(HSeparator.new())

	var fs_check := CheckButton.new()
	fs_check.text = "Tela Cheia"
	fs_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs_check.toggled.connect(_on_fullscreen_toggled)
	vbox.add_child(fs_check)

	vbox.add_child(HSeparator.new())

	var btn_continue := Button.new()
	btn_continue.text = "Continuar"
	btn_continue.pressed.connect(_close)
	vbox.add_child(btn_continue)

	var btn_menu := Button.new()
	btn_menu.text = "Menu Principal"
	btn_menu.pressed.connect(_go_to_menu)
	vbox.add_child(btn_menu)

	var btn_reset := Button.new()
	btn_reset.text = "Resetar Jogo"
	btn_reset.modulate = Color(1.0, 0.45, 0.45, 1)
	btn_reset.pressed.connect(_reset_game)
	vbox.add_child(btn_reset)

func _add_slider(parent: VBoxContainer, label_text: String, initial: float, callback: Callable) -> void:
	var lbl := Label.new()
	lbl.text = label_text
	parent.add_child(lbl)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = initial
	slider.custom_minimum_size = Vector2(320, 0)
	slider.value_changed.connect(callback)
	parent.add_child(slider)

func _on_master_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Music")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _reset_game() -> void:
	get_tree().paused = false
	SaveSystem.account_money = 0
	SaveSystem.characters.clear()
	SaveSystem.save_account()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

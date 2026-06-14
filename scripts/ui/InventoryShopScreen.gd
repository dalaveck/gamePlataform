class_name InventoryShopScreen
extends Control

var _player: Node = null

var _gold_label: Label = null
var _slot_labels: Dictionary = {}       # ItemData.ItemType -> Label
var _shop_list: VBoxContainer = null
var _inv_list: VBoxContainer = null
var _shop_scroll: ScrollContainer = null
var _inv_scroll: ScrollContainer = null

const SLOT_ORDER: Array = [
	ItemData.ItemType.WEAPON,
	ItemData.ItemType.ARMOR,
	ItemData.ItemType.HELMET,
	ItemData.ItemType.BOOTS,
	ItemData.ItemType.BRACELET,
	ItemData.ItemType.NECKLACE,
	ItemData.ItemType.RING,
]

const SLOT_LABELS: Dictionary = {
	ItemData.ItemType.WEAPON:   "Arma",
	ItemData.ItemType.ARMOR:    "Roupa",
	ItemData.ItemType.HELMET:   "Capacete",
	ItemData.ItemType.BOOTS:    "Botas",
	ItemData.ItemType.BRACELET: "Bracelete",
	ItemData.ItemType.NECKLACE: "Colar",
	ItemData.ItemType.RING:     "Anel",
}

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
	if event.is_action_pressed("open_inventory"):
		if visible:
			_close()
		elif not get_tree().paused:
			_open()
		get_viewport().set_input_as_handled()

func _open() -> void:
	if _player == null:
		return
	visible = true
	get_tree().paused = true
	_refresh_all()

func _close() -> void:
	visible = false
	get_tree().paused = false

func _build_ui() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.72)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(780, 540)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)

	# ── Left column: equipped slots ──────────────────────────
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(230, 0)
	left.add_theme_constant_override("separation", 8)
	hbox.add_child(left)

	var eq_title := Label.new()
	eq_title.text = "Equipamentos"
	eq_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eq_title.add_theme_font_size_override("font_size", 18)
	left.add_child(eq_title)

	_gold_label = Label.new()
	_gold_label.text = "Ouro: 0"
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	left.add_child(_gold_label)

	left.add_child(HSeparator.new())

	for slot_type in SLOT_ORDER:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		var name_lbl := Label.new()
		name_lbl.text = SLOT_LABELS[slot_type] + ":"
		name_lbl.custom_minimum_size = Vector2(76, 0)
		var item_lbl := Label.new()
		item_lbl.text = "—"
		item_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_lbl.clip_text = true
		var unequip_btn := Button.new()
		unequip_btn.text = "X"
		unequip_btn.custom_minimum_size = Vector2(26, 0)
		unequip_btn.pressed.connect(func(): _unequip(slot_type))
		row.add_child(name_lbl)
		row.add_child(item_lbl)
		row.add_child(unequip_btn)
		left.add_child(row)
		_slot_labels[slot_type] = item_lbl

	left.add_child(HSeparator.new())

	var close_btn := Button.new()
	close_btn.text = "Fechar  [I / ESC]"
	close_btn.pressed.connect(_close)
	left.add_child(close_btn)

	# ── Right column: shop / inventory tabs ──────────────────
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	hbox.add_child(right)

	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 0)
	right.add_child(tab_row)

	var tab_shop := Button.new()
	tab_shop.text = "Loja"
	tab_shop.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_shop.pressed.connect(func(): _switch_tab(true))
	tab_row.add_child(tab_shop)

	var tab_inv := Button.new()
	tab_inv.text = "Inventario"
	tab_inv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_inv.pressed.connect(func(): _switch_tab(false))
	tab_row.add_child(tab_inv)

	_shop_scroll = ScrollContainer.new()
	_shop_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_shop_scroll)
	_shop_list = VBoxContainer.new()
	_shop_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shop_list.add_theme_constant_override("separation", 4)
	_shop_scroll.add_child(_shop_list)

	_inv_scroll = ScrollContainer.new()
	_inv_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inv_scroll.visible = false
	right.add_child(_inv_scroll)
	_inv_list = VBoxContainer.new()
	_inv_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inv_list.add_theme_constant_override("separation", 4)
	_inv_scroll.add_child(_inv_list)

func _switch_tab(show_shop: bool) -> void:
	_shop_scroll.visible = show_shop
	_inv_scroll.visible  = not show_shop
	if show_shop:
		_refresh_shop()
	else:
		_refresh_inventory()

func _refresh_all() -> void:
	_gold_label.text = "Ouro: %d" % SaveSystem.account_money
	_refresh_slots()
	if _shop_scroll.visible:
		_refresh_shop()
	else:
		_refresh_inventory()

func _refresh_slots() -> void:
	if _player == null:
		return
	var cd: CharacterData = _player.character_data
	for slot_type in SLOT_ORDER:
		var item := cd.get_equipped_in_slot(slot_type)
		_slot_labels[slot_type].text = item.item_name if item else "—"

func _refresh_shop() -> void:
	for child in _shop_list.get_children():
		child.queue_free()
	if _player == null:
		return
	var cd: CharacterData = _player.character_data
	for item: ItemData in ItemDatabase.get_for_class(cd.character_class):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var type_lbl := Label.new()
		type_lbl.text = "[%s]" % item.get_type_name()
		type_lbl.custom_minimum_size = Vector2(76, 0)
		type_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		var name_lbl := Label.new()
		name_lbl.text = item.item_name
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var price_lbl := Label.new()
		price_lbl.text = "%d G" % item.price
		price_lbl.custom_minimum_size = Vector2(56, 0)
		price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		price_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		var buy_btn := Button.new()
		buy_btn.text = "Comprar"
		buy_btn.custom_minimum_size = Vector2(72, 0)
		buy_btn.disabled = SaveSystem.account_money < item.price
		buy_btn.pressed.connect(func(): _buy(item))
		row.add_child(type_lbl)
		row.add_child(name_lbl)
		row.add_child(price_lbl)
		row.add_child(buy_btn)
		_shop_list.add_child(row)

func _refresh_inventory() -> void:
	for child in _inv_list.get_children():
		child.queue_free()
	if _player == null:
		return
	var cd: CharacterData = _player.character_data
	if cd.inventory.is_empty():
		var empty := Label.new()
		empty.text = "Inventario vazio"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_inv_list.add_child(empty)
		return
	for item_id: String in cd.inventory:
		var item := ItemDatabase.get_item(item_id)
		if item == null:
			continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var type_lbl := Label.new()
		type_lbl.text = "[%s]" % item.get_type_name()
		type_lbl.custom_minimum_size = Vector2(76, 0)
		type_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		var name_lbl := Label.new()
		name_lbl.text = item.item_name
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sell_price := Label.new()
		sell_price.text = "+%dG" % (item.price / 2)
		sell_price.custom_minimum_size = Vector2(48, 0)
		sell_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		sell_price.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
		var equip_btn := Button.new()
		equip_btn.text = "Equipar"
		equip_btn.custom_minimum_size = Vector2(64, 0)
		equip_btn.pressed.connect(func(): _equip(item))
		var sell_btn := Button.new()
		sell_btn.text = "Vender"
		sell_btn.custom_minimum_size = Vector2(64, 0)
		sell_btn.pressed.connect(func(): _sell(item))
		row.add_child(type_lbl)
		row.add_child(name_lbl)
		row.add_child(sell_price)
		row.add_child(equip_btn)
		row.add_child(sell_btn)
		_inv_list.add_child(row)

func _buy(item: ItemData) -> void:
	if SaveSystem.account_money < item.price:
		return
	SaveSystem.account_money -= item.price
	var cd: CharacterData = _player.character_data
	var existing := cd.get_equipped_in_slot(item.item_type)
	if existing == null:
		cd.set_equipped_in_slot(item)
		_player.stats.recalculate_from(cd)
	else:
		cd.inventory.append(item.item_id)
	SaveSystem.save_account()
	EventBus.hud_update_requested.emit()
	_refresh_all()

func _equip(item: ItemData) -> void:
	var cd: CharacterData = _player.character_data
	var idx := cd.inventory.find(item.item_id)
	if idx >= 0:
		cd.inventory.remove_at(idx)
	var old := cd.get_equipped_in_slot(item.item_type)
	if old != null:
		cd.inventory.append(old.item_id)
	cd.set_equipped_in_slot(item)
	_player.stats.recalculate_from(cd)
	SaveSystem.save_account()
	_refresh_all()

func _unequip(slot_type: ItemData.ItemType) -> void:
	var cd: CharacterData = _player.character_data
	var item := cd.clear_equipped_in_slot(slot_type)
	if item != null:
		cd.inventory.append(item.item_id)
		_player.stats.recalculate_from(cd)
		SaveSystem.save_account()
	_refresh_all()

func _sell(item: ItemData) -> void:
	var cd: CharacterData = _player.character_data
	var idx := cd.inventory.find(item.item_id)
	if idx < 0:
		return
	cd.inventory.remove_at(idx)
	SaveSystem.account_money += item.price / 2
	SaveSystem.save_account()
	EventBus.hud_update_requested.emit()
	_refresh_all()

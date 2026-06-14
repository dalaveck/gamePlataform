extends Node

## Banco de dados de todos os itens do jogo.
## Carregado de data/config/items.json — edite o JSON para adicionar/modificar itens.
## Registrado como autoload ANTES do SaveSystem para estar disponível na desserialização.

const ITEMS_JSON := "res://data/config/items.json"

var _items: Dictionary = {}  ## item_id -> ItemData

func _ready() -> void:
	_load_from_json()

func get_item(id: String) -> ItemData:
	return _items.get(id, null)

func get_all() -> Array:
	return _items.values()

## Retorna todos os itens que o personagem pode usar (classe + universais),
## ordenados por tipo e depois por preço.
func get_for_class(cc: CharacterData.CharacterClass) -> Array:
	var result: Array = []
	for item: ItemData in _items.values():
		if item.can_be_equipped_by(cc):
			result.append(item)
	result.sort_custom(func(a: ItemData, b: ItemData) -> bool:
		if a.item_type != b.item_type:
			return a.item_type < b.item_type
		return a.price < b.price
	)
	return result

# ─── Carregamento ──────────────────────────────────────────
func _load_from_json() -> void:
	var file := FileAccess.open(ITEMS_JSON, FileAccess.READ)
	if file == null:
		push_error("ItemDatabase: nao foi possivel abrir %s — usando lista vazia." % ITEMS_JSON)
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Array:
		push_error("ItemDatabase: falha ao parsear %s" % ITEMS_JSON)
		return
	for entry in parsed:
		if not entry is Dictionary:
			continue
		var id: String = entry.get("id", "")
		if id == "":
			continue   # entrada de comentario, ignorar
		_register(entry)

func _register(d: Dictionary) -> void:
	var item := ItemData.new()
	item.item_id           = d.get("id",   "")
	item.item_name         = d.get("name", "")
	item.item_type         = _parse_type(d.get("type", "WEAPON"))
	item.class_restriction = _parse_restriction(d.get("restriction", "ALL"))
	item.price             = d.get("price",           0)
	item.bonus_atk         = d.get("bonus_atk",       0)
	item.bonus_defense     = d.get("bonus_defense",   0)
	item.bonus_magic_power = d.get("bonus_magic_power", 0)
	item.bonus_strength    = d.get("bonus_strength",  0)
	item.bonus_skill       = d.get("bonus_skill",     0)
	item.bonus_constitution= d.get("bonus_constitution", 0)
	item.bonus_spirit      = d.get("bonus_spirit",    0)
	_items[item.item_id] = item

func _parse_type(s: String) -> ItemData.ItemType:
	match s:
		"WEAPON":    return ItemData.ItemType.WEAPON
		"ARMOR":     return ItemData.ItemType.ARMOR
		"HELMET":    return ItemData.ItemType.HELMET
		"BOOTS":     return ItemData.ItemType.BOOTS
		"BRACELET":  return ItemData.ItemType.BRACELET
		"NECKLACE":  return ItemData.ItemType.NECKLACE
		"RING":      return ItemData.ItemType.RING
		"CONSUMABLE":return ItemData.ItemType.CONSUMABLE
	push_warning("ItemDatabase: tipo desconhecido '%s', usando WEAPON" % s)
	return ItemData.ItemType.WEAPON

func _parse_restriction(s: String) -> ItemData.ClassRestriction:
	match s:
		"ALL":     return ItemData.ClassRestriction.ALL
		"WARRIOR": return ItemData.ClassRestriction.WARRIOR
		"CLERIC":  return ItemData.ClassRestriction.CLERIC
		"ARCHER":  return ItemData.ClassRestriction.ARCHER
	push_warning("ItemDatabase: restricao desconhecida '%s', usando ALL" % s)
	return ItemData.ClassRestriction.ALL

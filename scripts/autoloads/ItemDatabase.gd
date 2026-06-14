extends Node

## Banco de dados de todos os itens do jogo.
## Registrado como autoload ANTES do SaveSystem para estar disponível na desserialização.

var _items: Dictionary = {}  ## item_id -> ItemData

func _ready() -> void:
	_register_all_items()

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

# ─── Registro ──────────────────────────────────────────────
func _register_all_items() -> void:
	# ── Guerreiro: Armas ──────────────────────────────────────
	_add("sword_iron",    "Espada de Ferro",        ItemData.ItemType.WEAPON, ItemData.ClassRestriction.WARRIOR,  80,  {atk=15})
	_add("axe_war",       "Machado de Guerra",      ItemData.ItemType.WEAPON, ItemData.ClassRestriction.WARRIOR,  160, {atk=28, str=1})
	_add("sword_dragon",  "Espada do Dragão",       ItemData.ItemType.WEAPON, ItemData.ClassRestriction.WARRIOR,  340, {atk=45, str=3})
	# ── Guerreiro: Armaduras ──────────────────────────────────
	_add("chainmail",     "Cota de Malha",          ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.WARRIOR,  100, {def_=20})
	_add("plate_armor",   "Armadura de Placas",     ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.WARRIOR,  210, {def_=36, con=1})
	_add("warrior_armor", "Armadura do Guerreiro",  ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.WARRIOR,  440, {def_=52, con=3})
	# ── Guerreiro: Elmos ──────────────────────────────────────
	_add("iron_helm",     "Elmo de Ferro",          ItemData.ItemType.HELMET, ItemData.ClassRestriction.WARRIOR,  60,  {def_=10})
	_add("battle_helm",   "Elmo de Batalha",        ItemData.ItemType.HELMET, ItemData.ClassRestriction.WARRIOR,  140, {def_=18, con=1})
	_add("warrior_helm",  "Elmo do Guerreiro",      ItemData.ItemType.HELMET, ItemData.ClassRestriction.WARRIOR,  280, {def_=28, con=2})
	# ── Clérigo: Armas ────────────────────────────────────────
	_add("birch_wand",    "Varinha de Bétula",      ItemData.ItemType.WEAPON, ItemData.ClassRestriction.CLERIC,   70,  {mag=15})
	_add("forest_staff",  "Cajado do Bosque",       ItemData.ItemType.WEAPON, ItemData.ClassRestriction.CLERIC,   150, {mag=28, spr=2})
	_add("holy_staff",    "Cajado Sagrado",         ItemData.ItemType.WEAPON, ItemData.ClassRestriction.CLERIC,   320, {mag=48, spr=4})
	# ── Clérigo: Armaduras ────────────────────────────────────
	_add("novice_robe",   "Roupão de Noviço",       ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.CLERIC,   50,  {def_=8})
	_add("sacred_robe",   "Roupão Sagrado",         ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.CLERIC,   120, {def_=16, spr=1})
	_add("high_robe",     "Vestes do Alto Clérigo", ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.CLERIC,   280, {def_=24, spr=3})
	# ── Clérigo: Elmos ────────────────────────────────────────
	_add("silk_hood",     "Capuz de Seda",          ItemData.ItemType.HELMET, ItemData.ClassRestriction.CLERIC,   55,  {spr=1})
	_add("blessed_hood",  "Capuz Abençoado",        ItemData.ItemType.HELMET, ItemData.ClassRestriction.CLERIC,   130, {spr=2, mag=8})
	_add("holy_hood",     "Capuz Sagrado",          ItemData.ItemType.HELMET, ItemData.ClassRestriction.CLERIC,   260, {spr=3, mag=15})
	# ── Arqueiro: Armas ───────────────────────────────────────
	_add("short_bow",     "Arco Curto",             ItemData.ItemType.WEAPON, ItemData.ClassRestriction.ARCHER,   70,  {atk=12})
	_add("crossbow",      "Besta de Campanha",      ItemData.ItemType.WEAPON, ItemData.ClassRestriction.ARCHER,   160, {atk=24, skl=2})
	_add("elven_bow",     "Arco Élfico",            ItemData.ItemType.WEAPON, ItemData.ClassRestriction.ARCHER,   320, {atk=40, skl=3})
	# ── Arqueiro: Armaduras ───────────────────────────────────
	_add("hard_leather",  "Couro Endurecido",       ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.ARCHER,   80,  {def_=12})
	_add("reinf_leather", "Couro Reforçado",        ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.ARCHER,   175, {def_=22, skl=1})
	_add("hunter_armor",  "Armadura do Caçador",    ItemData.ItemType.ARMOR,  ItemData.ClassRestriction.ARCHER,   340, {def_=34, skl=2})
	# ── Arqueiro: Elmos ───────────────────────────────────────
	_add("ranger_hood",   "Capuz do Ranger",        ItemData.ItemType.HELMET, ItemData.ClassRestriction.ARCHER,   55,  {skl=1})
	_add("shadow_hood",   "Capuz das Sombras",      ItemData.ItemType.HELMET, ItemData.ClassRestriction.ARCHER,   130, {skl=2, atk=5})
	_add("eagle_hood",    "Capuz da Águia",         ItemData.ItemType.HELMET, ItemData.ClassRestriction.ARCHER,   260, {skl=3, atk=8})
	# ── Universais: Botas ─────────────────────────────────────
	_add("leather_boots", "Botas de Couro",         ItemData.ItemType.BOOTS,    ItemData.ClassRestriction.ALL, 40,  {def_=4})
	_add("swift_boots",   "Botas Velozes",          ItemData.ItemType.BOOTS,    ItemData.ClassRestriction.ALL, 90,  {skl=1, def_=5})
	_add("iron_boots",    "Botas de Ferro",         ItemData.ItemType.BOOTS,    ItemData.ClassRestriction.ALL, 120, {def_=10, con=1})
	# ── Universais: Colares ───────────────────────────────────
	_add("amulet_str",    "Amuleto de Força",       ItemData.ItemType.NECKLACE, ItemData.ClassRestriction.ALL, 90,  {str=2})
	_add("amulet_magic",  "Colar de Magia",         ItemData.ItemType.NECKLACE, ItemData.ClassRestriction.ALL, 90,  {spr=2})
	_add("gem_prot",      "Gema Protetora",         ItemData.ItemType.NECKLACE, ItemData.ClassRestriction.ALL, 90,  {con=2})
	_add("pearl_wisdom",  "Pérola da Sabedoria",    ItemData.ItemType.NECKLACE, ItemData.ClassRestriction.ALL, 200, {spr=3, skl=1})
	# ── Universais: Anéis ─────────────────────────────────────
	_add("ring_agility",  "Anel de Agilidade",      ItemData.ItemType.RING,     ItemData.ClassRestriction.ALL, 60,  {skl=1})
	_add("ring_vigor",    "Anel de Vigor",          ItemData.ItemType.RING,     ItemData.ClassRestriction.ALL, 60,  {con=1})
	_add("ring_mana",     "Anel de Mana",           ItemData.ItemType.RING,     ItemData.ClassRestriction.ALL, 60,  {spr=1})
	_add("ring_power",    "Anel do Poder",          ItemData.ItemType.RING,     ItemData.ClassRestriction.ALL, 150, {str=2, atk=4})
	# ── Universais: Braceletes ────────────────────────────────
	_add("brace_power",   "Bracelete de Poder",     ItemData.ItemType.BRACELET, ItemData.ClassRestriction.ALL, 80,  {str=1, atk=5})
	_add("brace_guard",   "Bracelete de Guarda",    ItemData.ItemType.BRACELET, ItemData.ClassRestriction.ALL, 80,  {def_=8})
	_add("brace_magic",   "Bracelete Mágico",       ItemData.ItemType.BRACELET, ItemData.ClassRestriction.ALL, 80,  {spr=1, mag=5})
	_add("brace_iron",    "Bracelete de Ferro",     ItemData.ItemType.BRACELET, ItemData.ClassRestriction.ALL, 150, {def_=14, con=1})

func _add(id: String, name: String, type: ItemData.ItemType,
		restriction: ItemData.ClassRestriction, price: int, bonuses: Dictionary = {}) -> void:
	var item := ItemData.new()
	item.item_id           = id
	item.item_name         = name
	item.item_type         = type
	item.class_restriction = restriction
	item.price             = price
	item.bonus_atk         = bonuses.get("atk",  0)
	item.bonus_defense     = bonuses.get("def_", 0)
	item.bonus_magic_power = bonuses.get("mag",  0)
	item.bonus_strength    = bonuses.get("str",  0)
	item.bonus_skill       = bonuses.get("skl",  0)
	item.bonus_constitution = bonuses.get("con", 0)
	item.bonus_spirit      = bonuses.get("spr",  0)
	_items[id] = item

extends Node

# ─── Combate ───────────────────────────────────────────────
signal enemy_killed(enemy_data: EnemyData, killer_peer_id: int)
signal player_damaged(peer_id: int, amount: int)
signal player_died(peer_id: int)
signal player_healed(peer_id: int, amount: int)

# ─── Progressão ────────────────────────────────────────────
signal xp_gained(character_id: String, amount: int)
signal money_gained(amount: int)
signal level_up(character_id: String, new_level: int)
signal attribute_points_gained(character_id: String, points: int)

# ─── Mapa ──────────────────────────────────────────────────
signal map_started(map_data: MapData)
signal miniboss_defeated(map_id: String)
signal boss_defeated(map_id: String)
signal map_completed(map_id: String)

# ─── Lobby / Sala ──────────────────────────────────────────
signal lobby_player_joined(peer_id: int, player_name: String)
signal lobby_player_left(peer_id: int)
signal lobby_ready_changed(peer_id: int, is_ready: bool)
signal lobby_character_selected(peer_id: int, character_id: String)
signal lobby_map_selected(map_data: MapData)

# ─── UI ────────────────────────────────────────────────────
signal hud_update_requested
signal shop_opened(class_restriction: int)
signal shop_closed

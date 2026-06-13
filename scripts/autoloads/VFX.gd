extends Node

## Efeitos visuais procedurais (sem assets externos).
## Gera partículas, anéis de choque e números flutuantes no current_scene.
## Chamado em pontos de dano/cura e nos ataques especiais dos personagens.

func _scene() -> Node:
	return get_tree().current_scene if get_tree() else null

# ─── Feedback de combate ───────────────────────────────────
func hit(pos: Vector2, color: Color = Color(1.0, 0.45, 0.35)) -> void:
	_burst(pos, color, 12, 170.0, 0.4, 2.6)

func damage_number(pos: Vector2, amount: int, color: Color = Color(1.0, 0.6, 0.4)) -> void:
	floating_text(pos, str(amount), color)

func heal(pos: Vector2, amount: int = 0) -> void:
	_burst(pos, Color(0.4, 1.0, 0.55), 14, 80.0, 0.7, -40.0)
	_ring(pos, Color(0.5, 1.0, 0.6), 28.0, 0.45)
	if amount > 0:
		floating_text(pos, "+%d" % amount, Color(0.55, 1.0, 0.65))

# ─── Efeitos dos ataques especiais ─────────────────────────
func special(pos: Vector2, kind: String) -> void:
	match kind:
		"spin":            # giratório do guerreiro
			_ring(pos, Color(1.0, 0.9, 0.4), 96.0, 0.35)
			_burst(pos, Color(1.0, 0.85, 0.3), 18, 220.0, 0.4, 200.0)
		"power":           # super ataque do guerreiro
			_burst(pos, Color(1.0, 0.4, 0.15), 22, 280.0, 0.45, 250.0)
			_ring(pos, Color(1.0, 0.5, 0.2), 50.0, 0.3)
		"protect":         # buff de proteção
			_ring(pos, Color(0.4, 0.7, 1.0), 60.0, 0.5)
			_burst(pos, Color(0.5, 0.8, 1.0), 14, 90.0, 0.6, -30.0)
		"heal_cast":       # conjuração da cura maior
			_ring(pos, Color(0.5, 1.0, 0.6), 80.0, 0.5)
			_burst(pos, Color(0.6, 1.0, 0.7), 18, 110.0, 0.7, -60.0)
		"fireball":        # bola de fogo
			_burst(pos, Color(1.0, 0.3, 0.05), 16, 130.0, 0.4, 120.0)
		"curse":           # maldição imperdoável
			_burst(pos, Color(0.6, 0.1, 0.9), 16, 120.0, 0.5, 60.0)
			_ring(pos, Color(0.55, 0.0, 0.9), 26.0, 0.4)
		"multishot":       # flechas múltiplas
			_burst(pos, Color(1.0, 0.95, 0.5), 10, 140.0, 0.3, 150.0)
		"penetrate":       # flecha avassaladora
			_burst(pos, Color(0.4, 0.9, 1.0), 12, 160.0, 0.35, 100.0)
		"explosion":       # impacto da flecha explosiva
			_burst(pos, Color(1.0, 0.55, 0.1), 24, 260.0, 0.5, 220.0)
			_ring(pos, Color(1.0, 0.6, 0.15), 70.0, 0.35)
		"death":           # inimigo derrotado
			_burst(pos, Color(0.85, 0.85, 0.9), 18, 200.0, 0.5, 260.0)
			_ring(pos, Color(0.9, 0.9, 0.95), 34.0, 0.4)
		_:
			_burst(pos, Color.WHITE, 12, 150.0, 0.4, 200.0)

# ─── Primitivas ────────────────────────────────────────────
func _burst(pos: Vector2, color: Color, amount: int, vmax: float, life: float, psize: float, grav: float = 260.0) -> void:
	var s := _scene()
	if s == null:
		return
	var p := CPUParticles2D.new()
	p.emitting              = true
	p.one_shot              = true
	p.amount                = amount
	p.lifetime              = life
	p.explosiveness         = 1.0
	p.direction             = Vector2.UP
	p.spread                = 180.0
	p.initial_velocity_min  = vmax * 0.4
	p.initial_velocity_max  = vmax
	p.gravity               = Vector2(0.0, grav)
	p.scale_amount_min      = psize * 1.6
	p.scale_amount_max      = psize * 3.0
	p.color                 = color
	p.z_index               = 50
	s.add_child(p)
	p.global_position = pos
	p.finished.connect(p.queue_free)

func _ring(pos: Vector2, color: Color, radius: float, duration: float = 0.4) -> void:
	var s := _scene()
	if s == null:
		return
	var poly := Polygon2D.new()
	poly.polygon  = _circle_points(radius, 24)
	poly.color    = Color(color.r, color.g, color.b, 0.45)
	poly.z_index  = 49
	s.add_child(poly)
	poly.global_position = pos
	poly.scale = Vector2(0.2, 0.2)
	var tw := poly.create_tween()
	tw.set_parallel(true)
	tw.tween_property(poly, "scale", Vector2(1.6, 1.6), duration)
	tw.tween_property(poly, "modulate:a", 0.0, duration)
	tw.chain().tween_callback(poly.queue_free)

func floating_text(pos: Vector2, text: String, color: Color) -> void:
	var s := _scene()
	if s == null:
		return
	var holder := Node2D.new()
	holder.z_index = 100
	s.add_child(holder)
	holder.global_position = pos + Vector2(0.0, -22.0)
	var lbl := Label.new()
	lbl.text = text
	lbl.modulate = color
	lbl.position = Vector2(-12.0, -8.0)
	lbl.add_theme_font_size_override("font_size", 14)
	holder.add_child(lbl)
	var tw := holder.create_tween()
	tw.set_parallel(true)
	tw.tween_property(holder, "global_position", holder.global_position + Vector2(0.0, -30.0), 0.7)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.7)
	tw.chain().tween_callback(holder.queue_free)

func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		var a := TAU * float(i) / float(segments)
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts

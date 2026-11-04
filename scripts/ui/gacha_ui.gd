class_name GachaUI
extends RefCounted
## Tela de invocacao (banners com desbloqueio pela historia) e animacao de abertura da capsula.

var main: Control
var banner_idx := 0


func _init(m: Control) -> void:
	main = m


func _featured(b: Dictionary) -> Array:
	var ids := []
	var worlds: Array = b.get("worlds", [])
	var min_r := int(b.get("min_rarity", 0))
	for id in DB.BALLS:
		var d: Dictionary = DB.BALLS[id]
		if (worlds.is_empty() or worlds.has(d.get("world", ""))) and int(d.rarity) >= min_r:
			ids.append(id)
	ids.sort_custom(func(a, c): return int(DB.BALLS[a].rarity) > int(DB.BALLS[c].rarity) or (int(DB.BALLS[a].rarity) == int(DB.BALLS[c].rarity) and str(a) < str(c)))
	return ids.slice(0, 4)


func screen() -> Control:
	var f: Array = main.screens.frame("Invocação", UI.C_PURPLE)
	var c: VBoxContainer = f[1]
	banner_idx = clampi(banner_idx, 0, DB.BANNERS.size() - 1)
	# seletor de banners
	var sc := ScrollContainer.new()
	sc.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.custom_minimum_size = Vector2(0, 74)
	var hb := UI.hbox(8)
	for i in DB.BANNERS.size():
		var b: Dictionary = DB.BANNERS[i]
		var unl := Game.banner_unlocked(b)
		var bt := UI.button(("" if unl else "[Cap. %d] " % int(b.chapter)) + str(b.name), Color(b.color) if i == banner_idx else (Color("#c8bca4") if unl else Color("#9a9288")), 16, Vector2(0, 62))
		var idx := i
		bt.pressed.connect(func() -> void:
			banner_idx = idx
			main.open_screen("gacha", true))
		hb.add_child(bt)
	sc.add_child(hb)
	c.add_child(sc)
	var bn: Dictionary = DB.BANNERS[banner_idx]
	var unlocked := Game.banner_unlocked(bn)
	# arte do banner
	var art := Control.new()
	art.custom_minimum_size = Vector2(0, 280)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.clip_contents = true
	var col := Color(bn.color)
	var t0 := Time.get_ticks_msec()
	art.draw.connect(func() -> void:
		var w := art.size.x
		var h := art.size.y
		var tt := (Time.get_ticks_msec() - t0) / 1000.0
		art.draw_rect(Rect2(0, 0, w, h), UI.C_BORDER)
		for i in 12:
			var k := i / 12.0
			art.draw_rect(Rect2(4, 4 + (h - 8) * k, w - 8, (h - 8) / 12.0 + 1), col.darkened(0.55).lerp(col.darkened(0.15), k))
		for i in 10:
			var an := tt * 0.3 + TAU * i / 10.0
			var cc := Vector2(w * 0.5, h * 0.62)
			art.draw_colored_polygon(PackedVector2Array([cc, cc + Vector2(cos(an), sin(an)) * w, cc + Vector2(cos(an + 0.18), sin(an + 0.18)) * w]), Color(1, 1, 1, 0.05))
		if not unlocked:
			art.draw_rect(Rect2(4, 4, w - 8, h - 8), Color(0, 0, 0, 0.55)))
	var tick := Timer.new()
	tick.wait_time = 0.05
	tick.autostart = true
	tick.timeout.connect(art.queue_redraw)
	art.add_child(tick)
	var feat := _featured(bn)
	var icons := []
	for i in feat.size():
		var bi := BallIcon.new().setup(feat[i])
		bi.frame = false
		bi.size = Vector2(130, 130)
		art.add_child(bi)
		icons.append(bi)
	var title := UI.label(str(bn.name), 28, Color("#ffe27a"), 8)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.clip_text = true
	art.add_child(title)
	var desc := UI.label(str(bn.desc), 17, Color.WHITE, 5)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.max_lines_visible = 2
	desc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	art.add_child(desc)
	art.resized.connect(func() -> void:
		var w := art.size.x
		for i in icons.size():
			var bi2: BallIcon = icons[i]
			var n := icons.size()
			bi2.position = Vector2(w * (i + 0.5) / n - 65, 52 + (12 if i % 2 == 0 else 0))
		title.size = Vector2(w - 16, 40)
		title.position = Vector2(8, 8)
		desc.size = Vector2(w - 24, 48)
		desc.position = Vector2(12, 222))
	if not unlocked:
		var lk := UI.label("Libere concluindo o capítulo %d da história" % int(bn.chapter), 20, Color.WHITE, 6)
		lk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lk.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		art.add_child(lk)
		art.resized.connect(func() -> void:
			lk.size = Vector2(art.size.x - 40, 60)
			lk.position = Vector2(20, art.size.y * 0.5 - 20))
	var ap := PanelContainer.new()
	ap.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	ap.add_child(art)
	c.add_child(ap)
	# info
	var info := UI.card(Color("#fffaf0"))
	var pity_left := DB.GACHA_PITY - int(Game.d.pity)
	info[1].add_child(UI.para("Garantia: Lendário ou melhor em até %d invocações (faltam %d). O 10x sempre traz Raro ou melhor." % [DB.GACHA_PITY, pity_left], 16))
	var pb := UI.bar(Color("#ffb020"), 12)
	pb.value = float(Game.d.pity) / DB.GACHA_PITY
	info[1].add_child(pb)
	if not (bn.get("worlds", []) as Array).is_empty():
		info[1].add_child(UI.para("Destaque: 60% das bolinhas vêm de " + ", ".join(bn.worlds) + ".", 15, UI.C_TEXT_MID))
	var rates := UI.button("Ver chances", UI.C_GRAY, 16, Vector2(0, 46))
	rates.pressed.connect(_rates_popup)
	info[1].add_child(rates)
	c.add_child(info[0])
	var h := UI.hbox(10)
	var b1 := UI.button("1x  ·  %d gemas" % DB.GACHA_COST_1, UI.C_PURPLE, 20, Vector2(0, 76))
	b1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b1.disabled = not unlocked
	b1.pressed.connect(func() -> void: pull(1, bn))
	var b10 := UI.button("10x  ·  %d gemas" % DB.GACHA_COST_10, Color("#ffb020"), 20, Vector2(0, 76))
	b10.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b10.disabled = not unlocked
	b10.pressed.connect(func() -> void: pull(10, bn))
	h.add_child(b1)
	h.add_child(b10)
	c.add_child(h)
	return f[0]


func _rates_popup() -> void:
	var v := UI.vbox(4)
	for i in DB.GACHA_RATES.size():
		var hh := UI.hbox(8)
		hh.add_child(UI.badge(DB.rarity(i).name, DB.rcolor(i).darkened(0.2), 15))
		hh.add_child(UI.para(("%s%%" % str(DB.GACHA_RATES[i])).replace(".", ","), 18))
		v.add_child(hh)
	v.add_child(UI.para("Transcendente só por evolução. Repetidas viram %d fragmentos." % DB.DUPE_FRAGS, 15, UI.C_TEXT_MID))
	main.screens.popup("Chances", v, [], 480)


func pull(n: int, bn: Dictionary) -> void:
	var res := Game.gacha(n, bn)
	if res.is_empty():
		main.toast("Gemas insuficientes", Color("#ffb0a0"))
		main.open_screen("shop")
		return
	_play(res, func() -> void: main.open_screen("gacha", true), [["De novo", UI.C_PURPLE, func() -> void: pull(n, bn)]])


## revela uma bolinha (bau, evolucao ou compra) com a mesma animacao
func reveal_single(id: String, r: int, from_chest: bool, evolved: bool = false) -> void:
	var res := [{"id": id, "rarity": r, "new": not Game.has_ball(id), "frags": DB.DUPE_FRAGS, "evolved": evolved}]
	var extra := []
	var on_close := Callable()
	if from_chest:
		on_close = func() -> void: main._take_drop()
	_play(res, on_close, extra, "Coletar" if from_chest else "OK")


func _play(res: Array, on_close: Callable, extra_buttons: Array = [], ok_text: String = "OK") -> void:
	var best := 0
	for r in res:
		best = maxi(best, int(r.rarity))
	var ov := GachaAnim.new()
	ov.results = res
	ov.best = best
	ov.on_close = on_close
	ov.extra_buttons = extra_buttons
	ov.ok_text = ok_text
	ov.set_meta("popup", true)
	main.popup_layer.add_child(ov)
	ov.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ov.size = main.popup_layer.size
	if main.mode == "campaign" and main.battle:
		main.battle.pause(true)
	ov.tree_exited.connect(func() -> void: main.screens._battle_pause())


# =============================================================================================
class GachaAnim:
	extends Control
	var results: Array = []
	var best := 0
	var on_close := Callable()
	var extra_buttons: Array = []
	var ok_text := "OK"
	var t := 0.0
	var phase := 0          # 0 queda/tremor, 1 abertura, 2 revelacao
	var crack_t := 0.0
	var cards: Array = []
	var revealed := 0
	var shown_ui := false
	var cap_pos := Vector2.ZERO
	var band := Color.WHITE

	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_STOP
		Snd.play("shake", -3.0, 0.0, 0.0)

	func _process(delta: float) -> void:
		t += delta
		if phase == 0:
			if t > 2.3:
				_open()
		elif phase == 1:
			crack_t += delta
			if crack_t > 0.55:
				phase = 2
				_reveal()
		queue_redraw()

	func _gui_input(e: InputEvent) -> void:
		if not ((e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT)):
			return
		if phase == 0:
			_open()
		elif phase == 2 and revealed < cards.size():
			for cnode: Control in cards:
				cnode.scale = Vector2.ONE
				cnode.modulate.a = 1.0
			revealed = cards.size()
			_show_buttons()

	func _open() -> void:
		if phase != 0:
			return
		phase = 1
		crack_t = 0.0
		Snd.play("open", -2.0, 0.0, 0.0)

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.03, 0.08, 0.86))
		var rc := DB.rcolor(best)
		var center := Vector2(w * 0.5, h * 0.42)
		# raios de luz
		if phase >= 1:
			var k := clampf(crack_t / 0.4, 0.0, 1.0) if phase == 1 else 1.0
			for i in 16:
				var an := t * 0.4 + TAU * i / 16.0
				var L := maxf(w, h) * k
				draw_colored_polygon(PackedVector2Array([center, center + Vector2(cos(an), sin(an)) * L, center + Vector2(cos(an + 0.12), sin(an + 0.12)) * L]), Color(rc, 0.16 if phase == 2 else 0.3))
		if phase == 2:
			return
		# capsula caindo e tremendo
		var drop := clampf(t / 0.6, 0.0, 1.0)
		var bounce := absf(sin(drop * PI * 2.5)) * (1.0 - drop) * 60.0
		var y := lerpf(-200.0, center.y, 1.0 - pow(1.0 - drop, 3.0)) - bounce
		var shake := 0.0 if t < 0.7 else sin(t * (30.0 + t * 12.0)) * minf(14.0, (t - 0.7) * 10.0)
		var c := Vector2(center.x + shake, y)
		var r := 110.0
		# a faixa vai revelando a cor da raridade (suspense)
		var hint := clampf((t - 1.0) / 1.0, 0.0, 1.0) if phase == 0 else 1.0
		band = Color.WHITE.lerp(rc, hint)
		for i in 5:
			draw_circle(c, r + 14 + i * 10, Color(band, 0.06 * hint))
		var open := clampf(crack_t / 0.45, 0.0, 1.0) if phase == 1 else 0.0
		var top_off := Vector2(0, -260.0 * open * open)
		# metade de baixo (branca)
		draw_circle(c, r + 5, UI.C_BORDER)
		_half(c, r, Color("#fff4dc"), false)
		for i in 5:
			draw_circle(c + Vector2(-60 + i * 30, 50 - absf(i - 2) * 12), 6, Color("#ffd8e8"))
		# metade de cima (colorida), sobe ao abrir
		var tc := c + top_off
		var a := 1.0 - open
		_half_outline(tc, r + 5, Color(UI.C_BORDER, a))
		_half(tc, r, Color(Color("#7a4ad8").lerp(rc, 0.5), a), true)
		for i in 4:
			_star_at(tc + Vector2(-55 + i * 36, -50 + absf(i - 1.5) * 14), 7.0, Color(1, 1, 0.8, 0.7 * a))
		draw_circle(tc + Vector2(-r * 0.4, -r * 0.5), r * 0.16, Color(1, 1, 1, 0.6 * a))
		# faixa central + botao
		draw_rect(Rect2(c.x - r - 5, c.y - 9, (r + 5) * 2, 18), UI.C_BORDER)
		draw_rect(Rect2(c.x - r, c.y - 5, r * 2, 10), band)
		draw_rect(Rect2(c.x - r - 5, c.y - 12, (r + 5) * 2, 24), UI.C_BORDER)
		draw_rect(Rect2(c.x - r, c.y - 8, r * 2, 16), Color("#ffcf3a").lerp(band, 0.5))
		_star_at(c, 30.0, UI.C_BORDER)
		_star_at(c, 24.0, Color("#ffe066"))
		_star_at(c, 12.0, band)
		if phase == 1:
			for i in 8:
				var an2 := TAU * i / 8.0
				var p := c + Vector2(cos(an2), sin(an2)) * (r + crack_t * 400.0)
				draw_circle(p, 8.0 * (1.0 - open), Color("#fff4c0"))
		var f := UI.font()
		if phase == 0:
			var txt := "toque para abrir"
			var tw := f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
			var ta := 0.7 + 0.3 * sin(t * 5.0)
			draw_string_outline(f, Vector2((w - tw) * 0.5, h * 0.8), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color(UI.C_OUTLINE, ta))
			draw_string(f, Vector2((w - tw) * 0.5, h * 0.8), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1, 1, 1, ta))

	func _half(c: Vector2, r: float, col: Color, top: bool) -> void:
		var pts := PackedVector2Array()
		for i in 33:
			var an := PI + PI * i / 32.0 if top else PI * i / 32.0
			pts.append(c + Vector2(cos(an), sin(an)) * r)
		draw_colored_polygon(pts, col)

	func _half_outline(c: Vector2, r: float, col: Color) -> void:
		_half(c, r, col, true)

	func _star_at(p: Vector2, r: float, col: Color) -> void:
		var pts := PackedVector2Array()
		for i in 10:
			var an := -PI / 2.0 + TAU * i / 10.0
			pts.append(p + Vector2(cos(an), sin(an)) * (r if i % 2 == 0 else r * 0.45))
		draw_colored_polygon(pts, col)

	func _reveal() -> void:
		Snd.play("fanfare" if best >= 4 else "coin", -2.0, 0.0, 0.0)
		var n := results.size()
		var w := size.x
		var grid := GridContainer.new()
		grid.columns = 1 if n == 1 else 5
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 10)
		var cw := 300.0 if n == 1 else minf(126.0, (w - 60.0) / 5.0)
		var chh := 360.0 if n == 1 else cw * 1.42
		for i in n:
			var r: Dictionary = results[i]
			var card := _card(r, Vector2(cw, chh), n == 1)
			grid.add_child(card)
			cards.append(card)
		add_child(grid)
		await get_tree().process_frame
		grid.position = Vector2((w - grid.size.x) * 0.5, size.y * 0.42 - grid.size.y * 0.5)
		for i in cards.size():
			var cn: Control = cards[i]
			cn.pivot_offset = cn.size * 0.5
			cn.scale = Vector2(0.0, 1.0)
			cn.modulate.a = 0.0
			var tw := cn.create_tween()
			tw.tween_interval(0.12 * i)
			tw.tween_property(cn, "modulate:a", 1.0, 0.05)
			tw.parallel().tween_property(cn, "scale", Vector2(1.1, 1.1), 0.18).set_trans(Tween.TRANS_BACK)
			tw.tween_property(cn, "scale", Vector2.ONE, 0.1)
			tw.tween_callback(func() -> void:
				revealed += 1
				if revealed >= cards.size():
					_show_buttons())

	func _card(r: Dictionary, sz: Vector2, big: bool) -> Control:
		var rar := int(r.rarity)
		var col := DB.rcolor(rar)
		var card := Control.new()
		card.custom_minimum_size = sz
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.draw.connect(func() -> void:
			var rr := Rect2(Vector2.ZERO, card.size)
			card.draw_rect(rr, UI.C_BORDER)
			card.draw_rect(rr.grow(-4), col.darkened(0.45))
			for i in 8:
				card.draw_rect(Rect2(4, 4 + (rr.size.y - 8) * i / 8.0, rr.size.x - 8, (rr.size.y - 8) / 8.0 + 1), Color(col, 0.08 + 0.04 * i))
			card.draw_rect(Rect2(4, 4, rr.size.x - 8, 6), Color(1, 1, 1, 0.25)))
		if rar >= 3:
			var beam := Fx.make(DB.rarity(rar).loot, {"scale": 1.2 if big else 0.65, "loop": true})
			if beam:
				beam.position = Vector2(sz.x * 0.5, sz.y * 0.78)
				card.add_child(beam)
		var bi := BallIcon.new().setup(r.id, rar)
		bi.frame = false
		var s := sz.x * (0.82 if big else 0.84)
		bi.size = Vector2(s, s)
		bi.position = Vector2((sz.x - s) * 0.5, sz.y * 0.06)
		card.add_child(bi)
		var nm := UI.label(DB.ball_name(r.id, rar) if big else DB.BALLS[r.id].name, 22 if big else 13, Color.WHITE, 5 if big else 4)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		# no maximo 2 linhas, com reticencias: nunca invade o selo de raridade embaixo
		nm.max_lines_visible = 2
		nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		nm.clip_text = true
		nm.size = Vector2(sz.x - 8, 56 if big else 40)
		nm.position = Vector2(4, sz.y * 0.72 if big else sz.y - 70)
		card.add_child(nm)
		var tag := "EVOLUIU!" if r.get("evolved", false) else ("NOVO!" if r.get("new", false) else "+%d frag." % int(r.get("frags", DB.DUPE_FRAGS)))
		var tl := UI.badge(tag, Color("#ffb020") if (r.get("new", false) or r.get("evolved", false)) else Color("#6a6a7a"), 16 if big else 13)
		tl.position = Vector2(6, 6)
		card.add_child(tl)
		var rl := UI.badge(DB.rarity(rar).name, col.darkened(0.2), 16 if big else 13)
		card.add_child(rl)
		rl.resized.connect(func() -> void: rl.position = Vector2(sz.x - rl.size.x - 6, 6) if big else Vector2((sz.x - rl.size.x) * 0.5, sz.y - rl.size.y - 6))
		return card

	func _show_buttons() -> void:
		if shown_ui:
			return
		shown_ui = true
		var h := UI.hbox(12)
		var ok := UI.button(ok_text, UI.C_YELLOW, 22, Vector2(170, 62))
		ok.pressed.connect(func() -> void:
			queue_free()
			if on_close.is_valid():
				on_close.call())
		h.add_child(ok)
		for b in extra_buttons:
			var eb := UI.button(b[0], b[1], 22, Vector2(170, 62))
			var cb: Callable = b[2]
			eb.pressed.connect(func() -> void:
				queue_free()
				cb.call())
			h.add_child(eb)
		add_child(h)
		await get_tree().process_frame
		h.position = Vector2((size.x - h.size.x) * 0.5, size.y - 230)

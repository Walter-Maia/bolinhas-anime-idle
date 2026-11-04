class_name StoryUI
extends RefCounted
## Modo Historia: mapa do capitulo (trilha de fases), dialogos com retrato, tela VS e fim de capitulo.

var main: Control
var view_chapter := -1


func _init(m: Control) -> void:
	main = m


# =============================================================================================
# MAPA
# =============================================================================================
func map_screen() -> Control:
	var cur_c := int(Game.d.chapter)
	var max_c := maxi(cur_c, Game.chapters_cleared() + 1)
	if view_chapter < 1 or view_chapter > max_c:
		view_chapter = cur_c
	var c := view_chapter
	var ch := DB.chapter(c)
	var theme: Dictionary = ch.get("theme", {})
	var f: Array = main.screens.frame("Modo História", Color("#3a7a9a"))
	var box: VBoxContainer = f[1]
	# seletor de capitulo
	var sel := UI.hbox(8)
	var prev := UI.button("<", UI.C_BLUE, 24, Vector2(56, 56))
	prev.disabled = c <= 1
	prev.pressed.connect(func() -> void:
		view_chapter = c - 1
		main.open_screen("story", true))
	sel.add_child(prev)
	var tv := UI.vbox(0)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var t1 := UI.para("Capítulo %d" % c, 17, UI.C_TEXT_MID)
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tv.add_child(t1)
	var t2 := UI.para(ch.name, 24, UI.C_TEXT_DARK)
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tv.add_child(t2)
	sel.add_child(tv)
	var nxt := UI.button(">", UI.C_BLUE, 24, Vector2(56, 56))
	nxt.disabled = c >= max_c
	nxt.pressed.connect(func() -> void:
		view_chapter = c + 1
		main.open_screen("story", true))
	sel.add_child(nxt)
	box.add_child(sel)
	# progresso
	var best := int(Game.d.best)
	var done_in := clampi(best - (c - 1) * DB.STAGES_PER_CHAPTER - 1, 0, DB.STAGES_PER_CHAPTER)
	if Game.chapters_cleared() >= c:
		done_in = DB.STAGES_PER_CHAPTER
	var pk := UI.card(Color("#fffaf0"))
	var info := "Capítulo concluído!" if done_in >= DB.STAGES_PER_CHAPTER else "%d de %d lutas vencidas · faltam %d para o próximo capítulo" % [done_in, DB.STAGES_PER_CHAPTER, DB.STAGES_PER_CHAPTER - done_in]
	pk[1].add_child(UI.para(info, 18))
	var bar := UI.bar(Color("#ffcf3a"), 16)
	bar.value = float(done_in) / DB.STAGES_PER_CHAPTER
	pk[1].add_child(bar)
	box.add_child(pk[0])
	# trilha
	var path := Control.new()
	path.custom_minimum_size = Vector2(0, 560)
	path.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path.mouse_filter = Control.MOUSE_FILTER_STOP
	var boss_tex := BallArt.make(BallArt.normalize(DB.BOSSES[ch.boss].look))
	var hero_tex := BallArt.make(DB.BALLS[Game.active_id()].look) if Game.has_ball(Game.active_id()) else null
	var t0 := Time.get_ticks_msec()
	var node_pos := func(i: int) -> Vector2:
		var row := i / 4
		var col := i % 4
		if row % 2 == 1:
			col = 3 - col
		var w := path.size.x
		return Vector2(w * (0.14 + col * 0.24), 520.0 - row * 112.0)
	path.draw.connect(func() -> void:
		var fcol := Color(theme.get("floor", "#f1ead2"))
		path.draw_rect(Rect2(Vector2.ZERO, path.size), fcol.darkened(0.03))
		for i in 19:
			var a: Vector2 = node_pos.call(i)
			var b: Vector2 = node_pos.call(i + 1)
			var reached := (c - 1) * DB.STAGES_PER_CHAPTER + i + 2 <= best
			path.draw_line(a, b, UI.C_BORDER, 12.0, true)
			path.draw_line(a, b, Color("#ffcf3a") if reached else Color("#cbbf9f"), 6.0, true)
			for k in 3:
				path.draw_circle(a.lerp(b, (k + 1) / 4.0), 2.0, Color(1, 1, 1, 0.5))
		var tt := (Time.get_ticks_msec() - t0) / 1000.0
		var f2 := UI.font()
		for i in 20:
			var p: Vector2 = node_pos.call(i)
			var s := i + 1
			var idx := (c - 1) * DB.STAGES_PER_CHAPTER + s
			var done := idx < best or Game.chapters_cleared() >= c
			var current := c == cur_c and s == int(Game.d.stage)
			var avail := idx <= best
			var boss := s == DB.STAGES_PER_CHAPTER or s == 10
			var r := 34.0 if s == DB.STAGES_PER_CHAPTER else (28.0 if boss else 24.0)
			if current:
				r += 3.0 * sin(tt * 5.0)
				path.draw_circle(p, r + 12.0, Color(1, 0.9, 0.3, 0.35))
			var col := Color("#ffcf3a") if done else (Color("#7cd0ff") if avail else Color("#bdb4a0"))
			if boss:
				col = Color("#ec5a48") if avail else Color("#c8a8a0")
			path.draw_circle(p, r + 4.0, UI.C_BORDER)
			path.draw_circle(p, r, col)
			path.draw_circle(p + Vector2(-r * 0.3, -r * 0.35), r * 0.25, Color(1, 1, 1, 0.5))
			if boss:
				var bs := r * 1.6
				path.draw_texture_rect(boss_tex, Rect2(p - Vector2(bs, bs) * 0.5 - Vector2(0, 2), Vector2(bs, bs)), false, Color.WHITE if avail else Color(0.3, 0.3, 0.3, 0.8))
			else:
				var txt := str(s)
				var tw := f2.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
				path.draw_string_outline(f2, p + Vector2(-tw * 0.5, 8), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 5, UI.C_OUTLINE)
				path.draw_string(f2, p + Vector2(-tw * 0.5, 8), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
			if done and not boss:
				_star(path, p + Vector2(r * 0.7, -r * 0.7), 8.0)
			if current and hero_tex:
				var hs := 56.0
				path.draw_texture_rect(hero_tex, Rect2(p - Vector2(hs * 0.5, hs + r + 4.0 + 4.0 * sin(tt * 4.0)), Vector2(hs, hs)), false))
	var redraw := Timer.new()
	redraw.wait_time = 0.05
	redraw.autostart = true
	redraw.timeout.connect(path.queue_redraw)
	path.add_child(redraw)
	path.gui_input.connect(func(e: InputEvent) -> void:
		if not (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
			return
		for i in 20:
			var p: Vector2 = node_pos.call(i)
			if p.distance_to(e.position) < 36.0:
				var s := i + 1
				if Game.go_stage(c, s):
					main.close_screen()
					main.start_campaign()
				else:
					main.toast("Vença as fases anteriores primeiro!", Color("#ffb0a0"))
				return)
	var pp := PanelContainer.new()
	pp.add_theme_stylebox_override("panel", UI.box(Color(0, 0, 0, 0), UI.C_BORDER, 4, 0, 14))
	pp.add_child(path)
	box.add_child(pp)
	box.add_child(UI.para("Toque numa fase vencida para jogá-la de novo (farm) ou na fase atual para continuar.", 15, UI.C_TEXT_MID))
	# sinopse e chefe
	var bd: Dictionary = DB.BOSSES[ch.boss]
	var bi := BallIcon.new().setup_look(BallArt.normalize(bd.look), int(bd.rarity))
	bi.custom_minimum_size = Vector2(80, 80)
	var syn := UI.card(Color("#fbeae2"))
	var sh := UI.hbox(10)
	sh.add_child(bi)
	var sv := UI.vbox(2)
	sv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sv.add_child(UI.para("Chefe: " + bd.name, 20))
	sv.add_child(UI.para(" ".join(ch.intro), 15, UI.C_TEXT_MID))
	sh.add_child(sv)
	syn[1].add_child(sh)
	var hb := UI.hbox(8)
	var rv := UI.button("Rever história", UI.C_BLUE, 17, Vector2(0, 50))
	rv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rv.pressed.connect(func() -> void: play_intro(c, Callable()))
	hb.add_child(rv)
	var go := UI.button("Continuar", UI.C_GREEN, 19, Vector2(0, 50))
	go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	go.pressed.connect(func() -> void:
		main.close_screen()
		main.start_campaign())
	hb.add_child(go)
	syn[1].add_child(hb)
	box.add_child(syn[0])
	# lista de capitulos
	box.add_child(main.screens.section("Capítulos"))
	for i in DB.chapter_count():
		var cc := i + 1
		var chi: Dictionary = DB.CHAPTERS[i]
		var unl := cc <= max_c
		var cleared := Game.chapters_cleared() >= cc
		var ic := BallIcon.new().setup_look(BallArt.normalize(DB.BOSSES[chi.boss].look), int(DB.BOSSES[chi.boss].rarity))
		ic.custom_minimum_size = Vector2(60, 60)
		ic.dim = not unl
		var sub := ("Concluído" if cleared else ("Em andamento" if unl else "Bloqueado")) + " · " + str(chi.world)
		var card: Control = main.screens.row_card(ic, "%d. %s" % [cc, chi.name], sub, "Ver" if unl else "", UI.C_BLUE, func() -> void:
			view_chapter = cc
			main.open_screen("story", true), unl, Color("#eaf6e0") if cleared else (Color("#fffaf0") if unl else Color("#e4ded4")))
		box.add_child(card)
	return f[0]


func _star(ci: CanvasItem, p: Vector2, r: float) -> void:
	var pts := PackedVector2Array()
	var pts2 := PackedVector2Array()
	for i in 10:
		var an := -PI / 2.0 + TAU * i / 10.0
		var rr := r if i % 2 == 0 else r * 0.45
		pts.append(p + Vector2(cos(an), sin(an)) * (rr + 2.5))
		pts2.append(p + Vector2(cos(an), sin(an)) * rr)
	ci.draw_colored_polygon(pts, UI.C_BORDER)
	ci.draw_colored_polygon(pts2, Color("#ffe066"))


# =============================================================================================
# DIALOGOS
# =============================================================================================
func _speaker(id: String) -> Dictionary:
	if DB.BALLS.has(id):
		return {"name": DB.BALLS[id].name, "look": DB.BALLS[id].look, "r": int(DB.BALLS[id].rarity)}
	var h := Game.active_id()
	return {"name": DB.BALLS[h].name, "look": DB.BALLS[h].look, "r": int(Game.ball(h).rarity)}


func play_intro(c: int, cb: Callable) -> void:
	var ch := DB.chapter(c)
	var sp := _speaker(ch.get("guide", ""))
	var lines := []
	lines.append({"who": "Narrador", "look": {}, "text": "Capítulo %d — %s" % [c, ch.name], "title": true})
	for l in ch.intro:
		lines.append({"who": sp.name, "look": sp.look, "r": sp.r, "text": l})
	if c == 1 and not Game.d.seen.has("tips"):
		Game.d.seen["tips"] = true
		for tip in [
			"Dica: sua bolinha luta sozinha! Ela quica pela arena, bate com a arma que gira em volta e usa skills automaticamente.",
			"Dica: toque no BAÚ (gasta 1 chave) para ganhar equipamentos. Eles são seus e valem para qualquer bolinha em campo.",
			"Dica: no INVOCAR você consegue novas bolinhas. Repetidas viram fragmentos para estrelas e evolução.",
			"Dica: toque em MAPA para ver quantas lutas faltam até o chefe e o próximo capítulo. Boa sorte!",
		]:
			lines.append({"who": "Dica", "look": {}, "text": tip})
	dialogue(lines, cb)


func play_boss(c: int, cb: Callable) -> void:
	var ch := DB.chapter(c)
	var bd: Dictionary = DB.BOSSES[ch.boss]
	var lines := [{"who": bd.name, "look": BallArt.normalize(bd.look), "r": int(bd.rarity), "text": ch.boss_line, "boss": true}]
	dialogue(lines, func() -> void: vs_splash(BallArt.normalize(bd.look), bd.name, cb))


func play_outro(c: int, cb: Callable) -> void:
	var ch := DB.chapter(c)
	var sp := _speaker(ch.get("guide", ""))
	dialogue([{"who": sp.name, "look": sp.look, "r": sp.r, "text": ch.outro}], func() -> void:
		Game.add_gems(100)
		Game.add_keys(50)
		var v := UI.vbox(8)
		var l := UI.para("Você concluiu o capítulo %d: %s!" % [c, ch.name], 21)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
		var l2 := UI.para("+100 gemas  ·  +50 chaves", 22, Color("#2a6a9a"))
		l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l2)
		for b in DB.BANNERS:
			if int(b.chapter) == Game.chapters_cleared():
				var l3 := UI.para("Novo banner liberado no Invocar: " + str(b.name) + "!", 19, Color("#a03aa0"))
				l3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				v.add_child(l3)
		if c < DB.chapter_count():
			var l4 := UI.para("Próximo: " + str(DB.chapter(c + 1).name), 18, UI.C_TEXT_MID)
			l4.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			v.add_child(l4)
		main.screens.popup("Capítulo Concluído!", v, [["Continuar", UI.C_GREEN, cb]], 560))


## dialogo estilo visual novel: retrato, nome, texto digitando. Toque avanca.
func dialogue(lines: Array, cb: Callable) -> void:
	var layer := Control.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.set_meta("popup", true)
	layer.set_meta("dialogue", true)
	main.popup_layer.add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0.04, 0.03, 0.06, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(dim)
	var portrait := BallIcon.new()
	portrait.frame = false
	portrait.size = Vector2(230, 230)
	layer.add_child(portrait)
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", UI.paper(UI.C_CREAM, 18))
	box.anchor_left = 0.0
	box.anchor_right = 1.0
	box.anchor_top = 1.0
	box.anchor_bottom = 1.0
	box.offset_left = 14
	box.offset_right = -14
	box.offset_top = -330
	box.offset_bottom = -130
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(box)
	var bv := UI.vbox(6)
	box.add_child(bv)
	var name_l := UI.label("", 24, Color("#ffe27a"))
	bv.add_child(name_l)
	var text_l := UI.para("", 22, UI.C_TEXT_DARK)
	text_l.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bv.add_child(text_l)
	var hint := UI.label("toque para continuar", 15, UI.C_TEXT_MID, 0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	bv.add_child(hint)
	var skip := UI.button("Pular", UI.C_GRAY, 17, Vector2(96, 48))
	skip.position = Vector2(main.size.x - 112, 16)
	layer.add_child(skip)
	var state := {"i": -1, "tw": null}
	var finish := func() -> void:
		if not is_instance_valid(layer):
			return
		layer.set_meta("popup", false)
		var tw := layer.create_tween()
		tw.tween_property(layer, "modulate:a", 0.0, 0.2)
		tw.tween_callback(layer.queue_free)
		main.screens._battle_pause()
		if cb.is_valid():
			cb.call()
	var show_line: Callable
	show_line = func() -> void:
		state.i += 1
		if state.i >= lines.size():
			finish.call()
			return
		var ln: Dictionary = lines[state.i]
		name_l.text = ln.who
		name_l.add_theme_color_override("font_color", Color("#ff8a7a") if ln.get("boss", false) else Color("#ffe27a"))
		text_l.text = ln.text
		text_l.visible_ratio = 0.0
		var tw2 := text_l.create_tween()
		tw2.tween_property(text_l, "visible_ratio", 1.0, clampf(ln.text.length() * 0.03, 0.4, 2.2))
		state.tw = tw2
		var lk: Dictionary = ln.get("look", {})
		portrait.visible = not lk.is_empty()
		if not lk.is_empty():
			portrait.setup_look(lk, int(ln.get("r", 0)))
			var left = not ln.get("boss", false)
			var target := Vector2(30.0 if left else main.size.x - 260.0, main.size.y - 330 - 210)
			portrait.position = target + Vector2(-260.0 if left else 260.0, 0)
			portrait.modulate.a = 0.0
			var tw3 := portrait.create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw3.tween_property(portrait, "position", target, 0.35)
			tw3.tween_property(portrait, "modulate:a", 1.0, 0.2)
		if ln.get("title", false):
			text_l.add_theme_font_size_override("font_size", 28)
		else:
			text_l.add_theme_font_size_override("font_size", 22)
	layer.gui_input.connect(func(e: InputEvent) -> void:
		if (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT) or (e is InputEventScreenTouch and e.pressed):
			var tw4: Variant = state.tw
			if tw4 != null and (tw4 as Tween).is_valid() and (tw4 as Tween).is_running():
				(tw4 as Tween).kill()
				text_l.visible_ratio = 1.0
			else:
				show_line.call())
	skip.pressed.connect(finish)
	main.screens._battle_pause()
	if main.mode == "campaign" and main.battle:
		main.battle.pause(true)
	show_line.call()


## tela "VS" antes do chefe
func vs_splash(boss_look: Dictionary, boss_name: String, cb: Callable) -> void:
	var layer := Control.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	main.popup_layer.add_child(layer)
	var hero := Game.active_id()
	var hc := DB.rcolor(int(Game.ball(hero).rarity))
	var t0 := Time.get_ticks_msec()
	layer.draw.connect(func() -> void:
		var w := layer.size.x
		var h := layer.size.y
		var k := clampf((Time.get_ticks_msec() - t0) / 350.0, 0.0, 1.0)
		var mid := h * 0.5
		layer.draw_colored_polygon(PackedVector2Array([Vector2(0, mid - 230), Vector2(w * 0.62 * k, mid - 230), Vector2(w * 0.38 * k, mid + 230), Vector2(0, mid + 230)]), hc.darkened(0.25))
		layer.draw_colored_polygon(PackedVector2Array([Vector2(w, mid - 230), Vector2(w - w * 0.38 * k, mid - 230), Vector2(w - w * 0.62 * k, mid + 230), Vector2(w, mid + 230)]), Color("#b83a3a"))
		layer.draw_line(Vector2(w * 0.62, mid - 230), Vector2(w * 0.38, mid + 230), Color.WHITE, 8.0)
		layer.draw_rect(Rect2(0, mid - 236, w, 6), UI.C_BORDER)
		layer.draw_rect(Rect2(0, mid + 230, w, 6), UI.C_BORDER))
	var ticker := Timer.new()
	ticker.wait_time = 0.016
	ticker.autostart = true
	ticker.timeout.connect(layer.queue_redraw)
	layer.add_child(ticker)
	var hi := BallIcon.new().setup(hero, int(Game.ball(hero).rarity))
	hi.frame = false
	hi.size = Vector2(220, 220)
	layer.add_child(hi)
	var bi := BallIcon.new().setup_look(boss_look, 5)
	bi.frame = false
	bi.size = Vector2(240, 240)
	layer.add_child(bi)
	var vs := UI.label("VS", 96, Color("#ffe27a"), 14)
	vs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layer.add_child(vs)
	var hn := UI.label(DB.BALLS[hero].name, 22)
	var bn := UI.label(boss_name, 22, Color("#ffd0c8"))
	layer.add_child(hn)
	layer.add_child(bn)
	await main.get_tree().process_frame
	var w := layer.size.x
	var h := layer.size.y
	hi.position = Vector2(-260, h * 0.5 - 200)
	bi.position = Vector2(w + 20, h * 0.5 - 40)
	vs.size = Vector2(w, 120)
	vs.position = Vector2(0, h * 0.5 - 60)
	vs.pivot_offset = vs.size * 0.5
	vs.scale = Vector2(3, 3)
	vs.modulate.a = 0.0
	hn.position = Vector2(24, h * 0.5 + 30)
	bn.position = Vector2(w - 24 - bn.get_combined_minimum_size().x, h * 0.5 - 190)
	var tw := layer.create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(hi, "position:x", 20.0, 0.45)
	tw.tween_property(bi, "position:x", w - 270.0, 0.45)
	tw.tween_property(vs, "scale", Vector2.ONE, 0.35).set_delay(0.35)
	tw.tween_property(vs, "modulate:a", 1.0, 0.2).set_delay(0.35)
	tw.chain().tween_interval(1.0)
	tw.chain().tween_property(layer, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(func() -> void:
		layer.queue_free()
		if cb.is_valid():
			cb.call())

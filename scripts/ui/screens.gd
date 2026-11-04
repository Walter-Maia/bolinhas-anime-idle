class_name Screens
extends RefCounted
## Telas gerais (Modos, Melhorias, Loja) e popups (item, offline, resultado, configuracoes/save, missoes).

var main: Control
var pvp_opps: Array = []
var modes_tab := "boss"


func _init(m: Control) -> void:
	main = m


# =============================================================================================
# estrutura comum
# =============================================================================================
## tela cheia acima da navegacao: fita de titulo + botao fechar + area rolavel. Retorna [root, content]
func frame(title: String, color: Color = UI.C_BROWN) -> Array:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := PanelContainer.new()
	var st := UI.box(UI.C_CREAM, UI.C_BORDER, 5, 0, 16)
	st.set_content_margin_all(10)
	bg.add_theme_stylebox_override("panel", st)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.offset_left = 6
	bg.offset_right = -6
	bg.offset_top = 6
	bg.offset_bottom = -2
	root.add_child(bg)
	var v := UI.vbox(10)
	bg.add_child(v)
	var head := UI.hbox(8)
	head.add_child(UI.ribbon(title, color, 26))
	var x := UI.button("X", UI.C_RED, 24, Vector2(56, 52))
	x.pressed.connect(main.close_screen)
	head.add_child(x)
	v.add_child(head)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var content := UI.vbox(12)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var mc := UI.margin(content, 6, 8)
	mc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(mc)
	v.add_child(sc)
	return [root, content, v]


## abas segmentadas
func segmented(options: Array, current: String, on_pick: Callable) -> Control:
	var h := UI.hbox(6)
	for o in options:
		var id: String = o[0]
		var b := UI.button(o[1], UI.C_YELLOW if id == current else Color("#d8cbb0"), 18, Vector2(0, 50))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func() -> void: on_pick.call(id))
		h.add_child(b)
	return h


func section(title: String) -> Control:
	var h := UI.hbox(8)
	var l := UI.dark_label(title, 22)
	h.add_child(l)
	var line := ColorRect.new()
	line.color = UI.C_PAPER_LINE
	line.custom_minimum_size = Vector2(0, 3)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(line)
	return h


func popup(title: String, content: Control, buttons: Array = [], width: float = 620.0) -> Control:
	var layer: Control = main.popup_layer
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.03, 0.02, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_meta("popup", true)
	layer.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UI.paper(UI.C_CREAM, 16))
	width = minf(width, main.size.x - 24)
	p.custom_minimum_size = Vector2(width, 0)
	center.add_child(p)
	var v := UI.vbox(10)
	p.add_child(v)
	v.add_child(UI.ribbon(title, UI.C_BROWN, 24))
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var mc := UI.margin(content, 4, 4)
	mc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(mc)
	v.add_child(sc)
	var bh := UI.hbox(10)
	bh.alignment = BoxContainer.ALIGNMENT_CENTER
	if buttons.is_empty():
		buttons = [["OK", UI.C_YELLOW, Callable()]]
	for b in buttons:
		var btn := UI.button(b[0], b[1], 22, Vector2(150, 58))
		var cb: Callable = b[2]
		btn.pressed.connect(func() -> void:
			_close(dim)
			if cb.is_valid():
				cb.call())
		bh.add_child(btn)
	v.add_child(bh)
	var fit := func() -> void:
		sc.custom_minimum_size = Vector2(0, minf(mc.get_combined_minimum_size().y + 6, main.size.y * 0.66))
	mc.minimum_size_changed.connect(fit)
	fit.call()
	# animacao de entrada
	p.pivot_offset = Vector2(width * 0.5, 200)
	p.scale = Vector2(0.85, 0.85)
	dim.modulate.a = 0.0
	var tw := dim.create_tween().set_parallel()
	tw.tween_property(dim, "modulate:a", 1.0, 0.12)
	tw.tween_property(p, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_battle_pause()
	dim.tree_exited.connect(_battle_pause)
	return dim


func _close(dim: Control) -> void:
	dim.set_meta("popup", false)
	var tw := dim.create_tween()
	tw.tween_property(dim, "modulate:a", 0.0, 0.1)
	tw.tween_callback(dim.queue_free)


func close_popups() -> void:
	for c in main.popup_layer.get_children():
		if c.has_meta("popup") and not c.has_meta("dialogue"):
			c.queue_free()


func _battle_pause() -> void:
	if not is_instance_valid(main) or main.battle == null:
		return
	var open := false
	for c in main.popup_layer.get_children():
		if c.has_meta("popup") and c.get_meta("popup") and not c.is_queued_for_deletion():
			open = true
	if main.mode == "campaign":
		main.battle.pause(open)


func build(id: String) -> Control:
	match id:
		"modes": return modes_screen()
		"upgrades": return upgrades_screen()
		"shop": return shop_screen()
	return null


func row_card(icon: Control, title: String, sub: String, btn_text: String, btn_color: Color, on_press: Callable, enabled: bool = true, bg: Color = Color("#fffaf0")) -> Control:
	var k := UI.card(bg)
	var h := UI.hbox(10)
	h.add_child(icon)
	var v := UI.vbox(2)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(UI.para(title, 21, UI.C_TEXT_DARK))
	if sub != "":
		v.add_child(UI.para(sub, 16, UI.C_TEXT_MID))
	h.add_child(v)
	if btn_text != "":
		var b := UI.button(btn_text, btn_color, 19, Vector2(112, 56))
		b.disabled = not enabled
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		b.pressed.connect(on_press)
		h.add_child(b)
	k[1].add_child(h)
	return k[0]


# =============================================================================================
# MODOS (Chefes | Torre | Masmorras | PvP)
# =============================================================================================
func modes_screen() -> Control:
	var f := frame("Modos de Jogo", Color("#8a5a3a"))
	var c: VBoxContainer = f[1]
	(f[2] as VBoxContainer).add_child(segmented([["boss", "Chefes"], ["tower", "Torre"], ["dungeon", "Masmorras"], ["pvp", "PvP"]], modes_tab, func(id: String) -> void:
		modes_tab = id
		main.open_screen("modes", true)))
	(f[2] as VBoxContainer).move_child((f[2] as VBoxContainer).get_child(2), 1)
	match modes_tab:
		"boss":
			c.add_child(UI.para("Chefes liberam com o nível da conta. Vencer um chefe é requisito para EVOLUIR a raridade das bolinhas.", 17, UI.C_TEXT_MID))
			for i in DB.BOSS_RAID.size():
				var br: Dictionary = DB.BOSS_RAID[i]
				var bd: Dictionary = DB.BOSSES[br.boss]
				var ic := BallIcon.new().setup_look(BallArt.normalize(bd.look), int(bd.rarity))
				ic.custom_minimum_size = Vector2(72, 72)
				var unl := Game.boss_unlocked(i)
				ic.dim = not unl
				var tier := Game.boss_tier(br.boss)
				var evo := DB.EVO_BOSS.find(br.boss)
				var sub := ("Dificuldade %d · Tentativas %d/3" % [tier + 1, Game.boss_tries_left(br.boss)]) if unl else "Libera no nível %d da conta" % int(br.level)
				if evo >= 0:
					sub += " · Evolução para %s" % DB.rarity(evo + 1).name
				var idx := i
				c.add_child(row_card(ic, bd.name, sub, "Lutar", UI.C_RED, func() -> void: start_boss(idx), unl and Game.boss_tries_left(br.boss) > 0, Color("#fbeae2") if unl else Color("#e4ded4")))
		"tower":
			var ic2 := UI.tex_rect(PixelArt.icon("tower"), Vector2(64, 64))
			c.add_child(row_card(ic2, "Andar %d" % int(Game.d.tower), "Recorde: %d · Chefe a cada 5 andares · gemas e cristais" % int(Game.d.tower_best), "Subir", UI.C_BLUE, start_tower))
			c.add_child(UI.para("Cada andar fica mais difícil. Os andares múltiplos de 5 têm chefes e dão cristais de evolução; os de 10 dão muitas gemas.", 17, UI.C_TEXT_MID))
		"dungeon":
			for dg in DB.DUNGEONS:
				var di := UI.tex_rect(PixelArt.icon("dungeon"), Vector2(64, 64))
				di.modulate = Color(dg.color).lightened(0.3)
				var unlocked := int(Game.d.level) >= int(dg.level)
				var sub2: String = ("%s Nível %d · Tentativas %d/2" % [dg.desc, Game.dungeon_level(dg.id), Game.dungeon_tries_left(dg.id)]) if unlocked else "Libera no nível %d da conta" % int(dg.level)
				var dgc: Dictionary = dg
				c.add_child(row_card(di, dg.name, sub2, "Entrar", UI.C_YELLOW, func() -> void: start_dungeon(dgc), unlocked and Game.dungeon_tries_left(dg.id) > 0))
		"pvp":
			_pvp_content(c)
	return f[0]


func start_boss(i: int) -> void:
	var br: Dictionary = DB.BOSS_RAID[i]
	var tier := Game.boss_tier(br.boss) + 1
	var g := float(br.level) * 4.0 + tier * 8.0
	var waves := [[Game.enemy_spec(br.boss, g, true, 1.0 + tier * 0.3)]]
	main.start_mode("boss", {"boss": br.boss, "tier": tier, "idx": i, "sub": "Modo Chefes · Dificuldade %d" % tier,
		"theme": {"floor": "#f6e6e0", "floor2": "#e8ccc4", "accent": "#e85a48", "line": "#d8a898"}},
		main._team_specs(), waves, DB.BOSSES[br.boss].name, 90.0)


func start_tower() -> void:
	var fl := int(Game.d.tower)
	var g := 3.0 + fl * 1.5
	var waves := []
	if fl % 5 == 0:
		var bosses := DB.BOSSES.keys()
		waves.append([Game.enemy_spec(bosses[(fl / 5) % bosses.size()], g, true, 0.7)])
	else:
		var list := []
		var kinds := DB.ENEMIES.keys()
		for i in mini(2 + fl / 10, 5):
			list.append(Game.enemy_spec(kinds[randi() % kinds.size()], g))
		waves.append(list)
	main.start_mode("tower", {"floor": fl, "sub": "Torre Infinita", "theme": {"floor": "#e6eef8", "floor2": "#cddcf0", "accent": "#5ab4f0", "line": "#a8c4e0"}},
		main._team_specs(), waves, "Torre · Andar %d" % fl, 75.0)


func start_dungeon(dg: Dictionary) -> void:
	var L := Game.dungeon_level(dg.id)
	var g := 4.0 + L * 5.0
	var waves := []
	for w in 3:
		var list := []
		for i in 2 + int(w == 2):
			list.append(Game.enemy_spec(dg.enemy, g + w))
		waves.append(list)
	main.start_mode("dungeon", {"dg": dg, "level": L, "sub": "Masmorra Nível %d" % L, "theme": {"floor": "#f8efd8", "floor2": "#ecdcb4", "accent": Color(dg.color).to_html(), "line": "#d8c090"}},
		main._team_specs(), waves, dg.name, 70.0)


func _pvp_content(c: VBoxContainer) -> void:
	var pv: Dictionary = Game.d.pvp
	var k := UI.card(Color("#efe4f8"))
	k[1].add_child(UI.label("Pontos de Arena: %d" % int(pv.rating), 26, Color("#e8d8ff")))
	k[1].add_child(UI.para("Vitórias %d · Derrotas %d · Bilhetes hoje: %d/5" % [int(pv.wins), int(pv.losses), int(pv.tickets)], 18))
	k[1].add_child(UI.para("Lute contra bolinhas de outros treinadores (geradas no aparelho; PvP online exige servidor).", 15, UI.C_TEXT_MID))
	c.add_child(k[0])
	if pvp_opps.is_empty():
		for i in 3:
			pvp_opps.append(Game.pvp_opponent())
	for opp in pvp_opps:
		var t: Dictionary = opp.team[0]
		var bi := BallIcon.new().setup(t.id, int(t.b.rarity))
		bi.custom_minimum_size = Vector2(72, 72)
		var o: Dictionary = opp
		c.add_child(row_card(bi, opp.name, "%s · Poder %s · Pontos %d" % [DB.BALLS[t.id].name, UI.fmt(Game.ball_power(t.id, t.b)), int(opp.rating)], "Lutar", UI.C_RED, func() -> void: start_pvp(o), int(pv.tickets) > 0))
	var h := UI.hbox(8)
	var rb := UI.button("Trocar oponentes", UI.C_BLUE, 18, Vector2(0, 54))
	rb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rb.pressed.connect(func() -> void:
		pvp_opps.clear()
		main.open_screen("modes", true))
	h.add_child(rb)
	var buy := UI.button("+5 bilhetes (40 gemas)", UI.C_PURPLE, 18, Vector2(0, 54))
	buy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy.pressed.connect(func() -> void:
		if Game.spend_gems(40):
			Game.d.pvp.tickets = int(Game.d.pvp.tickets) + 5
			main.open_screen("modes", true)
		else:
			main.toast("Gemas insuficientes", Color("#ffb0a0")))
	h.add_child(buy)
	c.add_child(h)


func start_pvp(opp: Dictionary) -> void:
	if int(Game.d.pvp.tickets) <= 0:
		main.toast("Sem bilhetes de arena hoje", Color("#ffb0a0"))
		return
	Game.d.pvp.tickets = int(Game.d.pvp.tickets) - 1
	var enemy := []
	for t in opp.team:
		enemy.append(Game.ball_spec(t.id, t.b))
	main.start_mode("pvp", {"opp": opp, "sub": "Arena PvP", "theme": {"floor": "#f0e8f8", "floor2": "#dccdec", "accent": "#9a64e0", "line": "#c0a8e0"}},
		main._team_specs(), [enemy], "PvP vs " + opp.name, 90.0)


func mode_result(mode: String, data: Dictionary, win: bool) -> void:
	var lines := []
	match mode:
		"boss":
			var boss: String = data.boss
			Game.d.boss_tries[boss] = int(Game.d.boss_tries.get(boss, 0)) + 1
			if win:
				Game.progress("boss")
				Game.d.boss[boss] = maxi(Game.boss_tier(boss), int(data.tier))
				var gems := 20 + 10 * int(data.tier)
				Game.add_gems(gems)
				var m := Game.roll_mat(clampi(int(data.idx) / 2, 0, 7), 2 + int(data.tier))
				lines.append("+%d gemas" % gems)
				lines.append("+%d %s" % [m.n, m.name])
				var frag := _random_frags(5)
				if frag != "":
					lines.append(frag)
				if DB.EVO_BOSS.has(boss):
					lines.append("Requisito de evolução cumprido: %s!" % DB.BOSSES[boss].name)
		"tower":
			if win:
				Game.progress("tower")
				var fl := int(data.floor)
				Game.d.tower = fl + 1
				Game.d.tower_best = maxi(int(Game.d.tower_best), fl)
				var coins := Game.stage_reward_coins(3.0 + fl * 1.5) * 2.0
				Game.add_coins(coins)
				var gems2 := 5 + (30 if fl % 10 == 0 else 0)
				Game.add_gems(gems2)
				lines.append("+%s moedas  +%d gemas" % [UI.fmt(coins), gems2])
				if fl % 5 == 0:
					var m2 := Game.roll_mat(clampi(fl / 10, 0, 7), 3)
					lines.append("+%d %s" % [m2.n, m2.name])
		"dungeon":
			var dg: Dictionary = data.dg
			Game.d.dungeon_tries[dg.id] = int(Game.d.dungeon_tries.get(dg.id, 0)) + 1
			if win:
				Game.progress("dungeon")
				var L := int(data.level)
				Game.d.dungeon[dg.id] = L
				match dg.reward:
					"coins":
						var cc := Game.stage_reward_coins(4.0 + L * 5.0) * 8.0
						Game.add_coins(cc)
						lines.append("+%s moedas" % UI.fmt(cc))
					"keys":
						Game.add_keys(15 + L * 5)
						lines.append("+%d chaves" % (15 + L * 5))
					"frags":
						lines.append(_random_frags(5 + L))
						var m3 := Game.roll_mat(clampi(L / 3, 0, 7), 3 + L)
						lines.append("+%d %s" % [m3.n, m3.name])
		"pvp":
			Game.progress("pvp")
			if win:
				Game.d.pvp.rating = int(Game.d.pvp.rating) + 25
				Game.d.pvp.wins = int(Game.d.pvp.wins) + 1
				Game.add_gems(15)
				lines.append("+25 pontos de arena  +15 gemas")
			else:
				Game.d.pvp.rating = maxi(0, int(Game.d.pvp.rating) - 15)
				Game.d.pvp.losses = int(Game.d.pvp.losses) + 1
				lines.append("-15 pontos de arena")
			pvp_opps.clear()
	if not win and lines.is_empty():
		lines.append("Evolua sua bolinha, troque equipamentos e tente de novo.")
	Game.save_game()
	var v := UI.vbox(6)
	for l in lines:
		var lb := UI.para(l, 21)
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(lb)
	popup("VITÓRIA!" if win else "DERROTA", v, [["Continuar", UI.C_GREEN if win else UI.C_YELLOW, main.back_to_campaign]], 540)


func _random_frags(n: int) -> String:
	var ids: Array = Game.d.balls.keys()
	if ids.is_empty():
		return ""
	var id: String = ids[randi() % ids.size()]
	Game.d.balls[id].frags = int(Game.d.balls[id].frags) + n
	return "+%d fragmentos de %s" % [n, DB.BALLS[id].name]


# =============================================================================================
# MELHORIAS
# =============================================================================================
func upgrades_screen() -> Control:
	var f := frame("Melhorias", Color("#4a7a5a"))
	var c: VBoxContainer = f[1]
	c.add_child(section("Treinos"))
	for u in DB.UPGRADES:
		var maxed: bool = u.has("max") and Game.upg(u.id) >= int(u.max)
		var uu: Dictionary = u
		var ic := UI.tex_rect(PixelArt.icon({"atk": "power", "hp": "armor", "gold": "coin", "chest": "chest", "offline": "hourglass"}.get(u.id, "star")), Vector2(56, 56))
		c.add_child(row_card(ic, "%s  ·  Nv.%d" % [u.name, Game.upg(u.id)], u.desc, "MÁX" if maxed else UI.fmt(Game.upg_cost(u)), UI.C_YELLOW, func() -> void:
			if Game.buy_upgrade(uu):
				main.open_screen("upgrades", true)
			else:
				main.toast("Moedas insuficientes", Color("#ffb0a0")), not maxed))
	c.add_child(section("Cristais de evolução"))
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 8)
	g.add_theme_constant_override("v_separation", 8)
	for m in DB.EVO_MATS:
		var h := UI.hbox(8)
		var ic2 := UI.tex_rect(PixelArt.icon("crystal"), Vector2(36, 36))
		ic2.modulate = Color(m.color)
		h.add_child(ic2)
		var l := UI.para("%s: %d" % [m.name, Game.mat_count(m.id)], 17)
		h.add_child(l)
		h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g.add_child(h)
	c.add_child(g)
	c.add_child(UI.para("Cristais caem em baús, masmorras, chefes e na torre. Use-os para evoluir a raridade das bolinhas.", 15, UI.C_TEXT_MID))
	return f[0]


# =============================================================================================
# LOJA
# =============================================================================================
func shop_screen() -> Control:
	var f := frame("Loja", Color("#b84a4a"))
	var c: VBoxContainer = f[1]
	if Billing.test_mode:
		var tk := UI.card(Color("#fff0c0"))
		tk[1].add_child(UI.para("MODO TESTE: as compras são simuladas e nada é cobrado. Na versão publicada da Play Store as compras são reais.", 15))
		c.add_child(tk[0])
	c.add_child(section("Grátis"))
	var gift := UI.tex_rect(PixelArt.icon("gift"), Vector2(54, 54))
	c.add_child(row_card(gift, "Presente diário", "30 gemas + 20 chaves", "Pegar", UI.C_GREEN, func() -> void:
		Game.d.free_day = Game.today()
		Game.add_gems(30)
		Game.add_keys(20)
		main.open_screen("shop", true), Game.d.get("free_day", "") != Game.today()))
	if Game.is_vip():
		c.add_child(row_card(UI.tex_rect(PixelArt.icon("vip"), Vector2(54, 54)), "Bônus VIP", "100 gemas por dia, +20% moedas, +2h idle", "Pegar", Color("#ffb020"), func() -> void:
			Game.d.vip_claim_day = Game.today()
			Game.add_gems(100)
			main.open_screen("shop", true), Game.d.get("vip_claim_day", "") != Game.today()))
	c.add_child(section("Gamepass & Ofertas"))
	for p in DB.IAP:
		if not (p.has("speed") or p.has("once") or p.has("vip_days")) or not Game.iap_available(p):
			continue
		c.add_child(_iap_card(p))
	c.add_child(section("Gemas"))
	for p in DB.IAP:
		if p.has("speed") or p.has("once") or p.has("vip_days"):
			continue
		c.add_child(_iap_card(p))
	c.add_child(section("Trocar gemas"))
	for p in DB.GEM_SHOP:
		var pp: Dictionary = p
		var txt: String = p.name
		if p.has("coins_hours"):
			txt += " (%s)" % UI.fmt(Game.stage_reward_coins(float(Game.d.best)) * 80.0 * int(p.coins_hours))
		c.add_child(row_card(UI.tex_rect(PixelArt.icon("key" if p.has("keys") else "coin"), Vector2(48, 48)), txt, "", "%d gemas" % int(p.cost), UI.C_PURPLE, func() -> void:
			if not Game.spend_gems(int(pp.cost)):
				main.toast("Gemas insuficientes", Color("#ffb0a0"))
				return
			if pp.has("keys"):
				Game.add_keys(int(pp["keys"]))
			if pp.has("coins_hours"):
				Game.add_coins(Game.stage_reward_coins(float(Game.d.best)) * 80.0 * int(pp.coins_hours))
			main.toast("Comprado!", Color("#7cf08c"))))
	return f[0]


func _iap_card(p: Dictionary) -> Control:
	var desc := ""
	if int(p.get("gems", 0)) > 0:
		desc = "%d gemas" % int(p.gems)
	if int(p.get("bonus", 0)) > 0:
		desc += " + %d bônus" % int(p.bonus)
	if p.has("keys"):
		desc += " + %d chaves" % int(p["keys"])
	if p.has("ball_rarity"):
		desc += " + bolinha %s" % DB.rarity(int(p.ball_rarity)).name
	if p.has("vip_days"):
		desc += " + VIP %d dias" % int(p.vip_days)
	if p.has("desc"):
		desc = p.desc
	var icon := "bolt" if p.has("speed") else ("vip" if p.has("vip_days") else ("gift" if p.has("once") else "gem"))
	var pid: String = p.id
	var card := row_card(UI.tex_rect(PixelArt.icon(icon), Vector2(54, 54)), p.name, desc, p.price, UI.C_GREEN, func() -> void: Billing.purchase(pid), true, Color("#fff6e0") if p.has("speed") else Color("#fffaf0"))
	return card


# =============================================================================================
# POPUPS
# =============================================================================================
func item_popup(it: Dictionary) -> void:
	if it.is_empty():
		return
	var v := UI.vbox(6)
	var h := UI.hbox(12)
	var tile := ItemTile.new()
	tile.custom_minimum_size = Vector2(110, 110)
	tile.set_item(it, it.slot)
	h.add_child(tile)
	var iv := UI.vbox(3)
	iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var info: Dictionary = DB.SLOT_INFO[it.slot]
	iv.add_child(UI.para("%s %s" % [info.name, DB.rarity(int(it.rarity)).name], 22, DB.rcolor(int(it.rarity)).darkened(0.25)))
	var mv := Game.item_main(it)
	match info.main:
		"atk": iv.add_child(UI.para("Ataque +%s" % UI.fmt(mv), 19))
		"hp": iv.add_child(UI.para("Vida +%s" % UI.fmt(mv), 19))
		"both": iv.add_child(UI.para("Ataque +%s · Vida +%s" % [UI.fmt(mv), UI.fmt(mv * 6.0)], 19))
	for k in it.get("subs", {}):
		iv.add_child(UI.para("%s +%s" % [DB.SUBSTATS[k].name, UI.pct(float(it.subs[k]))], 17, Color("#2a6a9a")))
	if it.slot == "weapon":
		iv.add_child(UI.para("Tipo: %s%s" % [DB.WEAPON_TYPES[int(it.get("wtype", 0))], " (dispara tiros)" if int(it.get("wtype", 0)) == 1 else " (+50% dano de colisão)"], 16))
	h.add_child(iv)
	v.add_child(h)
	v.add_child(UI.para("Equipamentos são seus, não da bolinha: valem para qualquer bolinha que estiver em campo.", 15, UI.C_TEXT_MID))
	var btns := []
	if Game.equipped(it.slot) == it:
		var cost := Game.forge_cost(it)
		v.add_child(UI.para("Forja: melhore este item em +1 nível por %s moedas." % UI.fmt(cost), 16, Color("#8a5a10")))
		btns.append(["Forjar +1", UI.C_YELLOW, func() -> void:
			if Game.forge(it.slot):
				main.toast("%s agora é Nv. %d!" % [DB.SLOT_INFO[it.slot].name, int(it.level)], Color("#ffe27a"))
				main._refresh_equipment()
				item_popup.call_deferred(it)
			else:
				main.toast("Moedas insuficientes", Color("#ffb0a0"))])
	btns.append(["Fechar", UI.C_GRAY, Callable()])
	popup("Equipamento", v, btns, 580)


func offline_popup() -> void:
	var off: Dictionary = Game.d.get("offline", {})
	var v := UI.vbox(8)
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(0, 90)
	var cs := Fx.make("coin_spin", {"scale": 2.0, "loop": true, "center": true})
	if cs:
		holder.add_child(cs)
		holder.resized.connect(func() -> void: cs.position = Vector2(holder.size.x * 0.5, 45))
	v.add_child(holder)
	v.add_child(UI.para("Sua bolinha continuou lutando por %s (máx. %dh)." % [UI.time_str(float(off.get("secs", 0))), int(Game.offline_cap_hours())], 19))
	var l1 := UI.para("+%s moedas" % UI.fmt(float(off.get("coins", 0))), 24, Color("#b07a10"))
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l1)
	var l2 := UI.para("+%d chaves  ·  +%s XP" % [int(off.get("keys", 0)), UI.fmt(float(off.get("xp", 0)))], 20, Color("#2a6a9a"))
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l2)
	popup("Recompensas Idle", v, [
		["Coletar", UI.C_GREEN, func() -> void: Game.claim_offline(1.0)],
		["x2 (30 gemas)", UI.C_PURPLE, func() -> void:
			if Game.spend_gems(30):
				Game.claim_offline(2.0)
			else:
				Game.claim_offline(1.0)],
	], 560)


var goals_tab := "login"


func missions_popup() -> void:
	var v := UI.vbox(8)
	v.add_child(segmented([["login", "Login"], ["daily", "Diárias"], ["ach", "Conquistas"]], goals_tab, func(t: String) -> void:
		goals_tab = t
		close_popups()
		missions_popup.call_deferred()))
	match goals_tab:
		"login":
			var st := Game.login_state()
			v.add_child(UI.para("Entre todo dia para ganhar prêmios. No 7º dia: uma bolinha Épica!", 16, UI.C_TEXT_MID))
			var g := GridContainer.new()
			g.columns = 4
			g.add_theme_constant_override("h_separation", 6)
			g.add_theme_constant_override("v_separation", 6)
			for i in 7:
				var rw: Dictionary = Game.LOGIN_REWARDS[i]
				var txt := ""
				if rw.has("gems"):
					txt = "%d gemas" % int(rw.gems)
				elif rw.has("keys"):
					txt = "%d chaves" % int(rw["keys"])
				elif rw.has("coins_h"):
					txt = "Moedas"
				elif rw.has("mat"):
					txt = "Cristais"
				elif rw.has("ball"):
					txt = "Bolinha Épica"
				var done: bool = i < int(st.day) or (i == int(st.day) and not st.can)
				var today_: bool = i == int(st.day) and st.can
				var k := UI.card(Color("#c8f0c0") if done else (Color("#fff0a8") if today_ else Color("#fffaf0")))
				k[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var l1 := UI.para("Dia %d" % (i + 1), 16, UI.C_TEXT_MID)
				l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				k[1].add_child(l1)
				var ic := UI.tex_rect(PixelArt.icon("gem" if rw.has("gems") else ("key" if rw.has("keys") else ("coin" if rw.has("coins_h") else ("crystal" if rw.has("mat") else "gacha")))), Vector2(40, 40))
				k[1].add_child(ic)
				var l2 := UI.para(txt, 14)
				l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				k[1].add_child(l2)
				g.add_child(k[0])
			v.add_child(g)
			var cb := UI.button("Pegar prêmio de hoje" if st.can else "Volte amanhã!", UI.C_GREEN, 19, Vector2(0, 56))
			cb.disabled = not st.can
			cb.pressed.connect(func() -> void:
				var res := Game.claim_login()
				if res.has("ball_id"):
					close_popups()
					main.gacha_ui.reveal_single(res.ball_id, int(DB.BALLS[res.ball_id].rarity), false)
				else:
					main.toast("Prêmio do dia coletado!", Color("#a8f0b0"))
					close_popups()
					missions_popup.call_deferred()
				main._refresh_top())
			v.add_child(cb)
		"daily":
			v.add_child(UI.para("Missões renovam todo dia. Complete para ganhar gemas!", 16, UI.C_TEXT_MID))
			for m in Game.MISSIONS:
				var cur := int(Game.d.missions.get(m.id, 0))
				var claimed: bool = Game.d.mission_claimed.has(m.id)
				v.add_child(_goal_row(m.name, cur, int(m.goal), int(m.gems), claimed, Game.mission_ready(m), func() -> void:
					Game.claim_mission(m)))
		"ach":
			v.add_child(UI.para("Conquistas permanentes: metas de longo prazo com muitas gemas.", 16, UI.C_TEXT_MID))
			var list := Game.achievements()
			list.sort_custom(func(a, b):
				var ra := 0 if Game.ach_ready(a) else (2 if Game.d.get("ach", {}).has(a[0]) else 1)
				var rb := 0 if Game.ach_ready(b) else (2 if Game.d.get("ach", {}).has(b[0]) else 1)
				return ra < rb)
			for a in list:
				var aa: Array = a
				v.add_child(_goal_row(a[1], int(a[2]), int(a[3]), int(a[4]), Game.d.get("ach", {}).has(a[0]), Game.ach_ready(a), func() -> void:
					Game.claim_ach(aa)))
	popup("Objetivos", v, [["Fechar", UI.C_YELLOW, Callable()]], 620)


func _goal_row(title: String, cur: int, goal: int, gems: int, claimed: bool, ready: bool, on_claim: Callable) -> Control:
	var k := UI.card(Color("#eaf6e0") if claimed else Color("#fffaf0"))
	var h := UI.hbox(8)
	var vv := UI.vbox(3)
	vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vv.add_child(UI.para(title, 17))
	var pr := UI.bar(UI.C_GREEN, 12)
	pr.value = clampf(float(cur) / float(maxi(1, goal)), 0.0, 1.0)
	vv.add_child(pr)
	vv.add_child(UI.para("%d/%d  ·  +%d gemas" % [mini(cur, goal), goal, gems], 14, UI.C_TEXT_MID))
	h.add_child(vv)
	var b := UI.button("Feito" if claimed else "Pegar", UI.C_GREEN, 17, Vector2(92, 50))
	b.disabled = not ready
	b.pressed.connect(func() -> void:
		on_claim.call()
		main.toast("+%d gemas" % gems, Color("#a8e2ff"))
		main._refresh_top()
		close_popups()
		missions_popup.call_deferred())
	h.add_child(b)
	k[1].add_child(h)
	return k[0]


func settings_popup() -> void:
	var v := UI.vbox(10)
	v.add_child(section("Jogador"))
	var nh := UI.hbox(8)
	var le := LineEdit.new()
	le.text = str(Game.d.name)
	le.max_length = 16
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	le.custom_minimum_size = Vector2(0, 50)
	le.add_theme_font_size_override("font_size", 20)
	nh.add_child(le)
	var sv := UI.button("Salvar nome", UI.C_BLUE, 17, Vector2(130, 50))
	sv.pressed.connect(func() -> void:
		Game.d.name = le.text.strip_edges() if le.text.strip_edges() != "" else "Jogador"
		main._refresh_top()
		main.toast("Nome salvo", Color.WHITE))
	nh.add_child(sv)
	v.add_child(nh)
	v.add_child(section("Salvar jogo"))
	v.add_child(UI.para("O jogo salva sozinho a cada 15s e ao sair. Use os espaços abaixo para guardar cópias do seu progresso.", 15, UI.C_TEXT_MID))
	var now := UI.button("Salvar agora", UI.C_GREEN, 19, Vector2(0, 54))
	now.pressed.connect(func() -> void:
		Game.save_game()
		main.toast("Jogo salvo!", Color("#a8f0b0")))
	v.add_child(now)
	for i in range(1, 4):
		var info := Game.slot_info(i)
		var desc := "Vazio" if info.is_empty() else "Cap. %d-%d · Nv.%d · %d bolinhas · %s" % [info.chapter, info.stage, info.level, info.balls, str(info.saved_at).replace("T", " ")]
		var k := UI.card(Color("#fffaf0"))
		var h := UI.hbox(6)
		var vv := UI.vbox(2)
		vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vv.add_child(UI.para("Espaço %d" % i, 19))
		vv.add_child(UI.para(desc, 14, UI.C_TEXT_MID))
		h.add_child(vv)
		var slot := i
		var bs := UI.button("Salvar", UI.C_BLUE, 16, Vector2(86, 50))
		bs.pressed.connect(func() -> void:
			Game.save_slot(slot)
			main.toast("Salvo no espaço %d" % slot, Color("#a8f0b0"))
			close_popups()
			settings_popup.call_deferred())
		h.add_child(bs)
		var bl := UI.button("Carregar", UI.C_YELLOW, 16, Vector2(96, 50))
		bl.disabled = info.is_empty()
		bl.pressed.connect(func() -> void:
			if Game.load_slot(slot):
				close_popups()
				main.close_screen()
				main.start_campaign()
				main.toast("Espaço %d carregado" % slot, Color("#a8f0b0")))
		h.add_child(bl)
		k[1].add_child(h)
		v.add_child(k[0])
	v.add_child(section("Backup por código"))
	v.add_child(UI.para("Copie o código para guardar ou passar o progresso para outro aparelho.", 15, UI.C_TEXT_MID))
	var ch := UI.hbox(8)
	var exp := UI.button("Copiar código", UI.C_BLUE, 17, Vector2(0, 52))
	exp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exp.pressed.connect(func() -> void:
		DisplayServer.clipboard_set(Game.export_code())
		main.toast("Código copiado!", Color("#a8e2ff")))
	ch.add_child(exp)
	var imp := UI.button("Colar código", UI.C_YELLOW, 17, Vector2(0, 52))
	imp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	imp.pressed.connect(func() -> void:
		var code := DisplayServer.clipboard_get()
		if Game.import_code(code):
			close_popups()
			main.close_screen()
			main.start_campaign()
			main.toast("Progresso importado!", Color("#a8f0b0"))
		else:
			main.toast("Código inválido na área de transferência", Color("#ffb0a0")))
	ch.add_child(imp)
	v.add_child(ch)
	v.add_child(section("Perigo"))
	var rs := UI.button("Apagar progresso", UI.C_RED, 17, Vector2(0, 52))
	rs.pressed.connect(func() -> void:
		popup("Tem certeza?", UI.para("Isso apaga TODO o progresso atual (os espaços salvos continuam).", 20), [["Apagar", UI.C_RED, func() -> void:
			Game.reset_save()
			close_popups()
			main.close_screen()
			main.start_campaign()], ["Cancelar", UI.C_GRAY, Callable()]], 520))
	v.add_child(rs)
	popup("Configurações", v, [["Fechar", UI.C_YELLOW, Callable()]], 640)

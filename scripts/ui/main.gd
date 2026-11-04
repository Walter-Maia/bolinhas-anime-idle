extends Control
## Tela principal: HUD + arena + equipamentos/bau + navegacao. Controla os modos de batalha e o fluxo da historia.

const NAV := [["story", "scroll", "História"], ["modes", "dungeon", "Modos"], ["balls", "", "Bolinhas"], ["upgrades", "book", "Melhorias"], ["gacha", "gacha", "Invocar"], ["shop", "shop", "Loja"]]

var battle: Battle
var arena_box: Control
var lbl_name: Label
var lbl_power: Label
var lbl_coins: Label
var lbl_gems: Label
var lbl_stage: Label
var lbl_chapter: Label
var lbl_left: Label
var wave_bars: Array = []
var xp_bar: ProgressBar
var avatar: BallIcon
var portraits: Array = []
var tabs: Array = []
var btn_auto: Button
var btn_speed: Button
var btn_advance: Button
var btn_missions: Button
var mission_dot: Control
var lbl_hour: Label
var btn_vip: Button

var tiles: Dictionary = {}
var lbl_ball: Label
var btn_chest: Button
var btn_auto_chest: Button
var pedestal_tile: ItemTile
var pedestal_ball: BallIcon
var lbl_keys: Label
var btn_equip: Button
var btn_sell: Button

var nav_buttons: Dictionary = {}
var screen_layer: Control
var popup_layer: Control
var cur_screen := ""
var screens: Screens
var story: StoryUI
var gacha_ui: GachaUI
var collection: CollectionUI

var mode := "campaign"
var mode_data: Dictionary = {}
var _chest_t := 0.0
var _idle_t := 0.0
var _flow_busy := false


func _ready() -> void:
	theme = UI.theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	screens = Screens.new(self)
	story = StoryUI.new(self)
	gacha_ui = GachaUI.new(self)
	collection = CollectionUI.new(self)
	_build()
	Game.changed.connect(_refresh_top)
	Game.team_changed.connect(_on_team_changed)
	Game.leveled_up.connect(func(l: int) -> void:
		toast("Nível da conta %d!  +20 gemas" % l, Color("#ffd23c"))
		battle.fx(battle.arena * 0.5, "stars", {"size": 120.0}))
	Game.mission_done.connect(func(m: Dictionary) -> void: toast("Missão concluída: " + str(m.name), Color("#a8f0b0")))
	Billing.purchase_finished.connect(_on_purchase)
	_refresh_top()
	_on_team_changed()
	await get_tree().process_frame
	start_campaign()
	if not Game.d.get("offline", {}).is_empty() and float(Game.d.offline.get("secs", 0)) > 120:
		screens.offline_popup()
	_debug_shots()


func _process(delta: float) -> void:
	var us := _player_units()
	for p: BallIcon in portraits:
		var u: Unit = us.get(p.get_meta("id", ""), null)
		p.show_cd = u != null
		if u:
			p.ratio = u.ready_skill_ratio()
		p.queue_redraw()
	_chest_t -= delta
	if Game.d.auto_chest and _chest_t <= 0.0:
		_chest_t = 0.9
		_auto_chest_step()
	_idle_t += delta
	if _idle_t >= 5.0:
		_idle_t = 0.0
		Game.idle_tick(5.0)
		lbl_hour.text = UI.fmt(float(Game.d.get("offline", {}).get("coins", 0)))
		mission_dot.visible = Game.goals_pending() > 0
		nav_buttons.story.dot = false


func _player_units() -> Dictionary:
	var out := {}
	if battle == null:
		return out
	for u: Unit in battle.units:
		if u.team == 0 and not u.is_summon and not u.dead:
			out[u.ball_id] = u
	return out


# =============================================================================================
# construcao
# =============================================================================================
func _build() -> void:
	var bg := Control.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.draw.connect(func() -> void:
		bg.draw_rect(Rect2(Vector2.ZERO, bg.size), UI.C_BG)
		# listras diagonais suaves
		var step := 46.0
		var n := int((bg.size.x + bg.size.y) / step) + 2
		for i in n:
			var x := i * step
			bg.draw_line(Vector2(x, 0), Vector2(x - bg.size.y, bg.size.y), Color(1, 1, 1, 0.035), 18.0))
	bg.resized.connect(bg.queue_redraw)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)
	root.add_child(_build_top())
	var am := MarginContainer.new()
	am.add_theme_constant_override("margin_left", 14)
	am.add_theme_constant_override("margin_right", 14)
	am.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var arena_panel := PanelContainer.new()
	var ast := UI.box(UI.C_CREAM, UI.C_BORDER, 5, 0, 14)
	ast.set_content_margin_all(5)
	ast.shadow_color = Color(0, 0, 0, 0.25)
	ast.shadow_size = 6
	ast.shadow_offset = Vector2(0, 5)
	arena_panel.add_theme_stylebox_override("panel", ast)
	am.add_child(arena_panel)
	arena_box = Control.new()
	arena_box.clip_contents = true
	arena_box.custom_minimum_size = Vector2(0, 320)
	arena_panel.add_child(arena_box)
	battle = Battle.new()
	arena_box.add_child(battle)
	arena_box.resized.connect(func() -> void: battle.set_arena(arena_box.size))
	battle.finished.connect(_on_battle_finished)
	battle.wave_started.connect(_on_wave)
	battle.enemy_killed.connect(_on_enemy_killed)
	root.add_child(am)
	root.add_child(_build_controls())
	root.add_child(_build_bottom())
	root.add_child(_build_nav())

	screen_layer = Control.new()
	screen_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_layer.offset_bottom = -106
	screen_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_layer.clip_contents = true
	add_child(screen_layer)
	popup_layer = Control.new()
	popup_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(popup_layer)


func _build_top() -> Control:
	var top := UI.vbox(6)
	var m := UI.margin(top, 12, 10)
	var r1 := UI.hbox(8)
	avatar = BallIcon.new()
	avatar.custom_minimum_size = Vector2(80, 80)
	avatar.pressed.connect(func() -> void: open_screen("balls"))
	r1.add_child(avatar)
	var nv := UI.vbox(3)
	nv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_name = UI.label("Jogador", 22)
	lbl_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nv.add_child(lbl_name)
	xp_bar = UI.bar(Color("#7cd0ff"), 10)
	xp_bar.custom_minimum_size = Vector2(150, 10)
	nv.add_child(xp_bar)
	var pwp := UI.panel(Color(0.08, 0.25, 0.14, 0.55), Color(0, 0, 0, 0.3), 2)
	(pwp.get_theme_stylebox("panel") as StyleBoxFlat).set_content_margin_all(3)
	var pw := UI.hbox(4)
	pw.add_child(UI.tex_rect(PixelArt.icon("power"), Vector2(26, 26)))
	lbl_power = UI.label("0", 22, Color("#bfe8ff"))
	pw.add_child(lbl_power)
	pwp.add_child(pw)
	pwp.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	nv.add_child(pwp)
	r1.add_child(nv)
	var cv := UI.vbox(4)
	lbl_coins = UI.label("0", 22)
	lbl_gems = UI.label("0", 22)
	cv.add_child(UI.currency_pill("coin", lbl_coins))
	var gp := UI.currency_pill("gem", lbl_gems, true)
	gp.mouse_filter = Control.MOUSE_FILTER_STOP
	gp.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			open_screen("shop"))
	cv.add_child(gp)
	r1.add_child(cv)
	var gear := UI.icon_button("gear", UI.C_BROWN, Vector2(52, 52))
	gear.pressed.connect(screens.settings_popup)
	r1.add_child(gear)
	top.add_child(r1)

	var r2 := UI.hbox(8)
	var p := BallIcon.new()
	p.custom_minimum_size = Vector2(66, 66)
	p.pressed.connect(func() -> void: _cast_manual())
	portraits.append(p)
	var pv := UI.vbox(0)
	pv.add_child(p)
	pv.add_child(_mini_label("SKILL", Color("#ffe27a")))
	r2.add_child(pv)
	var sv := UI.vbox(2)
	sv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sp := PanelContainer.new()
	var sst := UI.box(Color(0.08, 0.25, 0.14, 0.6), Color(0, 0, 0, 0.35), 2, 0, 16)
	sst.content_margin_top = 2
	sst.content_margin_bottom = 4
	sp.add_theme_stylebox_override("panel", sst)
	sp.mouse_filter = Control.MOUSE_FILTER_STOP
	sp.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			open_screen("story"))
	var spv := UI.vbox(2)
	lbl_stage = UI.label("Normal 1-1", 26)
	lbl_stage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spv.add_child(lbl_stage)
	var wb := UI.hbox(5)
	wb.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in 3:
		var seg := Panel.new()
		seg.custom_minimum_size = Vector2(54, 14)
		seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wb.add_child(seg)
		wave_bars.append(seg)
	spv.add_child(wb)
	lbl_left = UI.label("", 15, Color("#e8ffe0"), 4)
	lbl_left.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spv.add_child(lbl_left)
	sp.add_child(spv)
	sv.add_child(sp)
	lbl_chapter = UI.label("", 15, Color("#e8ffe0"), 4)
	lbl_chapter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_chapter.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sv.add_child(lbl_chapter)
	r2.add_child(sv)
	var vb := UI.vbox(4)
	btn_vip = UI.button("VIP 0", Color("#cfcad8"), 17, Vector2(92, 46))
	btn_vip.pressed.connect(func() -> void: open_screen("shop"))
	vb.add_child(btn_vip)
	var mapb := UI.button("Mapa", UI.C_YELLOW, 17, Vector2(92, 46))
	mapb.pressed.connect(func() -> void: open_screen("story"))
	vb.add_child(mapb)
	r2.add_child(vb)
	top.add_child(r2)
	return m


func _mini_label(t: String, c: Color) -> Label:
	var l := UI.label(t, 14, c, 4)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _build_controls() -> Control:
	var h := UI.hbox(8)
	var m := UI.margin(h, 14, 8)
	btn_auto = UI.button("Auto", UI.C_GREEN, 17, Vector2(80, 54))
	btn_auto.pressed.connect(func() -> void:
		Game.d.auto_skill = not Game.d.auto_skill
		_refresh_controls())
	h.add_child(btn_auto)
	btn_speed = UI.button("1x", Color("#2e6b3a"), 20, Vector2(66, 54))
	btn_speed.pressed.connect(_cycle_speed)
	h.add_child(btn_speed)
	btn_advance = UI.button("Avançar", UI.C_YELLOW, 18, Vector2(110, 54))
	btn_advance.pressed.connect(func() -> void:
		Game.d.auto_advance = true
		_refresh_controls()
		if mode == "campaign":
			start_campaign())
	h.add_child(btn_advance)
	h.add_child(UI.spacer())
	btn_missions = UI.icon_button("gift", Color("#d8a860"), Vector2(58, 54))
	btn_missions.pressed.connect(screens.missions_popup)
	mission_dot = Control.new()
	mission_dot.custom_minimum_size = Vector2(1, 1)
	mission_dot.position = Vector2(46, -4)
	mission_dot.draw.connect(func() -> void:
		mission_dot.draw_circle(Vector2.ZERO, 9, UI.C_BORDER)
		mission_dot.draw_circle(Vector2.ZERO, 6.5, Color("#ff4a3a")))
	btn_missions.add_child(mission_dot)
	mission_dot.visible = false
	h.add_child(btn_missions)
	var gb := UI.icon_button("gacha", UI.C_PURPLE, Vector2(58, 54))
	gb.pressed.connect(func() -> void: open_screen("gacha"))
	h.add_child(gb)
	var hv := UI.vbox(0)
	var hg := UI.icon_button("hourglass", Color("#d0b070"), Vector2(58, 46))
	hg.pressed.connect(func() -> void: screens.offline_popup())
	hv.add_child(hg)
	lbl_hour = _mini_label("0", Color.WHITE)
	hv.add_child(lbl_hour)
	h.add_child(hv)
	return m


func _build_bottom() -> Control:
	var panel := PanelContainer.new()
	var st := UI.box(UI.C_CREAM, UI.C_BORDER, 0, 0, 0)
	st.border_width_top = 4
	st.set_content_margin_all(10)
	st.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", st)
	var v := UI.vbox(8)
	panel.add_child(v)
	var th := UI.hbox(8)
	var t := BallIcon.new()
	t.custom_minimum_size = Vector2(46, 46)
	t.pressed.connect(func() -> void: collection.ball_popup(sel_ball()))
	th.add_child(t)
	tabs.append(t)
	lbl_ball = UI.dark_label("", 18)
	lbl_ball.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_ball.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lbl_ball.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	th.add_child(lbl_ball)
	var swap := UI.button("Trocar", UI.C_BLUE, 17, Vector2(96, 46))
	swap.pressed.connect(func() -> void: open_screen("balls"))
	th.add_child(swap)
	v.add_child(th)
	var grid := UI.hbox(8)
	grid.alignment = BoxContainer.ALIGNMENT_CENTER
	var weapon := ItemTile.new()
	weapon.custom_minimum_size = Vector2(104, 200)
	weapon.pressed.connect(func() -> void: _tile_pressed("weapon"))
	tiles["weapon"] = weapon
	grid.add_child(weapon)
	var g := GridContainer.new()
	g.columns = 4
	g.add_theme_constant_override("h_separation", 8)
	g.add_theme_constant_override("v_separation", 8)
	for s in ["armor", "helmet", "amulet", "wings", "gloves", "boots", "belt", "ring"]:
		var tile := ItemTile.new()
		tile.custom_minimum_size = Vector2(96, 96)
		var sl: String = s
		tile.pressed.connect(func() -> void: _tile_pressed(sl))
		tiles[s] = tile
		g.add_child(tile)
	grid.add_child(g)
	v.add_child(grid)
	var ch := UI.hbox(10)
	var cv := UI.vbox(6)
	btn_chest = UI.button("Baú\nNível 1", UI.C_YELLOW, 20, Vector2(160, 70))
	btn_chest.pressed.connect(_open_chest)
	cv.add_child(btn_chest)
	btn_auto_chest = UI.button("Auto", UI.C_BLUE, 19, Vector2(160, 48))
	btn_auto_chest.pressed.connect(func() -> void:
		Game.d.auto_chest = not Game.d.auto_chest
		_refresh_controls())
	cv.add_child(btn_auto_chest)
	ch.add_child(cv)
	var pv := UI.vbox(2)
	pv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pbox := Control.new()
	pbox.custom_minimum_size = Vector2(140, 96)
	pbox.draw.connect(func() -> void:
		pbox.draw_set_transform(Vector2(pbox.size.x * 0.5, 92), 0.0, Vector2(1.0, 0.28))
		pbox.draw_circle(Vector2.ZERO, 66.0, Color("#e6d4ac"))
		pbox.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE))
	pedestal_tile = ItemTile.new()
	pedestal_tile.size = Vector2(90, 90)
	pedestal_tile.pressed.connect(func() -> void: screens.item_popup(Game.d.pending_drop.get("item", {})))
	pbox.add_child(pedestal_tile)
	pedestal_ball = BallIcon.new()
	pedestal_ball.size = Vector2(90, 90)
	pbox.add_child(pedestal_ball)
	pbox.resized.connect(func() -> void:
		pedestal_tile.position = Vector2((pbox.size.x - 90) * 0.5, 0)
		pedestal_ball.position = pedestal_tile.position)
	pv.add_child(pbox)
	var kh := UI.hbox(4)
	kh.alignment = BoxContainer.ALIGNMENT_CENTER
	kh.add_child(UI.tex_rect(PixelArt.icon("key"), Vector2(26, 26)))
	lbl_keys = UI.label("0", 22)
	kh.add_child(lbl_keys)
	pv.add_child(kh)
	ch.add_child(pv)
	var bv := UI.vbox(6)
	btn_equip = UI.button("Equipar", UI.C_GREEN, 19, Vector2(124, 56))
	btn_equip.pressed.connect(_take_drop)
	btn_sell = UI.button("Vender", UI.C_RED, 17, Vector2(124, 56))
	btn_sell.pressed.connect(_sell_drop)
	bv.add_child(btn_equip)
	bv.add_child(btn_sell)
	ch.add_child(bv)
	v.add_child(ch)
	return panel


func _build_nav() -> Control:
	var p := PanelContainer.new()
	var st := UI.box(UI.C_BROWN, UI.C_BROWN_DARK, 0, 0, 0)
	st.border_width_top = 5
	st.set_content_margin_all(0)
	st.content_margin_top = 4
	p.add_theme_stylebox_override("panel", st)
	p.custom_minimum_size = Vector2(0, 106)
	var h := UI.hbox(0)
	for it in NAV:
		var b := NavButton.new()
		b.text = it[2]
		if it[1] == "":
			b.tex = BallArt.make(DB.BALLS.raposa.look)
			b.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		else:
			b.tex = PixelArt.icon(it[1])
			b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var id: String = it[0]
		b.pressed.connect(func() -> void: open_screen(id))
		h.add_child(b)
		nav_buttons[id] = b
	p.add_child(h)
	return p


# =============================================================================================
# refresh
# =============================================================================================
func _refresh_top() -> void:
	lbl_coins.text = UI.fmt(Game.d.coins)
	lbl_gems.text = UI.fmt(Game.d.gems)
	lbl_keys.text = UI.fmt(Game.d.keys)
	lbl_name.text = "%s · Nv.%d" % [Game.d.name, Game.d.level]
	xp_bar.value = clampf(float(Game.d.xp) / Game.xp_need(), 0.0, 1.0)
	lbl_power.text = UI.fmt(Game.team_power())
	btn_chest.text = "Baú\nNível %d" % Game.chest_level()
	btn_vip.text = "VIP %d" % Game.vip_level()
	mission_dot.visible = Game.goals_pending() > 0
	_refresh_drop()


func _on_team_changed() -> void:
	var id := Game.active_id()
	Game.d.sel = 0
	if id != "" and Game.has_ball(id):
		var r := int(Game.ball(id).rarity)
		avatar.setup(id, r)
		portraits[0].set_meta("id", id)
		portraits[0].setup(id, r)
		tabs[0].setup(id, r)
	if battle and mode == "campaign" and battle.running:
		var cur := _player_units()
		if not cur.is_empty() and not cur.has(id):
			start_campaign()
	_refresh_equipment()
	_refresh_top()
	_refresh_controls()


func sel_ball() -> String:
	return Game.active_id()


func _refresh_equipment() -> void:
	var id := sel_ball()
	if id == "" or not Game.has_ball(id):
		return
	var b := Game.ball(id)
	lbl_ball.text = "%s · Nv.%d" % [DB.ball_name(id, int(b.rarity)), int(b.level)]
	for s in tiles:
		var t: ItemTile = tiles[s]
		t.set_item(Game.equipped(s), s, not Game.slot_unlocked(s))
	_refresh_drop()


func _refresh_drop() -> void:
	if pedestal_tile == null:
		return
	var pd: Dictionary = Game.d.get("pending_drop", {})
	var typ: String = pd.get("type", "")
	pedestal_tile.visible = typ == "item"
	pedestal_ball.visible = typ == "ball"
	btn_equip.visible = typ != ""
	btn_sell.visible = typ == "item"
	if typ == "item":
		var it: Dictionary = pd.item
		pedestal_tile.set_item(it, it.slot)
		pedestal_tile.arrow = 1 if Game.item_score(it) > Game.item_score(Game.equipped(it.slot)) else -1
		btn_equip.text = "Equipar"
		btn_sell.text = "Vender +" + UI.fmt(Game.item_sell(it))
	elif typ == "ball":
		pedestal_ball.setup(pd.id, int(pd.rarity))
		btn_equip.text = "Coletar"


func _cycle_speed() -> void:
	var sp: Array = Game.speeds()
	var i := sp.find(int(Game.d.speed))
	Game.d.speed = sp[(i + 1) % sp.size()]
	if sp.size() <= 2 and int(Game.d.speed) == 1:
		toast("Gamepass 3x e 4x na Loja!", Color("#ffe27a"))
	_refresh_controls()


func _refresh_controls() -> void:
	var a: bool = Game.d.auto_skill
	btn_auto.text = "Auto\nON" if a else "Auto\nOFF"
	UI.style_button(btn_auto, UI.C_GREEN if a else UI.C_GRAY)
	var spd := int(Game.d.get("speed", 1))
	btn_speed.text = "%dx" % spd
	UI.style_button(btn_speed, [Color("#2e6b3a"), Color("#2e6b3a"), Color("#ff8a2a"), Color("#e8503a"), Color("#c03aa8")][clampi(spd, 0, 4)])
	Engine.time_scale = float(spd)
	UI.style_button(btn_auto_chest, Color("#ffb020") if Game.d.auto_chest else UI.C_BLUE)
	btn_auto_chest.text = "Auto ON" if Game.d.auto_chest else "Auto"
	btn_advance.visible = not Game.d.auto_advance
	if battle:
		battle.auto_skill = a


func _on_wave(idx: int, total: int) -> void:
	for i in wave_bars.size():
		var seg: Panel = wave_bars[i]
		seg.visible = i < total
		var col := Color("#ffe27a") if i <= idx else Color("#c8c8c8")
		seg.add_theme_stylebox_override("panel", UI.box(col, UI.C_BORDER, 2, 0, 6))


# =============================================================================================
# batalhas e historia
# =============================================================================================
func _team_specs() -> Array:
	var out := []
	for id in Game.team_ids():
		out.append(Game.ball_spec(id))
	return out


func start_campaign() -> void:
	mode = "campaign"
	mode_data = {}
	var c := int(Game.d.chapter)
	var s := int(Game.d.stage)
	var ch := DB.chapter(c)
	var loop := int((c - 1) / DB.chapter_count())
	var diff = ["Normal", "Difícil", "Pesadelo", "Inferno"][mini(loop, 3)]
	lbl_stage.text = "%s %d-%d" % [diff, c, s]
	lbl_chapter.text = ch.name
	var left := DB.STAGES_PER_CHAPTER - s + 1
	lbl_left.text = ("CHEFE DO CAPÍTULO!" if s == DB.STAGES_PER_CHAPTER else ("Mini-chefe!" if s == 10 else "%d lutas até o chefe" % left))
	battle.set_theme(ch.get("theme", {}))
	# dialogos: inicio de capitulo e antes de chefe
	var seen: Dictionary = Game.d.seen
	if s == 1 and not seen.has("ch%d" % c) and not _flow_busy:
		seen["ch%d" % c] = true
		_flow_busy = true
		battle.clear()
		story.play_intro(c, func() -> void:
			_flow_busy = false
			_launch_stage(c, s))
		return
	if s == DB.STAGES_PER_CHAPTER and not seen.has("boss%d" % c) and not _flow_busy:
		seen["boss%d" % c] = true
		_flow_busy = true
		battle.clear()
		story.play_boss(c, func() -> void:
			_flow_busy = false
			_launch_stage(c, s))
		return
	_launch_stage(c, s)


func _launch_stage(c: int, s: int) -> void:
	if mode != "campaign":
		return
	battle.start(_team_specs(), Game.stage_waves(c, s))


func start_mode(m: String, data: Dictionary, players: Array, waves: Array, title: String, limit: float = 0.0) -> void:
	close_screen()
	mode = m
	mode_data = data
	lbl_stage.text = title
	lbl_chapter.text = data.get("sub", "")
	lbl_left.text = "Tempo: %ds" % int(limit) if limit > 0 else ""
	battle.set_theme(data.get("theme", {"floor": "#efe6f6", "floor2": "#dccdec", "accent": "#9a64e0", "line": "#c0a8e0"}))
	battle.start(players, waves, limit)


func _on_enemy_killed(u: Unit) -> void:
	if mode != "campaign":
		return
	var g := float(Game.stage_index())
	var c := Game.kill_reward_coins(g) * (5.0 if u.is_boss else 1.0)
	Game.add_coins(c)
	Game.add_xp(2.0 + g * 0.2)
	Drawer.text(battle.layer_text, u.position, "+" + UI.fmt(c), Color("#ffd23c"), 20, 0.9)
	if randf() < 0.12:
		Game.add_keys(1)
		Drawer.text(battle.layer_text, u.position + Vector2(0, 22), "+1 chave", Color("#a8e2ff"), 18, 0.9)


func _on_battle_finished(win: bool) -> void:
	match mode:
		"campaign":
			var cleared := false
			var ch_done := int(Game.d.chapter)
			if win:
				var r := Game.on_stage_win()
				cleared = r.chapter_clear
				toast("Vitória!  +%s moedas  +%d chaves%s" % [UI.fmt(r.coins), r.keys, ("  +%d gemas" % r.gems) if r.gems > 0 else ""], Color("#ffe27a"))
			else:
				Game.on_stage_lose()
				toast("Derrota... evolua sua bolinha e tente de novo!", Color("#ffb0a0"))
			_refresh_controls()
			Game.save_game()
			await get_tree().create_timer(1.2 * Engine.time_scale).timeout
			if mode != "campaign":
				return
			if cleared:
				_flow_busy = true
				story.play_outro(ch_done, func() -> void:
					_flow_busy = false
					start_campaign())
			else:
				start_campaign()
		_:
			screens.mode_result(mode, mode_data, win)


func back_to_campaign() -> void:
	start_campaign()


func _cast_manual() -> void:
	var id := Game.active_id()
	var u: Unit = _player_units().get(id, null)
	if u == null or Game.d.auto_skill:
		collection.ball_popup(id)
		return
	u.manual_cast = true


# =============================================================================================
# bau / drops
# =============================================================================================
func _open_chest() -> void:
	if not Game.d.get("pending_drop", {}).is_empty():
		toast("Equipe ou venda o item primeiro", Color("#ffb0a0"))
		return
	if int(Game.d.keys) <= 0:
		toast("Sem chaves! Vença fases ou jogue a Cripta das Chaves", Color("#ffb0a0"))
		return
	var res := Game.open_chest()
	_chest_fx()
	match res.get("type", ""):
		"mat":
			toast("+%d %s (material de evolução)" % [res.mat.n, res.mat.name], Color(DB.EVO_MATS[res.mat.tier].color))
		"ball":
			gacha_ui.reveal_single(res.id, int(res.rarity), true)
	_refresh_drop()


func _chest_fx() -> void:
	var p := btn_chest.global_position - global_position + btn_chest.size * 0.5
	var f := CuteFx.make("stars", {"size": 46.0, "color": Color("#ffd23c")})
	f.position = p
	popup_layer.add_child(f)


func _auto_chest_step() -> void:
	var pd: Dictionary = Game.d.get("pending_drop", {})
	if not pd.is_empty():
		if pd.type == "item":
			if Game.item_score(pd.item) > Game.item_score(Game.equipped(pd.item.slot)):
				_take_drop()
			else:
				_sell_drop()
		elif pd.type == "ball":
			_take_drop()
		return
	if int(Game.d.keys) > 0:
		var res := Game.open_chest()
		if res.get("type", "") == "ball":
			Game.d.auto_chest = false
			_refresh_controls()
			gacha_ui.reveal_single(res.id, int(res.rarity), true)
		elif res.get("type", "") == "mat":
			toast("+%d %s" % [res.mat.n, res.mat.name], Color(DB.EVO_MATS[res.mat.tier].color))
		_refresh_drop()
	else:
		Game.d.auto_chest = false
		_refresh_controls()
		toast("As chaves acabaram", Color("#ffb0a0"))


func _take_drop() -> void:
	var pd: Dictionary = Game.d.get("pending_drop", {})
	if pd.is_empty():
		return
	if pd.type == "item":
		var sold := Game.equip(pd.item)
		if sold > 0:
			toast("Item antigo vendido: +" + UI.fmt(sold), Color("#ffe27a"))
	elif pd.type == "ball":
		var r := Game.add_ball(pd.id)
		toast("%s %s" % [DB.BALLS[pd.id].name, "entrou para a coleção!" if r.new else "+%d fragmentos" % r.frags], DB.rcolor(int(pd.rarity)))
	Game.d.pending_drop = {}
	_refresh_equipment()
	_refresh_top()


func _sell_drop() -> void:
	var pd: Dictionary = Game.d.get("pending_drop", {})
	if pd.get("type", "") != "item":
		return
	Game.add_coins(Game.item_sell(pd.item))
	Game.d.pending_drop = {}
	_refresh_drop()


func _tile_pressed(slot: String) -> void:
	if not Game.slot_unlocked(slot):
		toast("Desbloqueia ao chegar na fase %d" % int(DB.SLOT_INFO[slot].unlock_stage), Color("#ffb0a0"))
		return
	var it := Game.equipped(slot)
	if it.is_empty():
		toast("%s vazio: abra baús para conseguir" % DB.SLOT_INFO[slot].name, Color.WHITE)
		return
	screens.item_popup(it)


func _on_purchase(_id: String, ok: bool, res: Dictionary) -> void:
	if ok:
		if res.has("speed"):
			toast("Gamepass ativado! Velocidade %dx liberada" % int(res.speed), Color("#ffe27a"))
		elif int(res.get("gems", 0)) > 0:
			toast("Compra concluída! +%s gemas" % UI.fmt(res.get("gems", 0)), Color("#a8e2ff"))
		if res.has("ball"):
			gacha_ui.reveal_single(res.ball, int(DB.BALLS[res.ball].rarity), false)
		_refresh_controls()
	else:
		toast("Compra não concluída", Color("#ffb0a0"))
	if cur_screen == "shop":
		open_screen("shop", true)


# =============================================================================================
# telas (com transicao deslizante) e toasts
# =============================================================================================
func _nav_index(id: String) -> int:
	for i in NAV.size():
		if NAV[i][0] == id:
			return i
	return -1


func open_screen(id: String, force: bool = false) -> void:
	if cur_screen == id and not force:
		close_screen()
		return
	var old_i := _nav_index(cur_screen)
	var new_i := _nav_index(id)
	var dir := 1.0 if new_i >= old_i else -1.0
	var olds := screen_layer.get_children()
	cur_screen = id
	for k in nav_buttons:
		nav_buttons[k].selected = k == id
	var s: Control
	match id:
		"story": s = story.map_screen()
		"balls": s = collection.screen()
		"gacha": s = gacha_ui.screen()
		_: s = screens.build(id)
	if s == null:
		return
	screen_layer.add_child(s)
	if force:
		for o in olds:
			o.queue_free()
		return
	var w := screen_layer.size.x
	if olds.is_empty():
		s.position.y = 40.0
		s.modulate.a = 0.0
		var tw := s.create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(s, "position:y", 0.0, 0.22)
		tw.tween_property(s, "modulate:a", 1.0, 0.18)
	else:
		s.position.x = w * dir
		var tw2 := s.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw2.tween_property(s, "position:x", 0.0, 0.24)
		for o in olds:
			var to := o.create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			to.tween_property(o, "position:x", -w * dir * 0.6, 0.24)
			to.tween_property(o, "modulate:a", 0.0, 0.2)
			to.chain().tween_callback(o.queue_free)


func close_screen() -> void:
	cur_screen = ""
	for k in nav_buttons:
		nav_buttons[k].selected = false
	for c in screen_layer.get_children():
		var tw := c.create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw.tween_property(c, "position:y", 60.0, 0.16)
		tw.tween_property(c, "modulate:a", 0.0, 0.16)
		tw.chain().tween_callback(c.queue_free)


func toast(txt: String, col: Color = Color.WHITE) -> void:
	var p := PanelContainer.new()
	var s := UI.box(Color(0.12, 0.08, 0.06, 0.88), Color(0, 0, 0, 0), 0, 0, 18)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 6
	s.content_margin_bottom = 8
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := UI.label(txt, 19, col, 4)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(minf(size.x - 80, 560), 0)
	p.add_child(l)
	popup_layer.add_child(p)
	var n := 0
	for c in popup_layer.get_children():
		if c is PanelContainer and c.has_meta("toast"):
			n += 1
	p.set_meta("toast", true)
	await get_tree().process_frame
	p.position = Vector2((size.x - p.size.x) * 0.5, 150 + n * 54)
	p.modulate.a = 0.0
	var tw := p.create_tween()
	tw.tween_property(p, "modulate:a", 1.0, 0.15)
	tw.parallel().tween_property(p, "position:y", p.position.y + 20, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_interval(1.6)
	tw.tween_property(p, "modulate:a", 0.0, 0.3)
	tw.tween_callback(p.queue_free)


# =============================================================================================
# ferramenta de desenvolvimento: godot --path . -- --shot=<png> [--screen=x] [--popup=id] [--wait=6] ...
# =============================================================================================
func _debug_shots() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	if not args.has("shot"):
		return
	Game.d.seen = {"ch1": true, "boss1": true}
	for k in 20:
		Game.d.seen["ch%d" % k] = true
		Game.d.seen["boss%d" % k] = true
	if args.has("give"):
		for id in DB.BALLS:
			Game.add_ball(id)
		Game.d.gems = 99999
		Game.d.coins = 1e7
		Game.d.keys = 500
	if args.has("best"):
		Game.d.best = int(args.best)
	if args.has("use"):
		Game.add_ball(args.use)
		Game.set_active(args.use)
		Game.ball(args.use).rarity = int(args.get("rar", "5"))
		Game.ball(args.use).level = 40
	if args.has("stage"):
		Game.d.chapter = int(args.stage.split("-")[0])
		Game.d.stage = int(args.stage.split("-")[1])
		Game.d.best = maxi(int(Game.d.best), Game.stage_index())
	screens.close_popups()
	start_campaign()
	if args.has("intro"):
		story.play_intro(int(Game.d.chapter), Callable())
	if args.has("boss"):
		story.play_boss(int(Game.d.chapter), Callable())
	await get_tree().create_timer(float(args.get("wait", "6")) * Engine.time_scale).timeout
	if args.has("screen"):
		open_screen(args.screen, true)
	if args.has("popup"):
		collection.ball_popup(args.popup)
	if args.has("pull"):
		gacha_ui.pull(int(args.pull), DB.BANNERS[0])
	if args.has("chest"):
		for i in int(args.chest):
			_open_chest()
			if not Game.d.pending_drop.is_empty() and Game.d.pending_drop.type == "item" and i < int(args.chest) - 1:
				_take_drop()
	if args.has("settings"):
		screens.settings_popup()
	if args.has("missions"):
		screens.missions_popup()
	await get_tree().create_timer(float(args.get("after", "0.8")) * Engine.time_scale).timeout
	var img := get_viewport().get_texture().get_image()
	img.save_png(args.shot)
	print("shot saved ", args.shot)
	get_tree().quit()

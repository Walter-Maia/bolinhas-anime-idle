class_name CollectionUI
extends RefCounted
## Colecao de bolinhas (filtro por anime, paginas, recompensa por completar um anime) e detalhe/evolucao.

const PER_PAGE := 20

var main: Control
var filter := "__mine"
var page := 0
var detail_tab := "skills"


func _init(m: Control) -> void:
	main = m


func _ids() -> Array:
	var out := []
	for id in DB.BALLS:
		var b: Dictionary = DB.BALLS[id]
		match filter:
			"__all":
				out.append(id)
			"__mine":
				if Game.has_ball(id):
					out.append(id)
			_:
				if b.get("world", "") == filter:
					out.append(id)
	out.sort_custom(func(a, b):
		var ra := int(Game.ball(a).rarity) if Game.has_ball(a) else int(DB.BALLS[a].rarity)
		var rb := int(Game.ball(b).rarity) if Game.has_ball(b) else int(DB.BALLS[b].rarity)
		var oa := 1 if Game.has_ball(a) else 0
		var ob := 1 if Game.has_ball(b) else 0
		if oa != ob:
			return oa > ob
		if ra != rb:
			return ra > rb
		return str(DB.BALLS[a].name) < str(DB.BALLS[b].name))
	return out


func screen() -> Control:
	var f: Array = main.screens.frame("Bolinhas  %d/%d" % [Game.d.balls.size(), DB.BALLS.size()], Color("#5a6ab8"))
	var c: VBoxContainer = f[1]
	# bolinha ativa
	var aid := Game.active_id()
	if aid != "" and Game.has_ball(aid):
		var bi := BallIcon.new().setup(aid, int(Game.ball(aid).rarity))
		bi.stars = int(Game.ball(aid).stars)
		bi.custom_minimum_size = Vector2(96, 96)
		bi.pressed.connect(func() -> void: ball_popup(aid))
		c.add_child(main.screens.row_card(bi, "Em campo: " + DB.ball_name(aid, int(Game.ball(aid).rarity)), "Nível %d · Poder %s · toque em outra bolinha para trocar" % [int(Game.ball(aid).level), UI.fmt(Game.ball_power(aid))], "", UI.C_BLUE, Callable(), true, Color("#eef6ff")))
	# filtros
	var chips := UI.hbox(6)
	for o in [["__mine", "Minhas"], ["__all", "Todas"]]:
		var id: String = o[0]
		var b := UI.button(o[1], UI.C_YELLOW if id == filter else Color("#d8cbb0"), 17, Vector2(110, 50))
		b.pressed.connect(func() -> void:
			filter = id
			page = 0
			main.open_screen("balls", true))
		chips.add_child(b)
	var wb := UI.button(("Anime: " + filter) if not filter.begins_with("__") else "Filtrar por anime", UI.C_YELLOW if not filter.begins_with("__") else UI.C_BLUE, 17, Vector2(0, 50))
	wb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wb.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	wb.clip_text = true
	wb.pressed.connect(_world_picker)
	chips.add_child(wb)
	c.add_child(chips)
	# recompensa de colecao
	if not filter.begins_with("__"):
		var pr2 := Game.world_progress(filter)
		var claimed: bool = Game.d.world_claimed.has(filter)
		var k := UI.card(Color("#fff4d8"))
		var h := UI.hbox(8)
		var vv := UI.vbox(3)
		vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vv.add_child(UI.para("Coleção: %s" % filter, 19))
		var bar := UI.bar(UI.C_PURPLE, 12)
		bar.value = float(pr2.x) / maxf(1.0, pr2.y)
		vv.add_child(bar)
		vv.add_child(UI.para("%d/%d · Complete para ganhar %d gemas" % [pr2.x, pr2.y, Game.world_reward(filter)], 15, UI.C_TEXT_MID))
		h.add_child(vv)
		var cb := UI.button("Feito" if claimed else "Pegar", UI.C_GREEN, 18, Vector2(96, 52))
		cb.disabled = claimed or pr2.x < pr2.y
		var wf := filter
		cb.pressed.connect(func() -> void:
			if Game.claim_world(wf):
				main.toast("+%d gemas pela coleção!" % Game.world_reward(wf), Color("#a8e2ff"))
				main.open_screen("balls", true))
		h.add_child(cb)
		k[1].add_child(h)
		c.add_child(k[0])
	var ids := _ids()
	if ids.is_empty():
		c.add_child(UI.para("Nenhuma bolinha aqui ainda. Abra baús e invoque para conseguir!", 18, UI.C_TEXT_MID))
		return f[0]
	var pages := int(ceil(ids.size() / float(PER_PAGE)))
	page = clampi(page, 0, pages - 1)
	var g := GridContainer.new()
	g.columns = 4
	g.add_theme_constant_override("h_separation", 8)
	g.add_theme_constant_override("v_separation", 10)
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for i in range(page * PER_PAGE, mini(ids.size(), (page + 1) * PER_PAGE)):
		var id: String = ids[i]
		var owned := Game.has_ball(id)
		var cell := UI.vbox(2)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var bi2 := BallIcon.new()
		bi2.custom_minimum_size = Vector2(0, 128)
		bi2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var r := int(Game.ball(id).rarity) if owned else int(DB.BALLS[id].rarity)
		bi2.setup(id, r)
		bi2.silhouette = not owned
		if owned:
			bi2.stars = int(Game.ball(id).stars)
			bi2.selected = id == aid
		var bid: String = id
		bi2.pressed.connect(func() -> void: ball_popup(bid))
		cell.add_child(bi2)
		var nm := UI.label(DB.BALLS[id].name if owned else "???", 14, Color.WHITE, 4)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nm.custom_minimum_size = Vector2(60, 0)
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.add_theme_color_override("font_color", UI.C_TEXT_DARK)
		nm.add_theme_constant_override("outline_size", 0)
		cell.add_child(nm)
		g.add_child(cell)
	c.add_child(g)
	if pages > 1:
		var ph := UI.hbox(8)
		ph.alignment = BoxContainer.ALIGNMENT_CENTER
		var pv := UI.button("< Anterior", UI.C_BLUE, 17, Vector2(140, 50))
		pv.disabled = page <= 0
		pv.pressed.connect(func() -> void:
			page -= 1
			main.open_screen("balls", true))
		ph.add_child(pv)
		ph.add_child(UI.dark_label("%d/%d" % [page + 1, pages], 20))
		var nx := UI.button("Próxima >", UI.C_BLUE, 17, Vector2(140, 50))
		nx.disabled = page >= pages - 1
		nx.pressed.connect(func() -> void:
			page += 1
			main.open_screen("balls", true))
		ph.add_child(nx)
		c.add_child(ph)
	return f[0]


func _world_picker() -> void:
	var v := UI.vbox(6)
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 6)
	g.add_theme_constant_override("v_separation", 6)
	for w in DB.WORLDS:
		var pr := Game.world_progress(w)
		var done: bool = pr.x >= pr.y
		var b := UI.button("%s  %d/%d" % [w, pr.x, pr.y], UI.C_GREEN if done else (UI.C_YELLOW if pr.x > 0 else Color("#d8cbb0")), 15, Vector2(0, 50))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		b.clip_text = true
		var ww: String = w
		b.pressed.connect(func() -> void:
			filter = ww
			page = 0
			main.screens.close_popups()
			main.open_screen("balls", true))
		g.add_child(b)
	v.add_child(g)
	main.screens.popup("Escolha o anime (%d)" % DB.WORLDS.size(), v, [["Fechar", UI.C_YELLOW, Callable()]], 680)


# =============================================================================================
# DETALHE
# =============================================================================================
func skill_text(sk: Dictionary, r: int, active: bool) -> Array:
	var lines := []
	lines.append(str(sk.get("desc", "")))
	if active:
		var info := []
		var t: String = sk.get("type", "")
		if sk.has("power") and not t in ["heal", "shield", "buff", "debuff"]:
			info.append("Dano %s" % UI.pct(float(DB.p(sk, "power", r, 1.0)) * float(DB.rarity(r).skill)))
		elif t == "heal":
			info.append("Cura %s da vida" % UI.pct(float(DB.p(sk, "power", r, 0.1))))
		elif t == "shield":
			info.append("Escudo %s da vida" % UI.pct(float(DB.p(sk, "power", r, 0.1))))
		if sk.has("count") and int(DB.p(sk, "count", r, 1)) > 1:
			info.append("x%d" % int(DB.p(sk, "count", r, 1)))
		info.append("Recarga %ss" % ("%.1f" % float(DB.p(sk, "cd", r, 6.0))).replace(".", ","))
		lines.append(" · ".join(info))
		if sk.has("alt"):
			lines.append("Transformado: %s" % str(sk.alt.get("name", sk.name)))
	else:
		match str(sk.get("type", "")):
			"low_hp":
				lines.append("Ativa com %s de vida (1x por luta, salva de golpe fatal)" % UI.pct(float(sk.get("threshold", 0.3)) + 0.02 * r))
			"stats":
				var parts := []
				for k in sk.get("stats", {}):
					parts.append("%s +%s" % [_stat_name(k), UI.pct(absf(float(sk.stats[k])) * (1.0 + 0.2 * r))])
				lines.append(" · ".join(parts))
			"on_hit":
				lines.append("Chance %s" % UI.pct(float(sk.get("chance", 0.1)) * (1.0 + 0.15 * r)))
	return lines


func _stat_name(k: String) -> String:
	return {"atk_pct": "Ataque", "hp_pct": "Vida", "def_pct": "Defesa", "spd_pct": "Velocidade", "crit": "Crítico", "critdmg": "Dano crítico",
		"dodge": "Esquiva", "lifesteal": "Roubo de vida", "cdr": "Recarga", "regen": "Regeneração/s", "thorns": "Espinhos", "contact_taken": "Dano de colisão"}.get(k, k)


const TYPE_NAMES := {"projectile": "Projétil", "beam": "Feixe", "breath": "Sopro", "aoe": "Área", "nova": "Explosão", "rain": "Chuva", "dash": "Investida",
	"hook": "Gancho", "multi": "Combo", "stretch": "Estica", "chain": "Corrente", "summon": "Invocação", "shield": "Escudo", "buff": "Fortalecer", "heal": "Cura",
	"timestop": "Parar o tempo", "strike": "Golpe", "orbit": "Órbita", "zone": "Domínio", "drain": "Drenar", "debuff": "Maldição", "execute": "Execução",
	"awaken": "Despertar", "knockback": "Empurrão", "teleport": "Teleporte", "mimic": "Cópia", "gamble": "Aposta",
	"stats": "Atributos", "low_hp": "Último suspiro", "on_hit": "Ao acertar", "on_kill": "Ao derrotar", "stack": "Acúmulo", "revive": "Reviver",
	"berserk": "Fúria", "periodic": "Periódica", "shield_start": "Escudo inicial", "first_strike": "Primeiro golpe", "on_crit": "Ao critar",
	"counter": "Contra-ataque", "aura_dmg": "Aura", "reflect": "Reflexo"}


func _skill_card(sk: Dictionary, r: int, active: bool) -> Control:
	var locked := int(sk.get("unlock", 0)) > r
	var accent := Color("#ff8a2a") if active else Color("#5a8ae0")
	var k := UI.card(Color("#e8e2d6") if locked else Color("#fffaf0"), accent)
	var h := UI.hbox(8)
	var tl := UI.para(str(sk.get("name", "?")), 20, UI.C_TEXT_DARK)
	h.add_child(tl)
	h.add_child(UI.badge(("Ativa · " if active else "Passiva · ") + str(TYPE_NAMES.get(sk.get("type", ""), "?")), accent.darkened(0.15), 13))
	k[1].add_child(h)
	if locked:
		k[1].add_child(UI.para("Bloqueada · libera ao evoluir para %s" % DB.rarity(int(sk.unlock)).name, 15, Color("#a03a3a")))
	for l in skill_text(sk, r, active):
		if str(l) != "":
			k[1].add_child(UI.para(str(l), 16, UI.C_TEXT_MID if locked else UI.C_TEXT_DARK))
	return k[0]


func ball_popup(id: String) -> void:
	if not DB.BALLS.has(id):
		return
	var def: Dictionary = DB.BALLS[id]
	var owned := Game.has_ball(id)
	var b := Game.ball(id)
	var r := int(b.rarity) if owned else int(def.rarity)
	var v := UI.vbox(10)
	# cabecalho
	var head := UI.card(DB.rcolor(r).lightened(0.75))
	var hh := UI.hbox(12)
	var big := BallIcon.new().setup(id, r)
	big.silhouette = not owned
	big.custom_minimum_size = Vector2(170, 170)
	if owned:
		big.stars = int(b.stars)
	hh.add_child(big)
	var iv := UI.vbox(4)
	iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rb := UI.badge(DB.rarity(r).name.to_upper(), DB.rcolor(r).darkened(0.2), 16)
	rb.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	iv.add_child(rb)
	iv.add_child(UI.para(DB.ball_name(id, r) if owned else def.name, 23, UI.C_TEXT_DARK))
	iv.add_child(UI.para("%s · %s" % [def.get("world", "?"), def.get("role", "?")], 16, UI.C_TEXT_MID))
	iv.add_child(UI.para(str(def.get("lore", "")), 15, UI.C_TEXT_MID))
	var w: Dictionary = def.get("weapon", {})
	if not w.is_empty():
		iv.add_child(UI.para("Arma: %s x%d (gira em volta)" % [str(w.get("kind", "?")), int(w.get("count", 1))], 15, UI.C_TEXT_MID))
	hh.add_child(iv)
	head[1].add_child(hh)
	if owned:
		var s := Game.ball_stats(id)
		var sg := GridContainer.new()
		sg.columns = 3
		sg.add_theme_constant_override("h_separation", 6)
		sg.add_theme_constant_override("v_separation", 4)
		for it in [["Vida", UI.fmt(s.hp), "armor"], ["Ataque", UI.fmt(s.atk), "power"], ["Defesa", UI.fmt(s.def), "helmet"],
				["Crítico", UI.pct(s.crit), "star"], ["Esquiva", UI.pct(s.dodge), "boots"], ["Nível", "%d/%d" % [int(b.level), Game.level_cap(id)], "xp"]]:
			var ch := UI.hbox(4)
			ch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			ch.add_child(UI.tex_rect(PixelArt.icon(it[2]), Vector2(26, 26)))
			ch.add_child(UI.para("%s %s" % [it[0], it[1]], 15, UI.C_TEXT_DARK))
			sg.add_child(ch)
		head[1].add_child(sg)
	v.add_child(head[0])
	# abas
	var tabs: Control = main.screens.segmented([["skills", "Habilidades"], ["evo", "Evolução"]], detail_tab, func(t: String) -> void:
		detail_tab = t
		_reopen(id))
	v.add_child(tabs)
	if detail_tab == "skills" or not owned:
		for sk in def.get("actives", []):
			v.add_child(_skill_card(sk, r, true))
		for sk in def.get("passives", []):
			v.add_child(_skill_card(sk, r, false))
		var forms: Array = def.get("forms", [])
		var fl := []
		for i in forms.size():
			if str(forms[i]) != "":
				fl.append("%s: %s" % [DB.rarity(i).name, forms[i]])
		if not fl.is_empty():
			v.add_child(UI.para("Formas evoluídas: " + " · ".join(fl), 15, UI.C_TEXT_MID))
	else:
		_evo_tab(v, id, def, b, r)
	var buttons := []
	if owned:
		var active := Game.active_id() == id
		buttons.append(["Em campo" if active else "Usar", UI.C_GREEN if not active else UI.C_GRAY, func() -> void:
			if not active:
				Game.set_active(id)
				main.toast("%s entrou na arena!" % def.name, DB.rcolor(r))
				if main.cur_screen == "balls":
					main.open_screen("balls", true)])
	buttons.append(["Fechar", UI.C_YELLOW, Callable()])
	main.screens.popup(DB.ball_name(id, r) if owned else def.name, v, buttons, 680)


func _evo_tab(v: VBoxContainer, id: String, def: Dictionary, b: Dictionary, r: int) -> void:
	var k := UI.card(Color("#fffaf0"))
	k[1].add_child(UI.para("Nível %d/%d · Fragmentos %d" % [int(b.level), Game.level_cap(id), int(b.frags)], 19))
	var h := UI.hbox(6)
	var b1 := UI.button("Nível +1\n%s" % UI.fmt(Game.level_cost(id)), UI.C_GREEN, 16, Vector2(0, 62))
	b1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b1.disabled = int(b.level) >= Game.level_cap(id)
	b1.pressed.connect(func() -> void:
		if Game.level_up(id, 1) == 0:
			main.toast("Moedas insuficientes ou nível máximo", Color("#ffb0a0"))
		_reopen(id))
	h.add_child(b1)
	var b10 := UI.button("Nível +10", UI.C_GREEN, 16, Vector2(0, 62))
	b10.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b10.pressed.connect(func() -> void:
		Game.level_up(id, 10)
		_reopen(id))
	h.add_child(b10)
	var sc := Game.star_cost(id)
	var bs := UI.button(("Estrela\n%d frag." % sc) if sc > 0 else "5 estrelas", UI.C_YELLOW, 16, Vector2(0, 62))
	bs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bs.disabled = sc < 0 or int(b.frags) < sc
	bs.pressed.connect(func() -> void:
		Game.star_up(id)
		_reopen(id))
	h.add_child(bs)
	k[1].add_child(h)
	v.add_child(k[0])
	var ek := UI.card(Color("#f6ecff"))
	if r < DB.MAX_RARITY:
		var forms: Array = def.get("forms", [])
		var fname: String = str(forms[r + 1]) if r + 1 < forms.size() else ""
		ek[1].add_child(UI.para("Evoluir para %s%s" % [DB.rarity(r + 1).name, (" — " + fname) if fname != "" else ""], 20, DB.rcolor(r + 1).darkened(0.35)))
		for q in Game.ascend_reqs(id):
			var qh := UI.hbox(6)
			var dot := UI.badge("OK" if q.ok else "--", UI.C_GREEN if q.ok else UI.C_GRAY, 13)
			qh.add_child(dot)
			qh.add_child(UI.para(q.text, 16, UI.C_TEXT_DARK if q.ok else Color("#8a4a3a")))
			ek[1].add_child(qh)
		var ba := UI.button("EVOLUIR RARIDADE", UI.C_PURPLE, 21, Vector2(0, 60))
		ba.disabled = not Game.can_ascend(id)
		ba.pressed.connect(func() -> void:
			if Game.ascend(id):
				main.screens.close_popups()
				main.gacha_ui.reveal_single(id, int(Game.ball(id).rarity), false, true))
		ek[1].add_child(ba)
		ek[1].add_child(UI.para("Fragmentos: cópias repetidas (baú, invocação, chefes, masmorra). Cristais: baú, masmorras, chefes e torre.", 14, UI.C_TEXT_MID))
	else:
		ek[1].add_child(UI.para("Raridade máxima: Transcendente!", 20, Color("#7a4ab8")))
	v.add_child(ek[0])


func _reopen(id: String) -> void:
	main.screens.close_popups()
	ball_popup.call_deferred(id)
	if main.cur_screen == "balls":
		main.open_screen("balls", true)

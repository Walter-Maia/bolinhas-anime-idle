class_name Skills
## Executa as skills ativas (campo "type" em docs/CONTENT_SPEC.md). Retorna false se nao havia como usar agora.

static var _pool: Array = []


static func resolve(u: Unit, sk: Dictionary) -> Dictionary:
	var d := sk.duplicate()
	if u.transformed and sk.has("alt"):
		var alt: Dictionary = sk.alt
		for k in alt:
			if k == "power_mult" or k == "speed_mult":
				d[k] = float(d.get(k, 1.0)) * float(alt[k])
			else:
				d[k] = alt[k]
	return d


static func power_of(u: Unit, d: Dictionary) -> float:
	return float(DB.p(d, "power", u.rarity, 1.0)) * float(DB.rarity(u.rarity).skill) * float(d.get("power_mult", 1.0))


static func apply_skill_status(b: Battle, u: Unit, e: Unit, d: Dictionary) -> void:
	if not d.has("status") or e == null or e.dead:
		return
	if randf() < float(d.get("status_chance", 1.0)):
		var sname: String = d.status
		var pw := 0.3
		if sname == "black_burn":
			pw = maxf(0.3, power_of(u, d) * 0.15)
		b.apply_status(u, e, sname, float(DB.p(d, "status_dur", u.rarity, 2.0)), pw)


static func hit(b: Battle, u: Unit, e: Unit, d: Dictionary, pw: float, opts: Dictionary = {}) -> float:
	var o := {"kind": "skill"}
	o.merge(opts, true)
	var dmg := b.deal(u, e, pw, o)
	apply_skill_status(b, u, e, d)
	return dmg


static func cast(b: Battle, u: Unit, sk: Dictionary, free: bool = false) -> bool:
	var d := resolve(u, sk)
	var r := u.rarity
	var t: String = d.get("type", "")
	var es := b.enemies_of(u)
	var pw := power_of(u, d)
	var count := int(DB.p(d, "count", r, 1))
	match t:
		"heal":
			var need := false
			for a: Unit in b.allies_of(u):
				if a.hp_ratio() < 0.8:
					need = true
			if not need:
				return false
		"awaken":
			if u.transformed:
				return false
		"shield", "buff":
			pass
		_:
			if es.is_empty():
				return false
	Snd.play("skill", -5.0, 0.12, 0.12)
	if not free:
		b.banner(u, d.get("name", ""), u.color.lightened(0.35))
	match t:
		"projectile":
			var sorted := es.duplicate()
			sorted.sort_custom(func(a, c): return a.position.distance_squared_to(u.position) < c.position.distance_squared_to(u.position))
			var arc := float(DB.p(d, "arc", r, 0.0))
			for i in count:
				var tg: Unit = sorted[0] if arc > 0.0 else sorted[i % sorted.size()]
				var spread := 0.0
				if arc > 0.0 and count > 1:
					spread = -arc * 0.5 + arc * i / float(count - 1)
				elif count > sorted.size():
					spread = (i - (count - 1) * 0.5) * 0.22
				var delay := 0.0 if arc > 0.0 else i * 0.12
				b.later(delay, func() -> void:
					if not is_instance_valid(u) or u.dead:
						return
					var dir := (tg.position - u.position).normalized().rotated(spread) if is_instance_valid(tg) else u.vel.normalized()
					projectile(b, u, d, pw, dir, tg if is_instance_valid(tg) else null))
		"beam":
			var tg := b.pick_target(u, d.get("target", "nearest"))
			var charge := float(d.get("charge", 0.4))
			u.invuln_t = maxf(u.invuln_t, charge)
			b.fx(u.position, "spell_charge", {"kind": "orb", "size": u.radius() * 0.5, "color": CuteFx.color_of(d.get("fx", "beam_ki")), "life": charge, "loop": true})
			b.later(charge, func() -> void:
				if not is_instance_valid(u) or u.dead:
					return
				var aim := tg.position if is_instance_valid(tg) and not tg.dead else u.position + u.vel
				beam(b, u, d, pw, (aim - u.position).normalized()))
		"breath":
			var tg := b.nearest_enemy(u)
			var dir := (tg.position - u.position).normalized()
			var rng := float(d.get("range", 240.0))
			b.fx(u.position + dir * u.radius(), d.get("fx", "fire_breath"), {"kind": "cone", "rot": dir.angle(), "length": rng, "size": 26.0, "dur": 0.9, "loop": false})
			var ticks := int(d.get("ticks", 3))
			for i in ticks:
				b.later(0.15 + i * 0.22, func() -> void:
					if not is_instance_valid(u) or u.dead:
						return
					for e: Unit in b.enemies_of(u):
						var v: Vector2 = e.position - u.position
						if v.length() <= rng + e.radius() and absf(v.angle_to(dir)) <= float(d.get("angle", 0.5)):
							hit(b, u, e, d, pw / ticks))
		"aoe":
			var tg := b.pick_target(u, d.get("target", "nearest"))
			aoe_at(b, u, d, pw, tg.position)
		"nova":
			aoe_at(b, u, d, pw, u.position)
		"rain":
			for i in count:
				b.later(i * 0.18, func() -> void:
					if not is_instance_valid(u) or u.dead:
						return
					var tg := b.pick_target(u, "random")
					if tg:
						aoe_at(b, u, d, pw, tg.position + Vector2(randf_range(-10, 10), randf_range(-10, 10))))
		"dash":
			b.start_dash(u, d, pw, count)
		"hook":
			b.start_dash(u, d, pw, count, true)
		"multi":
			var first := b.pick_target(u, d.get("target", "nearest"))
			var iv := float(DB.p(d, "interval", r, 0.15))
			for i in count:
				b.later(i * iv, func() -> void:
					if not is_instance_valid(u) or u.dead:
						return
					var tg: Unit = b.pick_target(u, "random") if d.get("spread", false) else first
					if not is_instance_valid(tg) or tg.dead:
						tg = b.nearest_enemy(u)
					if tg == null:
						return
					b.fx(tg.position, d.get("fx", "sword_slash"), {"scale": float(d.get("fx_scale", 0.6)), "rot": randf() * TAU})
					hit(b, u, tg, d, pw)
					b.add_shake(1.5))
		"stretch":
			for i in count:
				b.later(i * 0.13, func() -> void:
					if not is_instance_valid(u) or u.dead:
						return
					var tg: Unit = b.nearest_enemy(u) if i == 0 else b.pick_target(u, "random")
					if tg:
						stretch(b, u, d, pw, tg))
		"chain":
			chain(b, u, d, pw, count)
		"summon":
			for i in count:
				var ang := TAU * i / float(count)
				summon_one(b, u, d, u.position + Vector2.RIGHT.rotated(ang) * (u.radius() + 26), pw)
		"shield":
			u.shield = u.max_hp * float(DB.p(d, "power", r, 0.2)) * (1.0 + 0.1 * r)
			u.shield_t = float(DB.p(d, "dur", r, 5.0))
			u.invuln_t = maxf(u.invuln_t, float(DB.p(d, "invuln", r, 0.0)))
			CuteFx.spawn(b.layer_fx, d.get("fx", "divine_shield"), u.position, {"kind": "shield", "follow": u, "size": u.radius() * 1.35, "life": u.shield_t, "loop": true})
		"buff":
			var bf := {}
			for k in d.get("buffs", {}):
				bf[k] = float(d.buffs[k]) * (1.0 + 0.15 * r)
			var dur := float(DB.p(d, "dur", r, 5.0))
			u.add_buff(bf, dur)
			CuteFx.spawn(b.layer_fx, d.get("fx", "aura_gold"), u.position, {"kind": "aura", "follow": u, "size": u.radius() * 1.15, "life": dur, "loop": true})
		"heal":
			for a: Unit in b.allies_of(u):
				b.heal(a, a.max_hp * float(DB.p(d, "power", r, 0.15)))
				b.fx(a.position, d.get("fx", "heal"), {"kind": "heal", "size": a.radius() * 1.3})
		"timestop":
			var dur := float(DB.p(d, "dur", r, 2.0))
			b.fx(b.arena * 0.5, d.get("fx", "time_stop"), {"kind": "rune", "size": b.arena.y * 0.45, "dur": 1.2})
			b.tint_t = dur
			b.tint_col = Color(0.45, 0.75, 1.0, 0.2)
			b.flash(Color("#d8f4ff"), 0.6)
			for e: Unit in es:
				b.apply_status(u, e, "freeze", dur)
				hit(b, u, e, d, pw)
		"strike":
			var tg := b.pick_target(u, d.get("target", "nearest"))
			if d.get("flash", false):
				b.flash(Color.WHITE, 0.85)
			b.later(0.12, func() -> void:
				if not is_instance_valid(tg) or tg.dead or not is_instance_valid(u):
					return
				b.fx(tg.position, d.get("fx", "crit_hit"), {"scale": float(d.get("fx_scale", 0.6)) * 1.3})
				if d.get("extra_fx", "") != "":
					b.fx(tg.position, d.extra_fx, {"scale": float(d.get("extra_scale", 0.6))})
				hit(b, u, tg, d, pw, {"force_crit": d.get("force_crit", false)})
				b.add_shake(float(d.get("shake", 6.0))))
		"orbit":
			var ob := OrbitBlades.new()
			ob.setup(b, u, d, pw, count)
			b.layer_fx.add_child(ob)
		"zone":
			var tgz: Unit = null if d.get("on_self", false) else b.pick_target(u, d.get("target", "nearest"))
			var zone := ZoneArea.new()
			zone.setup(b, u, d, pw, u.position if tgz == null else tgz.position)
			b.layer_fx.add_child(zone)
		"drain":
			var tg := b.pick_target(u, d.get("target", "nearest"))
			b.fx(tg.position, d.get("fx", "life_steal"), {"scale": float(d.get("fx_scale", 0.6))})
			var dmg := hit(b, u, tg, d, pw)
			b.heal(u, dmg * float(DB.p(d, "heal_pct", r, 0.5)))
			_drain_trail(b, tg.position, u)
		"debuff":
			var rad := float(d.get("radius", 0.0))
			var tgd := b.pick_target(u, d.get("target", "nearest"))
			var center := tgd.position
			b.fx(center if rad > 0.0 else b.arena * 0.5, d.get("fx", "curse"), {"kind": "rune", "size": rad if rad > 0.0 else b.arena.y * 0.4})
			for e: Unit in (b.in_radius(u, center, rad) if rad > 0.0 else es):
				b.apply_status(u, e, d.get("status", "weaken"), float(DB.p(d, "status_dur", r, 4.0)), 0.3)
				if d.has("power"):
					b.deal(u, e, pw, {"kind": "skill"})
		"execute":
			var tg := b.pick_target(u, "weakest")
			var thr := float(DB.p(d, "threshold", r, 0.3))
			var mult := 3.0 if tg.hp_ratio() < thr else 1.0
			b.fx(tg.position, d.get("fx", "crit_hit"), {"scale": float(d.get("fx_scale", 0.6)) * (1.4 if mult > 1.0 else 1.0)})
			if mult > 1.0:
				b.flash(Color("#ffe0e0"), 0.4)
				b.banner(tg, "EXECUTADO", Color("#ff5a5a"))
			hit(b, u, tg, d, pw * mult, {"force_crit": mult > 1.0})
			b.add_shake(4.0 * mult)
		"awaken":
			var h := float(d.get("heal", 0.2))
			if h > 0.0:
				b.heal(u, u.max_hp * h * (1.0 + 0.1 * r))
			var bf2 := {}
			for k in d.get("buffs", {}):
				bf2[k] = float(d.buffs[k]) * (1.0 + 0.15 * r)
			u.add_buff(bf2, 99999.0)
			u.set_transformed(d.get("aura", "aura_gold"))
			u.invuln_t = maxf(u.invuln_t, 0.8)
			b.transform_burst(u)
		"knockback":
			var rad2 := float(d.get("radius", 140.0))
			b.fx(u.position, d.get("fx", "mana_burst"), {"kind": "burst", "size": rad2})
			for e: Unit in b.in_radius(u, u.position, rad2):
				var dir2: Vector2 = (e.position - u.position).normalized()
				e.vel = dir2 * float(d.get("force", 600.0))
				hit(b, u, e, d, pw)
				b.apply_status(u, e, "stun", 0.35)
			b.add_shake(5)
		"teleport":
			var tg := b.pick_target(u, d.get("target", "nearest"))
			b.fx(u.position, "poof", {"size": u.radius() * 1.2})
			var behind := tg.position + (tg.position - u.position).normalized() * (tg.radius() + u.radius() + 4.0)
			u.position = behind.clamp(Vector2(u.radius(), u.radius()), b.arena - Vector2(u.radius(), u.radius() + 20))
			u.invuln_t = maxf(u.invuln_t, 0.3)
			b.fx(u.position, "poof", {"size": u.radius() * 1.2})
			b.fx(tg.position, d.get("fx", "slash_red"), {"scale": float(d.get("fx_scale", 0.7)) * 1.2})
			hit(b, u, tg, d, pw)
			b.add_shake(3)
		"mimic":
			if _pool.is_empty():
				for id in DB.BALLS:
					for a in DB.BALLS[id].get("actives", []):
						if not str(a.get("type", "")) in ["mimic", "awaken", "summon", "orbit", "zone", "heal", "shield"]:
							_pool.append(a)
			if _pool.is_empty():
				return false
			var copy: Dictionary = (_pool[randi() % _pool.size()] as Dictionary).duplicate()
			copy.erase("alt")
			copy.power_mult = float(copy.get("power_mult", 1.0)) * maxf(0.6, float(d.get("power", 1.0)))
			b.banner(u, "Copiou: " + str(copy.get("name", "?")), Color("#e0c8ff"))
			b.fx(u.position, "rune_circle", {"kind": "rune", "size": u.radius() * 1.4})
			return cast(b, u, copy, true)
		"gamble":
			var rolls := [0.3, 0.6, 1.0, 1.0, 1.5, 2.0, 2.5, 5.0]
			var m: float = rolls[randi() % rolls.size()]
			var tg := b.pick_target(u, d.get("target", "nearest"))
			var col := Color("#ff6a6a") if m < 1.0 else (Color("#ffd23c") if m >= 5.0 else Color("#7cf08c"))
			Drawer.text(b.layer_text, u.position + Vector2(0, -u.radius() - 52), "x%s" % ("%.1f" % m).replace(".", ","), col, 26, 1.0, 20)
			b.fx(tg.position, d.get("fx", "cartoon_pow"), {"scale": float(d.get("fx_scale", 0.6)) * (0.8 + m * 0.15)})
			hit(b, u, tg, d, pw * m, {"force_crit": m >= 5.0})
			if m >= 5.0:
				b.banner(u, "JACKPOT", Color("#ffd23c"))
				b.fx(u.position, "stars", {"size": u.radius() * 2.0})
				var jbd: Dictionary = d.get("jackpot_buffs", {"atk_pct": 0.5, "spd_pct": 0.3})
				var jb := {}
				for k in jbd:
					jb[k] = float(jbd[k])
				u.add_buff(jb, 8.0)
				u.hp = minf(u.max_hp, u.hp + u.max_hp * 0.3)
		_:
			return false
	return true


# ---------------------------------------------------------------------------------- auxiliares
static func projectile(b: Battle, u: Unit, d: Dictionary, pw: float, dir: Vector2, tg: Unit) -> void:
	var p := Projectile.new()
	p.battle = b
	p.src = u
	p.team = u.team
	p.position = u.position + dir * u.radius()
	p.vel = dir * float(d.get("speed", 300.0)) * float(d.get("speed_mult", 1.0))
	p.power = pw
	p.hit_r = float(d.get("hit_r", 14.0))
	p.pierce = bool(d.get("pierce", false))
	p.aoe = float(d.get("aoe", 0.0))
	p.hit_fx = d.get("hit_fx", "hit_spark")
	p.hit_scale = float(d.get("hit_scale", 0.5))
	p.skill = d
	p.shake_amt = float(d.get("shake", 1.5))
	p.target = tg
	p.homing = float(d.get("homing", 2.5))
	b.layer_fx.add_child(p)
	var fxn: String = d.get("fx", "")
	if fxn != "":
		var k := CuteFx.kind_of(fxn)
		if not k in ["orb", "shot", "disc"]:
			k = "orb" if not d.get("rotate", true) else "shot"
		var sz := CuteFx.base_size(fxn, k) * clampf(float(d.get("fx_scale", 0.6)) / 0.6, 0.6, 2.4)
		p.sprite = CuteFx.make(fxn, {"kind": k, "size": sz, "loop": true})
		p.add_child(p.sprite)


static func basic_shot(b: Battle, u: Unit, tg: Unit) -> void:
	var p := Projectile.new()
	p.battle = b
	p.src = u
	p.team = u.team
	var dir := (tg.position - u.position).normalized()
	p.position = u.position + dir * u.radius()
	p.vel = dir * 460.0
	p.power = 0.6
	p.hit_r = 6.0
	p.kind = "shot"
	p.hit_fx = "hit"
	p.hit_scale = 0.45
	p.target = tg
	p.homing = 1.5
	p.color = u.color
	p.shake_amt = 0.0
	b.layer_fx.add_child(p)


static func beam(b: Battle, u: Unit, d: Dictionary, pw: float, dir: Vector2) -> void:
	var start := u.position + dir * u.radius() * 0.6
	var len := 2000.0
	for i in 2:
		if absf(dir[i]) > 0.001:
			var lim: float = (b.arena[i] - start[i]) / dir[i] if dir[i] > 0 else -start[i] / dir[i]
			len = minf(len, lim)
	len = maxf(len, 60.0)
	var w := float(d.get("width", 32.0))
	var dur := 0.75
	b.fx(start, d.get("fx", "beam_ki"), {"kind": "beam", "rot": dir.angle(), "length": len, "size": w * 0.5, "dur": dur})
	b.add_shake(5)
	b.flash(CuteFx.color_of(d.get("fx", "beam_ki")).lightened(0.5), 0.22)
	var ticks := int(d.get("ticks", 4))
	for i in ticks:
		b.later(0.1 + i * (dur * 0.8 / ticks), func() -> void:
			if not is_instance_valid(u) or u.dead:
				return
			for e: Unit in b.enemies_of(u):
				var q := Geometry2D.get_closest_point_to_segment(e.position, start, start + dir * len)
				if q.distance_to(e.position) <= w * 0.5 + e.radius():
					hit(b, u, e, d, pw / ticks)
					if randf() < 0.4:
						b.fx(e.position, "hit", {"size": 20.0, "color": CuteFx.color_of(d.get("fx", "beam_ki"))}))


static func aoe_at(b: Battle, u: Unit, d: Dictionary, pw: float, pos: Vector2) -> void:
	var rad := float(d.get("radius", 70.0))
	var warn := float(d.get("warn", 0.0))
	var delay := float(d.get("hit_delay", 0.12)) + warn
	if warn > 0.0:
		Drawer.spawn(b.ground, pos, warn, func(n: Drawer, k: float) -> void:
			n.draw_circle(Vector2.ZERO, rad, Color(1, 0.3, 0.3, 0.12 + 0.12 * sin(k * 20.0)))
			n.draw_arc(Vector2.ZERO, rad, 0, TAU, 40, Color(1, 0.3, 0.3, 0.8), 3.0)
			n.draw_arc(Vector2.ZERO, rad * k, 0, TAU, 40, Color(1, 0.5, 0.5, 0.6), 2.0))
	b.later(warn, func() -> void:
		var fxn: String = d.get("fx", "")
		if fxn != "":
			b.fx(pos, fxn, {"size": maxf(rad, CuteFx.base_size(fxn, CuteFx.kind_of(fxn)) * 0.7)})
		if d.get("extra_fx", "") != "":
			b.fx(pos, d.extra_fx, {"scale": float(d.get("extra_scale", 0.7)), "rot": randf_range(-0.6, 0.6)}))
	b.later(delay, func() -> void:
		if not is_instance_valid(u) or u.dead:
			return
		for e: Unit in b.in_radius(u, pos, rad):
			hit(b, u, e, d, pw)
		b.add_shake(float(d.get("shake", 2.5))))


static func stretch(b: Battle, u: Unit, d: Dictionary, pw: float, tg: Unit) -> void:
	var arm := Color(d.get("arm", "#f2c79a"))
	var rel := tg.position - u.position
	var fist := CuteFx.color_of(d.get("hit_fx", "pow"))
	Drawer.spawn(b.layer_units, u.position, 0.24, func(n: Drawer, k: float) -> void:
		var ext := sin(k * PI)
		var end := rel * ext
		n.draw_line(Vector2.ZERO, end, Color("#1b1420"), 13.0, true)
		n.draw_line(Vector2.ZERO, end, arm, 8.0, true)
		n.draw_line(Vector2.ZERO, end, Color(1, 1, 1, 0.4), 2.5, true)
		n.draw_circle(end, 11.0, Color("#1b1420"))
		n.draw_circle(end, 8.0, fist)
		n.draw_circle(end + Vector2(-2.5, -2.5), 2.5, Color(1, 1, 1, 0.8)))
	b.later(0.1, func() -> void:
		if is_instance_valid(tg) and not tg.dead and is_instance_valid(u):
			b.fx(tg.position, d.get("hit_fx", "cartoon_pow"), {"scale": float(d.get("hit_scale", 0.45))})
			hit(b, u, tg, d, pw)
			tg.vel += rel.normalized() * 400.0
			b.add_shake(2.5))


static func chain(b: Battle, u: Unit, d: Dictionary, pw: float, count: int) -> void:
	var hitd := {}
	var cur := b.nearest_enemy(u)
	var dmg := pw
	var pts: Array = [u.position]
	var targets: Array = []
	for i in count:
		if cur == null:
			break
		hitd[cur.get_instance_id()] = true
		pts.append(cur.position)
		targets.append(cur)
		var best: Unit = null
		var bd := INF
		for e: Unit in b.enemies_of(u):
			if hitd.has(e.get_instance_id()):
				continue
			var dd := e.position.distance_to(cur.position)
			if dd < bd:
				bd = dd
				best = e
		cur = best
	var col := CuteFx.color_of(d.get("hit_fx", "zap_hit"))
	Drawer.spawn(b.layer_fx, Vector2.ZERO, 0.35, func(n: Drawer, k: float) -> void:
		for i in pts.size() - 1:
			var p0: Vector2 = pts[i]
			var p1: Vector2 = pts[i + 1]
			var prev := p0
			for s in range(1, 8):
				var q := p0.lerp(p1, s / 7.0)
				if s < 7:
					q += (p1 - p0).orthogonal().normalized() * randf_range(-10, 10)
				n.draw_line(prev, q, Color("#1b1420", 1.0 - k), 9.0)
				n.draw_line(prev, q, Color(col, 1.0 - k), 5.0)
				n.draw_line(prev, q, Color(1, 1, 1, 1.0 - k), 2.0)
				prev = q)
	for e: Unit in targets:
		b.fx(e.position, d.get("hit_fx", "zap_hit"), {"size": 26.0})
		hit(b, u, e, d, dmg)
		dmg *= 0.85


static func summon_one(b: Battle, u: Unit, d: Dictionary, pos: Vector2, pw: float) -> void:
	var lk: Dictionary = u.look
	var sl: Variant = d.get("summon_look")
	if sl is Dictionary:
		lk = sl
	elif sl is String and DB.SUMMON_LOOKS.has(sl):
		lk = DB.SUMMON_LOOKS[sl]
	var spec := {
		"name": "Invocação", "look": lk, "rarity": 0, "summon": true, "ttl": float(DB.p(d, "dur", u.rarity, 8.0)),
		"pscale": 0.75, "color": u.color.to_html(),
		"stats": {"hp": u.max_hp * clampf(pw, 0.2, 1.0), "atk": u.atk() * clampf(pw, 0.2, 1.0) * 1.3, "def": u.defense() * 0.5,
			"spd": u.speed() * 1.1, "crit": 0.05, "critdmg": 1.5, "contact_mult": 1.0},
	}
	pos = pos.clamp(Vector2(24, 24), b.arena - Vector2(24, 46))
	var s := b.spawn(spec, u.team, pos)
	b.fx(pos, d.get("fx", "poof"), {"kind": "puff", "size": 28.0})
	s.vel = (pos - u.position).normalized() * s.speed()


static func _drain_trail(b: Battle, from: Vector2, u: Unit) -> void:
	for i in 5:
		var start := from + Vector2(randf_range(-12, 12), randf_range(-12, 12))
		Drawer.spawn(b.layer_fx, start, 0.45, func(n: Drawer, k: float) -> void:
			if not is_instance_valid(u):
				return
			var p := (u.position - start) * k * k
			n.draw_circle(p, 5.0, Color("#1b1420", 1.0 - k))
			n.draw_circle(p, 3.5, Color("#ff7aa0", 1.0 - k)))

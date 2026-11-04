class_name Unit
extends Node2D
## Uma bolinha na arena: fisica simples, atributos, status, skills e passivas.

var battle: Battle
var team := 0
var uname := ""
var ball_id := ""
var look: Dictionary = {}
var look_tf: Dictionary = {}
var tex: Texture2D
var pscale := 1.0
var base_radius := 28.0
var rarity := 0
var color := Color.WHITE
var is_boss := false
var is_summon := false
var summon_ttl := -1.0

var max_hp := 100.0
var hp := 100.0
var hp_trail := 100.0
var st: Dictionary = {}
var buffs: Array = []
var status: Dictionary = {}
var immune: Array = []
var actives: Array = []
var passives: Array = []
var shield := 0.0
var shield_t := 0.0
var invuln_t := 0.0
var transformed := false
var stacks := 0
var stack_val := 0.0
var stack_max := 0
var vel := Vector2.ZERO
var mass := 1.0
var ranged := false
var shot_cd := 1.0
var dash_t := 0.0
var dash_power := 0.0
var dash_left := 0
var dash_skill: Dictionary = {}
var dash_hit: Dictionary = {}
var ghost_t := 0.0
var flash := 0.0
var hit_cd: Dictionary = {}
var grow := 1.0
var dead := false
var manual_cast := false
var bob := 0.0
var squash := 0.0
var aura_fx: Node2D
var revived := false
var periodic_t: Dictionary = {}
var weapon: Dictionary = {}
var weapon_angle := 0.0
var weapon_cd: Dictionary = {}
var hook := false


func setup(spec: Dictionary, team_id: int) -> void:
	team = team_id
	uname = spec.get("name", "?")
	ball_id = spec.get("ball_id", "")
	look = spec.get("look", {})
	look_tf = spec.get("look_tf", {})
	rarity = int(spec.get("rarity", 0))
	is_boss = bool(spec.get("boss", false))
	is_summon = bool(spec.get("summon", false))
	summon_ttl = float(spec.get("ttl", -1.0))
	pscale = float(spec.get("pscale", 1.6 if is_boss else 1.0))
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	base_radius = 28.0 * pscale
	mass = pscale * pscale
	color = Color(spec.get("color", "#ffffff"))
	tex = BallArt.make(look)
	st = spec.get("stats", {}).duplicate()
	max_hp = float(st.get("hp", 100.0))
	hp = max_hp
	hp_trail = max_hp
	ranged = bool(spec.get("ranged", false))
	immune = spec.get("immune", []).duplicate()
	for a in spec.get("actives", []):
		if int(a.get("unlock", 0)) <= rarity:
			actives.append({"def": a, "cd": float(DB.p(a, "cd", rarity, 6.0)) * randf_range(0.35, 0.7)})
	for p in spec.get("passives", []):
		if int(p.get("unlock", 0)) > rarity:
			continue
		passives.append({"def": p, "done": false})
		match str(p.get("type", "")):
			"stack":
				stack_val = float(p.get("atk_pct", 0.03)) * (1.0 + 0.15 * rarity)
				stack_max = int(p.get("max", 10))
			"shield_start":
				shield = max_hp * float(p.get("shield", 0.2)) * (1.0 + 0.1 * rarity)
				shield_t = 9999.0
			"first_strike":
				var bf := {}
				for k in p.get("buffs", {}):
					bf[k] = float(p.buffs[k]) * (1.0 + 0.15 * rarity)
				add_buff(bf, float(p.get("dur", 5.0)))
			"periodic":
				periodic_t[p] = float(p.get("every", 6.0)) * 0.5
		for im in p.get("immune", []):
			immune.append(im)
	shot_cd = randf_range(0.3, 1.0)
	bob = randf() * TAU
	weapon = spec.get("weapon", {})
	weapon_angle = randf() * TAU


func is_dead() -> bool:
	return dead


func radius() -> float:
	return base_radius * grow


func passive(type: String) -> Dictionary:
	for p in passives:
		if p.def.get("type", "") == type:
			return p.def
	return {}


# ---------------------------------------------------------------------------------- atributos
func bsum(k: String) -> float:
	var v := 0.0
	for b in buffs:
		v += float(b.stats.get(k, 0.0))
	return v


func atk() -> float:
	var m := 1.0 + bsum("atk_pct") + stacks * stack_val
	if status.has("weaken"):
		m -= 0.3
	var bz := passive("berserk")
	if not bz.is_empty():
		m += float(bz.get("atk_pct", 0.5)) * (1.0 + 0.1 * rarity) * (1.0 - hp_ratio())
	return float(st.get("atk", 10.0)) * maxf(0.1, m)


func defense() -> float:
	var m := 1.0 + bsum("def_pct")
	if status.has("armor_break"):
		m -= 0.5
	return float(st.get("def", 0.0)) * maxf(0.0, m)


func speed() -> float:
	var s := float(st.get("spd", 150.0)) * maxf(0.2, 1.0 + bsum("spd_pct"))
	if status.has("slow"):
		s *= 0.5
	return s


func stat(k: String) -> float:
	return float(st.get(k, 0.0)) + bsum(k)


func cant_act() -> bool:
	return status.has("freeze") or status.has("stun") or status.has("petrify") or status.has("sleep")


func silenced() -> bool:
	return status.has("silence")


func hp_ratio() -> float:
	return clampf(hp / max_hp, 0.0, 1.0)


# ---------------------------------------------------------------------------------- tick
func tick(dt: float) -> void:
	bob += dt * 3.0
	flash = maxf(0.0, flash - dt * 4.0)
	squash = maxf(0.0, squash - dt * 5.0)
	invuln_t = maxf(0.0, invuln_t - dt)
	hp_trail = move_toward(hp_trail, hp, max_hp * dt * 0.6) if hp_trail > hp else hp
	if shield_t > 0.0:
		shield_t -= dt
		if shield_t <= 0.0:
			shield = 0.0
	for k in hit_cd.keys():
		hit_cd[k] -= dt
		if hit_cd[k] <= 0.0:
			hit_cd.erase(k)
	for k in weapon_cd.keys():
		weapon_cd[k] -= dt
		if weapon_cd[k] <= 0.0:
			weapon_cd.erase(k)
	for i in range(buffs.size() - 1, -1, -1):
		buffs[i].t -= dt
		if buffs[i].t <= 0.0:
			buffs.remove_at(i)
	for sname in status.keys():
		var s: Dictionary = status[sname]
		s.t -= dt
		if sname in ["burn", "black_burn", "poison", "bleed"]:
			s.tick -= dt
			if s.tick <= 0.0:
				s.tick = 0.5
				battle.dot(s.get("src"), self, float(s.power), sname)
				if dead:
					return
		if s.t <= 0.0:
			_clear_status(sname)
	var rg := stat("regen")
	if rg > 0.0 and hp < max_hp:
		hp = minf(max_hp, hp + max_hp * rg * dt)
	# dano em area passivo
	var ad := passive("aura_dmg")
	if not ad.is_empty():
		var key := "aura_dmg"
		periodic_t[key] = float(periodic_t.get(key, 0.0)) - dt
		if float(periodic_t[key]) <= 0.0:
			periodic_t[key] = 0.5
			for e in battle.in_radius(self, position, float(ad.get("radius", 90.0))):
				battle.deal(self, e, float(ad.get("power", 0.3)) * 0.5 * (1.0 + 0.1 * rarity), {"kind": "dot"})
	if summon_ttl > 0.0:
		summon_ttl -= dt
		if summon_ttl <= 0.0:
			battle.kill(self, null, true)
			return
	if cant_act():
		return
	# passivas periodicas
	for p in passives:
		if p.def.get("type", "") == "periodic":
			periodic_t[p.def] = float(periodic_t.get(p.def, 3.0)) - dt
			if float(periodic_t[p.def]) <= 0.0:
				periodic_t[p.def] = float(p.def.get("every", 6.0))
				if p.def.has("skill"):
					Skills.cast(battle, self, p.def.skill, true)
	if silenced():
		return
	var cdr := clampf(stat("cdr"), 0.0, 0.6)
	for a in actives:
		if a.cd > 0.0:
			a.cd -= dt * (1.0 + cdr)
	if team == 1 or battle.auto_skill or is_summon or manual_cast:
		for a in actives:
			if a.cd <= 0.0 and dash_t <= 0.0:
				if Skills.cast(battle, self, a.def):
					a.cd = float(DB.p(a.def, "cd", rarity, 6.0))
					manual_cast = false
					break
	if ranged:
		shot_cd -= dt
		if shot_cd <= 0.0:
			var tg := battle.nearest_enemy(self)
			if tg:
				shot_cd = 1.15 / maxf(0.5, 1.0 + bsum("spd_pct") * 0.5)
				Skills.basic_shot(battle, self, tg)


func _clear_status(sname: String) -> void:
	var s: Dictionary = status.get(sname, {})
	var sfx: Variant = s.get("fx")
	if is_instance_valid(sfx):
		(sfx as Node).queue_free()
	status.erase(sname)


func ready_skill_ratio() -> float:
	if actives.is_empty():
		return 0.0
	var a: Dictionary = actives[0]
	return clampf(1.0 - a.cd / float(DB.p(a.def, "cd", rarity, 6.0)), 0.0, 1.0)


func add_buff(stats: Dictionary, dur: float) -> void:
	buffs.append({"stats": stats, "t": dur})


func set_transformed(aura_name: String = "") -> void:
	transformed = true
	if not look_tf.is_empty():
		var l := look.duplicate(true)
		for k in look_tf:
			l[k] = look_tf[k]
		look = l
		tex = BallArt.make(look)
	if aura_name != "":
		set_aura(aura_name)


func set_aura(aura_name: String) -> void:
	if is_instance_valid(aura_fx):
		aura_fx.queue_free()
	aura_fx = CuteFx.spawn(battle.ground, aura_name, position, {"follow": self, "size": radius() * 1.12, "loop": true})


# ---------------------------------------------------------------------------------- desenho
func _process(_dt: float) -> void:
	queue_redraw()


func _draw() -> void:
	var r := radius()
	var s := r / BallArt.RADIUS_PX
	# sombra
	draw_set_transform(Vector2(0, r * 0.92), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, r * 0.95, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# brilho da raridade (sutil) para o heroi e chefes
	if (team == 0 and not is_summon) or is_boss:
		var ac := DB.rcolor(rarity) if not is_boss else Color("#ff5a4a")
		var pulse := 0.5 + 0.5 * sin(bob * 1.6)
		for i in 3:
			draw_circle(Vector2.ZERO, r + 3.0 + i * 3.5 + pulse * 2.0, Color(ac, 0.1 - i * 0.028))
	var mod := Color.WHITE
	if flash > 0.0:
		mod = Color(1.0, 1.0 - flash * 0.55, 1.0 - flash * 0.55)
	if status.has("freeze"):
		mod = mod * Color(0.65, 0.88, 1.25)
	if status.has("petrify"):
		mod = Color(0.6, 0.6, 0.62)
	if invuln_t > 0.0 and int(invuln_t * 12.0) % 2 == 0:
		mod.a = 0.6
	if is_summon:
		mod.a *= 0.88
	# squash ao ser atingido
	var sq := squash * 0.12
	draw_set_transform(Vector2(0, sin(bob) * 1.5), 0.0, Vector2(1.0 + sq, 1.0 - sq))
	var size := Vector2(BallArt.SIZE, BallArt.SIZE) * s
	draw_texture_rect(tex, Rect2(-BallArt.CENTER * s, size), false, mod)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_weapons(r)
	if is_summon:
		return
	_draw_hp(r)


func _draw_weapons(r: float) -> void:
	if weapon.is_empty():
		return
	var cnt := int(weapon.get("count", 1))
	var orbit := r * float(weapon.get("orbit", 1.4))
	var col := Color(weapon.get("color", "#d8dde8"))
	var ws := clampf(r / 28.0, 0.7, 2.0)
	var spin := float(weapon.get("spin", 3.0))
	for i in cnt:
		var ang := weapon_angle + TAU * i / float(cnt)
		var p := Vector2(cos(ang), sin(ang)) * orbit
		# rastro durante investida
		if dash_t > 0.0:
			for k in 3:
				var a2 := ang - signf(spin) * (k + 1) * 0.25
				WeaponArt.draw(self, str(weapon.get("kind", "sword")), col, Vector2(cos(a2), sin(a2)) * orbit, a2, ws, 0.25 - k * 0.07)
		# a arma aponta para fora, levemente inclinada no sentido do giro
		WeaponArt.draw(self, str(weapon.get("kind", "sword")), col, p, ang + signf(spin) * 0.5, ws)


func _draw_hp(r: float) -> void:
	var bw := maxf(44.0, r * 1.7)
	var bh := 8.0 if not is_boss else 11.0
	var pos := Vector2(-bw * 0.5, r + 9.0)
	var ink := Color("#1b1420")
	# moldura arredondada
	var full := Rect2(pos - Vector2(3, 3), Vector2(bw + 6, bh + 6))
	_rrect(full, ink, (bh + 6) * 0.5)
	_rrect(Rect2(pos, Vector2(bw, bh)), Color("#4a3a44"), bh * 0.5)
	var ratio := hp_ratio()
	var trail := clampf(hp_trail / max_hp, 0.0, 1.0)
	if trail > ratio:
		_rrect(Rect2(pos, Vector2(bw * trail, bh)), Color("#fff0c0"), bh * 0.5)
	var c1 := Color("#7cf08c") if team == 0 else Color("#ff7a6a")
	var c2 := Color("#2fb84a") if team == 0 else Color("#d43a3a")
	if ratio > 0.0:
		var w := maxf(bh, bw * ratio)
		_rrect(Rect2(pos, Vector2(w, bh)), c2, bh * 0.5)
		_rrect(Rect2(pos, Vector2(w, bh * 0.55)), c1, bh * 0.3)
		draw_line(pos + Vector2(bh * 0.5, 2), pos + Vector2(w - bh * 0.5, 2), Color(1, 1, 1, 0.5), 1.5)
	if shield > 0.0:
		var sw := bw * clampf(shield / max_hp, 0.0, 1.0)
		_rrect(Rect2(pos + Vector2(0, -5), Vector2(maxf(4.0, sw), 4)), Color("#bfeaff"), 2.0)


func _rrect(r: Rect2, c: Color, rad: float) -> void:
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	draw_rect(Rect2(r.position + Vector2(rad, 0), Vector2(r.size.x - rad * 2.0, r.size.y)), c)
	draw_rect(Rect2(r.position + Vector2(0, rad), Vector2(r.size.x, r.size.y - rad * 2.0)), c)
	draw_circle(r.position + Vector2(rad, rad), rad, c)
	draw_circle(r.position + Vector2(r.size.x - rad, rad), rad, c)
	draw_circle(r.position + Vector2(rad, r.size.y - rad), rad, c)
	draw_circle(r.position + Vector2(r.size.x - rad, r.size.y - rad), rad, c)

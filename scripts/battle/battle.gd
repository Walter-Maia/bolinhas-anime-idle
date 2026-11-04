class_name Battle
extends Node2D
## Arena de combate. As bolinhas quicam sozinhas pelas paredes em velocidade constante (sem perseguir
## ninguem). Dano vem de encostar no corpo, das ARMAS que giram em volta e das skills.

signal finished(win: bool)
signal wave_started(idx: int, total: int)
signal enemy_killed(u: Unit)

const STATUS_FX := {
	"burn": "st_burning", "black_burn": "st_burning", "poison": "st_poisoned", "bleed": "st_bleeding", "freeze": "st_frozen",
	"stun": "st_stunned", "slow": "st_slowed", "weaken": "st_cursed", "armor_break": "st_cursed", "marked": "st_charmed",
	"silence": "st_confused", "petrify": "st_petrified", "sleep": "st_sleep",
}

var arena := Vector2(680, 470)
var units: Array = []
var running := false
var ended := false
var auto_skill := true
var waves: Array = []
var wave_idx := 0
var between := -1.0
var shake := 0.0
var base_pos := Vector2.ZERO
var theme_cfg: Dictionary = {"floor": "#f3e7cf", "floor2": "#e9dabb", "accent": "#d8b878", "line": "#cdb48a"}
var timers: Array = []
var elapsed := 0.0
var time_limit := 0.0
var flash_a := 0.0
var flash_col := Color.WHITE
var tint_t := 0.0
var tint_col := Color(0.4, 0.7, 1.0, 0.18)
var deco: Array = []
var motes: Array = []

var ground: Node2D
var layer_units: Node2D
var layer_fx: Node2D
var layer_text: Node2D
var overlay: Drawer


func _ready() -> void:
	ground = Node2D.new()
	layer_units = Node2D.new()
	layer_fx = Node2D.new()
	layer_text = Node2D.new()
	for n in [ground, layer_units, layer_fx, layer_text]:
		add_child(n)
	overlay = Drawer.new()
	overlay.life = 1e12
	overlay.draw_fn = _draw_overlay
	add_child(overlay)
	_make_deco()


func set_arena(sz: Vector2) -> void:
	arena = sz
	_make_deco()
	queue_redraw()


func set_theme(cfg: Dictionary) -> void:
	theme_cfg = cfg
	_make_deco()
	queue_redraw()


func _make_deco() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(theme_cfg))
	deco.clear()
	for i in 22:
		deco.append({"p": Vector2(rng.randf() * arena.x, rng.randf() * arena.y), "r": rng.randf_range(2.0, 5.0), "k": rng.randi() % 3})
	motes.clear()
	for i in 10:
		motes.append({"p": Vector2(rng.randf() * arena.x, rng.randf() * arena.y), "v": rng.randf_range(6.0, 16.0), "r": rng.randf_range(2.0, 4.5), "ph": rng.randf() * TAU})


func _process(delta: float) -> void:
	for m in motes:
		m.p.y -= m.v * delta
		m.ph += delta
		if m.p.y < -10:
			m.p.y = arena.y + 10
	queue_redraw()


func _draw() -> void:
	var f1 := Color(theme_cfg.get("floor", "#f3e7cf"))
	var f2 := Color(theme_cfg.get("floor2", "#e9dabb"))
	var acc := Color(theme_cfg.get("accent", "#d8b878"))
	var ln := Color(theme_cfg.get("line", "#cdb48a"))
	var steps := 16
	for i in steps:
		var t := float(i) / steps
		draw_rect(Rect2(0, arena.y * t, arena.x, arena.y / steps + 1.0), f1.lerp(f2, t))
	var tile := 68.0
	for y in int(arena.y / tile) + 2:
		for x in int(arena.x / tile) + 2:
			if (x + y) % 2 == 0:
				var c := Vector2(x * tile, y * tile)
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -tile * 0.5), c + Vector2(tile * 0.5, 0), c + Vector2(0, tile * 0.5), c + Vector2(-tile * 0.5, 0)]), Color(ln, 0.12))
	for d in deco:
		var c2 := Color(acc, 0.35)
		match int(d.k):
			0:
				draw_circle(d.p, d.r, c2)
			1:
				draw_line(d.p - Vector2(d.r, 0), d.p + Vector2(d.r, 0), c2, 2.0)
				draw_line(d.p - Vector2(0, d.r), d.p + Vector2(0, d.r), c2, 2.0)
			2:
				draw_arc(d.p, d.r, 0, TAU, 12, c2, 1.5)
	for m in motes:
		draw_circle(m.p + Vector2(sin(m.ph) * 6.0, 0), m.r, Color(1, 1, 1, 0.25))
	for i in 6:
		draw_rect(Rect2(Vector2.ZERO, arena), Color(ln.darkened(0.4), 0.05), false, 6.0 + i * 5.0)


func _draw_overlay(n: Drawer, _k: float) -> void:
	if tint_t > 0.0:
		n.draw_rect(Rect2(Vector2.ZERO, arena), tint_col)
	if flash_a > 0.0:
		n.draw_rect(Rect2(Vector2.ZERO, arena), Color(flash_col, flash_a))


# ---------------------------------------------------------------------------------- setup
func clear() -> void:
	for layer in [ground, layer_units, layer_fx, layer_text]:
		for c in layer.get_children():
			c.queue_free()
	units.clear()
	timers.clear()
	running = false
	ended = false
	between = -1.0
	tint_t = 0.0
	flash_a = 0.0


func start(players: Array, wave_list: Array, limit: float = 0.0) -> void:
	clear()
	waves = wave_list
	wave_idx = 0
	elapsed = 0.0
	time_limit = limit
	var n := players.size()
	for i in n:
		var p := Vector2(arena.x * 0.22, arena.y * (i + 1) / float(n + 1))
		var u := spawn(players[i], 0, p)
		fx(u.position, "poof", {"size": 34.0})
	running = true
	_start_wave(0)


func _start_wave(i: int) -> void:
	wave_idx = i
	wave_started.emit(i, waves.size())
	var list: Array = waves[i]
	var n := list.size()
	for j in n:
		var spec: Dictionary = list[j]
		var p := Vector2(arena.x * randf_range(0.62, 0.85), arena.y * (j + 1) / float(n + 1) + randf_range(-20, 20))
		if spec.get("boss", false):
			p = Vector2(arena.x * 0.74, arena.y * 0.5)
		var u := spawn(spec, 1, p)
		fx(u.position, "poof", {"size": 46.0 if u.is_boss else 30.0})
		if u.is_boss:
			add_shake(6)


func spawn(spec: Dictionary, team: int, pos: Vector2) -> Unit:
	var u := Unit.new()
	u.battle = self
	u.setup(spec, team)
	pos = pos.clamp(Vector2(u.radius(), u.radius()), arena - Vector2(u.radius(), u.radius() + 20))
	u.position = pos
	# direcao inicial diagonal aleatoria (nunca reta, para quicar bonito)
	var ang := randf_range(0.35, 1.2) * (1.0 if randf() < 0.5 else -1.0) + (0.0 if team == 0 else PI)
	u.vel = Vector2.RIGHT.rotated(ang) * u.speed()
	layer_units.add_child(u)
	units.append(u)
	return u


func later(t: float, cb: Callable) -> void:
	timers.append({"t": t, "cb": cb})


## atalho para efeitos de combate (padrao fofo)
func fx(pos: Vector2, n: String, opts: Dictionary = {}) -> Node2D:
	if n == "":
		return null
	return CuteFx.spawn(layer_fx, n, pos, opts)


# ---------------------------------------------------------------------------------- consultas
func enemies_of(u: Unit) -> Array:
	var out := []
	for o: Unit in units:
		if not o.dead and o.team != u.team:
			out.append(o)
	return out


func allies_of(u: Unit) -> Array:
	var out := []
	for o: Unit in units:
		if not o.dead and o.team == u.team:
			out.append(o)
	return out


func nearest_enemy(u: Unit, from: Vector2 = Vector2.INF) -> Unit:
	var p := u.position if from == Vector2.INF else from
	var best: Unit = null
	var bd := INF
	for o: Unit in units:
		if o.dead or o.team == u.team:
			continue
		var d := p.distance_squared_to(o.position)
		if d < bd:
			bd = d
			best = o
	return best


func pick_target(u: Unit, mode: String) -> Unit:
	var es := enemies_of(u)
	if es.is_empty():
		return null
	match mode:
		"strongest":
			var best: Unit = es[0]
			for e: Unit in es:
				if e.hp > best.hp:
					best = e
			return best
		"weakest":
			var low: Unit = es[0]
			for e: Unit in es:
				if e.hp_ratio() < low.hp_ratio():
					low = e
			return low
		"random":
			return es[randi() % es.size()]
	return nearest_enemy(u)


func in_radius(u: Unit, center: Vector2, r: float) -> Array:
	var out := []
	for e: Unit in enemies_of(u):
		if e.position.distance_to(center) <= r + e.radius():
			out.append(e)
	return out


# ---------------------------------------------------------------------------------- loop
func _physics_process(dt: float) -> void:
	_fx_decay(dt)
	if not running:
		return
	elapsed += dt
	for i in range(timers.size() - 1, -1, -1):
		if i >= timers.size():
			continue
		var tm: Dictionary = timers[i]
		tm.t -= dt
		if tm.t <= 0.0:
			timers.remove_at(i)
			if not ended:
				tm.cb.call()
	for u: Unit in units.duplicate():
		if not u.dead:
			u.tick(dt)
	_move(dt)
	_collide()
	_weapons(dt)
	_check_end(dt)


func _fx_decay(dt: float) -> void:
	shake = maxf(0.0, shake - dt * 20.0)
	position = base_pos + (Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake if shake > 0.1 else Vector2.ZERO)
	flash_a = maxf(0.0, flash_a - dt * 2.5)
	tint_t = maxf(0.0, tint_t - dt)


func _move(dt: float) -> void:
	for u: Unit in units:
		if u.dead:
			continue
		if u.cant_act():
			u.vel *= 0.86
		elif u.dash_t > 0.0:
			u.dash_t -= dt
			u.ghost_t -= dt
			if u.ghost_t <= 0.0:
				u.ghost_t = 0.035
				_ghost(u)
			if u.dash_t <= 0.0:
				_end_dash(u)
		else:
			# velocidade constante: so normaliza o modulo (depois de colisoes/empurroes volta suave)
			var s := u.speed()
			if u.vel.length() < 1.0:
				u.vel = Vector2.RIGHT.rotated(randf() * TAU) * s
			var cur := u.vel.length()
			u.vel = u.vel.normalized() * move_toward(cur, s, s * 2.5 * dt)
			# evita trajetorias quase retas na horizontal/vertical (ficaria preso quicando no mesmo lugar)
			var a := absf(fmod(u.vel.angle(), PI / 2.0))
			if a < 0.12 or a > PI / 2.0 - 0.12:
				u.vel = u.vel.rotated(0.2 * dt * 10.0)
		u.position += u.vel * dt
		var r := u.radius()
		var bounced := false
		if u.position.x < r:
			u.position.x = r
			u.vel.x = absf(u.vel.x)
			bounced = true
		elif u.position.x > arena.x - r:
			u.position.x = arena.x - r
			u.vel.x = -absf(u.vel.x)
			bounced = true
		if u.position.y < r:
			u.position.y = r
			u.vel.y = absf(u.vel.y)
			bounced = true
		elif u.position.y > arena.y - r - 20:
			u.position.y = arena.y - r - 20
			u.vel.y = -absf(u.vel.y)
			bounced = true
		if bounced:
			u.squash = 1.0
			# um pouquinho de aleatoriedade em cada quique (o "rng" da partida)
			u.vel = u.vel.rotated(randf_range(-0.18, 0.18))


func _collide() -> void:
	var arr := units.duplicate()
	var n := arr.size()
	for i in n:
		var a: Unit = arr[i]
		if a.dead:
			continue
		for j in range(i + 1, n):
			var b: Unit = arr[j]
			if b.dead:
				continue
			var d := b.position - a.position
			var rr := a.radius() + b.radius()
			var dist := d.length()
			if dist >= rr or dist < 0.001:
				continue
			var nrm := d / dist
			var overlap := rr - dist
			var tm := a.mass + b.mass
			a.position -= nrm * overlap * (b.mass / tm)
			b.position += nrm * overlap * (a.mass / tm)
			var rel := (a.vel - b.vel).dot(nrm)
			if rel > 0.0:
				var imp := 2.0 * rel / tm
				if a.dash_t <= 0.0:
					a.vel -= nrm * imp * b.mass
				if b.dash_t <= 0.0:
					b.vel += nrm * imp * a.mass
			if a.team != b.team:
				var hit := false
				hit = _contact(a, b) or hit
				hit = _contact(b, a) or hit
				if hit:
					a.squash = 1.0
					b.squash = 1.0
					fx(a.position + nrm * a.radius(), "hit_spark", {"size": 20.0})


## armas girando em volta: cada lamina acerta inimigos que tocar (com recarga por alvo)
func _weapons(dt: float) -> void:
	for u: Unit in units:
		if u.dead or u.weapon.is_empty() or u.cant_act():
			continue
		var w: Dictionary = u.weapon
		var fast := 4.0 if u.dash_t > 0.0 else 1.0
		u.weapon_angle += float(w.get("spin", 3.0)) * fast * dt
		var cnt := int(w.get("count", 1))
		var orbit := u.radius() * float(w.get("orbit", 1.4))
		var reach := u.radius() * 0.6
		for i in cnt:
			var ang := u.weapon_angle + TAU * i / float(cnt)
			var tip := u.position + Vector2(cos(ang), sin(ang)) * orbit
			for e: Unit in units:
				if e.dead or e.team == u.team:
					continue
				if tip.distance_to(e.position) > reach + e.radius():
					continue
				var key := e.get_instance_id() * 8 + i
				if u.weapon_cd.has(key):
					continue
				u.weapon_cd[key] = 0.45
				var pw := float(w.get("power", 0.5))
				if u.dash_t > 0.0:
					pw = maxf(pw, u.dash_power * 0.6)
				deal(u, e, pw, {"kind": "weapon"})
				fx(tip, "hit", {"size": 18.0, "color": Color(w.get("color", "#ffffff"))})
				e.vel += (e.position - u.position).normalized() * 120.0


func _contact(a: Unit, b: Unit) -> bool:
	if a.dead or b.dead:
		return false
	var key := b.get_instance_id()
	if a.hit_cd.has(key):
		return false
	a.hit_cd[key] = 0.4
	if a.dash_t > 0.0 and not a.dash_hit.has(key):
		a.dash_hit[key] = true
		var sk := a.dash_skill
		deal(a, b, a.dash_power, {"kind": "skill"})
		fx(b.position, sk.get("hit_fx", "hit_spark"), {"scale": float(sk.get("hit_scale", 0.6)), "rot": a.vel.angle()})
		Skills.apply_skill_status(self, a, b, sk)
		add_shake(3)
		_next_dash(a)
		return true
	var mult := float(a.st.get("contact_mult", 1.0)) * (1.0 + a.bsum("contact_pct"))
	deal(a, b, mult, {"kind": "contact"})
	return true


func _check_end(dt: float) -> void:
	if ended:
		return
	var players := 0
	var enemies := 0
	for u: Unit in units:
		if u.dead:
			continue
		if u.team == 0 and not u.is_summon:
			players += 1
		elif u.team == 1:
			enemies += 1
	if players == 0:
		_finish(false)
		return
	if time_limit > 0.0 and elapsed >= time_limit:
		Drawer.text(layer_text, arena * 0.5, "TEMPO ESGOTADO", Color("#ff8a7a"), 34, 1.5, 10)
		_finish(false)
		return
	if enemies == 0:
		if between < 0.0:
			between = 0.9
		else:
			between -= dt
			if between <= 0.0:
				between = -1.0
				if wave_idx < waves.size() - 1:
					_start_wave(wave_idx + 1)
				else:
					_finish(true)


func _finish(win: bool) -> void:
	ended = true
	running = false
	if win:
		fx(Vector2(arena.x * 0.5, arena.y * 0.45), "firework", {"size": 120.0})
	finished.emit.call_deferred(win)


func pause(p: bool) -> void:
	if ended:
		return
	running = not p


# ---------------------------------------------------------------------------------- dano, cura, status
func deal(src: Unit, dst: Unit, mult: float, o: Dictionary = {}) -> float:
	if dst == null or dst.dead or ended:
		return 0.0
	var kind: String = o.get("kind", "skill")
	if dst.invuln_t > 0.0:
		if randf() < 0.3:
			Drawer.text(layer_text, dst.position + Vector2(0, -dst.radius()), "IMUNE", Color("#c8b0ff"), 18, 0.6)
		return 0.0
	var valid_src := src != null and is_instance_valid(src)
	if kind != "dot" and randf() < clampf(dst.stat("dodge"), 0.0, 0.6):
		Drawer.text(layer_text, dst.position + Vector2(0, -dst.radius()), "Esquiva!", Color("#a8e2ff"), 18, 0.6)
		_counter(dst, src if valid_src else null)
		return 0.0
	var b := (src.atk() if valid_src else float(o.get("raw", 10.0))) * mult
	var crit := false
	if kind != "dot" and valid_src and (o.get("force_crit", false) or randf() < src.stat("crit")):
		crit = true
		b *= maxf(1.2, src.stat("critdmg"))
	var df := dst.defense()
	var dmg := b * b / (b + df) if b > 0.0 else 0.0
	if kind == "contact":
		dmg *= maxf(0.2, 1.0 + dst.stat("contact_taken"))
	if dst.status.has("marked"):
		dmg *= 1.3
	if valid_src:
		var ex := src.passive("execute")
		if not ex.is_empty() and dst.hp_ratio() < float(ex.get("threshold", 0.3)):
			dmg *= 1.0 + float(ex.get("bonus", 0.5)) * (1.0 + 0.1 * src.rarity)
	dmg *= randf_range(0.92, 1.08)
	if dst.shield > 0.0:
		var ab := minf(dst.shield, dmg)
		dst.shield -= ab
		dmg -= ab
	dst.hp -= dmg
	dst.flash = 1.0
	dst.squash = maxf(dst.squash, 0.6)
	if dst.status.has("sleep"):
		dst._clear_status("sleep")
	var col := Color.WHITE if dst.team == 1 else Color("#ffb0a0")
	var size := 20 if kind == "weapon" else 22
	if crit:
		col = Color("#ffd23c")
		size = 30
	if dmg > 0.5:
		Drawer.text(layer_text, dst.position + Vector2(randf_range(-12, 12), -dst.radius() - 6), UI.fmt(dmg) + ("!" if crit else ""), col, size, 0.75 if not crit else 0.95)
	if valid_src and not src.dead and kind != "dot":
		var ls := src.stat("lifesteal")
		if ls > 0.0:
			src.hp = minf(src.max_hp, src.hp + dmg * ls)
		if kind == "contact":
			var th := dst.stat("thorns")
			if th > 0.0:
				src.hp -= dmg * th
				_check_hp(src, dst)
		var rf := dst.passive("reflect")
		if not rf.is_empty() and not src.dead:
			src.hp -= dmg * float(rf.get("pct", 0.15))
			_check_hp(src, dst)
		if crit and not src.dead:
			var oc := src.passive("on_crit")
			if not oc.is_empty():
				if oc.has("heal"):
					src.hp = minf(src.max_hp, src.hp + dmg * float(oc.heal))
				if oc.has("status"):
					apply_status(src, dst, oc.status, float(oc.get("status_dur", 2.0)))
		if not src.dead:
			_on_hit(src, dst, kind)
	if kind != "dot" and valid_src and not dst.dead:
		var ct := dst.passive("counter")
		if not ct.is_empty() and randf() < 0.5:
			_counter(dst, src)
	_check_hp(dst, src if valid_src else null)
	return dmg


func _counter(u: Unit, target: Unit) -> void:
	if u == null or u.dead:
		return
	var ct := u.passive("counter")
	if ct.is_empty() or target == null or not is_instance_valid(target) or target.dead:
		return
	if randf() > float(ct.get("chance", 0.25)):
		return
	fx(target.position, "slash", {"size": 30.0, "color": u.color})
	deal(u, target, float(ct.get("power", 1.0)), {"kind": "dot"})


func _check_hp(u: Unit, killer: Unit) -> void:
	if u.dead:
		return
	for p in u.passives:
		if p.done or p.def.get("type", "") != "low_hp":
			continue
		var thr := float(p.def.get("threshold", 0.3)) + 0.02 * u.rarity
		if u.hp_ratio() <= thr:
			p.done = true
			if u.hp <= 0.0:
				u.hp = 1.0
			_trigger_low_hp(u, p.def)
	if u.hp <= 0.0:
		var rv := u.passive("revive")
		if not rv.is_empty() and not u.revived:
			u.revived = true
			u.hp = u.max_hp * float(rv.get("heal", 0.4)) * (1.0 + 0.05 * u.rarity)
			u.invuln_t = 1.2
			banner(u, rv.get("name", "Renascer"), Color("#ffe680"))
			fx(u.position, rv.get("fx", "resurrection"), {"size": 60.0})
			flash(Color("#fff4c0"), 0.5)
			return
		kill(u, killer)


func dot(src: Variant, dst: Unit, amount: float, kind: String) -> void:
	if dst.dead or ended:
		return
	if dst.shield > 0.0:
		var ab := minf(dst.shield, amount)
		dst.shield -= ab
		amount -= ab
	dst.hp -= amount
	var c: Color = {"burn": Color("#ff9a3a"), "poison": Color("#9ae04a"), "bleed": Color("#ff5a5a")}.get(kind, Color("#b088ff"))
	Drawer.text(layer_text, dst.position + Vector2(randf_range(-14, 14), -dst.radius()), UI.fmt(amount), c, 17, 0.6, 30)
	_check_hp(dst, src as Unit if is_instance_valid(src) else null)


func heal(u: Unit, amount: float) -> void:
	if u.dead:
		return
	u.hp = minf(u.max_hp, u.hp + amount)
	Drawer.text(layer_text, u.position + Vector2(0, -u.radius() - 10), "+" + UI.fmt(amount), Color("#7cf08c"), 22, 0.8)


func apply_status(src: Unit, dst: Unit, sname: String, dur: float, power: float = 0.3) -> void:
	if dst == null or dst.dead or dst.immune.has(sname) or not STATUS_FX.has(sname):
		return
	if dst.is_boss and sname in ["stun", "freeze", "petrify", "sleep"]:
		dur *= 0.5
	var amount := 0.0
	if src != null and is_instance_valid(src):
		amount = src.atk() * power
	if dst.status.has(sname):
		var s: Dictionary = dst.status[sname]
		s.t = maxf(s.t, dur)
		s.power = maxf(float(s.power), amount)
		return
	var f: Node2D = CuteFx.spawn(layer_fx, STATUS_FX[sname], dst.position, {"follow": dst, "size": dst.radius(), "loop": true})
	dst.status[sname] = {"t": dur, "power": amount, "src": src, "tick": 0.5, "fx": f}


func _on_hit(src: Unit, dst: Unit, kind: String) -> void:
	for p in src.passives:
		var d: Dictionary = p.def
		match d.get("type", ""):
			"stack":
				if kind in ["contact", "shot", "weapon"]:
					src.stacks = mini(src.stack_max, src.stacks + 1)
			"on_hit":
				if randf() < float(d.get("chance", 0.1)) * (1.0 + 0.15 * src.rarity) * (0.5 if kind == "weapon" else 1.0):
					apply_status(src, dst, d.get("status", "burn"), float(d.get("status_dur", 2.0)), 0.3)


func _trigger_low_hp(u: Unit, d: Dictionary) -> void:
	var r := u.rarity
	banner(u, d.get("name", "Despertar"), Color("#ffb020"))
	var h := float(d.get("heal", 0.0)) * (1.0 + 0.2 * r)
	if h > 0.0:
		heal(u, u.max_hp * h)
	var bf := {}
	for k in d.get("buffs", {}):
		var v := float(d.buffs[k])
		bf[k] = v * (1.0 + 0.15 * r) if v > 0.0 else v
	if not bf.is_empty():
		u.add_buff(bf, 99999.0)
	if d.get("transform", false):
		u.set_transformed()
	if d.has("aura"):
		u.set_aura(d.aura)
	if d.has("grow"):
		var tw := create_tween()
		tw.tween_property(u, "grow", float(d.grow), 0.4).set_trans(Tween.TRANS_BACK)
		u.mass *= float(d.grow) * float(d.grow)
	if d.has("stun_all"):
		tint_t = 1.2
		tint_col = Color(0.5, 0.2, 0.9, 0.2)
		for e: Unit in enemies_of(u):
			apply_status(u, e, "stun", float(d.stun_all))
	u.invuln_t = 0.8
	transform_burst(u)


## explosao visual de transformacao: anel, estrelas e flash na cor da aura
func transform_burst(u: Unit) -> void:
	var c := u.color
	if is_instance_valid(u.aura_fx) and u.aura_fx is CuteFx:
		c = (u.aura_fx as CuteFx).col
	fx(u.position, "burst", {"size": u.radius() * 2.6, "color": c.lightened(0.2)})
	fx(u.position, "stars", {"size": u.radius() * 1.6, "color": Color("#ffe680")})
	flash_col = c
	flash_a = 0.4
	add_shake(5)


func kill(u: Unit, killer: Unit, silent: bool = false) -> void:
	if u.dead:
		return
	u.dead = true
	units.erase(u)
	if u.is_summon:
		fx(u.position, "poof", {"size": 26.0})
	elif u.team == 1:
		fx(u.position, "burst", {"size": u.radius() * 1.8, "color": Color("#fff0c0")})
		fx(u.position, "stars", {"size": u.radius(), "color": Color("#ffd23c")})
	else:
		fx(u.position, "soul_rise", {"size": 40.0})
	# esconde agora e libera depois: callbacks atrasados de skills ainda podem referenciar a unidade
	u.visible = false
	u.set_process(false)
	get_tree().create_timer(3.0).timeout.connect(u.queue_free)
	if silent:
		return
	if u.team == 1:
		enemy_killed.emit(u)
	if killer and is_instance_valid(killer) and not killer.dead:
		for p in killer.passives:
			if p.def.get("type", "") != "on_kill":
				continue
			if p.def.has("heal"):
				heal(killer, killer.max_hp * float(p.def.heal))
			if p.def.has("summon"):
				var n := 0
				for o: Unit in allies_of(killer):
					if o.is_summon:
						n += 1
				if n < int(p.def.get("max_summons", 3)):
					Skills.summon_one(self, killer, {"power": 0.4, "dur": 12.0, "summon_look": p.def.get("summon_look", "sombra"), "fx": "summon_rise"}, u.position, 0.4)


func banner(u: Unit, txt: String, col: Color) -> void:
	if txt == "":
		return
	Drawer.text(layer_text, u.position + Vector2(0, -u.radius() - 30), txt.to_upper() + "!", col, 22, 1.2, 25)


func add_shake(a: float) -> void:
	shake = maxf(shake, a)


func flash(col: Color, a: float = 0.7) -> void:
	flash_col = col
	flash_a = a


# ---------------------------------------------------------------------------------- investidas / gancho
func start_dash(u: Unit, sk: Dictionary, power: float, count: int, hook: bool = false) -> void:
	var tg := nearest_enemy(u)
	if tg == null:
		return
	u.dash_skill = sk
	u.dash_power = power
	u.dash_left = count - 1
	u.dash_hit = {}
	u.hook = hook
	u.hit_cd.clear()
	u.weapon_cd.clear()
	_dash_to(u, tg)
	if sk.get("trail_fx", "") != "":
		CuteFx.spawn(layer_fx, sk.trail_fx, u.position, {"follow": u, "size": u.radius(), "life": 0.5 * count, "loop": true})


func _dash_to(u: Unit, tg: Unit) -> void:
	var dir := (tg.position - u.position).normalized()
	u.vel = dir * maxf(720.0, u.speed() * 4.0)
	u.dash_t = 0.5
	u.invuln_t = maxf(u.invuln_t, 0.2)
	if u.hook:
		var cord := Color(u.dash_skill.get("arm", "#c8ccd8"))
		var target_pos := tg.position
		Drawer.spawn(layer_fx, Vector2.ZERO, 0.45, func(n: Drawer, k: float) -> void:
			if not is_instance_valid(u):
				return
			var a := u.position
			var b := target_pos
			n.draw_line(a, b, Color("#1b1420", 1.0 - k), 6.0, true)
			n.draw_line(a, b, Color(cord, 1.0 - k), 3.0, true)
			n.draw_circle(b, 6.0, Color("#1b1420", 1.0 - k))
			n.draw_circle(b, 4.0, Color("#c8ccd8", 1.0 - k)))


func _next_dash(u: Unit) -> void:
	if u.dash_left > 0:
		u.dash_left -= 1
		var es := enemies_of(u)
		es.shuffle()
		for e: Unit in es:
			if not u.dash_hit.has(e.get_instance_id()) or es.size() == 1:
				u.dash_hit.erase(e.get_instance_id())
				_dash_to(u, e)
				return
	u.dash_t = 0.12


func _end_dash(u: Unit) -> void:
	u.dash_t = 0.0
	u.hook = false
	u.vel = u.vel.normalized().rotated(randf_range(-0.5, 0.5)) * u.speed()


func _ghost(u: Unit) -> void:
	var tex := u.tex
	var s := u.radius() / BallArt.RADIUS_PX
	var c := u.color
	Drawer.spawn(layer_units, u.position, 0.25, func(n: Drawer, k: float) -> void:
		var size := Vector2(BallArt.SIZE, BallArt.SIZE) * s
		n.draw_texture_rect(tex, Rect2(-BallArt.CENTER * s, size), false, Color(c.r, c.g, c.b, 0.45 * (1.0 - k))))

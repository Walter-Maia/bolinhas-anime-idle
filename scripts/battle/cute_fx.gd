class_name CuteFx
extends Node2D
## Efeitos de combate no padrao "fofo" das bolinhas: formas redondas, contorno escuro grosso,
## brilho branco, halo suave e particulas em estrelinhas/bolhas. Tudo desenhado em codigo.
## O nome do efeito (ex.: "orb_spiral", "slash_red", "big_explosion") define o ARQUETIPO e a COR.

const INK := Color("#1b1420")
const OUT := 3.0

var kind := "burst"
var col := Color.WHITE
var size := 40.0
var t := 0.0
var dur := 0.6
var loop := false
var life := -1.0
var follow: Node2D = null
var follow_offset := Vector2.ZERO
var length := 300.0
var fade := 0.2
var rng := RandomNumberGenerator.new()
var parts: Array = []


# ------------------------------------------------------------------------------- mapeamento
static func color_of(n: String) -> Color:
	var table := [
		["fox", "#ff5a24"], ["blood", "#ff4a4a"], ["_red", "#ff4a4a"], ["red_", "#ff4a4a"], ["gold", "#ffd23c"], ["volt", "#ffd23c"],
		["pink", "#ff6ad5"], ["black", "#5a3a8a"], ["purple", "#b05cf5"], ["void", "#8a4cf0"], ["shadow", "#7a4ad0"],
		["curse", "#9a4ad8"], ["hex", "#b04ae0"], ["necro", "#9ad06a"], ["eclipse", "#6a4ad0"], ["dark", "#7a4ad0"],
		["green", "#6cd04a"], ["poison", "#8ae04a"], ["acid", "#a8e04a"], ["spore", "#b8d04a"], ["leaf", "#6cd04a"],
		["thorns", "#5ab84a"], ["vine", "#5ab84a"], ["root", "#7a9a3a"], ["cyan", "#2ff0ff"], ["emp", "#2ff0ff"],
		["glitch", "#2ff0ff"], ["hologram", "#5af0e0"], ["laser_grid", "#ff4a8a"], ["white", "#fffaf0"], ["holy", "#ffe680"],
		["smite", "#ffe680"], ["blessing", "#ffe680"], ["halo", "#ffe680"], ["sunburst", "#ffd23c"], ["feather", "#fff4e0"],
		["resurrection", "#ffe680"], ["ice", "#9be4ff"], ["frost", "#9be4ff"], ["freeze", "#9be4ff"], ["icicle", "#9be4ff"],
		["blizzard", "#bfeeff"], ["crystal", "#9be4ff"], ["water", "#4ab4ff"], ["wave_water", "#4ab4ff"], ["splash", "#4ab4ff"],
		["geyser", "#4ab4ff"], ["whirlpool", "#4ab4ff"], ["spiral", "#4aa8ff"], ["ki", "#5ad0ff"], ["blue", "#4ab4ff"],
		["fire", "#ff8a2a"], ["flame", "#ff8a2a"], ["meteor", "#ff7a2a"], ["burn", "#ff8a2a"], ["lightning", "#ffe066"],
		["zap", "#ffe066"], ["thunder", "#ffe066"], ["spark", "#ffe066"], ["electr", "#7cd8ff"], ["chain_l", "#7cd8ff"],
		["plasma", "#7cc8ff"], ["storm", "#7cc8ff"], ["quake", "#c8925a"], ["earth", "#c8925a"], ["boulder", "#b88a5a"],
		["ground", "#c8925a"], ["hammer", "#c8c8d0"], ["heal", "#7cf08c"], ["bloom", "#ff9ad0"], ["time_stop", "#a8d8ff"],
		["magic_circle", "#b8a0ff"], ["rune", "#b8a0ff"], ["portal", "#b080ff"], ["star_fall", "#ffe066"], ["arcane", "#c080ff"],
		["mana", "#c080ff"], ["missile", "#c080ff"], ["energy", "#5af0e0"], ["firework", "#ff6ad5"], ["confetti", "#ff6ad5"],
		["nuke", "#ffb03a"], ["explosion", "#ffb03a"], ["grenade", "#ffb03a"], ["bomb", "#9a9aa8"], ["smoke", "#d8d4e0"],
		["poof", "#f0ecf8"], ["summon", "#9a6ad0"], ["soul", "#c8f0ff"], ["ghost", "#f0f4ff"], ["wisp", "#a8f0ff"],
		["bat", "#6a4a8a"], ["snake", "#8ad04a"], ["skull", "#f0ece0"], ["butterfly", "#ff9ad0"], ["haste", "#a8f0ff"],
		["rage", "#ff5a4a"], ["shield", "#a8d8ff"], ["force", "#7cf0ff"], ["divine", "#ffe680"], ["parry", "#f0f4ff"],
		["slash", "#f0f4ff"], ["cleave", "#f0f4ff"], ["claw", "#f0f4ff"], ["dagger", "#e0e8f0"], ["thrust", "#f0f4ff"],
		["spear", "#e0e8f0"], ["whip", "#e8c090"], ["scythe", "#c8b0ff"], ["blunt", "#ffe680"], ["pow", "#ffd23c"],
		["crit", "#ffd23c"], ["impact", "#fffaf0"], ["hit", "#fff4c0"], ["arrow", "#e8d0a0"], ["bullet", "#ffe066"],
		["rocket", "#ff8a2a"], ["shotgun", "#ffe066"], ["disc", "#5ad0ff"], ["laser", "#ff6a6a"], ["orb", "#8ab8ff"],
	]
	for row in table:
		if n.find(row[0]) >= 0:
			return Color(row[1])
	return Color("#fff4c0")


static func kind_of(n: String) -> String:
	if n.begins_with("aura_") or n == "electrified" or n == "haste" or n == "spirit_flame":
		return "aura"
	if n.begins_with("st_"):
		return "status_" + n.substr(3)
	var rules := [
		["beam", "beam"], ["breath", "cone"], ["flamethrower", "cone"], ["water_jet", "cone"],
		["slash", "slash"], ["cleave", "slash"], ["reap", "slash"], ["claw", "slash"], ["flurry", "slash"], ["thrust", "slash"],
		["uppercut", "slash"], ["whip", "slash"], ["spear", "slash"], ["parry", "slash"],
		["shield", "shield"], ["force_field", "shield"], ["divine", "shield"],
		["black_hole", "swirl"], ["whirlpool", "swirl"], ["tornado", "swirl"], ["vortex", "swirl"], ["void_orb", "swirl"], ["eclipse", "swirl"],
		["time_stop", "rune"], ["magic_circle", "rune"], ["rune", "rune"], ["hex", "rune"], ["portal", "rune"], ["curse", "rune"],
		["lightning", "bolt"], ["thunderclap", "burst"], ["zap", "hit"], ["chain_lightning", "bolt"], ["spark", "hit"],
		["ice", "ice"], ["frost_nova", "ice"], ["freeze", "ice"], ["icicle", "ice"], ["crystal", "ice"],
		["heal", "heal"], ["bloom", "heal"], ["blessing", "heal"], ["resurrection", "heal"], ["life_steal", "heal"], ["soul_drain", "heal"],
		["quake", "rocks"], ["earth", "rocks"], ["boulder", "rocks"], ["ground_slam", "rocks"], ["hammer", "rocks"], ["thorns", "rocks"],
		["root", "rocks"], ["vine", "slash"], ["star_fall", "stars"], ["meteor", "stars"], ["firework", "stars"], ["sunburst", "rune"],
		["flame_pillar", "flame"], ["fire_ring", "flame"], ["shadow_flames", "flame"], ["fire_tornado", "flame"], ["holy_pillar", "pillar"],
		["smite", "pillar"], ["geyser", "pillar"], ["poof", "puff"], ["smoke", "puff"], ["summon", "puff"], ["warp", "puff"], ["blink", "puff"],
		["spawn", "puff"], ["soul_rise", "puff"], ["shatter", "burst"], ["poison", "bubbles"], ["acid", "bubbles"], ["spore", "bubbles"],
		["splash", "bubbles"], ["wave", "wave"], ["leaf", "swirl"], ["feather", "feathers"], ["necro", "ghosts"], ["ghost", "ghosts"],
		["skull", "ghosts"], ["bat", "ghosts"], ["wisp", "orb"], ["butterfly", "feathers"], ["snake", "slash"],
		["grasping", "rocks"], ["tendrils", "rocks"], ["glitch", "burst"], ["laser_grid", "rune"], ["hologram", "shield"],
		["orb", "orb"], ["plasma_ball", "orb"], ["ball_lightning", "orb"], ["water_orb", "orb"], ["energy_core", "orb"], ["spell_charge", "orb"],
		["charge", "orb"], ["fireball", "shot"], ["laser", "shot"], ["plasma_shot", "shot"], ["arrow", "shot"], ["bullet", "shot"],
		["rocket", "shot"], ["missile", "shot"], ["lance", "shot"], ["disc", "disc"], ["muzzle", "hit"],
		["explosion", "burst"], ["nuke", "burst"], ["pow", "burst"], ["implosion", "burst"], ["grenade", "burst"], ["emp", "burst"],
		["mana_burst", "burst"], ["crit", "burst"], ["impact", "burst"], ["blunt", "hit"], ["hit", "hit"], ["ricochet", "hit"],
	]
	for row in rules:
		if n.find(row[0]) >= 0:
			return row[1]
	return "burst"


static func base_size(n: String, k: String) -> float:
	match k:
		"burst":
			if n.find("big") >= 0 or n.find("nuke") >= 0 or n.find("dark_explosion") >= 0:
				return 120.0
			if n.find("small") >= 0 or n.find("crit") >= 0:
				return 70.0
			return 85.0
		"hit": return 26.0
		"orb": return 22.0
		"shot": return 16.0
		"disc": return 16.0
		"slash": return 48.0
		"aura": return 30.0
		"shield": return 34.0
		"swirl": return 62.0
		"rune": return 70.0
		"ice", "rocks", "flame", "pillar", "bubbles", "heal": return 52.0
		"bolt": return 70.0
		"stars": return 70.0
		"wave": return 90.0
		"puff": return 30.0
		"ghosts", "feathers": return 50.0
	return 40.0


static func make(n: String, opts: Dictionary = {}) -> CuteFx:
	var f := CuteFx.new()
	f.kind = opts.get("kind", kind_of(n))
	f.col = opts.get("color", color_of(n))
	var sc: Variant = opts.get("scale", 1.0)
	var s := float(sc.x) if sc is Vector2 else float(sc)
	# a escala antiga era pensada para sprites grandes; aqui normalizamos para o tamanho base
	f.size = base_size(n, f.kind) * clampf(s / 0.6, 0.45, 2.6)
	if opts.has("size"):
		f.size = float(opts.size)
	f.rotation = float(opts.get("rot", 0.0))
	f.loop = bool(opts.get("loop", f.kind in ["aura", "orb", "shot", "disc", "shield", "swirl"] or f.kind.begins_with("status_")))
	f.life = float(opts.get("life", -1.0))
	f.length = float(opts.get("length", 300.0))
	if opts.has("follow"):
		f.follow = opts.follow
		f.follow_offset = opts.get("offset", Vector2.ZERO)
		if f.kind == "aura" or f.kind == "shield" or f.kind.begins_with("status_"):
			f.follow_offset = Vector2.ZERO
	f.dur = {"burst": 0.55, "hit": 0.3, "slash": 0.32, "bolt": 0.5, "ice": 0.7, "rocks": 0.8, "heal": 0.9, "flame": 1.0,
		"pillar": 0.8, "stars": 0.9, "rune": 1.1, "puff": 0.5, "bubbles": 0.9, "wave": 0.8, "cone": 0.8, "beam": 0.7,
		"ghosts": 1.0, "feathers": 1.0}.get(f.kind, 1.0)
	if opts.has("dur"):
		f.dur = float(opts.dur)
	f.z_index = int(opts.get("z", 0))
	f.rng.seed = randi()
	if f.kind == "burst" and f.size >= 80.0:
		Snd.play("explosion", -7.0, 0.12, 0.15)
	f._init_parts()
	return f


static func spawn(parent: Node, n: String, pos: Vector2, opts: Dictionary = {}) -> CuteFx:
	var f := make(n, opts)
	parent.add_child(f)
	f.position = pos
	if f.follow:
		f.position = f.follow.position + f.follow_offset
	return f


func _init_parts() -> void:
	var n = {"burst": 9, "hit": 5, "ice": 7, "rocks": 7, "heal": 7, "flame": 9, "stars": 6, "puff": 6, "bubbles": 10,
		"ghosts": 4, "feathers": 8, "cone": 12, "pillar": 6, "aura": 7, "status_burning": 3, "status_poisoned": 4,
		"status_bleeding": 3, "status_stunned": 3, "status_sleep": 3, "status_charmed": 3}.get(kind, 0)
	for i in n:
		parts.append({"a": rng.randf() * TAU, "r": rng.randf_range(0.5, 1.0), "s": rng.randf_range(0.6, 1.2), "d": rng.randf_range(0.0, 0.25), "o": rng.randf()})


func is_dead() -> bool:
	return false


func _process(delta: float) -> void:
	t += delta
	if follow != null:
		if not is_instance_valid(follow) or (follow.has_method("is_dead") and follow.is_dead()) or not follow.visible:
			queue_free()
			return
		position = follow.position + follow_offset
	if life >= 0.0:
		if t >= life:
			queue_free()
			return
	elif not loop and t >= dur:
		queue_free()
		return
	queue_redraw()


# ------------------------------------------------------------------------------- utilitarios de desenho
func _alpha() -> float:
	if life >= 0.0 and t > life - fade:
		return clampf((life - t) / fade, 0.0, 1.0)
	return 1.0


func blob(p: Vector2, r: float, c: Color, a: float = 1.0, shine: bool = true) -> void:
	if r <= 0.5:
		return
	draw_circle(p, r + OUT, Color(INK, a))
	draw_circle(p, r, Color(c, a))
	draw_circle(p + Vector2(r * 0.12, r * 0.18), r * 0.7, Color(c.darkened(0.12), a * 0.6))
	if shine and r > 4.0:
		draw_circle(p + Vector2(-r * 0.35, -r * 0.38), r * 0.26, Color(1, 1, 1, 0.8 * a))


func glow(p: Vector2, r: float, c: Color, a: float = 1.0) -> void:
	for i in 4:
		draw_circle(p, r * (1.0 + i * 0.28), Color(c, 0.12 * a * (1.0 - i * 0.22)))


func star(p: Vector2, r: float, c: Color, a: float = 1.0, rot: float = 0.0) -> void:
	var pts := PackedVector2Array()
	var pts2 := PackedVector2Array()
	for i in 10:
		var an := rot - PI / 2.0 + TAU * i / 10.0
		var rr := r if i % 2 == 0 else r * 0.48
		pts.append(p + Vector2(cos(an), sin(an)) * (rr + OUT * (1.0 if i % 2 == 0 else 0.7)))
		pts2.append(p + Vector2(cos(an), sin(an)) * rr)
	draw_colored_polygon(pts, Color(INK, a))
	draw_colored_polygon(pts2, Color(c, a))


func sparkle(p: Vector2, r: float, a: float) -> void:
	var c := Color(1, 1, 0.92, a)
	draw_colored_polygon(PackedVector2Array([p + Vector2(0, -r), p + Vector2(r * 0.22, 0), p + Vector2(0, r), p + Vector2(-r * 0.22, 0)]), c)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-r, 0), p + Vector2(0, r * 0.22), p + Vector2(r, 0), p + Vector2(0, -r * 0.22)]), c)


func ring(p: Vector2, r: float, w: float, c: Color, a: float) -> void:
	if r <= 1.0:
		return
	draw_arc(p, r, 0, TAU, 48, Color(INK, a), w + OUT * 2.0, true)
	draw_arc(p, r, 0, TAU, 48, Color(c, a), w, true)


func capsule(a: Vector2, b: Vector2, w: float, c: Color, al: float = 1.0) -> void:
	draw_line(a, b, Color(INK, al), w + OUT * 2.0, true)
	draw_circle(a, w * 0.5 + OUT, Color(INK, al))
	draw_circle(b, w * 0.5 + OUT, Color(INK, al))
	draw_line(a, b, Color(c, al), w, true)
	draw_circle(a, w * 0.5, Color(c, al))
	draw_circle(b, w * 0.5, Color(c, al))


func ease_out(k: float) -> float:
	return 1.0 - pow(1.0 - clampf(k, 0.0, 1.0), 3.0)


func pop(k: float) -> float:
	# sobe rapido, passa um pouco e assenta (ease-out-back)
	var c1 := 1.70158
	var x := clampf(k, 0.0, 1.0) - 1.0
	return 1.0 + (c1 + 1.0) * x * x * x + c1 * x * x


# ------------------------------------------------------------------------------- desenho
func _draw() -> void:
	var k := t / dur if not loop else fposmod(t, dur) / dur
	var a := _alpha()
	var c := col
	var light := c.lightened(0.45)
	match kind:
		"burst", "hit":
			var r := size * ease_out(k * 1.4)
			var fa := (1.0 - clampf((k - 0.55) / 0.45, 0.0, 1.0)) * a
			glow(Vector2.ZERO, r * 0.8, c, fa)
			ring(Vector2.ZERO, r, maxf(2.0, size * 0.09 * (1.0 - k)), light, fa)
			blob(Vector2.ZERO, size * 0.42 * (1.0 - ease_out(k)) + 0.1, c.lightened(0.25), fa)
			for p in parts:
				var pk := clampf((k - p.d) / (1.0 - p.d), 0.0, 1.0)
				var pos = Vector2(cos(p.a), sin(p.a)) * size * 1.05 * ease_out(pk) * p.r
				var pr = size * 0.13 * p.s * (1.0 - pk)
				if p.o > 0.6:
					star(pos, pr * 1.4, Color("#ffe680"), fa, p.a + t * 4.0)
				else:
					blob(pos, pr, c, fa)
		"orb":
			var bob := sin(t * 6.0) * 0.06
			glow(Vector2.ZERO, size * 1.15, c, a)
			blob(Vector2.ZERO, size * (1.0 + bob), c, a)
			draw_arc(Vector2.ZERO, size * 0.55, t * 9.0, t * 9.0 + PI * 1.2, 16, Color(light, a), size * 0.18, true)
			draw_arc(Vector2.ZERO, size * 0.28, -t * 7.0, -t * 7.0 + PI, 12, Color(1, 1, 1, 0.8 * a), size * 0.1, true)
			for i in 3:
				var an := t * 5.0 + TAU * i / 3.0
				blob(Vector2(cos(an), sin(an) * 0.6) * size * 1.45, size * 0.16, light, a, false)
		"shot":
			var L := size * 2.4
			glow(Vector2(-L * 0.2, 0), size, c, a)
			for i in 4:
				blob(Vector2(-L * 0.55 - i * size * 0.65, sin(t * 20.0 + i) * 2.0), size * 0.32 * (1.0 - i * 0.2), c, a * (0.9 - i * 0.18), false)
			capsule(Vector2(-L * 0.4, 0), Vector2(L * 0.25, 0), size * 0.9, c, a)
			draw_line(Vector2(-L * 0.25, -size * 0.18), Vector2(L * 0.2, -size * 0.18), Color(1, 1, 1, 0.75 * a), size * 0.2, true)
		"disc":
			var rot := t * 18.0
			glow(Vector2.ZERO, size * 1.1, c, a)
			var pts := PackedVector2Array()
			var pts2 := PackedVector2Array()
			for i in 8:
				var an := rot + TAU * i / 8.0
				var rr := size * (1.0 if i % 2 == 0 else 0.55)
				pts.append(Vector2(cos(an), sin(an)) * (rr + OUT))
				pts2.append(Vector2(cos(an), sin(an)) * rr)
			draw_colored_polygon(pts, Color(INK, a))
			draw_colored_polygon(pts2, Color(c, a))
			blob(Vector2.ZERO, size * 0.28, light, a)
		"slash":
			var sweep := ease_out(k * 1.6)
			var fa2 := (1.0 - clampf((k - 0.5) / 0.5, 0.0, 1.0)) * a
			var a0 := -PI * 0.75
			var a1 := a0 + PI * 1.3 * sweep
			var w := size * 0.28
			draw_arc(Vector2.ZERO, size, a0, a1, 24, Color(INK, fa2), w + OUT * 2.0, true)
			draw_arc(Vector2.ZERO, size, a0, a1, 24, Color(c, fa2), w, true)
			draw_arc(Vector2.ZERO, size - w * 0.2, a0, a1, 24, Color(1, 1, 1, 0.85 * fa2), w * 0.35, true)
			sparkle(Vector2(cos(a1), sin(a1)) * size, size * 0.3, fa2)
		"beam":
			var L2 := length
			var w2 := size * (1.0 + sin(t * 30.0) * 0.08)
			var grow := ease_out(k * 3.0)
			var fa3 := a
			if k > 0.75:
				fa3 *= (1.0 - (k - 0.75) / 0.25)
				w2 *= 1.0 - (k - 0.75) / 0.25 * 0.8
			var end := Vector2(L2 * grow, 0)
			for i in 3:
				draw_line(Vector2.ZERO, end, Color(c, 0.12 * fa3), w2 * (2.2 - i * 0.4), true)
			capsule(Vector2.ZERO, end, w2, c, fa3)
			capsule(Vector2.ZERO, end, w2 * 0.45, light.lightened(0.4), fa3)
			blob(Vector2.ZERO, w2 * 0.85, c, fa3)
			for i in 6:
				var bx := fposmod(t * 520.0 + i * L2 / 6.0, maxf(1.0, end.x))
				draw_circle(Vector2(bx, sin(i * 2.0 + t * 12.0) * w2 * 0.3), w2 * 0.12, Color(1, 1, 1, 0.8 * fa3))
		"cone":
			for p in parts:
				var pk2 := fposmod(k + p.o, 1.0)
				var dist := length * pk2
				var spread = (p.a / TAU - 0.5) * 0.9 * pk2
				var pos2 := Vector2(dist, dist * spread)
				var pr2 = size * 0.18 + size * 0.45 * pk2 * p.s
				var fa4 := a * (1.0 - pk2 * 0.7)
				blob(pos2, pr2, c.lerp(light, 1.0 - pk2), fa4)
		"aura":
			var pulse := 0.5 + 0.5 * sin(t * 5.0)
			glow(Vector2.ZERO, size * 1.15, c, a)
			ring(Vector2.ZERO, size * (1.05 + pulse * 0.08), 3.0, light, a * 0.9)
			for p in parts:
				var pk3 := fposmod(t * 0.9 + p.o, 1.0)
				var an2 = p.a + t * 1.4
				var pos3 := Vector2(cos(an2), sin(an2)) * size * (1.0 + pk3 * 0.25) + Vector2(0, -pk3 * size * 0.6)
				var fr = size * 0.17 * p.s * (1.0 - pk3)
				# chama-gota
				var tip := pos3 + Vector2(0, -fr * 2.2)
				draw_colored_polygon(PackedVector2Array([pos3 + Vector2(-fr - 2, 0), tip + Vector2(0, -2), pos3 + Vector2(fr + 2, 0)]), Color(INK, a * (1.0 - pk3)))
				draw_circle(pos3, fr + 2, Color(INK, a * (1.0 - pk3)))
				draw_colored_polygon(PackedVector2Array([pos3 + Vector2(-fr, 0), tip, pos3 + Vector2(fr, 0)]), Color(c, a * (1.0 - pk3)))
				draw_circle(pos3, fr, Color(c, a * (1.0 - pk3)))
				draw_circle(pos3 + Vector2(-fr * 0.3, -fr * 0.3), fr * 0.35, Color(light, a * (1.0 - pk3)))
		"shield":
			var wob := sin(t * 4.0) * 0.03
			draw_circle(Vector2.ZERO, size * (1.0 + wob), Color(c, 0.22 * a))
			draw_arc(Vector2.ZERO, size * (1.0 + wob), 0, TAU, 48, Color(INK, 0.8 * a), 5.0, true)
			draw_arc(Vector2.ZERO, size * (1.0 + wob), 0, TAU, 48, Color(light, a), 2.5, true)
			draw_arc(Vector2.ZERO, size * 0.78, PI * 1.1, PI * 1.45, 12, Color(1, 1, 1, 0.85 * a), 4.0, true)
			sparkle(Vector2(size * 0.6, -size * 0.6), 5.0 + 2.0 * sin(t * 6.0), a)
		"swirl":
			var sp := t * 5.0
			glow(Vector2.ZERO, size * 0.9, c, a)
			for arm in 4:
				var prev := Vector2.ZERO
				for j in 14:
					var u := j / 13.0
					var an3 := sp + TAU * arm / 4.0 + u * 3.2
					var p3 := Vector2(cos(an3), sin(an3) * 0.75) * size * u
					if j > 0:
						draw_line(prev, p3, Color(INK, a), 7.0 * (1.0 - u * 0.5) + 2.0, true)
						draw_line(prev, p3, Color(c.lerp(light, u), a), 7.0 * (1.0 - u * 0.5), true)
					prev = p3
			blob(Vector2.ZERO, size * 0.2, c.darkened(0.4), a)
		"rune":
			var sc2 := pop(k * 2.0) if not loop else 1.0
			var fa5 := a * (1.0 - clampf((k - 0.7) / 0.3, 0.0, 1.0)) if not loop else a
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.55))
			ring(Vector2.ZERO, size * sc2, 3.0, c, fa5)
			ring(Vector2.ZERO, size * 0.72 * sc2, 2.0, light, fa5)
			var pts3 := PackedVector2Array()
			for i in 6:
				var an4 := t * 1.5 + TAU * i / 6.0
				pts3.append(Vector2(cos(an4), sin(an4)) * size * 0.72 * sc2)
			for i in 6:
				draw_line(pts3[i], pts3[(i + 2) % 6], Color(c, fa5), 2.5, true)
			for i in 6:
				blob(pts3[i], 4.0, light, fa5, false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		"bolt":
			var fa6 := a * (1.0 - clampf((k - 0.4) / 0.6, 0.0, 1.0))
			var pts4 := PackedVector2Array([Vector2(0, -size * 2.2)])
			for i in 5:
				pts4.append(Vector2((10.0 if i % 2 == 0 else -10.0) * size / 70.0 * (1.0 + rng.randf() * 0.4), -size * 2.2 + size * 2.2 * (i + 1) / 5.0))
			for i in pts4.size() - 1:
				draw_line(pts4[i], pts4[i + 1], Color(INK, fa6), 13.0, true)
			for i in pts4.size() - 1:
				draw_line(pts4[i], pts4[i + 1], Color(c, fa6), 7.0, true)
				draw_line(pts4[i], pts4[i + 1], Color(1, 1, 1, fa6), 2.5, true)
			ring(Vector2.ZERO, size * 0.6 * ease_out(k * 2.0), 3.0, light, fa6)
			for i in 4:
				star(Vector2(cos(i * 1.6), sin(i * 1.6)) * size * 0.55 * ease_out(k * 2.0), 5.0 * (1.0 - k), Color("#ffe680"), fa6)
		"ice":
			var fa7 := a * (1.0 - clampf((k - 0.6) / 0.4, 0.0, 1.0))
			for p in parts:
				var pk4 := clampf((k - p.d) * 3.0, 0.0, 1.0)
				var base = Vector2(cos(p.a), sin(p.a) * 0.5) * size * 0.6 * p.r
				var h = size * 0.7 * p.s * pop(pk4)
				var shard := PackedVector2Array([base + Vector2(-h * 0.25, 0), base + Vector2(0, -h), base + Vector2(h * 0.25, 0), base + Vector2(0, h * 0.18)])
				var big := PackedVector2Array()
				for q in shard:
					big.append(base + (q - base) * 1.0 + (q - base).normalized() * OUT)
				draw_colored_polygon(big, Color(INK, fa7))
				draw_colored_polygon(shard, Color(c, fa7))
				draw_line(base + Vector2(-h * 0.08, -h * 0.1), base + Vector2(0, -h * 0.8), Color(1, 1, 1, 0.8 * fa7), 2.0)
		"rocks":
			var fa8 := a * (1.0 - clampf((k - 0.65) / 0.35, 0.0, 1.0))
			for p in parts:
				var pk5 := clampf((k - p.d) * 2.5, 0.0, 1.0)
				var pos4 = Vector2(cos(p.a), sin(p.a) * 0.5) * size * 0.8 * p.r + Vector2(0, -size * 0.6 * sin(pk5 * PI) * p.s)
				var rs = size * 0.17 * p.s
				draw_rect(Rect2(pos4 - Vector2(rs, rs) - Vector2(OUT, OUT), Vector2(rs, rs) * 2.0 + Vector2(OUT, OUT) * 2.0), Color(INK, fa8))
				draw_rect(Rect2(pos4 - Vector2(rs, rs), Vector2(rs, rs) * 2.0), Color(c, fa8))
				draw_rect(Rect2(pos4 - Vector2(rs, rs) + Vector2(2, 2), Vector2(rs * 0.7, rs * 0.5)), Color(light, fa8))
			ring(Vector2.ZERO, size * ease_out(k * 1.5), 3.0, c.lightened(0.2), fa8 * 0.7)
		"heal":
			ring(Vector2.ZERO, size * 0.8 * ease_out(k * 2.0), 3.0, c, a * (1.0 - k))
			for p in parts:
				var pk6 := clampf((k - p.d) / 0.75, 0.0, 1.0)
				var pos5 := Vector2(cos(p.a) * size * 0.7 * p.r, size * 0.3 - size * 1.3 * pk6)
				var cs = 6.0 * p.s
				var fa9 := a * sin(pk6 * PI)
				draw_rect(Rect2(pos5 - Vector2(cs * 0.35 + 2, cs + 2), Vector2(cs * 0.7 + 4, cs * 2 + 4)), Color(INK, fa9))
				draw_rect(Rect2(pos5 - Vector2(cs + 2, cs * 0.35 + 2), Vector2(cs * 2 + 4, cs * 0.7 + 4)), Color(INK, fa9))
				draw_rect(Rect2(pos5 - Vector2(cs * 0.35, cs), Vector2(cs * 0.7, cs * 2)), Color(c, fa9))
				draw_rect(Rect2(pos5 - Vector2(cs, cs * 0.35), Vector2(cs * 2, cs * 0.7)), Color(c, fa9))
		"flame", "pillar":
			var fa10 := a * (1.0 - clampf((k - 0.7) / 0.3, 0.0, 1.0))
			if kind == "pillar":
				var hgt := size * 2.6 * ease_out(k * 2.5)
				draw_rect(Rect2(-size * 0.4 - OUT, -hgt, size * 0.8 + OUT * 2, hgt), Color(INK, fa10 * 0.9))
				draw_rect(Rect2(-size * 0.4, -hgt, size * 0.8, hgt), Color(c, fa10 * 0.85))
				draw_rect(Rect2(-size * 0.15, -hgt, size * 0.3, hgt), Color(1, 1, 1, 0.7 * fa10))
			for p in parts:
				var pk7 := fposmod(k * 1.4 + p.o, 1.0)
				var pos6 := Vector2(cos(p.a) * size * 0.55 * p.r, -size * 1.4 * pk7)
				var fr2 = size * 0.22 * p.s * (1.0 - pk7 * 0.7)
				blob(pos6, fr2, c.lerp(Color("#ffe680"), pk7), fa10 * (1.0 - pk7 * 0.5))
		"stars":
			for p in parts:
				var pk8 := clampf((k - p.d) / 0.6, 0.0, 1.0)
				var target = Vector2(cos(p.a), sin(p.a) * 0.5) * size * 0.6 * p.r
				var pos7 = target + Vector2(-size * 0.8, -size * 2.4) * (1.0 - pk8)
				var fa11 := a * (1.0 if pk8 < 1.0 else 0.0)
				star(pos7, 9.0 * p.s, c, fa11, t * 6.0)
				if pk8 >= 1.0 and k - p.d < 0.85:
					ring(target, 14.0 * p.s * ease_out((k - p.d - 0.6) * 4.0), 2.0, light, a * 0.8)
		"puff":
			for p in parts:
				var pk9 := ease_out(k * 1.3)
				var pos8 = Vector2(cos(p.a), sin(p.a) * 0.7) * size * 0.8 * pk9 * p.r
				blob(pos8, size * 0.4 * p.s * (1.0 - k * 0.8), c, a * (1.0 - k), false)
		"bubbles":
			for p in parts:
				var pk10 := clampf((k - p.d) / 0.75, 0.0, 1.0)
				var pos9 := Vector2(cos(p.a) * size * 0.8 * p.r, sin(p.a) * size * 0.3 - size * 0.9 * pk10)
				var br = 4.0 + 7.0 * p.s
				var fa12 := a * sin(pk10 * PI)
				draw_circle(pos9, br + OUT, Color(INK, fa12))
				draw_circle(pos9, br, Color(c, fa12 * 0.8))
				draw_circle(pos9 + Vector2(-br * 0.35, -br * 0.35), br * 0.3, Color(1, 1, 1, fa12))
		"wave":
			var fa13 := a * (1.0 - clampf((k - 0.6) / 0.4, 0.0, 1.0))
			var wr := size * ease_out(k * 1.3)
			draw_arc(Vector2.ZERO, wr, -PI * 0.45, PI * 0.45, 24, Color(INK, fa13), 16.0, true)
			draw_arc(Vector2.ZERO, wr, -PI * 0.45, PI * 0.45, 24, Color(c, fa13), 10.0, true)
			draw_arc(Vector2.ZERO, wr - 3.0, -PI * 0.4, PI * 0.4, 24, Color(1, 1, 1, 0.8 * fa13), 3.0, true)
			for i in 4:
				var an5 := -PI * 0.4 + PI * 0.8 * i / 3.0
				blob(Vector2(cos(an5), sin(an5)) * (wr + 10.0), 4.0, light, fa13, false)
		"ghosts", "feathers":
			for p in parts:
				var pk11 := clampf((k - p.d) / 0.75, 0.0, 1.0)
				var pos10 = Vector2(cos(p.a + pk11 * 2.0), sin(p.a + pk11 * 2.0) * 0.6) * size * (0.4 + pk11 * 0.8) * p.r + Vector2(0, -pk11 * 20.0)
				var fa14 := a * sin(pk11 * PI)
				if kind == "ghosts":
					blob(pos10, 8.0 * p.s, c, fa14)
					draw_rect(Rect2(pos10 + Vector2(-8.0 * p.s, 0), Vector2(16.0 * p.s, 7.0 * p.s)), Color(c, fa14))
				else:
					draw_set_transform(pos10, p.a + t * 3.0, Vector2.ONE)
					draw_colored_polygon(PackedVector2Array([Vector2(-11.7, 0), Vector2(0, -5.2), Vector2(11.7, 0), Vector2(0, 5.2)]), Color(INK, fa14))
					draw_colored_polygon(PackedVector2Array([Vector2(-8, 0), Vector2(0, -3), Vector2(8, 0), Vector2(0, 3)]), Color(c, fa14))
					draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_:
			_draw_status(k, a)


func _draw_status(_k: float, a: float) -> void:
	var r := size
	match kind:
		"status_burning":
			for p in parts:
				var pk := fposmod(t * 1.2 + p.o, 1.0)
				blob(Vector2(cos(p.a) * r * 0.6, r * 0.4 - pk * r * 1.2), 5.0 * (1.0 - pk) + 1.0, Color("#ff8a2a").lerp(Color("#ffe066"), pk), a)
		"status_frozen":
			draw_rect(Rect2(-r - 2, -r - 2, r * 2 + 4, r * 2 + 4), Color(INK, 0.5 * a))
			draw_rect(Rect2(-r, -r, r * 2, r * 2), Color(0.6, 0.88, 1.0, 0.45 * a))
			draw_line(Vector2(-r * 0.7, -r * 0.5), Vector2(-r * 0.2, -r * 0.9), Color(1, 1, 1, 0.8 * a), 3.0)
		"status_stunned", "status_confused":
			for i in 3:
				var an := t * 4.0 + TAU * i / 3.0
				star(Vector2(cos(an) * r * 0.7, -r * 1.05 + sin(an) * r * 0.2), 5.0, Color("#ffe066"), a, t * 3.0)
		"status_slowed":
			draw_arc(Vector2(0, -r * 1.1), 6.0, t * 3.0, t * 3.0 + PI * 1.5, 12, Color(INK, a), 5.0)
			draw_arc(Vector2(0, -r * 1.1), 6.0, t * 3.0, t * 3.0 + PI * 1.5, 12, Color("#a8c8ff", a), 2.5)
		"status_poisoned":
			for p in parts:
				var pk2 := fposmod(t * 0.8 + p.o, 1.0)
				var br = 3.0 + 3.0 * p.s
				var pos := Vector2(cos(p.a) * r * 0.7, r * 0.3 - pk2 * r * 1.3)
				draw_circle(pos, br + 2.0, Color(INK, a * (1.0 - pk2)))
				draw_circle(pos, br, Color("#8ae04a", a * (1.0 - pk2)))
		"status_bleeding":
			for p in parts:
				var pk3 := fposmod(t * 1.1 + p.o, 1.0)
				blob(Vector2(cos(p.a) * r * 0.5, -r * 0.2 + pk3 * r * 0.9), 3.0, Color("#e83a3a"), a * (1.0 - pk3), false)
		"status_sleep":
			var f := UI.font()
			for i in 3:
				var pk4 := fposmod(t * 0.6 + i / 3.0, 1.0)
				var pos2 := Vector2(r * 0.5 + pk4 * 10.0, -r * 0.9 - pk4 * 22.0)
				draw_string_outline(f, pos2, "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 14 + int(pk4 * 8), 5, Color(INK, a * (1.0 - pk4)))
				draw_string(f, pos2, "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 14 + int(pk4 * 8), Color(0.8, 0.9, 1, a * (1.0 - pk4)))
		"status_cursed", "status_charmed":
			var cc := Color("#b05cf5") if kind == "status_cursed" else Color("#ff6ad5")
			for i in 2:
				var an2 := t * 2.0 + PI * i
				blob(Vector2(cos(an2) * r * 0.8, -r * 0.9 + sin(an2) * 4.0), 5.0, cc, a)
		"status_petrified":
			draw_circle(Vector2.ZERO, r, Color(0.5, 0.5, 0.55, 0.55 * a))
		_:
			pass

class_name WeaponArt
## Desenha as armas que giram em volta das bolinhas, no mesmo padrao fofo dos efeitos
## (contorno escuro grosso, cor chapada, brilho branco). A arma aponta para fora (angulo radial).

const INK := Color("#1b1420")


static func default_for(def: Dictionary) -> Dictionary:
	var acc: Array = def.get("look", {}).get("acc", def.get("look", {}).get("extras", []))
	var col := "#d8dde8"
	var kind := "sword"
	if acc.has("card"):
		kind = "card"
	elif acc.has("hammer"):
		kind = "hammer"
	elif acc.has("chains"):
		kind = "chain"
	else:
		match str(def.get("role", "Atacante")):
			"Tanque":
				kind = "shield"
			"Velocista":
				kind = "kunai"
			"Suporte":
				kind = "orb"
				col = def.get("color", "#a8e2ff")
	return {"kind": kind, "color": col, "count": 1, "orbit": 1.45, "spin": 4.0, "power": 0.6}


static func poly(ci: CanvasItem, pts: PackedVector2Array, c: Color, a: float, out: float = 2.5) -> void:
	# contorno: desenha uma versao "inflada" atras
	var center := Vector2.ZERO
	for p in pts:
		center += p
	center /= pts.size()
	var big := PackedVector2Array()
	for p in pts:
		big.append(p + (p - center).normalized() * out)
	ci.draw_colored_polygon(big, Color(INK, a))
	ci.draw_colored_polygon(pts, Color(c, a))


static func draw(ci: CanvasItem, kind: String, col: Color, pos: Vector2, ang: float, s: float, a: float = 1.0) -> void:
	ci.draw_set_transform(pos, ang, Vector2(s, s))
	var c := col
	var hi := Color(1, 1, 1, 0.75 * a)
	var wood := Color("#8e5c2c")
	var gold := Color("#ffd23c")
	match kind:
		"sword", "katana", "greatsword":
			var L := 20.0 if kind == "sword" else (24.0 if kind == "katana" else 26.0)
			var W := 3.2 if kind == "katana" else (6.0 if kind == "greatsword" else 4.2)
			poly(ci, PackedVector2Array([Vector2(-2, -W * 0.5), Vector2(L, -W * 0.5), Vector2(L + 4, 0), Vector2(L, W * 0.5), Vector2(-2, W * 0.5)]), c, a)
			ci.draw_line(Vector2(0, -W * 0.15), Vector2(L, -W * 0.15), hi, 1.2)
			poly(ci, PackedVector2Array([Vector2(-3, -6), Vector2(-1, -6), Vector2(-1, 6), Vector2(-3, 6)]), gold if kind != "katana" else Color("#3a2a20"), a, 2.0)
			poly(ci, PackedVector2Array([Vector2(-11, -2), Vector2(-3, -2), Vector2(-3, 2), Vector2(-11, 2)]), Color("#3a2a40") if kind == "katana" else wood, a, 2.0)
		"dagger", "kunai":
			poly(ci, PackedVector2Array([Vector2(0, -3), Vector2(11, 0), Vector2(0, 3)]), c, a)
			poly(ci, PackedVector2Array([Vector2(-8, -1.5), Vector2(0, -1.5), Vector2(0, 1.5), Vector2(-8, 1.5)]), Color("#3a3240"), a, 2.0)
			if kind == "kunai":
				ci.draw_arc(Vector2(-11, 0), 3.0, 0, TAU, 12, Color(INK, a), 3.5)
				ci.draw_arc(Vector2(-11, 0), 3.0, 0, TAU, 12, Color(c, a), 1.5)
		"shuriken", "gear":
			var pts := PackedVector2Array()
			var n := 4 if kind == "shuriken" else 8
			for i in n * 2:
				var an := TAU * i / (n * 2.0)
				pts.append(Vector2(cos(an), sin(an)) * (9.0 if i % 2 == 0 else (3.5 if kind == "shuriken" else 7.0)))
			poly(ci, pts, c, a)
			ci.draw_circle(Vector2.ZERO, 2.0, Color(INK, a))
		"spear", "trident":
			ci.draw_line(Vector2(-14, 0), Vector2(14, 0), Color(INK, a), 5.0)
			ci.draw_line(Vector2(-14, 0), Vector2(14, 0), Color(wood, a), 2.5)
			poly(ci, PackedVector2Array([Vector2(13, -4), Vector2(24, 0), Vector2(13, 4)]), c, a)
			if kind == "trident":
				poly(ci, PackedVector2Array([Vector2(12, -8), Vector2(20, -7), Vector2(13, -4)]), c, a, 2.0)
				poly(ci, PackedVector2Array([Vector2(12, 8), Vector2(20, 7), Vector2(13, 4)]), c, a, 2.0)
		"scythe":
			ci.draw_line(Vector2(-14, 0), Vector2(14, 0), Color(INK, a), 5.0)
			ci.draw_line(Vector2(-14, 0), Vector2(14, 0), Color(wood.darkened(0.3), a), 2.5)
			poly(ci, PackedVector2Array([Vector2(12, -2), Vector2(14, 2), Vector2(4, 16), Vector2(-4, 18), Vector2(6, 10)]), c, a)
		"hammer", "axe":
			ci.draw_line(Vector2(-12, 0), Vector2(12, 0), Color(INK, a), 5.0)
			ci.draw_line(Vector2(-12, 0), Vector2(12, 0), Color(wood, a), 2.5)
			if kind == "hammer":
				poly(ci, PackedVector2Array([Vector2(8, -8), Vector2(18, -8), Vector2(18, 8), Vector2(8, 8)]), c, a)
			else:
				poly(ci, PackedVector2Array([Vector2(8, -2), Vector2(14, -11), Vector2(19, -3), Vector2(19, 4), Vector2(14, 11), Vector2(8, 2)]), c, a)
			ci.draw_line(Vector2(10, -5), Vector2(10, 5), hi, 1.2)
		"staff", "wand":
			ci.draw_line(Vector2(-14, 0), Vector2(12, 0), Color(INK, a), 5.0)
			ci.draw_line(Vector2(-14, 0), Vector2(12, 0), Color(wood if kind == "staff" else Color("#f4f4fa"), a), 2.5)
			ci.draw_circle(Vector2(15, 0), 5.5, Color(INK, a))
			ci.draw_circle(Vector2(15, 0), 3.8, Color(c, a))
			ci.draw_circle(Vector2(14, -1.4), 1.2, hi)
		"bow":
			ci.draw_arc(Vector2(0, 0), 12.0, -1.2, 1.2, 16, Color(INK, a), 5.0)
			ci.draw_arc(Vector2(0, 0), 12.0, -1.2, 1.2, 16, Color(c, a), 2.5)
			ci.draw_line(Vector2(cos(-1.2), sin(-1.2)) * 12.0, Vector2(cos(1.2), sin(1.2)) * 12.0, Color(1, 1, 1, 0.9 * a), 1.0)
		"gun", "rifle":
			var L2 := 12.0 if kind == "gun" else 20.0
			poly(ci, PackedVector2Array([Vector2(-4, -3), Vector2(L2, -3), Vector2(L2, 1), Vector2(-4, 1)]), c, a)
			poly(ci, PackedVector2Array([Vector2(-4, 0), Vector2(1, 0), Vector2(-1, 7), Vector2(-5, 7)]), c.darkened(0.3), a, 2.0)
		"fan":
			var pts2 := PackedVector2Array([Vector2.ZERO])
			for i in 7:
				var an2 := -0.8 + 1.6 * i / 6.0
				pts2.append(Vector2(cos(an2), sin(an2)) * 15.0)
			poly(ci, pts2, c, a)
			for i in 4:
				var an3 := -0.6 + 1.2 * i / 3.0
				ci.draw_line(Vector2.ZERO, Vector2(cos(an3), sin(an3)) * 14.0, Color(INK, 0.5 * a), 1.0)
		"card", "book":
			var w := 8.0 if kind == "card" else 11.0
			poly(ci, PackedVector2Array([Vector2(-w, -6), Vector2(w, -6), Vector2(w, 6), Vector2(-w, 6)]), Color("#f8f4ec") if kind == "card" else c, a)
			if kind == "card":
				ci.draw_rect(Rect2(-w + 2, -4, w * 2 - 4, 8), Color(c, a))
			else:
				ci.draw_line(Vector2(0, -6), Vector2(0, 6), Color(INK, a), 1.5)
		"chain":
			for i in 5:
				ci.draw_arc(Vector2(-10 + i * 6.0, 0), 3.2, 0, TAU, 10, Color(INK, a), 3.6)
				ci.draw_arc(Vector2(-10 + i * 6.0, 0), 3.2, 0, TAU, 10, Color(c, a), 1.8)
			poly(ci, PackedVector2Array([Vector2(18, -4), Vector2(26, 0), Vector2(18, 4)]), c, a, 2.0)
		"orb", "bomb":
			ci.draw_circle(Vector2.ZERO, 8.5, Color(INK, a))
			ci.draw_circle(Vector2.ZERO, 6.5, Color(c if kind == "orb" else Color("#3a3a48"), a))
			ci.draw_circle(Vector2(-2.2, -2.2), 2.0, hi)
			if kind == "bomb":
				ci.draw_line(Vector2(5, -5), Vector2(9, -9), Color(INK, a), 2.5)
				ci.draw_circle(Vector2(10, -10), 2.2, Color("#ffb03a", a))
		"shield":
			poly(ci, PackedVector2Array([Vector2(-6, -10), Vector2(6, -10), Vector2(8, 0), Vector2(0, 11), Vector2(-8, 0)]), c, a)
			poly(ci, PackedVector2Array([Vector2(-2, -6), Vector2(2, -6), Vector2(3, 0), Vector2(0, 5), Vector2(-3, 0)]), gold, a, 1.0)
		"fist":
			ci.draw_circle(Vector2(6, 0), 8.0, Color(INK, a))
			ci.draw_circle(Vector2(6, 0), 6.0, Color(c, a))
			ci.draw_circle(Vector2(4, -2), 2.0, hi)
			ci.draw_rect(Rect2(-6, -4, 8, 8), Color(INK, a))
			ci.draw_rect(Rect2(-5, -2.5, 7, 5), Color(c.darkened(0.2), a))
		"claw":
			for i in 3:
				var off := -5.0 + i * 5.0
				poly(ci, PackedVector2Array([Vector2(0, off - 1.5), Vector2(14, off), Vector2(0, off + 1.5)]), c, a, 1.8)
		"whip":
			var prev := Vector2(-6, 0)
			for i in 7:
				var p := Vector2(i * 4.0, sin(i * 1.1) * 3.0)
				ci.draw_line(prev, p, Color(INK, a), 4.5)
				ci.draw_line(prev, p, Color(c, a), 2.0)
				prev = p
		"tonfa", "bat":
			poly(ci, PackedVector2Array([Vector2(-10, -2.5), Vector2(14, -3.5), Vector2(14, 3.5), Vector2(-10, 2.5)]), c, a)
			if kind == "tonfa":
				poly(ci, PackedVector2Array([Vector2(-2, 2), Vector2(1, 2), Vector2(1, 9), Vector2(-2, 9)]), c.darkened(0.25), a, 2.0)
		"chainsaw":
			poly(ci, PackedVector2Array([Vector2(-6, -5), Vector2(18, -4), Vector2(21, 0), Vector2(18, 4), Vector2(-6, 5)]), Color("#c8ccd4"), a)
			for i in 6:
				ci.draw_line(Vector2(-3 + i * 4.0, -5), Vector2(-1 + i * 4.0, -7), Color(INK, a), 2.0)
			poly(ci, PackedVector2Array([Vector2(-12, -5), Vector2(-6, -5), Vector2(-6, 5), Vector2(-12, 5)]), Color("#ff8a2a"), a, 2.0)
		"umbrella":
			ci.draw_line(Vector2(-12, 0), Vector2(10, 0), Color(INK, a), 4.0)
			var pts3 := PackedVector2Array([Vector2(8, -12), Vector2(14, -7), Vector2(16, 0), Vector2(14, 7), Vector2(8, 12)])
			poly(ci, pts3, c, a)
		"guitar":
			ci.draw_circle(Vector2(-4, 0), 7.5, Color(INK, a))
			ci.draw_circle(Vector2(-4, 0), 5.5, Color(c, a))
			ci.draw_line(Vector2(0, 0), Vector2(18, 0), Color(INK, a), 4.0)
			ci.draw_line(Vector2(0, 0), Vector2(18, 0), Color(wood, a), 2.0)
		"flag":
			ci.draw_line(Vector2(-12, 0), Vector2(14, 0), Color(INK, a), 4.0)
			poly(ci, PackedVector2Array([Vector2(6, 0), Vector2(14, 0), Vector2(14, 10), Vector2(6, 9)]), c, a, 2.0)
		"needle":
			ci.draw_line(Vector2(-10, 0), Vector2(14, 0), Color(INK, a), 3.5)
			ci.draw_line(Vector2(-10, 0), Vector2(14, 0), Color(c, a), 1.5)
			ci.draw_circle(Vector2(-10, 0), 2.6, Color(INK, a))
		"feather":
			poly(ci, PackedVector2Array([Vector2(-8, 0), Vector2(4, -5), Vector2(14, 0), Vector2(4, 5)]), c, a)
			ci.draw_line(Vector2(-10, 0), Vector2(13, 0), Color(INK, 0.6 * a), 1.0)
		"rose":
			ci.draw_line(Vector2(-12, 0), Vector2(6, 0), Color(INK, a), 3.5)
			ci.draw_line(Vector2(-12, 0), Vector2(6, 0), Color("#3cb46a", a), 1.6)
			ci.draw_circle(Vector2(9, 0), 5.5, Color(INK, a))
			ci.draw_circle(Vector2(9, 0), 4.0, Color(c, a))
		"bottle":
			poly(ci, PackedVector2Array([Vector2(-8, -5), Vector2(6, -5), Vector2(8, -2), Vector2(14, -2), Vector2(14, 2), Vector2(8, 2), Vector2(6, 5), Vector2(-8, 5)]), c, a)
		_:
			ci.draw_circle(Vector2.ZERO, 7.0, Color(INK, a))
			ci.draw_circle(Vector2.ZERO, 5.0, Color(c, a))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

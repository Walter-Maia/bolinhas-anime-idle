class_name BallArt
## Arte pixelada das bolinhas (60x60 ampliada 2x = 120x120), sem rosto: corpo, cabelo, roupa, chapeu e acessorios.
## Coordenadas de "design" numa grade 40x40 (centro 20,22 / raio 14) multiplicadas por K=3.
## Texturas ficam em cache e podem ser pre-geradas em assets/balls (tools/bake_balls.gd).

const K := 3.0
const SIZE := 120
const CX := 20.0
const CY := 22.0
const R := 14.0
const CENTER := Vector2(60, 66)
const RADIUS_PX := 42.0
## pixel-art: desenha numa grade LS x LS e amplia PX vezes (nearest) para 120x120
const PX := 2
const LS := 60
const KL := 1.5
const OUTLINE := Color("#1b1420")
const LIGHT := Vector3(-0.42, -0.62, 0.66)
const BAKED := "res://assets/balls/%s.png"

static var _cache: Dictionary = {}


static func key_of(look: Dictionary) -> String:
	return JSON.stringify(look, "", true).md5_text().substr(0, 16)


static func make(look: Dictionary, gray: bool = false) -> Texture2D:
	var key := key_of(look)
	if _cache.has(key):
		return _cache[key]
	var path := BAKED % key
	var t: Texture2D
	if ResourceLoader.exists(path):
		t = load(path)
	else:
		t = ImageTexture.create_from_image(render(look))
	_cache[key] = t
	return t


static func render(look: Dictionary) -> Image:
	var img := Image.create(LS, LS, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	Art.new(img, normalize(look)).draw_all()
	img.resize(SIZE, SIZE, Image.INTERPOLATE_NEAREST)
	return img


## aceita o formato antigo (base/lower/extras/eyes) e devolve o novo
static func normalize(l: Dictionary) -> Dictionary:
	var o := l.duplicate(true)
	if not o.has("skin") and o.has("base"):
		o.skin = o.base
	if not o.has("outfit") and o.has("lower"):
		o.outfit = o.lower
		o.outfit_color = o.get("lower_color", "#444444")
	var acc: Array = o.get("acc", []).duplicate()
	for e in o.get("extras", []):
		match str(e):
			"straw_hat":
				o.hat = "straw"
			"mil_hat":
				o.hat = "military"
			"bandana_dark":
				acc.append("bandana")
				o.acc_color = "#26222e"
			"hollow_mask":
				acc.append("half_mask")
			"whiskers", "scar", "forehead_scar", "freckles", "curse_marks", "tear_lines", "cheek_mark", "eye_paint", "fangs", "sharp_teeth", "grin":
				pass
			"curly_brow":
				pass
			_:
				acc.append(str(e))
	match str(o.get("eyes", "")):
		"blindfold": acc.append("blindfold")
		"visor": acc.append("visor")
	if o.get("hair_style", "") == "cap":
		o.hair_style = "short"
		o.hat = "cap"
		o.hat_color = o.get("hair", "#e8ecf4")
	o.acc = acc
	return o


class Art:
	var img: Image
	var look: Dictionary
	var skin: Color
	var hair: Color
	var style: String
	var acc: Array
	var hat: String
	var hc: Color
	var hc2: Color
	var oc: Color
	var oc2: Color
	var ac: Color
	var hat_stripes := false
	var _hair_mask := {}

	func _init(i: Image, l: Dictionary) -> void:
		img = i
		look = l
		skin = Color(l.get("skin", "#f6d0a8"))
		hair = Color(l.get("hair", "#333333"))
		style = l.get("hair_style", "short")
		acc = l.get("acc", [])
		hat = l.get("hat", "none")
		hc = Color(l.get("hat_color", "#d8c060"))
		hc2 = Color(l.get("hat_color2", "#d42a30"))
		oc = Color(l.get("outfit_color", "#444444"))
		oc2 = Color(l.get("outfit_color2", oc.lightened(0.35).to_html()))
		ac = Color(l.get("acc_color", "#d42a30"))
		hat_stripes = bool(l.get("hat_stripes", false))

	# ------------------------------------------------------------ primitivas
	## cor de um acessorio especifico: acc_colors[nome] > acc_color > padrao
	func acol(name: String, fallback: String) -> Color:
		var d: Dictionary = look.get("acc_colors", {})
		if d.has(name):
			return Color(d[name])
		return Color(fallback)

	func setp(x: int, y: int, c: Color) -> void:
		if x < 0 or y < 0 or x >= LS or y >= LS:
			return
		if c.a >= 0.99:
			img.set_pixel(x, y, c)
		else:
			var o := img.get_pixel(x, y)
			if o.a <= 0.0:
				img.set_pixel(x, y, c)
			else:
				img.set_pixel(x, y, Color(o.lerp(c, c.a), maxf(o.a, c.a)))

	func fill(x0: float, y0: float, x1: float, y1: float, fn: Callable) -> void:
		for y in range(maxi(0, int(y0 * KL) - 1), mini(LS, int(y1 * KL) + 2)):
			for x in range(maxi(0, int(x0 * KL) - 1), mini(LS, int(x1 * KL) + 2)):
				var c: Variant = fn.call(Vector2((x + 0.5) / KL, (y + 0.5) / KL))
				if c != null:
					setp(x, y, c)

	func ellipse(cx: float, cy: float, rx: float, ry: float, c: Color, shaded: bool = false) -> void:
		fill(cx - rx, cy - ry, cx + rx, cy + ry, func(p: Vector2) -> Variant:
			if Vector2((p.x - cx) / rx, (p.y - cy) / ry).length_squared() <= 1.0:
				return lit(c, p, 0.6) if shaded else c
			return null)

	func circle(cx: float, cy: float, r: float, c: Color, shaded: bool = false) -> void:
		ellipse(cx, cy, r, r, c, shaded)

	func rect(x: float, y: float, w: float, h: float, c: Color) -> void:
		fill(x, y, x + w, y + h, func(p: Vector2) -> Variant:
			return c if p.x >= x and p.x < x + w and p.y >= y and p.y < y + h else null)

	func line(a: Vector2, b: Vector2, t: float, c: Color, mask: Callable = Callable()) -> void:
		var mn := a.min(b) - Vector2(t, t)
		var mx := a.max(b) + Vector2(t, t)
		fill(mn.x, mn.y, mx.x, mx.y, func(p: Vector2) -> Variant:
			if mask.is_valid() and not mask.call(p):
				return null
			var q := Geometry2D.get_closest_point_to_segment(p, a, b)
			return c if p.distance_to(q) <= t * 0.5 else null)

	func poly(pts: PackedVector2Array, c: Color, shaded: bool = false, grad_to: Variant = null) -> void:
		var mn := Vector2(1e9, 1e9)
		var mx := Vector2(-1e9, -1e9)
		for p in pts:
			mn = mn.min(p)
			mx = mx.max(p)
		fill(mn.x, mn.y, mx.x, mx.y, func(p: Vector2) -> Variant:
			if not Geometry2D.is_point_in_polygon(p, pts):
				return null
			var col := c
			if grad_to != null:
				col = c.lerp(grad_to, clampf((p.y - mn.y) / maxf(0.01, mx.y - mn.y), 0.0, 1.0))
			return lit(col, p, 0.55) if shaded else col)

	func inside(p: Vector2, r: float = R) -> bool:
		return Vector2(p.x - CX, p.y - CY).length() <= r

	func lit(c: Color, p: Vector2, strength: float = 1.0) -> Color:
		var n := Vector2(p.x - CX, p.y - CY) / R
		var z := sqrt(maxf(0.0, 1.0 - minf(n.length_squared(), 1.0)))
		var diff := clampf(Vector3(n.x, n.y, z).dot(LIGHT.normalized()), 0.0, 1.0)
		var f := lerpf(1.0, 0.6 + 0.58 * (round(diff * 6.0) / 6.0), strength)
		if f > 1.0:
			return c.lerp(Color.WHITE, (f - 1.0) * 0.75)
		return Color(c.r * f, c.g * f, c.b * f, c.a)

	# ------------------------------------------------------------ ordem de desenho
	func draw_all() -> void:
		_back_acc()
		_back_hair()
		_body()
		_outfit()
		_hair()
		_hat()
		_front_acc()
		_spec()
		_outline(OUTLINE, 1)

	func _body() -> void:
		var rim := skin.lightened(0.4)
		fill(CX - R, CY - R, CX + R, CY + R, func(p: Vector2) -> Variant:
			var d := Vector2(p.x - CX, p.y - CY).length()
			if d > R:
				return null
			var c := lit(skin, p)
			if d > R - 1.2 and (p.x - CX) + (p.y - CY) > 5.0:
				c = c.lerp(rim, 0.3)
			return c)

	func _spec() -> void:
		var bald := style == "bald" or style == "dome"
		if bald and hat == "none":
			ellipse(CX - 5.5, CY - 8.5, 3.4, 2.0, Color(1, 1, 1, 0.8))
		circle(CX + 8.8, CY + 8.0, 0.9, Color(1, 1, 1, 0.3))

	func _outline(c: Color, w: int) -> void:
		for _i in w:
			var src := img.duplicate() as Image
			for y in LS:
				for x in LS:
					if src.get_pixel(x, y).a > 0.3:
						continue
					for dd: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
						var nx := x + dd.x
						var ny := y + dd.y
						if nx >= 0 and ny >= 0 and nx < LS and ny < LS and src.get_pixel(nx, ny).a > 0.3:
							img.set_pixel(x, y, c)
							break

	# ------------------------------------------------------------ cabelo
	## limite inferior da franja (y) para cada x
	func fringe(x: float) -> float:
		var dx := x - CX
		match style:
			"buzz": return CY - 8.5
			"short": return CY - 5.0 + 1.0 * absf(sin(x * 1.3))
			"messy": return CY - 3.6 + 2.6 * absf(sin(x * 0.9 + 1.0)) * absf(cos(x * 0.41))
			"spiky", "spiky_back": return CY - 3.5 + 3.4 * absf(fposmod(x + 40.0, 4.0) - 2.0) / 2.0
			"big_spiky", "spiky_long", "wild_long": return CY - 2.5 + 3.8 * absf(fposmod(x + 40.0, 4.6) - 2.3) / 2.3
			"flame": return CY - 6.5 + 1.5 * absf(fposmod(x + 40.0, 3.0) - 1.5)
			"long", "twintail", "pigtails", "ponytail", "braid", "bun", "drills": return CY - 4.5 + 1.0 * absf(sin(x * 0.9))
			"hime", "bob": return CY - 2.0
			"undercut": return CY - 6.0 + 0.6 * absf(sin(x * 1.3))
			"slick": return CY - 8.0 + 0.4 * dx * 0.1
			"side_part": return CY - 6.5 + clampf(dx * 0.45, -3.0, 4.0)
			"cover_eye": return CY + 3.5 if dx < 1.0 else CY - 5.0
			"afro": return CY - 6.0
			"curly": return CY - 4.5 + 1.4 * absf(sin(x * 1.6))
			"mohawk": return CY - 12.0
			"pompadour": return CY - 7.0
			"dome": return CY - 7.0
			"split": return CY - 5.0 + 0.8 * absf(sin(x * 1.2))
			"odango", "twin_braids": return CY - 4.5 + 1.0 * absf(sin(x * 0.9))
			"pineapple": return CY - 4.0 + 2.6 * absf(fposmod(x + 40.0, 3.6) - 1.8) / 1.8
			"mid": return CY - 7.0 + clampf(absf(dx) * 0.55, 0.0, 5.0)
			"long_bangs": return CY + 3.5 if dx > -1.0 else CY - 4.5
		return CY - 5.0

	func in_hair(p: Vector2) -> bool:
		if not inside(p, R + 0.2):
			return false
		if style == "mohawk":
			return absf(p.x - CX) < 3.2 and p.y < CY - 3.0
		if style == "undercut" and absf(p.x - CX) > 10.5:
			return false
		var f := fringe(p.x)
		if p.y < f:
			return true
		# costeletas/laterais para estilos que descem pelos lados
		var side := 0.0
		match style:
			"long", "hime", "bob", "wild_long", "twintail", "pigtails", "braid", "drills", "spiky_long", "odango", "twin_braids", "long_bangs", "mid":
				side = 10.2
			"messy", "spiky", "big_spiky", "curly", "short", "spiky_back", "ponytail", "bun", "side_part", "cover_eye", "split", "pineapple":
				side = 12.0
		var limit := CY + (6.0 if style in ["bob", "mid"] else 2.0)
		if style in ["long", "hime", "wild_long", "drills", "spiky_long", "long_bangs", "twin_braids", "odango"]:
			limit = CY + 9.0
		if side > 0.0 and absf(p.x - CX) > side and p.y < limit:
			return true
		return false

	func hair_col(p: Vector2) -> Color:
		var c := lit(hair, p, 0.75)
		var hc2v: Variant = look.get("hair2")
		if hc2v != null and style == "split":
			if p.x > CX:
				c = lit(Color(hc2v), p, 0.75)
		elif hc2v != null and absf(p.x - (CX - 4.0)) < 1.3:
			c = lit(Color(hc2v), p, 0.75)
		var tipv: Variant = look.get("tips")
		if tipv != null and not style in ["spiky", "big_spiky", "spiky_long", "flame", "spiky_back", "pineapple"] and p.y > CY - 1.0:
			c = lit(Color(tipv), p, 0.75)
		var rr := Vector2(p.x - CX, p.y - CY).length()
		if rr > R * 0.66 and rr < R * 0.8 and p.y < CY - 6.5 and p.x < CX + 7.0:
			c = c.lerp(hair.lightened(0.45), 0.55)
		return c

	func _back_hair() -> void:
		var dk := hair.darkened(0.22)
		match style:
			"long", "hime", "wild_long", "spiky_long", "long_bangs", "mid":
				var wild := style == "wild_long" or style == "spiky_long"
				fill(CX - R - 4, CY - R - 1, CX + R + 4, CY + 17, func(p: Vector2) -> Variant:
					var dx := p.x - CX
					var dy := p.y - CY
					# silhueta: elipse larga que desce ate abaixo do corpo, com pontas na barra
					var q := Vector2(dx / (R + 2.6), (dy - 1.0) / (R + 2.2))
					if q.length_squared() > 1.0:
						return null
					var bottom := CY + (6.5 if style == "mid" else 12.0) + (2.6 if wild else 1.2) * absf(fposmod(p.x + 40.0, 3.0 if wild else 4.0) - (1.5 if wild else 2.0))
					if p.y > bottom:
						return null
					var c := lit(dk, p, 0.55)
					if look.has("tips") and p.y > CY + 6.0:
						c = lit(Color(look.tips).darkened(0.1), p, 0.55)
					if fposmod(p.x * 0.9, 3.0) < 0.35:
						c = c.darkened(0.15)
					return c)
			"ponytail":
				poly(PackedVector2Array([Vector2(CX + 9, CY - 10), Vector2(CX + 13, CY - 12), Vector2(CX + 19, CY + 2), Vector2(CX + 17.5, CY + 9), Vector2(CX + 14, CY + 1)]), hair, true, dk)
				circle(CX + 11.5, CY - 10.5, 1.6, ac)
			"twintail", "odango":
				for s: float in [-1.0, 1.0]:
					poly(PackedVector2Array([Vector2(CX + s * 12, CY - 12), Vector2(CX + s * 17, CY - 10), Vector2(CX + s * 19.5, CY + 6), Vector2(CX + s * 15.5, CY + 13), Vector2(CX + s * 14, CY + 2)]), hair, true, dk)
			"pigtails":
				for s: float in [-1.0, 1.0]:
					poly(PackedVector2Array([Vector2(CX + s * 12, CY - 2), Vector2(CX + s * 16, CY - 1), Vector2(CX + s * 17.5, CY + 9), Vector2(CX + s * 14, CY + 12), Vector2(CX + s * 12.5, CY + 4)]), hair, true, dk)
			"drills":
				for s: float in [-1.0, 1.0]:
					for i in 4:
						ellipse(CX + s * 15.0, CY - 2.0 + i * 3.6, 3.2 - i * 0.35, 2.0, hair if i % 2 == 0 else dk, true)
			"braid":
				for i in 7:
					circle(CX + 13.5 + i * 0.3, CY - 1.0 + i * 2.1, 1.6, hair if i % 2 == 0 else dk, true)
				circle(CX + 15.6, CY + 13.8, 1.0, ac)
			"spiky_back":
				for i in 4:
					var y0 := CY - 11.0 + i * 3.0
					poly(PackedVector2Array([Vector2(CX + 8, y0), Vector2(CX + 8, y0 + 4), Vector2(CX + 19 - i * 0.6, y0 + 1.0)]), hair, true, dk)

	func _hair() -> void:
		if style == "none" or style == "bald":
			return
		if style == "dome":
			fill(CX - R, CY - R, CX + R, CY - 6, func(p: Vector2) -> Variant:
				return lit(hair.lightened(0.15), p, 0.8) if inside(p) and p.y < CY - 7.0 else null)
			return
		var dk := hair.darkened(0.28)
		var hl := hair.lightened(0.38)
		# massa
		fill(CX - R - 1, CY - R - 1, CX + R + 1, CY + 10, func(p: Vector2) -> Variant:
			if not in_hair(p):
				return null
			var c := hair_col(p)
			if style != "buzz" and p.y < fringe(p.x) and p.y > fringe(p.x) - 0.9:
				c = c.darkened(0.18)
			return c)
		# mechas (linhas escuras do topo para a franja)
		var mask := func(p: Vector2) -> bool: return in_hair(p)
		if style != "buzz" and style != "mohawk" and style != "slick":
			var xs := [CX - 9.0, CX - 5.0, CX - 1.0, CX + 3.0, CX + 7.0]
			for x0: float in xs:
				line(Vector2(CX + (x0 - CX) * 0.25, CY - R + 1.5), Vector2(x0, fringe(x0) - 0.6), 0.45, dk, mask)
		elif style == "slick":
			for i in 4:
				line(Vector2(CX - 8 + i * 4.5, CY - 8.5), Vector2(CX - 6 + i * 4.0, CY - R + 1.2), 0.45, dk, mask)
		# geometria extra
		var top := CY - R
		match style:
			"spiky", "big_spiky", "spiky_long", "wild_long":
				var xs2: Array = [CX - 11.0, CX - 6.0, CX - 1.0, CX + 4.0, CX + 9.0]
				var hgt := 5.5
				var fan := 0.18
				if style != "spiky":
					xs2 = [CX - 13.0, CX - 8.5, CX - 3.5, CX + 1.5, CX + 6.5, CX + 11.5]
					hgt = 8.0
					fan = 0.32
				_spikes(xs2, hgt, fan, top, dk, hl)
			"flame":
				_spikes([CX - 7.5, CX - 3.5, CX + 0.5, CX + 4.5, CX + 8.0], 11.0, 0.12, top + 1.0, dk, hl)
			"spiky_back":
				_spikes([CX - 8.0, CX - 3.0, CX + 2.0], 4.0, 0.5, top + 0.5, dk, hl)
			"messy":
				for sx: float in [CX - 8.0, CX - 2.5, CX + 3.5, CX + 8.5]:
					poly(PackedVector2Array([Vector2(sx - 2.6, top + 3.0), Vector2(sx + 2.6, top + 3.0), Vector2(sx + 1.8, top - 1.8), Vector2(sx - 0.3, top - 0.2)]), hair, true, dk)
			"afro":
				for i in 9:
					var a := PI + PI * i / 8.0
					circle(CX + cos(a) * 12.5, CY - 4.0 + sin(a) * 11.0, 4.2, hair, true)
				circle(CX, CY - 10.0, 9.0, hair, true)
			"curly":
				for i in 7:
					var a2 := PI + PI * i / 6.0
					circle(CX + cos(a2) * 13.0, CY - 3.0 + sin(a2) * 12.0, 2.6, hair, true)
			"mohawk":
				for i in 5:
					var sx2 := CX - 1.0 + (i - 2) * 0.4
					var sy := top + 2.0 + absf(i - 2) * 2.0
					poly(PackedVector2Array([Vector2(sx2 - 2.5, sy + 4), Vector2(sx2 + 2.5, sy + 4), Vector2(sx2 + (i - 2) * 1.6, sy - 6.0)]), hair, true, dk)
			"pompadour":
				poly(PackedVector2Array([Vector2(CX - 9, top + 4), Vector2(CX + 9, top + 4), Vector2(CX + 7, top - 3), Vector2(CX - 2, top - 7), Vector2(CX - 11, top - 2)]), hair, true, dk)
				line(Vector2(CX - 8, top + 1), Vector2(CX + 5, top - 4), 0.6, hl)
			"bun":
				circle(CX, top - 1.5, 4.0, hair, true)
				line(Vector2(CX - 3, top - 1), Vector2(CX + 3, top - 2), 0.5, dk)
			"undercut":
				rect(CX - R, CY - 6, 3.6, 7, skin.darkened(0.2))
				rect(CX + R - 3.6, CY - 6, 3.6, 7, skin.darkened(0.2))
			"cover_eye":
				line(Vector2(CX - 10, CY - 6), Vector2(CX - 1, CY + 3), 0.6, hl, mask)
			"hime":
				for s: float in [-1.0, 1.0]:
					poly(PackedVector2Array([Vector2(CX + s * 9.0, CY - 3), Vector2(CX + s * 12.6, CY - 3), Vector2(CX + s * 12.0, CY + 8), Vector2(CX + s * 9.6, CY + 8)]), hair, true)
		# ahoge (fio rebelde)
		match style:
			"odango":
				for s: float in [-1.0, 1.0]:
					circle(CX + s * 9.5, CY - 14.0, 4.2, hair, true)
					circle(CX + s * 8.5, CY - 15.2, 1.2, hl)
			"twin_braids":
				for s: float in [-1.0, 1.0]:
					for i in 6:
						circle(CX + s * (10.5 - i * 0.2), CY + 1.0 + i * 2.2, 1.7, hair if i % 2 == 0 else dk, true)
					circle(CX + s * 9.4, CY + 14.2, 0.9, ac)
			"pineapple":
				for i in 5:
					var a := -PI * 0.85 + i * 0.32
					var bp := Vector2(CX + 2.0, CY - R + 4.0)
					poly(PackedVector2Array([bp + Vector2(-2.5, 1), bp + Vector2(2.5, 1), bp + Vector2(cos(a), sin(a)) * 11.0]), hair, true, dk)
		if acc.has("ahoge"):
			poly(PackedVector2Array([Vector2(CX - 0.8, top + 1.5), Vector2(CX + 0.8, top + 1.5), Vector2(CX + 3.5, top - 4.5), Vector2(CX + 1.0, top - 1.5)]), hair, true)

	func _spikes(xs: Array, hgt: float, fan: float, top: float, dk: Color, hl: Color) -> void:
		var tip: Variant = look.get("tips")
		var mid := (xs.size() - 1) * 0.5
		for i in xs.size():
			var sx: float = xs[i]
			var hh := hgt - absf(i - mid) * (hgt * 0.16)
			var by := top + 4.2 + absf(sx - CX) / 3.2
			var lean := (sx - CX) * fan
			var a := Vector2(sx - 3.3, by + 1.0)
			var b := Vector2(sx + 3.3, by + 1.0)
			var c := Vector2(sx + 1.0 + lean, by - hh - 1.5)
			poly(PackedVector2Array([a, b, c]), hair, true, dk if tip == null else Color(tip))
			line(Vector2(sx - 0.6, by), c.lerp(Vector2(sx, by), 0.25), 0.7, hl)
			line(b + Vector2(-0.4, -0.2), c, 0.45, dk)

	# ------------------------------------------------------------ roupa
	func _outfit() -> void:
		var kind: String = look.get("outfit", "none")
		if kind == "none":
			return
		var y0 := CY + 6.5
		fill(CX - R, y0 - 1.0, CX + R, CY + R, func(p: Vector2) -> Variant:
			if not inside(p):
				return null
			var dx := p.x - CX
			var dy := p.y - y0
			# decote arredondado padrao
			var neck := dy + 0.18 * dx * dx * 0.12
			if neck < 0.0:
				return null
			var col := oc
			match kind:
				"gi":
					if absf(dx) < 2.2 - dy * 0.35 and dy < 5.0:
						col = oc2 if look.has("outfit_color2") else Color("#2a4fa8")
					if absf(dy - 5.2) < 0.6:
						col = Color("#2a4fa8")
				"vest":
					if absf(dx) < 2.0 - dy * 0.15:
						col = skin
				"cape":
					col = skin.darkened(0.08) if absf(dx) < 4.5 else oc
					if absf(dx) < 4.5 and dy < 1.6:
						col = oc2
				"checker":
					col = oc if (int(floor(p.x / 2.6)) + int(floor(p.y / 2.6))) % 2 == 0 else Color("#14101e")
				"robe", "kimono":
					if absf(absf(dx) - dy * 0.9) < 0.7 and dy < 5.5:
						col = oc2
					elif absf(dx) < dy * 0.9 - 0.7 and dy < 5.5:
						col = Color("#f4f4fa") if kind == "kimono" else oc.lightened(0.15)
					if kind == "kimono" and absf(dy - 5.5) < 0.9:
						col = oc2
				"coat", "lab_coat", "scarf_coat":
					if kind == "lab_coat":
						col = Color("#f2f2f6")
					if absf(dx) < 0.45:
						col = col.darkened(0.3)
					if absf(dx - 1.5) < 0.55 and fposmod(dy, 2.4) < 0.9:
						col = Color("#ffd23c") if kind == "coat" else col.darkened(0.2)
					if dy < 1.6 and absf(dx) > 2.0:
						col = col.darkened(0.15)
				"uniform":
					if dy < 1.4:
						col = oc.darkened(0.2)
					if absf(dx) < 0.9 and fposmod(dy, 2.6) < 1.0 and dy > 1.2:
						col = Color("#ffd23c")
				"sailor":
					col = Color("#f4f4fa")
					if dy < 1.8 or (absf(dx) > 8.0 and dy < 3.0):
						col = oc
					if absf(dx) < 1.3 and dy > 1.6 and dy < 3.6:
						col = oc2 if look.has("outfit_color2") else Color("#e83a3a")
				"suit", "shirt_tie":
					var shirt := absf(dx) < 2.8 - dy * 0.1
					if kind == "shirt_tie":
						shirt = true
						col = oc2 if look.has("outfit_color2") else Color("#f4f4fa")
					if shirt and kind == "suit":
						col = Color("#f4f4fa")
					if absf(dx) < 0.9 and dy < 6.0:
						col = acol("tie", look.get("tie", "#d42a30"))
					if kind == "suit" and absf(absf(dx) - 2.8) < 0.5:
						col = oc.darkened(0.25)
				"armor", "armor_gold":
					var base := Color("#ffd23c") if kind == "armor_gold" else oc
					col = base
					if fposmod(dy, 3.0) < 0.55 or absf(dx) < 0.4:
						col = base.darkened(0.35)
					if absf(dx) > 9.0 and dy < 4.0:
						col = base.lightened(0.15)
				"hoodie":
					if absf(dx) < 3.5 and dy > 4.0:
						col = oc.darkened(0.15)
					if (absf(dx + 1.6) < 0.35 or absf(dx - 1.6) < 0.35) and dy < 3.5:
						col = Color("#f4f4fa")
				"jacket":
					if absf(dx) < 0.5:
						col = Color("#c8c8d0")
					if dy < 2.0 and absf(dx) > 1.0 and absf(dx) < 5.0:
						col = oc.lightened(0.2)
					if absf(dx) < 2.5 and dy < 3.0:
						col = oc2 if look.has("outfit_color2") else Color("#f4f4fa")
				"cyber":
					if absf(fposmod(dx + dy * 0.6, 4.0)) < 0.35 or absf(dx) < 0.3:
						col = oc2 if look.has("outfit_color2") else Color("#2ff0ff")
				"dress":
					if dy > 5.0 and fposmod(p.x, 2.0) < 0.9:
						col = Color("#f4f4fa")
					if dy < 1.4:
						col = oc2 if look.has("outfit_color2") else Color("#f4f4fa")
				"tank":
					if absf(dx) < 5.5 and dy < 1.6:
						col = skin
					if absf(absf(dx) - 4.0) < 0.8 and dy < 1.6:
						col = oc
				"cloak_clouds":
					col = Color("#16121e")
					var cx2 := fposmod(p.x, 7.0) - 3.5
					var cy2 := fposmod(p.y + 1.5, 6.0) - 3.0
					if Vector2(cx2, cy2 * 1.4).length() < 1.8:
						col = Color("#d42a30") if Vector2(cx2, cy2 * 1.4).length() > 0.7 else Color("#f4f4fa")
					if dy < 1.5:
						col = Color("#2a2234")
			return lit(col, p))
		if kind == "cape" or kind == "scarf_coat":
			circle(CX, y0 + 1.0, 1.2, Color("#ffd23c"))
		if kind == "scarf_coat":
			ellipse(CX, y0 + 0.5, 9.0, 1.8, ac, true)

	# ------------------------------------------------------------ chapeus
	func _hat() -> void:
		var top := CY - R
		match hat:
			"none":
				pass
			"straw":
				ellipse(CX, CY - 10.0, 9.5, 8.5, hc, true)
				fill(CX - 10, CY - 10, CX + 10, CY - 8, func(p: Vector2) -> Variant: return null)
				rect(CX - 9.4, CY - 12.2, 18.8, 2.4, hc2)
				ellipse(CX, CY - 8.6, 17.5, 2.0, hc.darkened(0.08), true)
				ellipse(CX, CY - 7.9, 17.5, 1.0, hc.darkened(0.3))
				_clip_below(CY - 8.5, CX - 10, CX + 10, CY - 19)
			"military":
				# copa larga (achatada) + faixa + aba preta
				fill(CX - 13, CY - 20, CX + 13, CY - 8, func(p: Vector2) -> Variant:
					var q := Vector2((p.x - CX) / 12.5, (p.y - (CY - 14.5)) / 4.6)
					if q.length_squared() <= 1.0 or (p.y > CY - 14.5 and p.y < CY - 9.5 and absf(p.x - CX) < 10.5):
						return lit(hc, p + Vector2(0, 7), 0.55)
					return null)
				rect(CX - 10.5, CY - 12.0, 21.0, 2.4, hc2)
				ellipse(CX + 1.5, CY - 9.0, 10.5, 1.6, Color("#1d1a22"))
				circle(CX, CY - 15.5, 1.2, Color("#ffd23c"))
			"witch":
				poly(PackedVector2Array([Vector2(CX - 9, CY - 10), Vector2(CX + 9, CY - 10), Vector2(CX + 6, CY - 22), Vector2(CX + 1, CY - 21)]), hc, true)
				rect(CX - 9, CY - 12, 18, 2, hc2)
				ellipse(CX, CY - 9.5, 16.0, 1.8, hc.darkened(0.15), true)
			"fedora":
				ellipse(CX, CY - 12.0, 9.5, 6.5, hc, true)
				_clip_below(CY - 9.5, CX - 10, CX + 10, CY - 19)
				line(Vector2(CX - 3, CY - 17.5), Vector2(CX + 3, CY - 17.5), 0.8, hc.darkened(0.3))
				rect(CX - 9.5, CY - 12.0, 19.0, 2.2, hc2)
				ellipse(CX, CY - 9.3, 15.5, 2.0, hc.darkened(0.12), true)
			"top_hat":
				rect(CX - 7, CY - 23, 14, 13, hc)
				rect(CX - 7, CY - 14, 14, 2.2, hc2)
				ellipse(CX, CY - 10.0, 13.0, 1.8, hc.darkened(0.2), true)
				rect(CX - 6, CY - 22, 2, 11, hc.lightened(0.15))
			"crown":
				var g := Color("#ffd23c")
				poly(PackedVector2Array([Vector2(CX - 8, CY - 11), Vector2(CX + 8, CY - 11), Vector2(CX + 9, CY - 18), Vector2(CX + 5, CY - 14), Vector2(CX, CY - 19.5), Vector2(CX - 5, CY - 14), Vector2(CX - 9, CY - 18)]), g, true)
				circle(CX, CY - 13.0, 1.2, Color("#e83a3a"))
				circle(CX - 5, CY - 12.5, 0.8, Color("#3c9cff"))
				circle(CX + 5, CY - 12.5, 0.8, Color("#3c9cff"))
			"beanie":
				fill(CX - R, CY - R - 2, CX + R, CY - 5, func(p: Vector2) -> Variant:
					if inside(p, R + 0.8) and p.y < CY - 6.0:
						var c := lit(hc, p, 0.6)
						if fposmod(p.x, 1.6) < 0.5:
							c = c.darkened(0.12)
						return c
					return null)
				rect(CX - 13, CY - 8, 26, 2.4, hc2)
				circle(CX, top - 1.5, 2.0, hc2, true)
			"cap":
				fill(CX - R, CY - R - 1, CX + R, CY - 6, func(p: Vector2) -> Variant:
					return lit(hc, p, 0.6) if inside(p, R + 0.6) and p.y < CY - 6.5 else null)
				ellipse(CX + 6.0, CY - 6.5, 10.0, 1.7, hc.darkened(0.25))
				circle(CX - 1, CY - 11, 1.6, hc2)
			"beret":
				ellipse(CX - 2.0, CY - 11.5, 11.5, 4.5, hc, true)
				circle(CX - 2.0, CY - 16.0, 0.9, hc.darkened(0.2))
			"chef":
				for i in 3:
					circle(CX - 5.0 + i * 5.0, CY - 17.0, 4.2, Color("#f8f8fc"), true)
				rect(CX - 8, CY - 15, 16, 5, Color("#f0f0f6"))
			"turban":
				ellipse(CX, CY - 9.5, 13.5, 8.0, hc, true)
				for i in 3:
					line(Vector2(CX - 12, CY - 9 - i * 2.5), Vector2(CX + 12, CY - 12 - i * 2.0), 0.4, hc.darkened(0.12))
				circle(CX, CY - 9.5, 1.4, hc2)
			"hood", "cat_hood":
				fill(CX - R - 2, CY - R - 2, CX + R + 2, CY + 8, func(p: Vector2) -> Variant:
					var d := Vector2(p.x - CX, p.y - CY).length()
					if d <= R + 1.5 and (p.y < CY - 6.0 or (absf(p.x - CX) > 9.5 and p.y < CY + 7.0)):
						return lit(hc, p, 0.6)
					return null)
				if hat == "cat_hood":
					for s: float in [-1.0, 1.0]:
						poly(PackedVector2Array([Vector2(CX + s * 6, CY - 13), Vector2(CX + s * 12, CY - 9), Vector2(CX + s * 12, CY - 19)]), hc, true)
						poly(PackedVector2Array([Vector2(CX + s * 8, CY - 13), Vector2(CX + s * 11, CY - 11), Vector2(CX + s * 11, CY - 16)]), hc2)
			"gold_helmet", "knight_helmet":
				var m := Color("#ffd23c") if hat == "gold_helmet" else hc
				fill(CX - R - 1, CY - R - 1, CX + R + 1, CY + 4, func(p: Vector2) -> Variant:
					if inside(p, R + 0.8) and (p.y < CY - 5.0 or (absf(p.x - CX) > 10.5 and p.y < CY + 3.0)):
						var c := lit(m, p, 0.7)
						if absf(p.y - (CY - 5.5)) < 0.6:
							c = m.darkened(0.3)
						return c
					return null)
				if hat == "gold_helmet":
					for s: float in [-1.0, 1.0]:
						poly(PackedVector2Array([Vector2(CX + s * 9, CY - 9), Vector2(CX + s * 13, CY - 12), Vector2(CX + s * 18, CY - 20), Vector2(CX + s * 11, CY - 15)]), m, true)
					poly(PackedVector2Array([Vector2(CX - 1.5, CY - 13), Vector2(CX + 1.5, CY - 13), Vector2(CX, CY - 20)]), hc2)
				else:
					rect(CX - 1, CY - R - 2, 2, 6, hc2)
			"bucket":
				fill(CX - 13, CY - 19, CX + 13, CY - 7, func(p: Vector2) -> Variant:
					if p.y > CY - 17.0 and p.y < CY - 8.5 and absf(p.x - CX) < 10.0 + (p.y - (CY - 17.0)) * 0.35:
						var c := lit(hc, p + Vector2(0, 6), 0.6)
						if hat_stripes and int((p.x + 40.0) / 2.0) % 2 == 0:
							c = hc2
						return c
					return null)
				ellipse(CX, CY - 8.5, 15.0, 2.0, hc.darkened(0.15), true)
			"kasa":
				poly(PackedVector2Array([Vector2(CX - 19, CY - 7), Vector2(CX + 19, CY - 7), Vector2(CX, CY - 19)]), hc, true, hc.darkened(0.2))
				line(Vector2(CX - 19, CY - 7), Vector2(CX + 19, CY - 7), 0.8, hc.darkened(0.4))
			"bandana_top":
				fill(CX - R, CY - R - 1, CX + R, CY - 5, func(p: Vector2) -> Variant:
					return lit(hc, p, 0.6) if inside(p, R + 0.6) and p.y < CY - 6.0 else null)
				poly(PackedVector2Array([Vector2(CX + 12, CY - 8), Vector2(CX + 17, CY - 6), Vector2(CX + 16, CY - 2), Vector2(CX + 12.5, CY - 5)]), hc, true)
				for i in 3:
					circle(CX - 6.0 + i * 5.5, CY - 10.5, 0.7, Color("#f4f4fa"))

	## apaga o que ficou abaixo da aba (para chapeus com copa elipsoidal)
	func _clip_below(_y: float, _x0: float, _x1: float, _top: float) -> void:
		pass

	# ------------------------------------------------------------ acessorios
	func _back_acc() -> void:
		var base_ac := ac
		for a in acc:
			ac = acol(str(a), base_ac.to_html())
			match str(a):
				"gourd":
					var gc := acol("gourd", "#c89a5a")
					circle(CX + 13.0, CY + 4.0, 5.2, gc, true)
					circle(CX + 11.5, CY - 4.0, 3.6, gc, true)
					line(Vector2(CX - 12, CY + 8), Vector2(CX + 12, CY - 6), 1.2, Color("#6a3a20"))
				"wings":
					for s: float in [-1.0, 1.0]:
						poly(PackedVector2Array([Vector2(CX + s * 8, CY - 2), Vector2(CX + s * 20, CY - 12), Vector2(CX + s * 19, CY - 4), Vector2(CX + s * 20, CY + 2), Vector2(CX + s * 10, CY + 6)]), acol("wings", "#f8f8ff"), true, acol("wings", "#c8d8f0").darkened(0.15))
				"devil_wings":
					for s: float in [-1.0, 1.0]:
						poly(PackedVector2Array([Vector2(CX + s * 8, CY - 3), Vector2(CX + s * 20, CY - 13), Vector2(CX + s * 17, CY - 6), Vector2(CX + s * 20, CY - 1), Vector2(CX + s * 15, CY + 1), Vector2(CX + s * 17, CY + 5), Vector2(CX + s * 9, CY + 5)]), ac.darkened(0.35), true)
				"tail":
					line(Vector2(CX + 10, CY + 10), Vector2(CX + 17, CY + 4), 1.6, ac)
					line(Vector2(CX + 17, CY + 4), Vector2(CX + 18, CY - 2), 1.6, ac)
				"sword_back":
					line(Vector2(CX - 15, CY + 12), Vector2(CX + 13, CY - 17), 2.2, Color("#c8d0dc"))
					line(Vector2(CX - 15, CY + 12), Vector2(CX - 11, CY + 8), 2.4, Color("#3a2a20"))
					line(Vector2(CX - 13, CY + 7.5), Vector2(CX - 9.5, CY + 11), 1.2, Color("#ffd23c"))
				"chainsaw":
					poly(PackedVector2Array([Vector2(CX - 2.5, CY - 9), Vector2(CX + 2.5, CY - 9), Vector2(CX + 2.0, CY - 24), Vector2(CX - 2.0, CY - 24)]), Color("#c8ccd4"), true)
					for i in 7:
						poly(PackedVector2Array([Vector2(CX + 2.0, CY - 11 - i * 2), Vector2(CX + 3.6, CY - 11.6 - i * 2), Vector2(CX + 2.0, CY - 12.6 - i * 2)]), Color("#8a8e98"))
						poly(PackedVector2Array([Vector2(CX - 2.0, CY - 11 - i * 2), Vector2(CX - 3.6, CY - 11.6 - i * 2), Vector2(CX - 2.0, CY - 12.6 - i * 2)]), Color("#8a8e98"))
					rect(CX - 3.5, CY - 10, 7, 2.5, Color("#ff8a2a"))
		ac = base_ac

	func _front_acc() -> void:
		var dark := Color("#1d1424")
		var base_ac2 := ac
		for a in acc:
			ac = acol(str(a), base_ac2.to_html())
			match str(a):
				"headband", "headband_slash", "third_eye_band":
					var band := ac if look.has("acc_color") else Color(look.get("band", "#2a4fa8"))
					fill(CX - R, CY - 8.8, CX + R, CY - 5.0, func(p: Vector2) -> Variant:
						return lit(band, p, 0.7) if inside(p, R + 0.4) and p.y >= CY - 8.6 and p.y < CY - 5.4 else null)
					if str(a) == "third_eye_band":
						ellipse(CX, CY - 7.0, 2.6, 1.3, Color("#f4f4fa"))
						circle(CX, CY - 7.0, 0.9, Color("#3cb46a"))
						circle(CX, CY - 7.0, 0.4, dark)
					else:
						rect(CX - 5.2, CY - 9.4, 10.4, 5.0, Color("#5a6478"))
						fill(CX - 4.6, CY - 8.8, CX + 4.6, CY - 5.0, func(p: Vector2) -> Variant:
							var t := (p.y - (CY - 8.8)) / 3.8
							return Color("#f2f6fa").lerp(Color("#9aa6ba"), t) if absf(p.x - CX) < 4.5 and p.y >= CY - 8.8 and p.y < CY - 5.0 else null)
						fill(CX - 2, CY - 8.4, CX + 2, CY - 5.4, func(p: Vector2) -> Variant:
							var v := Vector2(p.x - CX, p.y - (CY - 6.9))
							return Color("#4a5468") if absf(v.length() - fposmod(atan2(v.y, v.x), TAU) / TAU * 1.6 - 0.2) < 0.28 and v.length() < 1.6 else null)
						if str(a) == "headband_slash":
							line(Vector2(CX - 4.2, CY - 5.6), Vector2(CX + 3.8, CY - 8.4), 0.6, Color("#4a2020"))
				"bandana":
					fill(CX - R, CY - 9.6, CX + R, CY - 5.0, func(p: Vector2) -> Variant:
						return lit(ac, p, 0.7) if inside(p, R + 0.4) and p.y >= CY - 9.4 and p.y < CY - 5.4 else null)
					poly(PackedVector2Array([Vector2(CX + 12.5, CY - 8), Vector2(CX + 17, CY - 9.5), Vector2(CX + 16, CY - 5.5), Vector2(CX + 12.5, CY - 6)]), ac.darkened(0.1))
				"tiara":
					line(Vector2(CX - 6.5, CY - 6.0), Vector2(CX + 6.5, CY - 6.0), 0.9, Color("#ffd23c"))
					poly(PackedVector2Array([Vector2(CX - 1.8, CY - 5.6), Vector2(CX + 1.8, CY - 5.6), Vector2(CX, CY - 8.8)]), Color("#ffd23c"))
					circle(CX, CY - 6.4, 0.85, ac)
				"scarf":
					fill(CX - R, CY + 4.5, CX + R, CY + 9, func(p: Vector2) -> Variant:
						if not inside(p, R + 0.3) or p.y < CY + 4.8 or p.y > CY + 8.4:
							return null
						var c := ac if look.has("acc_color") else Color("#f4f4fa")
						if int(p.x / 1.4) % 2 == 0:
							c = c.darkened(0.1)
						return lit(c, p, 0.6))
					poly(PackedVector2Array([Vector2(CX + 6, CY + 7), Vector2(CX + 10, CY + 7), Vector2(CX + 11, CY + 14), Vector2(CX + 7, CY + 13)]), ac if look.has("acc_color") else Color("#f4f4fa"), true)
				"earrings":
					for s: float in [-1.0, 1.0]:
						circle(CX + s * 13.6, CY + 3.0, 1.1, ac)
				"glasses", "sunglasses":
					var lens := Color(0.12, 0.1, 0.16, 0.95) if str(a) == "sunglasses" else Color(0.85, 0.95, 1.0, 0.45)
					for s: float in [-1.0, 1.0]:
						ellipse(CX + s * 5.0, CY + 0.5, 3.2, 2.4, dark)
						ellipse(CX + s * 5.0, CY + 0.5, 2.5, 1.8, lens)
						line(Vector2(CX + s * 6.2, CY - 0.4), Vector2(CX + s * 4.2, CY + 0.6), 0.4, Color(1, 1, 1, 0.6))
					line(Vector2(CX - 1.8, CY), Vector2(CX + 1.8, CY), 0.6, dark)
				"goggles":
					rect(CX - R, CY - 9.5, 2 * R, 1.6, Color("#3a3240"))
					for s: float in [-1.0, 1.0]:
						circle(CX + s * 4.5, CY - 9.0, 3.0, Color("#5a5068"))
						circle(CX + s * 4.5, CY - 9.0, 2.2, ac if look.has("acc_color") else Color("#ff9a3a"))
						circle(CX + s * 4.5 - 0.8, CY - 9.8, 0.6, Color(1, 1, 1, 0.8))
				"headphones":
					line(Vector2(CX - 13, CY - 2), Vector2(CX, CY - R - 1.2), 1.2, dark)
					line(Vector2(CX + 13, CY - 2), Vector2(CX, CY - R - 1.2), 1.2, dark)
					for s: float in [-1.0, 1.0]:
						ellipse(CX + s * 14.0, CY + 0.5, 2.4, 3.6, ac, true)
				"mouth_mask":
					var mcol := acol("mouth_mask", look.get("mask_color", "#2c2c38"))
					fill(CX - R, CY + 1.5, CX + R, CY + R, func(p: Vector2) -> Variant:
						return lit(mcol, p, 0.7) if inside(p, R + 0.3) and p.y > CY + 1.8 - absf(p.x - CX) * 0.1 and p.y < CY + 8.0 else null)
				"half_mask":
					fill(CX - R, CY - 8, CX + 1, CY + 10, func(p: Vector2) -> Variant:
						return lit(acol("half_mask", "#f0ece0"), p) if inside(p, R + 0.2) and p.x < CX + 0.5 and p.y > CY - 7.5 else null)
					line(Vector2(CX - 10.5, CY - 4.0), Vector2(CX - 10.0, CY + 6.0), 0.9, Color("#d42a30"))
					line(Vector2(CX - 3.5, CY + 2.0), Vector2(CX - 3.8, CY + 8.0), 0.9, Color("#d42a30"))
					ellipse(CX - 5.2, CY + 0.6, 2.4, 2.0, dark)
				"full_mask":
					fill(CX - R, CY - 10, CX + R, CY + 11, func(p: Vector2) -> Variant:
						return lit(acol("full_mask", "#f0ece0"), p) if inside(p, R + 0.2) and absf(p.x - CX) < 12.0 and p.y > CY - 9.5 else null)
					ellipse(CX - 5.5, CY, 2.6, 2.2, dark)
					ellipse(CX + 5.5, CY, 2.6, 2.2, dark)
					rect(CX - 7.0, CY + 5.2, 14.0, 0.7, dark)
					for i in 8:
						rect(CX - 6.6 + i * 1.8, CY + 5.2, 0.5, 2.6, dark)
				"blindfold":
					fill(CX - R, CY - 3.2, CX + R, CY + 2.4, func(p: Vector2) -> Variant:
						if not inside(p, R + 0.4) or p.y < CY - 3.0 or p.y > CY + 2.2:
							return null
						return lit(Color("#15111e"), p, 0.6) if p.y > CY - 2.4 else Color("#3e3656"))
				"visor":
					rect(CX - 10.5, CY - 2.4, 21.0, 4.8, dark)
					rect(CX - 9.6, CY - 1.5, 19.2, 3.0, ac if look.has("acc_color") else Color("#ff3a3a"))
					rect(CX - 8.0, CY - 1.2, 5.0, 0.8, Color(1, 1, 1, 0.7))
				"horns", "small_horns":
					var hcol := acol(str(a), ac.to_html() if look.has("acc_color") and str(a) == "small_horns" else "#f0e8d0")
					var big := 1.0 if str(a) == "horns" else 0.55
					for s: float in [-1.0, 1.0]:
						poly(PackedVector2Array([Vector2(CX + s * 11.5, CY - 8.5), Vector2(CX + s * 6, CY - 11.5), Vector2(CX + s * (8 + 4 * big), CY - 11 - 9 * big)]), hcol, true)
				"cat_ears", "fox_ears", "bunny_ears":
					for s: float in [-1.0, 1.0]:
						if str(a) == "bunny_ears":
							ellipse(CX + s * 5.0, CY - 19.0, 2.4, 7.0, hair, true)
							ellipse(CX + s * 5.0, CY - 18.5, 1.2, 5.0, Color("#ffb8c8"))
						else:
							var ec := hair if str(a) == "cat_ears" else Color("#ff8a2a")
							poly(PackedVector2Array([Vector2(CX + s * 4, CY - 12.5), Vector2(CX + s * 12, CY - 9.5), Vector2(CX + s * 11, CY - 20)]), ec, true)
							poly(PackedVector2Array([Vector2(CX + s * 6.5, CY - 12.5), Vector2(CX + s * 10.5, CY - 11), Vector2(CX + s * 10, CY - 16.5)]), Color("#ffb8c8") if str(a) == "cat_ears" else Color("#f4f4fa"))
				"halo":
					ellipse(CX, CY - 19.5, 7.0, 2.0, Color("#ffe066"))
					ellipse(CX, CY - 19.5, 5.4, 1.0, Color(0, 0, 0, 0))
					fill(CX - 6, CY - 21, CX + 6, CY - 18, func(p: Vector2) -> Variant:
						return Color(0, 0, 0, 0) if Vector2((p.x - CX) / 5.0, (p.y - (CY - 19.5)) / 0.9).length_squared() < 1.0 else null)
				"antennae":
					for s: float in [-1.0, 1.0]:
						line(Vector2(CX + s * 3, CY - 13), Vector2(CX + s * 6, CY - 20), 0.9, skin.darkened(0.1))
						circle(CX + s * 6, CY - 20, 1.1, skin.darkened(0.1))
				"elf_ears":
					for s: float in [-1.0, 1.0]:
						poly(PackedVector2Array([Vector2(CX + s * 13.0, CY - 1.0), Vector2(CX + s * 13.0, CY + 3.5), Vector2(CX + s * 19.0, CY - 4.5)]), skin, true)
				"ribbon", "bow":
					var bc := ac
					var ry := CY - 13.0
					var rx := CX + 6.0
					poly(PackedVector2Array([Vector2(rx, ry), Vector2(rx - 6, ry - 4), Vector2(rx - 6, ry + 3)]), bc, true)
					poly(PackedVector2Array([Vector2(rx, ry), Vector2(rx + 6, ry - 4), Vector2(rx + 6, ry + 3)]), bc, true)
					circle(rx, ry, 1.4, bc.darkened(0.2))
				"hairclip":
					rect(CX - 9, CY - 7.5, 4, 1.2, ac)
					rect(CX - 8.5, CY - 9.0, 4, 1.2, ac)
				"flower":
					for i in 5:
						var an := TAU * i / 5.0
						circle(CX - 8 + cos(an) * 1.6, CY - 10 + sin(an) * 1.6, 1.3, ac)
					circle(CX - 8, CY - 10, 0.9, Color("#ffe066"))
				"pacifier":
					circle(CX, CY + 9.5, 2.4, Color("#ffd23c"), true)
					ellipse(CX, CY + 9.5, 1.2, 1.0, Color("#ff8a2a"))
					line(Vector2(CX - 2, CY + 6), Vector2(CX, CY + 7.2), 0.4, Color("#c8c8d0"))
					line(Vector2(CX + 2, CY + 6), Vector2(CX, CY + 7.2), 0.4, Color("#c8c8d0"))
				"puzzle_pendant":
					line(Vector2(CX - 4, CY + 6), Vector2(CX, CY + 8), 0.4, Color("#8a6a2a"))
					line(Vector2(CX + 4, CY + 6), Vector2(CX, CY + 8), 0.4, Color("#8a6a2a"))
					poly(PackedVector2Array([Vector2(CX - 3.5, CY + 8.5), Vector2(CX + 3.5, CY + 8.5), Vector2(CX, CY + 14)]), Color("#ffd23c"), true)
					ellipse(CX, CY + 10.0, 1.0, 0.6, Color("#5a3a10"))
				"soul_gem":
					ellipse(CX, CY + 9.5, 1.8, 2.4, ac, true)
					circle(CX - 0.5, CY + 8.6, 0.5, Color(1, 1, 1, 0.9))
					rect(CX - 1.6, CY + 11.6, 3.2, 0.8, Color("#ffd23c"))
				"cross":
					rect(CX - 0.5, CY + 7.5, 1.0, 5.0, Color("#ffd23c"))
					rect(CX - 1.8, CY + 8.8, 3.6, 1.0, Color("#ffd23c"))
				"chains":
					for i in 9:
						ellipse(CX - 12 + i * 3.0, CY + 7.5 + sin(i * 0.9) * 1.2, 1.4, 0.8, Color("#c8ccd8"))
				"cyber_lines":
					var nc := ac if look.has("acc_color") else Color("#2ff0ff")
					line(Vector2(CX - 12, CY - 2), Vector2(CX - 7, CY + 3), 0.5, nc)
					line(Vector2(CX - 7, CY + 3), Vector2(CX - 7, CY + 9), 0.5, nc)
					line(Vector2(CX + 11, CY - 4), Vector2(CX + 7, CY), 0.5, nc)
					circle(CX + 7, CY, 0.7, nc)
				"collar":
					fill(CX - R, CY + 5, CX + R, CY + 8, func(p: Vector2) -> Variant:
						return lit(ac, p, 0.5) if inside(p, R + 0.3) and p.y > CY + 5.6 and p.y < CY + 7.4 else null)
				"bell":
					circle(CX, CY + 8.5, 1.6, Color("#ffd23c"), true)
					rect(CX - 0.3, CY + 9.0, 0.6, 1.0, Color("#5a3a10"))
				"necklace":
					for i in 9:
						var an2 := PI * 0.15 + PI * 0.7 * i / 8.0
						circle(CX + cos(an2) * 9.0, CY + 1.5 + sin(an2) * 7.0, 0.7, ac)
				"tie":
					poly(PackedVector2Array([Vector2(CX - 1, CY + 7), Vector2(CX + 1, CY + 7), Vector2(CX + 1.5, CY + 13), Vector2(CX, CY + 14.5), Vector2(CX - 1.5, CY + 13)]), ac)
				"flame_forehead":
					poly(PackedVector2Array([Vector2(CX - 3.5, CY - 7), Vector2(CX + 3.5, CY - 7), Vector2(CX + 2.5, CY - 13), Vector2(CX + 0.5, CY - 11), Vector2(CX - 0.5, CY - 16), Vector2(CX - 2.5, CY - 11)]), Color("#ff8a2a"), false, Color("#ffe066"))
				"star_mark":
					_star(Vector2(CX + 7, CY + 9), 1.8, ac if look.has("acc_color") else Color("#ffd23c"))
				"beard", "goatee", "mustache":
					var bc := acol(str(a), hair.to_html())
					if str(a) == "beard":
						fill(CX - R, CY + 1, CX + R, CY + R + 2, func(p: Vector2) -> Variant:
							var dx2 := p.x - CX
							if inside(p, R + 1.2) and p.y > CY + 2.5 + absf(dx2) * 0.05 and p.y < CY + 12.5 - absf(dx2) * 0.35:
								return lit(bc, p, 0.6)
							return null)
					elif str(a) == "goatee":
						poly(PackedVector2Array([Vector2(CX - 2.5, CY + 6), Vector2(CX + 2.5, CY + 6), Vector2(CX + 1, CY + 11), Vector2(CX - 1, CY + 11)]), bc, true)
					fill(CX - 7, CY + 2, CX + 7, CY + 6, func(p: Vector2) -> Variant:
						var dx3 := absf(p.x - CX)
						var yy := CY + 3.6 + dx3 * 0.18
						return bc.darkened(0.1) if absf(p.y - yy) < 1.0 - dx3 * 0.08 and dx3 < 6.5 else null)
				"high_collar", "fur_collar":
					var cc := acol(str(a), oc.to_html() if str(a) == "high_collar" else "#f4f0e8")
					fill(CX - R - 1, CY + 2, CX + R + 1, CY + 10, func(p: Vector2) -> Variant:
						var d2 := Vector2(p.x - CX, p.y - CY).length()
						if d2 > R - 4.0 and d2 < R + 1.2 and p.y > CY + 3.0:
							var c2 := lit(cc, p, 0.6)
							if str(a) == "fur_collar" and int(p.x * 1.7 + p.y) % 3 == 0:
								c2 = c2.darkened(0.08)
							return c2
						return null)
				"armband":
					line(Vector2(CX - 13.5, CY + 6), Vector2(CX - 10, CY + 10.5), 2.2, acol("armband", "#e83a3a"))
				"shoulder_pads":
					for s: float in [-1.0, 1.0]:
						ellipse(CX + s * 12.5, CY + 6.5, 4.2, 2.8, acol("shoulder_pads", "#e8e8f0"), true)
				"plume":
					poly(PackedVector2Array([Vector2(CX + 6, CY - 14), Vector2(CX + 8, CY - 14), Vector2(CX + 16, CY - 22), Vector2(CX + 13, CY - 19)]), acol("plume", "#e83a3a"), true)
				"clown_nose":
					circle(CX, CY + 1.5, 2.2, acol("clown_nose", "#e83a3a"), true)
				"eyepatch":
					line(Vector2(CX - R, CY - 4.5), Vector2(CX + R, CY - 2.0), 0.7, dark)
					ellipse(CX + 5.0, CY + 0.6, 3.2, 2.6, dark)
				"scar_x":
					line(Vector2(CX - 3.5, CY - 3.0), Vector2(CX + 2.5, CY + 4.0), 0.6, Color("#a04040"))
					line(Vector2(CX + 2.5, CY - 3.0), Vector2(CX - 3.5, CY + 4.0), 0.6, Color("#a04040"))
				"bandage":
					rect(CX - 8, CY - 6, 5, 1.6, Color("#f4ecd8"))
					rect(CX - 6.3, CY - 7.6, 1.6, 5, Color("#f4ecd8"))
				"card":
					poly(PackedVector2Array([Vector2(CX + 12, CY - 3), Vector2(CX + 17, CY - 4), Vector2(CX + 18.5, CY + 4), Vector2(CX + 13.5, CY + 5)]), Color("#f8f4ec"), true)
					poly(PackedVector2Array([Vector2(CX + 13, CY - 2), Vector2(CX + 16.5, CY - 3), Vector2(CX + 17.5, CY + 3), Vector2(CX + 14, CY + 4)]), ac)
				"hammer":
					line(Vector2(CX + 10, CY + 12), Vector2(CX + 16, CY - 2), 1.2, Color("#8e5c2c"))
					poly(PackedVector2Array([Vector2(CX + 12, CY - 6), Vector2(CX + 19, CY - 3), Vector2(CX + 17.5, CY + 1), Vector2(CX + 10.5, CY - 2)]), Color("#9aa6ba"), true)
		ac = base_ac2

	func _star(c: Vector2, r: float, col: Color) -> void:
		var pts := PackedVector2Array()
		for i in 10:
			var an := -PI / 2.0 + TAU * i / 10.0
			pts.append(c + Vector2(cos(an), sin(an)) * (r if i % 2 == 0 else r * 0.45))
		poly(pts, col)

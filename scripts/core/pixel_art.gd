class_name PixelArt
## Gera pixel art em codigo: as bolinhas (40x40, corpo de raio 14) e os icones (18x18).
## Tudo em cache. Use sempre com filtro NEAREST e escala inteira.

const TEX := 40
const CX := 20
const CY := 22
const R := 14.0
const OUTLINE := Color("#1b1420")

static var _cache: Dictionary = {}


# =============================================================================================
# canvas simples
# =============================================================================================
class Px:
	var img: Image
	var w: int
	var h: int

	func _init(width: int, height: int) -> void:
		w = width
		h = height
		img = Image.create(w, h, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))

	func px(x: int, y: int, c: Color) -> void:
		if x >= 0 and y >= 0 and x < w and y < h:
			img.set_pixel(x, y, c)

	func get_c(x: int, y: int) -> Color:
		if x >= 0 and y >= 0 and x < w and y < h:
			return img.get_pixel(x, y)
		return Color(0, 0, 0, 0)

	func rect(x: int, y: int, rw: int, rh: int, c: Color) -> void:
		for yy in range(y, y + rh):
			for xx in range(x, x + rw):
				px(xx, yy, c)

	func circle(cx: float, cy: float, r: float, c: Color) -> void:
		for yy in range(int(cy - r - 1), int(cy + r + 2)):
			for xx in range(int(cx - r - 1), int(cx + r + 2)):
				if Vector2(xx + 0.5 - cx, yy + 0.5 - cy).length() <= r:
					px(xx, yy, c)

	func ring(cx: float, cy: float, r: float, t: float, c: Color) -> void:
		for yy in range(int(cy - r - 1), int(cy + r + 2)):
			for xx in range(int(cx - r - 1), int(cx + r + 2)):
				var d := Vector2(xx + 0.5 - cx, yy + 0.5 - cy).length()
				if d <= r and d > r - t:
					px(xx, yy, c)

	func line(x0: float, y0: float, x1: float, y1: float, c: Color, t: float = 1.0) -> void:
		var n := int(maxf(absf(x1 - x0), absf(y1 - y0)) * 2.0) + 1
		for i in n + 1:
			var f := float(i) / float(n)
			var x := lerpf(x0, x1, f)
			var y := lerpf(y0, y1, f)
			if t <= 1.0:
				px(int(round(x)), int(round(y)), c)
			else:
				circle(x + 0.5, y + 0.5, t * 0.5, c)

	func poly(points: PackedVector2Array, c: Color) -> void:
		var mn := Vector2(1e9, 1e9)
		var mx := Vector2(-1e9, -1e9)
		for p in points:
			mn = mn.min(p)
			mx = mx.max(p)
		for yy in range(int(mn.y) - 1, int(mx.y) + 2):
			for xx in range(int(mn.x) - 1, int(mx.x) + 2):
				if Geometry2D.is_point_in_polygon(Vector2(xx + 0.5, yy + 0.5), points):
					px(xx, yy, c)

	## contorno de 1px em volta de tudo que for opaco
	func outline(c: Color) -> void:
		var src := img.duplicate() as Image
		for yy in h:
			for xx in w:
				if src.get_pixel(xx, yy).a > 0.1:
					continue
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx: int = xx + d.x
					var ny: int = yy + d.y
					if nx >= 0 and ny >= 0 and nx < w and ny < h and src.get_pixel(nx, ny).a > 0.1:
						img.set_pixel(xx, yy, c)
						break

	func tex() -> ImageTexture:
		return ImageTexture.create_from_image(img)


# =============================================================================================
# BOLINHAS
# =============================================================================================
static func ball(look: Dictionary, gray: bool = false) -> ImageTexture:
	return BallArt.make(look, gray)


# =============================================================================================
# ICONES 18x18 (desenhados com primitivas + contorno automatico)
# =============================================================================================
static func icon(id: String) -> ImageTexture:
	var key := "icon:" + id
	if _cache.has(key):
		return _cache[key]
	var cv := Px.new(18, 18)
	var m := Color("#9aa6ba")
	var l := Color("#e0e6f0")
	var w := Color.WHITE
	var y := Color("#ffd23c")
	var o := Color("#c48412")
	var b := Color("#b47c40")
	var n := Color("#6a421e")
	var r := Color("#e83a3a")
	var u := Color("#3c9cff")
	var t := Color("#a8e2ff")
	var k := Color("#2c2438")
	match id:
		"weapon_melee":
			cv.line(14, 2, 6, 10, m, 2.2)
			cv.line(14, 2, 7, 9, l)
			cv.line(3, 8, 8, 13, o, 2.0)
			cv.line(5, 11, 2, 14, n, 2.0)
			cv.px(2, 15, y)
		"weapon_ranged":
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(11, 7), Vector2(17, 9), Vector2(11, 11), Vector2(9, 17), Vector2(7, 11), Vector2(1, 9), Vector2(7, 7)]), m)
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(11, 7), Vector2(9, 9), Vector2(7, 7)]), l)
			cv.poly(PackedVector2Array([Vector2(1, 9), Vector2(7, 7), Vector2(9, 9), Vector2(7, 11)]), l.darkened(0.1))
			cv.circle(9, 9, 1.6, k)
		"armor":
			cv.rect(4, 5, 10, 10, b)
			cv.rect(2, 4, 4, 5, b.lightened(0.15))
			cv.rect(12, 4, 4, 5, b.lightened(0.15))
			cv.rect(7, 4, 4, 2, Color(0, 0, 0, 0))
			cv.rect(8, 6, 2, 9, n)
			cv.rect(5, 6, 2, 3, b.lightened(0.3))
			cv.rect(4, 14, 10, 1, n)
		"helmet":
			cv.circle(9, 9, 6.5, m)
			cv.rect(3, 9, 12, 6, m)
			cv.rect(5, 10, 8, 2, k)
			cv.rect(8, 12, 2, 3, k)
			cv.rect(8, 1, 2, 4, r)
			cv.rect(5, 5, 2, 2, l)
		"amulet":
			cv.line(4, 1, 9, 9, y)
			cv.line(14, 1, 9, 9, y)
			cv.circle(9, 12, 4, o)
			cv.circle(9, 12, 2.8, r)
			cv.px(8, 11, w)
		"wings":
			cv.poly(PackedVector2Array([Vector2(8, 6), Vector2(1, 2), Vector2(2, 9), Vector2(1, 13), Vector2(8, 11)]), l)
			cv.poly(PackedVector2Array([Vector2(10, 6), Vector2(17, 2), Vector2(16, 9), Vector2(17, 13), Vector2(10, 11)]), l)
			cv.line(2, 7, 7, 8, t)
			cv.line(16, 7, 11, 8, t)
			cv.rect(8, 6, 2, 6, y)
		"gloves":
			cv.rect(5, 7, 8, 7, b)
			cv.rect(5, 3, 2, 5, b)
			cv.rect(7, 2, 2, 6, b)
			cv.rect(9, 2, 2, 6, b)
			cv.rect(11, 3, 2, 5, b)
			cv.rect(3, 8, 2, 4, b)
			cv.rect(5, 13, 8, 3, n)
			cv.rect(6, 4, 1, 3, b.lightened(0.3))
		"boots":
			cv.rect(5, 2, 6, 10, b)
			cv.rect(5, 10, 10, 4, b)
			cv.rect(5, 14, 10, 2, n)
			cv.rect(4, 2, 8, 2, n)
			cv.rect(6, 5, 1, 5, b.lightened(0.3))
		"belt":
			cv.rect(1, 7, 16, 4, n)
			cv.rect(1, 8, 16, 1, b)
			cv.ring(9, 9, 3.6, 1.5, y)
			cv.px(9, 9, n)
		"ring":
			cv.ring(9, 11, 5.5, 2.0, y)
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(13, 5), Vector2(9, 8), Vector2(5, 5)]), u)
			cv.px(8, 4, t)
			cv.px(9, 3, w)
		"chest":
			cv.rect(2, 8, 14, 8, b)
			cv.rect(2, 4, 14, 4, b.lightened(0.2))
			cv.rect(3, 3, 12, 1, b.lightened(0.2))
			cv.rect(4, 3, 2, 13, o)
			cv.rect(12, 3, 2, 13, o)
			cv.rect(2, 8, 14, 1, n)
			cv.rect(8, 7, 2, 4, y)
		"coin":
			cv.circle(9, 9, 7, y)
			cv.ring(9, 9, 5, 1, o)
			cv.rect(8, 6, 2, 6, o)
			cv.rect(5, 4, 2, 2, w)
		"gem":
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(16, 7), Vector2(9, 17), Vector2(2, 7)]), u)
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(12, 7), Vector2(6, 7)]), t)
			cv.poly(PackedVector2Array([Vector2(2, 7), Vector2(6, 7), Vector2(9, 17)]), u.darkened(0.3))
			cv.px(8, 4, w)
		"key":
			cv.ring(5, 5, 4, 1.8, y)
			cv.line(8, 8, 15, 15, y, 2.0)
			cv.rect(11, 13, 2, 3, y)
			cv.rect(13, 11, 3, 2, y)
			cv.px(4, 3, w)
		"hourglass":
			cv.rect(3, 1, 12, 2, n)
			cv.rect(3, 15, 12, 2, n)
			cv.poly(PackedVector2Array([Vector2(4, 3), Vector2(14, 3), Vector2(9, 9)]), t)
			cv.poly(PackedVector2Array([Vector2(9, 9), Vector2(14, 15), Vector2(4, 15)]), t)
			cv.poly(PackedVector2Array([Vector2(6, 15), Vector2(12, 15), Vector2(9, 11)]), y)
			cv.rect(8, 5, 2, 3, y)
		"power":
			cv.line(3, 3, 14, 14, l, 2.0)
			cv.line(14, 3, 3, 14, l, 2.0)
			cv.rect(2, 12, 4, 4, y)
			cv.rect(12, 12, 4, 4, y)
		"dungeon":
			cv.rect(2, 4, 14, 13, m)
			cv.circle(9, 5, 7, m)
			cv.rect(5, 7, 8, 10, k)
			cv.circle(9, 7, 4, k)
			for i in 3:
				cv.rect(6 + i * 3, 5, 1, 12, Color("#6e7a90"))
			cv.rect(2, 16, 14, 1, Color("#5a6068"))
		"pvp":
			cv.line(3, 2, 14, 13, l, 2.0)
			cv.line(15, 2, 4, 13, l, 2.0)
			cv.line(11, 15, 16, 10, y, 2.0)
			cv.line(7, 15, 2, 10, y, 2.0)
		"book":
			cv.poly(PackedVector2Array([Vector2(1, 4), Vector2(9, 6), Vector2(9, 16), Vector2(1, 14)]), Color("#f4ecd8"))
			cv.poly(PackedVector2Array([Vector2(17, 4), Vector2(9, 6), Vector2(9, 16), Vector2(17, 14)]), Color("#e8dcc0"))
			cv.line(9, 6, 9, 16, r)
			for i in 3:
				cv.line(3, 7 + i * 2, 7, 8 + i * 2, Color("#9a8a6a"))
				cv.line(11, 8 + i * 2, 15, 7 + i * 2, Color("#9a8a6a"))
		"gacha":
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(11, 7), Vector2(17, 7), Vector2(12, 11), Vector2(14, 17), Vector2(9, 13), Vector2(4, 17), Vector2(6, 11), Vector2(1, 7), Vector2(7, 7)]), y)
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(11, 7), Vector2(9, 9), Vector2(7, 7)]), Color("#fff6c4"))
			cv.px(9, 9, w)
		"shop":
			for i in 4:
				cv.rect(1 + i * 4, 2, 4, 5, r if i % 2 == 0 else w)
			cv.rect(1, 7, 16, 1, Color("#8c1d1c"))
			cv.rect(2, 8, 14, 8, Color("#cfe6ff"))
			cv.rect(2, 12, 14, 4, b)
			cv.rect(4, 9, 4, 3, u)
		"tower":
			cv.rect(5, 4, 8, 13, m)
			cv.rect(4, 2, 10, 3, m)
			for i in 3:
				cv.rect(4 + i * 4, 0, 2, 2, m)
			cv.rect(8, 7, 2, 3, k)
			cv.rect(7, 13, 4, 4, k)
		"skull":
			cv.circle(9, 8, 6.5, Color("#f0ece0"))
			cv.rect(5, 12, 8, 4, Color("#f0ece0"))
			cv.rect(5, 7, 3, 3, k)
			cv.rect(10, 7, 3, 3, k)
			cv.px(9, 11, k)
			cv.rect(6, 15, 1, 1, k)
			cv.rect(9, 15, 1, 1, k)
			cv.rect(12, 15, 1, 1, k)
		"scroll":
			cv.rect(3, 3, 12, 12, Color("#f4ecd8"))
			cv.rect(2, 2, 14, 2, b)
			cv.rect(2, 14, 14, 2, b)
			for i in 4:
				cv.rect(5, 6 + i * 2, 8 - (i % 2) * 2, 1, Color("#9a8a6a"))
		"bolt":
			cv.poly(PackedVector2Array([Vector2(11, 1), Vector2(4, 10), Vector2(9, 10), Vector2(7, 17), Vector2(14, 7), Vector2(9, 7)]), y)
		"star":
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(11, 7), Vector2(17, 7), Vector2(12, 11), Vector2(14, 17), Vector2(9, 13), Vector2(4, 17), Vector2(6, 11), Vector2(1, 7), Vector2(7, 7)]), y)
		"star_empty":
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(11, 7), Vector2(17, 7), Vector2(12, 11), Vector2(14, 17), Vector2(9, 13), Vector2(4, 17), Vector2(6, 11), Vector2(1, 7), Vector2(7, 7)]), Color("#5a5468"))
		"lock":
			cv.ring(9, 7, 4.5, 1.8, m)
			cv.rect(3, 8, 12, 9, y)
			cv.rect(8, 11, 2, 3, n)
		"vip":
			cv.poly(PackedVector2Array([Vector2(1, 5), Vector2(5, 9), Vector2(9, 2), Vector2(13, 9), Vector2(17, 5), Vector2(15, 15), Vector2(3, 15)]), y)
			cv.circle(9, 11, 1.5, r)
			cv.rect(3, 14, 12, 2, o)
		"gift":
			cv.rect(2, 7, 14, 10, r)
			cv.rect(1, 5, 16, 3, r.lightened(0.2))
			cv.rect(8, 5, 2, 12, y)
			cv.circle(6, 3, 2.5, y)
			cv.circle(12, 3, 2.5, y)
		"frag":
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(14, 6), Vector2(11, 17), Vector2(5, 14), Vector2(4, 5)]), Color("#c070f0"))
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(14, 6), Vector2(9, 8)]), Color("#ecc8ff"))
		"gear":
			for i in 8:
				var an := TAU * i / 8.0
				cv.rect(int(9 + cos(an) * 6.5) - 1, int(9 + sin(an) * 6.5) - 1, 3, 3, m)
			cv.circle(9, 9, 5.8, m)
			cv.circle(9, 9, 2.4, k)
			cv.px(7, 6, l)
		"crystal":
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(15, 6), Vector2(13, 16), Vector2(5, 16), Vector2(3, 6)]), Color("#c8c8d0"))
			cv.poly(PackedVector2Array([Vector2(9, 1), Vector2(15, 6), Vector2(9, 8), Vector2(3, 6)]), Color("#ffffff"))
			cv.poly(PackedVector2Array([Vector2(9, 8), Vector2(13, 16), Vector2(5, 16)]), Color("#9a9aa8"))
		"xp":
			cv.circle(9, 9, 7, Color("#58d07a"))
			cv.rect(5, 7, 8, 4, Color("#1f6b2a"))
			cv.rect(6, 8, 6, 2, Color("#c8ffd0"))
		_:
			cv.circle(9, 9, 6, Color("#ff00ff"))
	cv.outline(OUTLINE)
	var tx := cv.tex()
	_cache[key] = tx
	return tx

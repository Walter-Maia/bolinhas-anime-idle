class_name BallIcon
extends Control
## Retrato de bolinha: moldura na cor da raridade, sprite pixel e (opcional) recarga da skill.

signal pressed

var tex: Texture2D
var rarity := 0
var ratio := 1.0          # 1 = skill pronta
var show_cd := false
var selected := false
var dim := false
## com moldura, a arte (coroas, orelhas) e cortada no quadro para nao vazar do cartao
var frame := true:
	set(v):
		frame = v
		clip_contents = v
		queue_redraw()
var stars := -1
var silhouette := false


func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	clip_contents = true
	set_process(false)


func _process(_dt: float) -> void:
	queue_redraw()


func setup(id: String, r: int = -1, gray: bool = false) -> BallIcon:
	var def: Dictionary = DB.BALLS.get(id, {})
	if def.is_empty():
		tex = null
	else:
		tex = PixelArt.ball(def.look, gray)
		rarity = r if r >= 0 else int(def.rarity)
	queue_redraw()
	return self


func setup_look(look: Dictionary, r: int) -> BallIcon:
	tex = PixelArt.ball(look)
	rarity = r
	queue_redraw()
	return self


func _gui_input(e: InputEvent) -> void:
	if (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		pressed.emit()
		accept_event()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if frame:
		var col := DB.rcolor(rarity) if not dim else Color(0.5, 0.48, 0.45)
		draw_rect(r, UI.C_BORDER)
		draw_rect(r.grow(-3), col.lightened(0.35))
		var inner := r.grow(-6)
		# degrade vertical
		var steps := 12
		for i in steps:
			var t := float(i) / steps
			draw_rect(Rect2(inner.position.x, inner.position.y + inner.size.y * t, inner.size.x, inner.size.y / steps + 1.0), col.lightened(0.2).lerp(col.darkened(0.35), t))
		# luz radial atras da bolinha
		var c0 := size * 0.5
		var rad := minf(size.x, size.y) * 0.46
		for i in 6:
			draw_circle(c0, rad * (1.0 - i * 0.13), Color(1, 1, 1, 0.05 + i * 0.012))
		# faixa de brilho diagonal
		var sh := PackedVector2Array([inner.position + Vector2(inner.size.x * 0.55, 0), inner.position + Vector2(inner.size.x * 0.75, 0),
			inner.position + Vector2(inner.size.x * 0.35, inner.size.y), inner.position + Vector2(inner.size.x * 0.15, inner.size.y)])
		draw_colored_polygon(sh, Color(1, 1, 1, 0.08))
		if rarity >= 3 and not dim and not silhouette:
			var t2 := Time.get_ticks_msec() / 1000.0
			for i in 3:
				var sp := inner.position + Vector2(fposmod(i * 37.0 + t2 * 9.0, inner.size.x), fposmod(i * 53.0 + 11.0, inner.size.y * 0.5))
				var s2 := 3.0 + 2.0 * sin(t2 * 3.0 + i * 2.0)
				draw_colored_polygon(PackedVector2Array([sp + Vector2(0, -s2), sp + Vector2(s2 * 0.3, 0), sp + Vector2(0, s2), sp + Vector2(-s2 * 0.3, 0)]), Color(1, 1, 0.9, 0.8))
				draw_colored_polygon(PackedVector2Array([sp + Vector2(-s2, 0), sp + Vector2(0, s2 * 0.3), sp + Vector2(s2, 0), sp + Vector2(0, -s2 * 0.3)]), Color(1, 1, 0.9, 0.8))
			if not is_processing():
				set_process(true)
	if selected:
		draw_rect(r.grow(-1), Color.WHITE, false, 3.0)
	if tex:
		var s := minf(size.x, size.y) / float(BallArt.SIZE) * 1.08
		var ts := Vector2(BallArt.SIZE, BallArt.SIZE) * s
		var tm := Color(1, 1, 1, 0.55) if dim else Color.WHITE
		if silhouette:
			tm = Color(0.13, 0.1, 0.18, 0.88)
		draw_texture_rect(tex, Rect2((size - ts) * 0.5 + Vector2(0, -2), ts), false, tm)
	if show_cd and ratio < 1.0:
		var c := size * 0.5
		var pts := PackedVector2Array([c])
		var a0 := -PI / 2.0 + TAU * ratio
		for i in 25:
			var a := lerpf(a0, -PI / 2.0 + TAU, i / 24.0)
			pts.append(c + Vector2(cos(a), sin(a)) * size.length())
		var cp := _clip(pts)
		if cp.size() >= 3:
			draw_colored_polygon(cp, Color(0, 0, 0, 0.5))
	elif show_cd:
		draw_rect(r.grow(-2), Color("#ffd23c"), false, 3.0)
	if stars >= 0:
		var star := PixelArt.icon("star")
		var se := PixelArt.icon("star_empty")
		var ss := 14.0
		var x0 := (size.x - ss * 5) * 0.5
		for i in 5:
			draw_texture_rect(star if i < stars else se, Rect2(x0 + i * ss, size.y - ss - 2, ss, ss), false)


func _clip(pts: PackedVector2Array) -> PackedVector2Array:
	var box := PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)])
	var res := Geometry2D.intersect_polygons(pts, box)
	return res[0] if res.size() > 0 else PackedVector2Array()

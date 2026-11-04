class_name ItemTile
extends Button
## Quadrado de equipamento (como no print): fundo na cor da raridade, icone pixel e "Nv. X".

var item: Dictionary = {}
var slot := ""
var locked := false
var tag := ""        # texto pequeno no canto ("A distancia")
var arrow := 0       # 1 melhor, -1 pior (comparacao)


func _init() -> void:
	focus_mode = Control.FOCUS_NONE
	text = ""
	flat = true
	add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	add_theme_stylebox_override("pressed", StyleBoxEmpty.new())


func set_item(it: Dictionary, s: String, is_locked: bool = false) -> void:
	item = it
	slot = s
	locked = is_locked
	tag = ""
	if s == "weapon" and not it.is_empty():
		tag = DB.WEAPON_TYPES[int(it.get("wtype", 0))]
	queue_redraw()


static func icon_id(s: String, it: Dictionary) -> String:
	if s == "weapon":
		return "weapon_ranged" if int(it.get("wtype", 0)) == 1 else "weapon_melee"
	return s


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var empty := item.is_empty()
	var bg := Color("#e6d8b8") if empty else DB.rcolor(int(item.rarity)).lightened(0.35)
	if locked:
		bg = Color("#d8ccb0")
	var press := 2.0 if button_pressed or is_hovered() else 0.0
	draw_rect(r, UI.C_BORDER)
	draw_rect(Rect2(3, 3, r.size.x - 6, r.size.y - 8), bg)
	draw_rect(Rect2(3, r.size.y - 8, r.size.x - 6, 5), bg.darkened(0.25))
	draw_rect(Rect2(6, 6, r.size.x - 12, 4), Color(1, 1, 1, 0.25))
	var tex := PixelArt.icon(icon_id(slot, item))
	var s := floorf(minf(size.x - 16, size.y - 30) / 18.0)
	s = maxf(s, 2.0)
	var ts := Vector2(18, 18) * s
	var mod := Color(1, 1, 1, 1)
	if empty or locked:
		mod = Color(0.2, 0.15, 0.1, 0.25)
	draw_texture_rect(tex, Rect2((size - ts) * 0.5 + Vector2(0, -8 + press), ts), false, mod)
	var f := UI.font()
	if locked:
		var lk := PixelArt.icon("lock")
		draw_texture_rect(lk, Rect2(size * 0.5 - Vector2(18, 18), Vector2(36, 36)), false)
	if not empty:
		var txt := "Nv. %d" % int(item.level)
		var fs := 20
		var tw := f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var p := Vector2((size.x - tw) * 0.5, size.y - 12)
		draw_string_outline(f, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 7, UI.C_OUTLINE)
		draw_string(f, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	if not empty and item.has("set"):
		draw_rect(Rect2(1, 1, size.x - 2, size.y - 2), Color("#ffcf3a"), false, 3.0)
		var sfs := 12
		var sw := f.get_string_size("SET", HORIZONTAL_ALIGNMENT_LEFT, -1, sfs).x
		draw_rect(Rect2(size.x - sw - 12, 4, sw + 8, 16), Color("#a0600a"))
		draw_string(f, Vector2(size.x - sw - 8, 16), "SET", HORIZONTAL_ALIGNMENT_LEFT, -1, sfs, Color("#ffe27a"))
	if tag != "":
		var fs2 := 13
		var tw2 := f.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, fs2).x
		draw_rect(Rect2(-4, -8, tw2 + 10, 20), Color.WHITE)
		draw_rect(Rect2(-4, -8, tw2 + 10, 20), UI.C_BORDER, false, 2.0)
		draw_string(f, Vector2(1, 7), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, fs2, UI.C_TEXT_DARK)
	if arrow != 0:
		var c := Color("#3cd650") if arrow > 0 else Color("#ff4a4a")
		var pts := PackedVector2Array([Vector2(size.x - 22, 22), Vector2(size.x - 8, 22), Vector2(size.x - 15, 10)]) if arrow > 0 else PackedVector2Array([Vector2(size.x - 22, 10), Vector2(size.x - 8, 10), Vector2(size.x - 15, 22)])
		var outline := PackedVector2Array([pts[0] + Vector2(-2, 1), pts[1] + Vector2(2, 1), pts[2] + Vector2(0, -2 * arrow)])
		draw_colored_polygon(outline, UI.C_BORDER)
		draw_colored_polygon(pts, c)

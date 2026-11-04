class_name UI
## Tema e componentes visuais. Linguagem: papel creme com borda de tinta marrom, fitas (ribbons) nos titulos,
## botoes com relevo que afundam ao tocar, icones pixel. Tudo pensado para toque (alvos >= 48 px).

const FONT_PATH := "res://assets/fonts/PixelifySans.ttf"

const C_BG := Color("#3f9a54")
const C_BG_DARK := Color("#2c7a40")
const C_CREAM := Color("#f8efd8")
const C_CREAM_DARK := Color("#eadcb8")
const C_PAPER_LINE := Color("#e2d0a8")
const C_BORDER := Color("#3a2a20")
const C_BROWN := Color("#7a5a44")
const C_BROWN_DARK := Color("#4e3a2e")
const C_YELLOW := Color("#ffcf3a")
const C_BLUE := Color("#5ab4f0")
const C_GREEN := Color("#5cc65a")
const C_RED := Color("#ec5a48")
const C_PURPLE := Color("#9a64e0")
const C_GRAY := Color("#b8b0a0")
const C_TEXT_DARK := Color("#3a2a20")
const C_TEXT_MID := Color("#6e5848")
const C_OUTLINE := Color("#2a1e18")

static var _font: Font
static var _theme: Theme


static func font() -> Font:
	if _font == null:
		var f := FontVariation.new()
		var base := load(FONT_PATH) as FontFile
		base.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
		base.hinting = TextServer.HINTING_LIGHT
		base.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		f.base_font = base
		var ts := TextServerManager.get_primary_interface()
		f.variation_opentype = {ts.name_to_tag("wght"): 500}
		f.opentype_features = {ts.name_to_tag("liga"): 0, ts.name_to_tag("clig"): 0, ts.name_to_tag("dlig"): 0, ts.name_to_tag("calt"): 0}
		_font = f
	return _font


static func box(bg: Color, border: Color = C_BORDER, bw: int = 4, bottom: int = 0, radius: int = 8) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.border_width_bottom = bw + bottom
	s.set_corner_radius_all(radius)
	s.anti_aliasing = true
	s.set_content_margin_all(8)
	return s


static func paper(bg: Color = C_CREAM, radius: int = 12) -> StyleBoxFlat:
	var s := box(bg, C_BORDER, 4, 2, radius)
	s.shadow_color = Color(0, 0, 0, 0.18)
	s.shadow_size = 4
	s.shadow_offset = Vector2(0, 4)
	s.set_content_margin_all(12)
	return s


static func theme() -> Theme:
	if _theme:
		return _theme
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = 22
	for cls in ["Label", "Button", "LineEdit", "RichTextLabel"]:
		t.set_color("font_outline_color", cls, C_OUTLINE)
		t.set_constant("outline_size", cls, 6)
		t.set_color("font_color", cls, Color.WHITE)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color(0.95, 0.95, 0.95))
	t.set_color("font_disabled_color", "Button", Color(0.92, 0.9, 0.88))
	t.set_color("font_focus_color", "Button", Color.WHITE)
	t.set_stylebox("panel", "PanelContainer", paper())
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	var sb := box(Color(0, 0, 0, 0.08), Color(0, 0, 0, 0), 0, 0, 6)
	sb.set_content_margin_all(2)
	var grab := box(C_BROWN, C_BROWN_DARK, 2, 0, 6)
	grab.set_content_margin_all(5)
	for n in ["grabber", "grabber_highlight", "grabber_pressed"]:
		t.set_stylebox(n, "VScrollBar", grab)
		t.set_stylebox(n, "HScrollBar", grab)
	t.set_stylebox("scroll", "VScrollBar", sb)
	t.set_stylebox("scroll", "HScrollBar", sb)
	var le := box(Color("#fffaf0"), C_BORDER, 3, 0, 8)
	t.set_stylebox("normal", "LineEdit", le)
	t.set_stylebox("focus", "LineEdit", box(Color("#fffaf0"), C_YELLOW.darkened(0.3), 3, 0, 8))
	t.set_color("font_color", "LineEdit", C_TEXT_DARK)
	t.set_constant("outline_size", "LineEdit", 0)
	_theme = t
	return t


# ---------------------------------------------------------------------------------------------
# textos
# ---------------------------------------------------------------------------------------------
static func label(text: String, size: int = 22, color: Color = Color.WHITE, outline: int = 6) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", outline)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func dark_label(text: String, size: int = 20) -> Label:
	return label(text, size, C_TEXT_DARK, 0)


## texto que quebra linha e ocupa a largura disponivel (nunca corta)
static func para(text: String, size: int = 18, color: Color = C_TEXT_DARK, outline: int = 0) -> Label:
	var l := label(text, size, color, outline)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.custom_minimum_size = Vector2(60, 0)
	return l


# ---------------------------------------------------------------------------------------------
# botoes
# ---------------------------------------------------------------------------------------------
static func button(text: String, color: Color = C_YELLOW, size: int = 22, min_size: Vector2 = Vector2(0, 0)) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	style_button(b, color)
	b.custom_minimum_size = Vector2(maxf(min_size.x, 0), maxf(min_size.y, 52))
	b.focus_mode = Control.FOCUS_NONE
	b.autowrap_mode = TextServer.AUTOWRAP_OFF
	press_anim(b)
	return b


static func style_button(b: Button, color: Color) -> void:
	var n := box(color, C_BORDER, 3, 5, 12)
	n.content_margin_top = 6
	n.content_margin_bottom = 9
	n.content_margin_left = 12
	n.content_margin_right = 12
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = color.lightened(0.1)
	var p := box(color.darkened(0.1), C_BORDER, 3, 2, 12)
	p.content_margin_top = 9
	p.content_margin_bottom = 6
	p.content_margin_left = 12
	p.content_margin_right = 12
	var d := n.duplicate() as StyleBoxFlat
	d.bg_color = Color("#a8a098")
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", p)
	b.add_theme_stylebox_override("hover_pressed", p)
	b.add_theme_stylebox_override("disabled", d)


## pequeno "pulo" ao apertar
static func press_anim(c: Control) -> void:
	c.resized.connect(func() -> void: c.pivot_offset = c.size * 0.5)
	c.gui_input.connect(func(e: InputEvent) -> void:
		var down = (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT)
		if not down:
			return
		var tw := c.create_tween()
		if e.pressed:
			tw.tween_property(c, "scale", Vector2(0.94, 0.94), 0.06)
		else:
			tw.tween_property(c, "scale", Vector2(1.04, 1.04), 0.07)
			tw.tween_property(c, "scale", Vector2.ONE, 0.08))


static func icon_button(icon: String, color: Color, sz: Vector2) -> Button:
	var b := button("", color, 18, sz)
	b.icon = PixelArt.icon(icon)
	b.expand_icon = true
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.add_theme_constant_override("icon_max_width", int(minf(sz.x, sz.y) - 20))
	return b


# ---------------------------------------------------------------------------------------------
# paineis
# ---------------------------------------------------------------------------------------------
static func panel(bg: Color = C_CREAM, border: Color = C_BORDER, bw: int = 4) -> PanelContainer:
	var p := PanelContainer.new()
	var s := box(bg, border, bw, 2, 12)
	s.set_content_margin_all(12)
	p.add_theme_stylebox_override("panel", s)
	return p


static func card(bg: Color = Color("#fffaf0"), accent: Color = Color(0, 0, 0, 0)) -> Array:
	var p := PanelContainer.new()
	var s := box(bg, C_BORDER, 3, 3, 12)
	s.set_content_margin_all(12)
	if accent.a > 0.0:
		s.border_width_left = 10
		s.border_color = C_BORDER
		s.bg_color = bg
		p.draw.connect(func() -> void:
			p.draw_rect(Rect2(3, 3, 6, p.size.y - 9), accent))
	p.add_theme_stylebox_override("panel", s)
	var v := vbox(6)
	p.add_child(v)
	return [p, v]


static func tex_rect(tex: Texture2D, size: Vector2, linear: bool = false) -> TextureRect:
	var t := TextureRect.new()
	t.texture = tex
	t.custom_minimum_size = size
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if linear else CanvasItem.TEXTURE_FILTER_NEAREST
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


static func hbox(sep: int = 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h


static func vbox(sep: int = 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


static func margin(c: Control, m: int, mv: int = -1) -> MarginContainer:
	var mc := MarginContainer.new()
	mc.add_theme_constant_override("margin_left", m)
	mc.add_theme_constant_override("margin_right", m)
	mc.add_theme_constant_override("margin_top", m if mv < 0 else mv)
	mc.add_theme_constant_override("margin_bottom", m if mv < 0 else mv)
	mc.add_child(c)
	return mc


static func spacer(w: float = 0, h: float = 0) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, h)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if w == 0 and h == 0:
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c


## fita de titulo com pontas recortadas
static func ribbon(text: String, color: Color = C_BROWN, size: int = 24) -> Control:
	var c := Control.new()
	var l := label(text, size)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	c.add_child(l)
	c.custom_minimum_size = Vector2(0, size + 26)
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.draw.connect(func() -> void:
		var w := c.size.x
		var h := c.size.y
		var n := 14.0
		var tail := PackedVector2Array([Vector2(0, 6), Vector2(n + 8, 6), Vector2(n + 8, h), Vector2(0, h), Vector2(n * 0.6, h * 0.55 + 3)])
		var tail2 := PackedVector2Array([Vector2(w, 6), Vector2(w - n - 8, 6), Vector2(w - n - 8, h), Vector2(w, h), Vector2(w - n * 0.6, h * 0.55 + 3)])
		for t in [tail, tail2]:
			c.draw_colored_polygon(t, C_BORDER)
		var inner := PackedVector2Array()
		for p in tail:
			inner.append(p + Vector2(3, 0) * (1.0 if p.x < n else -1.0) + Vector2(0, 0))
		c.draw_colored_polygon(PackedVector2Array([Vector2(3, 9), Vector2(n + 8, 9), Vector2(n + 8, h - 3), Vector2(3, h - 3), Vector2(n * 0.6 + 2, h * 0.55 + 3)]), color.darkened(0.3))
		c.draw_colored_polygon(PackedVector2Array([Vector2(w - 3, 9), Vector2(w - n - 8, 9), Vector2(w - n - 8, h - 3), Vector2(w - 3, h - 3), Vector2(w - n * 0.6 - 2, h * 0.55 + 3)]), color.darkened(0.3))
		var body := Rect2(n, 0, w - n * 2, h - 6)
		c.draw_rect(body, C_BORDER)
		c.draw_rect(body.grow(-3), color)
		c.draw_rect(Rect2(body.position + Vector2(3, 3), Vector2(body.size.x - 6, 4)), Color(1, 1, 1, 0.22)))
	return c


## etiqueta pequena (pilula)
static func badge(text: String, color: Color, size: int = 15) -> PanelContainer:
	var p := PanelContainer.new()
	var s := box(color, C_BORDER, 2, 1, 10)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 1
	s.content_margin_bottom = 2
	p.add_theme_stylebox_override("panel", s)
	var l := label(text, size, Color.WHITE, 4)
	p.add_child(l)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


## pilula de moeda/gema no topo
static func currency_pill(icon_id: String, value_label: Label, plus: bool = false) -> PanelContainer:
	var p := PanelContainer.new()
	var s := box(Color(0.08, 0.25, 0.14, 0.55), Color(0, 0, 0, 0.35), 2, 0, 18)
	s.content_margin_left = 6
	s.content_margin_right = 10
	s.content_margin_top = 2
	s.content_margin_bottom = 2
	p.add_theme_stylebox_override("panel", s)
	var h := hbox(6)
	h.add_child(tex_rect(PixelArt.icon(icon_id), Vector2(36, 36)))
	value_label.custom_minimum_size = Vector2(84, 0)
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(value_label)
	if plus:
		var pl := label("+", 22, C_YELLOW)
		h.add_child(pl)
	p.add_child(h)
	return p


static func bar(fill: Color, h: int = 16) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(0, h)
	b.add_theme_stylebox_override("background", box(Color("#4a382e"), C_BORDER, 3, 0, h / 2))
	var f := box(fill, Color(0, 0, 0, 0), 0, 0, h / 2)
	f.set_content_margin_all(0)
	b.add_theme_stylebox_override("fill", f)
	b.max_value = 1.0
	return b


# ---------------------------------------------------------------------------------------------
# numeros
# ---------------------------------------------------------------------------------------------
const SUFFIX := ["", "k", "M", "B", "T", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah"]


static func fmt(v: float) -> String:
	var neg := v < 0
	v = absf(v)
	if v < 1000.0:
		return ("-" if neg else "") + str(int(v))
	var i := 0
	while v >= 1000.0 and i < SUFFIX.size() - 1:
		v /= 1000.0
		i += 1
	var s: String
	if v >= 100.0:
		s = str(int(v))
	else:
		s = ("%.1f" % v).replace(".", ",")
		if s.ends_with(",0"):
			s = s.substr(0, s.length() - 2)
	return ("-" if neg else "") + s + SUFFIX[i]


static func pct(v: float) -> String:
	var x := v * 100.0
	if absf(x) >= 10.0 or is_equal_approx(x, roundf(x)):
		return "%d%%" % int(roundf(x))
	return ("%.1f" % x).replace(".", ",") + "%"


static func time_str(sec: float) -> String:
	var s := int(sec)
	if s >= 3600:
		return "%dh%02dm" % [s / 3600, (s % 3600) / 60]
	if s >= 60:
		return "%dm%02ds" % [s / 60, s % 60]
	return "%ds" % s

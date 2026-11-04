class_name NavButton
extends Control
## Botao da barra inferior. Quando selecionado vira uma "aba" creme elevada, com o icone maior.

signal pressed

var tex: Texture2D
var text := ""
var selected := false:
	set(v):
		if v != selected:
			selected = v
			_lift = 0.0
		queue_redraw()
var dot := false:
	set(v):
		dot = v
		queue_redraw()
var linear := false
var _lift := 1.0
var _t := 0.0
var _last_press := -1000


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(96, 100)


func _process(delta: float) -> void:
	_t += delta
	if _lift < 1.0:
		_lift = minf(1.0, _lift + delta * 5.0)
		queue_redraw()
	elif selected or dot:
		queue_redraw()


func _gui_input(e: InputEvent) -> void:
	# so o evento de mouse (no celular o toque ja e emulado como mouse; tratar os dois disparava 2x
	# e a aba abria e fechava no mesmo toque)
	if (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT):
		accept_event()
		var now := Time.get_ticks_msec()
		if now - _last_press < 250:
			return
		_last_press = now
		pressed.emit()


func _draw() -> void:
	var f := UI.font()
	var w := size.x
	var h := size.y
	var k := 1.0 - pow(1.0 - _lift, 3.0)
	if selected:
		# aba elevada
		var top := -14.0 * k
		var r := Rect2(4, top, w - 8, h - top + 4)
		draw_rect(r, UI.C_BORDER)
		draw_rect(r.grow(-3), UI.C_CREAM)
		draw_rect(Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6, 5)), Color(1, 1, 1, 0.5))
	var isz := 56.0 + (10.0 * k if selected else 0.0)
	var bounce := sin(_t * 4.0) * 2.0 if selected else 0.0
	var ip := Vector2((w - isz) * 0.5, (6.0 - 16.0 * k if selected else 8.0) + bounce)
	if tex:
		draw_texture_rect(tex, Rect2(ip, Vector2(isz, isz)), false, Color.WHITE if selected else Color(0.92, 0.88, 0.84))
	var fs := 18
	var tw := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var tp := Vector2((w - tw) * 0.5, h - 12)
	var col := UI.C_BROWN_DARK if selected else Color.WHITE
	if not selected:
		draw_string_outline(f, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, UI.C_OUTLINE)
	draw_string(f, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	if dot:
		var dp := Vector2(w * 0.5 + 24, 12)
		var s := 1.0 + 0.15 * sin(_t * 6.0)
		draw_circle(dp, 9.0 * s, UI.C_BORDER)
		draw_circle(dp, 6.5 * s, Color("#ff4a3a"))

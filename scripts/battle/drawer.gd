class_name Drawer
extends Node2D
## No temporario que desenha via callable (bracos elasticos, raios, rastros, textos flutuantes, overlays).
##   draw_fn(node: Drawer, k: float) -> k vai de 0 a 1 ao longo da vida

var draw_fn: Callable
var life := 0.5
var t := 0.0
var vel := Vector2.ZERO


static func spawn(parent: Node, pos: Vector2, life_s: float, fn: Callable) -> Drawer:
	var d := Drawer.new()
	d.draw_fn = fn
	d.life = life_s
	d.position = pos
	parent.add_child(d)
	return d


## texto flutuante (dano, cura, nome de skill)
static func text(parent: Node, pos: Vector2, txt: String, col: Color, size: int = 22, life_s: float = 0.8, rise: float = 50.0) -> Drawer:
	var f := UI.font()
	var w := f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var d := spawn(parent, pos, life_s, func(n: Drawer, k: float) -> void:
		var a := 1.0 if k < 0.7 else (1.0 - (k - 0.7) / 0.3)
		var pop := 1.0 + maxf(0.0, 0.25 - k) * 2.0
		n.draw_set_transform(Vector2.ZERO, 0.0, Vector2(pop, pop))
		n.draw_string_outline(f, Vector2(-w * 0.5, 0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 7, Color(0.16, 0.1, 0.08, a))
		n.draw_string(f, Vector2(-w * 0.5, 0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(col, a)))
	d.vel = Vector2(randf_range(-12, 12), -rise)
	return d


func _process(delta: float) -> void:
	t += delta
	position += vel * delta
	vel *= 0.94
	if t >= life:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if draw_fn.is_valid():
		draw_fn.call(self, clampf(t / life, 0.0, 1.0))

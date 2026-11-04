class_name ZoneArea
extends Node2D
## Skill "zone": area persistente (dominio, nevoa, buraco negro...) que da dano por tick e pode puxar.

var battle: Battle
var owner_u: Unit
var skill: Dictionary
var power := 1.0
var radius := 90.0
var dur := 4.0
var pull := 0.0
var on_self := false
var t := 0.0
var tick := 0.0
var col := Color.WHITE
var visual: CuteFx


func setup(b: Battle, u: Unit, d: Dictionary, pw: float, pos: Vector2) -> void:
	battle = b
	owner_u = u
	skill = d
	power = pw
	radius = float(DB.p(d, "radius", u.rarity, 90.0))
	dur = float(DB.p(d, "dur", u.rarity, 4.0))
	pull = float(d.get("pull", 0.0))
	on_self = bool(d.get("on_self", false))
	position = pos
	var fxn: String = d.get("fx", "magic_circle")
	col = CuteFx.color_of(fxn)
	var k := CuteFx.kind_of(fxn)
	if not k in ["swirl", "rune", "bubbles", "flame"]:
		k = "rune"
	visual = CuteFx.make(fxn, {"kind": k, "size": radius, "loop": true, "dur": 1.6})
	add_child(visual)


func _physics_process(dt: float) -> void:
	if battle.ended or not is_instance_valid(owner_u):
		queue_free()
		return
	if not battle.running:
		return
	t += dt
	if on_self and not owner_u.dead:
		position = owner_u.position
	if t >= dur:
		queue_free()
		return
	tick -= dt
	for e: Unit in battle.enemies_of(owner_u):
		var v := position - e.position
		if v.length() > radius + e.radius():
			continue
		if pull > 0.0:
			e.vel += v.normalized() * pull * dt * 4.0
	if tick <= 0.0 and not owner_u.dead:
		tick = 0.5
		for e: Unit in battle.in_radius(owner_u, position, radius):
			Skills.hit(battle, owner_u, e, skill, power * 0.5)
	queue_redraw()


func _draw() -> void:
	var a := 1.0 if t < dur - 0.3 else (dur - t) / 0.3
	draw_circle(Vector2.ZERO, radius, Color(col, 0.14 * a))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 56, Color("#1b1420", 0.5 * a), 5.0, true)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 56, Color(col.lightened(0.3), 0.9 * a), 2.5, true)
	if visual:
		visual.modulate.a = a

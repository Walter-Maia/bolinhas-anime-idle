class_name OrbitBlades
extends Node2D
## Skill "orbit": orbes/laminas girando em volta de quem usou, ferindo ao tocar.

var battle: Battle
var owner_u: Unit
var skill: Dictionary
var power := 1.0
var count := 3
var dur := 5.0
var orbit_r := 70.0
var t := 0.0
var shape := ""
var shape_color := Color.WHITE
var fx_name := ""
var cd: Dictionary = {}
var sprites: Array = []


func setup(b: Battle, u: Unit, d: Dictionary, pw: float, n: int) -> void:
	battle = b
	owner_u = u
	skill = d
	power = pw
	count = maxi(1, n)
	dur = float(DB.p(d, "dur", u.rarity, 5.0))
	orbit_r = float(d.get("orbit_r", u.radius() * 2.2))
	shape = d.get("shape", "")
	fx_name = d.get("fx", "")
	shape_color = Color(d.get("shape_color", CuteFx.color_of(fx_name if fx_name != "" else "orb").to_html()))
	if shape == "" and fx_name != "":
		for i in count:
			var s := CuteFx.make(fx_name, {"kind": "orb", "size": 13.0, "loop": true})
			add_child(s)
			sprites.append(s)


func _physics_process(dt: float) -> void:
	if not is_instance_valid(owner_u) or owner_u.dead or battle.ended:
		queue_free()
		return
	if not battle.running:
		return
	t += dt
	position = owner_u.position
	if t >= dur:
		battle.fx(position, "poof", {"size": orbit_r * 0.5, "color": shape_color})
		queue_free()
		return
	for k in cd.keys():
		cd[k] -= dt
		if cd[k] <= 0.0:
			cd.erase(k)
	for i in count:
		var p := _pos(i)
		if i < sprites.size():
			(sprites[i] as Node2D).position = p
		for e: Unit in battle.enemies_of(owner_u):
			var key := e.get_instance_id() * 16 + i
			if cd.has(key):
				continue
			if (position + p).distance_to(e.position) <= 14.0 + e.radius():
				cd[key] = 0.5
				Skills.hit(battle, owner_u, e, skill, power / maxf(1.0, count * 0.6))
				battle.fx(position + p, "hit", {"size": 18.0, "color": shape_color})
	queue_redraw()


func _pos(i: int) -> Vector2:
	var grow := minf(1.0, t * 3.0)
	var ang := t * 4.0 + TAU * i / float(count)
	return Vector2(cos(ang), sin(ang)) * orbit_r * grow


func _draw() -> void:
	if shape == "":
		return
	var a := 1.0 if t < dur - 0.3 else (dur - t) / 0.3
	for i in count:
		var p := _pos(i)
		var ang := t * 4.0 + TAU * i / float(count) + PI * 0.5
		match shape:
			"petal":
				_petal(p, ang, a)
			"blade":
				WeaponArt.draw(self, "katana", shape_color, p, ang, 0.9, a)
			"card":
				WeaponArt.draw(self, "card", shape_color, p, ang + t * 6.0, 1.0, a)
			"feather":
				WeaponArt.draw(self, "feather", shape_color, p, ang, 1.0, a)
			"chain":
				WeaponArt.draw(self, "chain", shape_color, p, ang, 0.8, a)
			"bubble":
				draw_circle(p, 10.0, Color("#1b1420", a))
				draw_circle(p, 8.0, Color(shape_color, 0.6 * a))
				draw_circle(p + Vector2(-3, -3), 2.5, Color(1, 1, 1, a))
			"star":
				var pts := PackedVector2Array()
				for k in 10:
					var an := t * 5.0 - PI / 2.0 + TAU * k / 10.0
					pts.append(p + Vector2(cos(an), sin(an)) * (11.0 if k % 2 == 0 else 5.0))
				WeaponArt.poly(self, pts, shape_color, a)
			_:
				draw_circle(p, 9.0, Color("#1b1420", a))
				draw_circle(p, 7.0, Color(shape_color, a))


func _petal(p: Vector2, ang: float, a: float) -> void:
	# chuva de petalas: cada "lamina" e um cacho de 4 petalas
	for k in 4:
		var off := Vector2(cos(ang + k * 1.6), sin(ang + k * 1.6)) * 7.0
		draw_set_transform(p + off, ang + k, Vector2.ONE)
		draw_colored_polygon(PackedVector2Array([Vector2(-7.5, 0), Vector2(0, -4.4), Vector2(7.5, 0), Vector2(0, 4.4)]), Color("#1b1420", a))
		draw_colored_polygon(PackedVector2Array([Vector2(-6, 0), Vector2(0, -3.5), Vector2(6, 0), Vector2(0, 3.5)]), Color(shape_color, a))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

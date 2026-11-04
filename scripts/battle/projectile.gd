class_name Projectile
extends Node2D
## Projetil de skill (visual CuteFx) ou tiro basico (desenhado).

var battle: Battle
var src: Unit
var team := 0
var vel := Vector2.ZERO
var power := 1.0
var hit_r := 14.0
var pierce := false
var aoe := 0.0
var hit_fx := ""
var hit_scale := 0.5
var skill: Dictionary = {}
var shake_amt := 0.0
var kind := "skill"
var target: Unit
var homing := 2.5
var life := 4.0
var hit: Dictionary = {}
var sprite: Node2D
var color := Color.WHITE
var trail: Array = []


func _physics_process(dt: float) -> void:
	if battle == null or battle.ended:
		queue_free()
		return
	if not battle.running:
		return
	life -= dt
	if is_instance_valid(target) and not target.dead and homing > 0.0 and not pierce:
		var want := (target.position - position).normalized() * vel.length()
		vel = vel.lerp(want, clampf(homing * dt, 0.0, 1.0))
	position += vel * dt
	if sprite:
		sprite.rotation = vel.angle()
	if kind == "shot":
		trail.push_front(position)
		if trail.size() > 5:
			trail.pop_back()
		queue_redraw()
	var m := 60.0
	if life <= 0.0 or position.x < -m or position.y < -m or position.x > battle.arena.x + m or position.y > battle.arena.y + m:
		queue_free()
		return
	for u: Unit in battle.units:
		if u.dead or u.team == team or hit.has(u.get_instance_id()):
			continue
		if position.distance_to(u.position) <= hit_r + u.radius():
			hit[u.get_instance_id()] = true
			_on_hit(u)
			if not pierce:
				queue_free()
				return


func _on_hit(u: Unit) -> void:
	var s: Unit = src if is_instance_valid(src) else null
	battle.deal(s, u, power, {"kind": kind, "raw": power * 10.0})
	if hit_fx != "":
		battle.fx(u.position, hit_fx, {"scale": hit_scale, "rot": vel.angle()})
	if s and not skill.is_empty():
		Skills.apply_skill_status(battle, s, u, skill)
	if shake_amt > 0.0:
		battle.add_shake(shake_amt)
	if aoe > 0.0 and s:
		battle.fx(u.position, "burst", {"size": aoe, "color": CuteFx.color_of(str(skill.get("fx", "orb")))})
		for e: Unit in battle.in_radius(s, u.position, aoe):
			if e != u:
				battle.deal(s, e, power * 0.5, {"kind": "skill"})


func _draw() -> void:
	if kind != "shot":
		return
	for i in trail.size():
		var p: Vector2 = trail[i] - position
		var a := 1.0 - float(i) / trail.size()
		draw_circle(p, 4.0 * a, Color(color, a * 0.6))
	draw_circle(Vector2.ZERO, 6.5, Color("#1b1420"))
	draw_circle(Vector2.ZERO, 4.5, color.lightened(0.3))
	draw_circle(Vector2(-1.5, -1.5), 1.6, Color.WHITE)

class_name Fx
extends Sprite2D
## Toca uma sprite sheet exportada do pixelfx (assets/fx/<nome>.png + FxData.D).
##   Fx.spawn(parent, "orb_spiral", pos, {"center": true, "scale": 0.5, "rot": 0.3, "follow": unit, "life": 2.0})

# ancoras especiais (pontos de origem de feixes/sopros dentro do frame)
const ANCHORS := {
	"beam_ki": Vector2(11, 48), "beam_purple": Vector2(11, 48), "beam_gold": Vector2(11, 48),
}

static var _tex: Dictionary = {}
static var _add_mat: CanvasItemMaterial

var fx_name := ""
var fps := 15.0
var nframes := 1
var loop := false
var t := 0.0
var life := -1.0
var fade := 0.25
var follow: Node2D = null
var follow_offset := Vector2.ZERO
var speed := 1.0
var hold_last := false


static func tex(n: String) -> Texture2D:
	if not _tex.has(n):
		_tex[n] = load("res://assets/fx/%s.png" % n)
	return _tex[n]


static func exists(n: String) -> bool:
	return FxData.D.has(n)


static func make(n: String, opts: Dictionary = {}) -> Fx:
	if not FxData.D.has(n):
		push_warning("fx inexistente: " + n)
		return null
	var d: Dictionary = FxData.D[n]
	var f := Fx.new()
	f.fx_name = n
	f.texture = tex(n)
	f.hframes = int(d.cols)
	f.vframes = int(ceil(float(d.n) / float(d.cols)))
	f.nframes = int(d.n)
	f.fps = float(d.fps)
	f.loop = bool(d.loop) if not opts.has("loop") else bool(opts.loop)
	f.centered = false
	f.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var anchor := Vector2(float(d.px), float(d.py))
	if opts.get("center", false):
		anchor = Vector2(float(d.w), float(d.h)) * 0.5
	if ANCHORS.has(n) and not opts.get("center", false):
		anchor = ANCHORS[n]
	if opts.has("anchor"):
		anchor = opts.anchor
	f.offset = -anchor
	var s: Variant = opts.get("scale", 1.0)
	f.scale = s if s is Vector2 else Vector2(float(s), float(s))
	if opts.get("flip", false):
		f.scale.x *= -1.0
	f.rotation = float(opts.get("rot", 0.0))
	f.life = float(opts.get("life", -1.0))
	f.speed = float(opts.get("speed", 1.0))
	f.hold_last = bool(opts.get("hold", false))
	if opts.has("modulate"):
		f.modulate = opts.modulate
	if opts.get("add", false):
		if _add_mat == null:
			_add_mat = CanvasItemMaterial.new()
			_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		f.material = _add_mat
	if opts.has("follow"):
		f.follow = opts.follow
		f.follow_offset = opts.get("offset", Vector2.ZERO)
	f.z_index = int(opts.get("z", 0))
	if opts.has("start"):
		f.t = float(opts.start)
	f.frame = 0
	return f


static func spawn(parent: Node, n: String, pos: Vector2, opts: Dictionary = {}) -> Fx:
	var f := make(n, opts)
	if f == null:
		return null
	parent.add_child(f)
	f.position = pos
	if f.follow:
		f.position = f.follow.position + f.follow_offset
	return f


func duration() -> float:
	return nframes / fps


func _process(delta: float) -> void:
	t += delta * speed
	if follow != null:
		if not is_instance_valid(follow) or (follow.has_method("is_dead") and follow.is_dead()):
			queue_free()
			return
		position = follow.position + follow_offset
	var fr := int(t * fps)
	if loop:
		fr = fr % nframes
	elif fr >= nframes:
		if hold_last:
			fr = nframes - 1
		elif life < 0:
			queue_free()
			return
		else:
			fr = nframes - 1
	frame = fr
	if life >= 0:
		if t >= life:
			queue_free()
		elif t > life - fade:
			modulate.a = clampf((life - t) / fade, 0.0, 1.0)

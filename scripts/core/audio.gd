extends Node
## Audio (autoload "Audio"): efeitos com pool de players, musica em loop e clique automatico em todos os botoes.

const SFX := ["click", "hit", "hit_weapon", "crit", "skill", "explosion", "coin", "chest", "shake", "open", "fanfare",
	"levelup", "win", "lose", "transform", "heal", "swoosh"]

var _streams: Dictionary = {}
var _pool: Array = []
var _next := 0
var _last: Dictionary = {}
var _music: AudioStreamPlayer
var _music_name := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for n in SFX:
		var p := "res://assets/audio/%s.wav" % n
		if ResourceLoader.exists(p):
			_streams[n] = load(p)
	for i in 10:
		var pl := AudioStreamPlayer.new()
		add_child(pl)
		_pool.append(pl)
	_music = AudioStreamPlayer.new()
	_music.volume_db = -14.0
	add_child(_music)
	_music.finished.connect(func() -> void:
		if music_on():
			_music.play())
	get_tree().node_added.connect(_on_node_added)
	Game.leveled_up.connect(func(_l: int) -> void: sfx("levelup"))
	music("music_home")


func sound_on() -> bool:
	return bool(Game.d.get("sound", true))


func music_on() -> bool:
	return bool(Game.d.get("music", true))


func sfx(name: String, vol_db: float = 0.0, pitch_var: float = 0.08, min_gap: float = 0.05) -> void:
	if not sound_on() or not _streams.has(name):
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - float(_last.get(name, -10.0)) < min_gap:
		return
	_last[name] = now
	var pl: AudioStreamPlayer = _pool[_next]
	_next = (_next + 1) % _pool.size()
	pl.stream = _streams[name]
	pl.volume_db = vol_db - 4.0
	pl.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
	pl.play()


func music(name: String) -> void:
	if name == _music_name and _music.playing:
		return
	_music_name = name
	var p := "res://assets/audio/%s.wav" % name
	if not ResourceLoader.exists(p):
		return
	_music.stream = load(p)
	if music_on():
		_music.play()


func refresh() -> void:
	if music_on():
		if not _music.playing:
			_music.play()
	else:
		_music.stop()


func _on_node_added(n: Node) -> void:
	if n is BaseButton:
		(n as BaseButton).pressed.connect(func() -> void: sfx("click", -6.0, 0.05, 0.03))
	elif n.has_signal("pressed") and n is Control:
		n.connect("pressed", func() -> void: sfx("click", -6.0, 0.05, 0.03))

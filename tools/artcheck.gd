extends SceneTree
## Renderiza looks de teste do vocabulario novo: godot --headless --path . --script res://tools/artcheck.gd -- <saida.png>

func _init() -> void:
	var looks := [
		{"skin": "#f6d0a8", "hair": "#f4f4fa", "hair2": "#d42a30", "hair_style": "split", "outfit": "jacket", "outfit_color": "#2a3a6a"},
		{"skin": "#f6d0a8", "hair": "#ffe066", "hair_style": "odango", "outfit": "sailor", "outfit_color": "#2a4fa8", "acc": ["tiara"]},
		{"skin": "#f6d0a8", "hair": "#4a2a6a", "hair_style": "pineapple", "outfit": "uniform", "outfit_color": "#1c2240"},
		{"skin": "#f6d0a8", "hair": "#5c3a1e", "hair_style": "mid", "outfit": "cape", "outfit_color": "#2e6b3a"},
		{"skin": "#f6d0a8", "hair": "#14101e", "hair_style": "twin_braids", "outfit": "dress", "outfit_color": "#d42a30", "acc_color": "#ffd23c"},
		{"skin": "#f6d0a8", "hair": "#ffe066", "hair_style": "long_bangs", "outfit": "robe", "outfit_color": "#2a2a40", "tips": "#ff8a2a"},
		{"skin": "#e8b888", "hair": "#f4f4fa", "hair_style": "bald", "outfit": "coat", "outfit_color": "#f4f4fa", "acc": ["beard"], "acc_colors": {"beard": "#f4f4fa"}},
		{"skin": "#e8b888", "hair": "#14101e", "hair_style": "slick", "outfit": "suit", "outfit_color": "#14101e", "acc": ["mustache", "goatee", "high_collar"], "acc_colors": {"high_collar": "#14101e"}},
		{"skin": "#f6d0a8", "hair": "#d42a30", "hair_style": "messy", "outfit": "gi", "outfit_color": "#6a4a2a", "acc": ["gourd"]},
		{"skin": "#f6d0a8", "hair": "#2a3a2a", "hair_style": "short", "hat": "bucket", "hat_color": "#3a6a3a", "hat_color2": "#f4f4fa", "hat_stripes": true, "outfit": "coat", "outfit_color": "#2a2a30"},
		{"skin": "#f6d0a8", "hair": "#14101e", "hair_style": "long", "hat": "kasa", "hat_color": "#d8b878", "outfit": "kimono", "outfit_color": "#3a2a60"},
		{"skin": "#f6d0a8", "hair": "#ffe066", "hair_style": "spiky", "outfit": "armor", "outfit_color": "#2a3a8a", "acc": ["shoulder_pads", "fur_collar", "wings", "horns"], "acc_colors": {"wings": "#ff6a4a", "horns": "#3a2a60"}},
	]
	var cell := 132
	var img := Image.create(6 * cell, 2 * cell, false, Image.FORMAT_RGBA8)
	img.fill(Color("#f6ecd2"))
	for i in looks.size():
		img.blend_rect(BallArt.render(BallArt.normalize(looks[i])), Rect2i(0, 0, 120, 120), Vector2i((i % 6) * cell + 6, (i / 6) * cell + 6))
	img.save_png(OS.get_cmdline_user_args()[0])
	quit()

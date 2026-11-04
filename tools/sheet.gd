extends SceneTree
## Gera folhas de previa das bolinhas para revisao visual.
##   godot --headless --path . --script res://tools/sheet.gd -- <saida.png> <filtro> [colunas] [inicio] [quantidade]
## filtro: prefixo de id ("cdz2_"), "*" para todas, ou "file:balls_f1" para as bolinhas de um arquivo.
## Imprime "indice: id (nome)" na ordem dos quadrados (esquerda->direita, cima->baixo).
## No canto de cada quadrado: miniatura da forma transformada (look_tf), quando existir.

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://sheet.png"
	var filt: String = args[1] if args.size() > 1 else "*"
	var cols: int = int(args[2]) if args.size() > 2 else 8
	var start: int = int(args[3]) if args.size() > 3 else 0
	var count: int = int(args[4]) if args.size() > 4 else 9999
	var ids: Array = []
	if filt.begins_with("file:"):
		var sc: Script = load("res://scripts/data/%s.gd" % filt.substr(5))
		var consts := sc.get_script_constant_map()
		for b in consts.get("LIST", []):
			ids.append(b.id)
		for id in consts.get("DICT", {}):
			ids.append(id)
	else:
		for id in DB.BALLS:
			if filt == "*" or str(id).begins_with(filt):
				ids.append(id)
	ids = ids.slice(start, start + count)
	var rows := int(ceil(ids.size() / float(cols)))
	var cell := 132
	var img := Image.create(cols * cell, maxi(1, rows) * cell, false, Image.FORMAT_RGBA8)
	img.fill(Color("#f6ecd2"))
	for i in ids.size():
		var b: Dictionary = DB.BALLS[ids[i]]
		var bi := BallArt.render(b.look)
		var x := (i % cols) * cell + 6
		var y := (i / cols) * cell + 6
		img.fill_rect(Rect2i(x - 4, y - 4, 128, 128), DB.rcolor(int(b.rarity)).lightened(0.3))
		img.blend_rect(bi, Rect2i(0, 0, 120, 120), Vector2i(x, y))
		if b.has("look_tf_full"):
			var ti := BallArt.render(b.look_tf_full)
			ti.resize(44, 44, Image.INTERPOLATE_BILINEAR)
			img.blend_rect(ti, Rect2i(0, 0, 44, 44), Vector2i(x + 80, y + 80))
		print("%d: %s (%s)" % [start + i, ids[i], b.name])
	img.save_png(out)
	print("ok ", ids.size())
	quit()

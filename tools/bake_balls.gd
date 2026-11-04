extends SceneTree
## Pre-gera as texturas das bolinhas (todas as formas), inimigos e chefes em assets/balls/<chave>.png.
## Rode depois de mudar looks ou o gerador:  godot --headless --path . --script res://tools/bake_balls.gd

func _init() -> void:
	var dir := "res://assets/balls"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	# limpa os antigos
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".png") or f.ends_with(".import"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(dir + "/" + f))
	var looks: Array = []
	for id in DB.BALLS:
		var b: Dictionary = DB.BALLS[id]
		looks.append(b.look)
		if b.has("look_tf_full"):
			looks.append(b.look_tf_full)
		for a in b.get("actives", []):
			if a.get("summon_look") is Dictionary:
				looks.append(BallArt.normalize(a.summon_look))
	for k in DB.ENEMIES:
		looks.append(BallArt.normalize(DB.ENEMIES[k].look))
	for k in DB.BOSSES:
		looks.append(BallArt.normalize(DB.BOSSES[k].look))
	for k in DB.SUMMON_LOOKS:
		looks.append(BallArt.normalize(DB.SUMMON_LOOKS[k]))
	var done := {}
	for l in looks:
		var key := BallArt.key_of(l)
		if done.has(key):
			continue
		done[key] = true
		BallArt.render(l).save_png(ProjectSettings.globalize_path("%s/%s.png" % [dir, key]))
	print("bake: %d texturas" % done.size())
	quit()

class_name Snd
## Atalho para tocar sons sem depender do autoload existir (scripts de QA rodam sem autoloads).

static func play(name: String, vol_db: float = 0.0, pitch_var: float = 0.08, min_gap: float = 0.05) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var a := tree.root.get_node_or_null("Audio")
	if a:
		a.sfx(name, vol_db, pitch_var, min_gap)


static func music(name: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var a := tree.root.get_node_or_null("Audio")
	if a:
		a.music(name)

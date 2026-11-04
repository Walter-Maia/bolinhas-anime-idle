extends SceneTree
## Simula fases da campanha para checar o ritmo (tempo de luta e vitoria) com um jogador "tipico".
##   godot --headless --path . --script res://tools/balance.gd

var G: Node


func _init() -> void:
	G = load("res://scripts/core/game.gd").new()
	G.d = {"equip": {}, "upgrades": {}, "vip_until": 0, "purchases": {}, "best": 1}
	_run.call_deferred()


func _run() -> void:
	var battle := Battle.new()
	root.add_child(battle)
	await process_frame
	battle.set_arena(Vector2(680, 440))
	# [capitulo, fase, nivel da bolinha, raridade, nivel dos itens]
	var cases := [[1, 1, 1, 0, 1], [1, 5, 5, 0, 4], [1, 10, 9, 0, 8], [1, 20, 16, 1, 16], [2, 10, 24, 1, 28],
		[3, 1, 30, 2, 40], [4, 20, 40, 2, 78], [6, 10, 52, 3, 110], [8, 20, 66, 3, 160], [12, 10, 85, 4, 230], [16, 20, 110, 5, 320]]
	for cs in cases:
		var c: int = cs[0]
		var s: int = cs[1]
		G.d.best = G.stage_index(c, s)
		G.d.equip = {}
		for slot in ["weapon", "armor", "helmet", "amulet", "gloves", "boots", "belt", "ring"]:
			G.d.equip[slot] = G.make_item(slot, mini(cs[3] + 1, 5), int(cs[4]))
		var wins := 0
		var tsum := 0.0
		for rep in 3:
			var b := {"level": cs[2], "stars": mini(cs[3] * 2, 5), "rarity": cs[3], "frags": 0}
			var spec: Dictionary = G.ball_spec("raposa", b)
			spec.stats = G.ball_stats("raposa", b.merged({"equip": G.d.equip}))
			battle.start([spec], G.stage_waves(c, s))
			var t := 0.0
			while not battle.ended and t < 180.0:
				battle._physics_process(1.0 / 30.0)
				t += 1.0 / 30.0
			var won := false
			for u: Unit in battle.units:
				if u.team == 0 and not u.dead and not u.is_summon:
					won = true
			if won and battle.ended:
				wins += 1
			tsum += t
			battle.clear()
			await process_frame
		print("cap %d-%d  lvl %d r%d itens %d  ->  vitorias %d/3  tempo medio %.1fs" % [c, s, cs[2], cs[3], cs[4], wins, tsum / 3.0])
	quit()

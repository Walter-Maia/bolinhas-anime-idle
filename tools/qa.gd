extends SceneTree
## QA automatizado: valida os dados de todas as bolinhas e simula batalhas forçando cada skill e passiva.
##   godot --headless --path . --script res://tools/qa.gd [-- <filtro_prefixo>]
## Imprime ">> <id>" antes de cada simulacao para localizar erros no log.

const SKILL_TYPES := ["projectile", "beam", "breath", "aoe", "nova", "rain", "dash", "hook", "multi", "stretch", "chain", "summon", "shield",
	"buff", "heal", "timestop", "strike", "orbit", "zone", "drain", "debuff", "execute", "awaken", "knockback", "teleport", "mimic", "gamble"]
const PASSIVE_TYPES := ["stats", "low_hp", "on_hit", "on_kill", "stack", "revive", "berserk", "periodic", "shield_start", "first_strike",
	"execute", "on_crit", "counter", "aura_dmg", "reflect"]
const WEAPONS := ["sword", "katana", "greatsword", "dagger", "kunai", "shuriken", "spear", "trident", "scythe", "hammer", "axe", "staff", "wand",
	"bow", "gun", "rifle", "fan", "card", "book", "chain", "orb", "shield", "fist", "claw", "whip", "tonfa", "chainsaw", "bat", "umbrella", "guitar",
	"flag", "needle", "gear", "feather", "rose", "bomb", "bottle"]

var issues: Array = []
var G: Node


func _init() -> void:
	G = load("res://scripts/core/game.gd").new()
	G.d = {"equip": {}, "upgrades": {}, "vip_until": 0, "purchases": {}}
	var filt: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else ""
	print("QA: %d bolinhas, %d mundos" % [DB.BALLS.size(), DB.WORLDS.size()])
	for e in DB.load_errors:
		issues.append("LOAD: " + str(e))
	_validate()
	print("validacao: %d problemas" % issues.size())
	for i in issues:
		print("  - ", i)
	_simulate.call_deferred(filt)


func _validate() -> void:
	for id in DB.BALLS:
		var b: Dictionary = DB.BALLS[id]
		for k in ["name", "world", "role", "look"]:
			if not b.has(k):
				issues.append("%s: sem campo %s" % [id, k])
		var acts: Array = b.get("actives", [])
		if acts.is_empty():
			issues.append("%s: sem skills ativas" % id)
		for a in acts:
			if not SKILL_TYPES.has(str(a.get("type", ""))):
				issues.append("%s: tipo de skill desconhecido '%s'" % [id, a.get("type", "")])
			if a.has("status") and not Battle.STATUS_FX.has(str(a.status)):
				issues.append("%s: status desconhecido '%s'" % [id, a.status])
			if a.has("alt") and a.alt.has("type") and not SKILL_TYPES.has(str(a.alt.type)):
				issues.append("%s: tipo alt desconhecido" % id)
		for p in b.get("passives", []):
			if not PASSIVE_TYPES.has(str(p.get("type", ""))):
				issues.append("%s: tipo de passiva desconhecido '%s'" % [id, p.get("type", "")])
			if p.has("status") and not Battle.STATUS_FX.has(str(p.status)):
				issues.append("%s: status de passiva desconhecido '%s'" % [id, p.status])
			if p.get("type", "") == "periodic" and not (p.get("skill", {}) as Dictionary).has("type"):
				issues.append("%s: periodic sem skill" % id)
		var w: Dictionary = b.get("weapon", {})
		if not WEAPONS.has(str(w.get("kind", ""))):
			issues.append("%s: arma desconhecida '%s'" % [id, w.get("kind", "")])
	for bid in DB.BOSSES:
		for a in DB.BOSSES[bid].actives:
			if not SKILL_TYPES.has(str(a.get("type", ""))):
				issues.append("chefe %s: tipo desconhecido %s" % [bid, a.type])
	for ch in DB.CHAPTERS:
		if not DB.BOSSES.has(ch.boss):
			issues.append("capitulo %s: chefe inexistente" % ch.name)
		if not DB.BALLS.has(ch.get("guide", "")):
			issues.append("capitulo %s: guia inexistente %s" % [ch.name, ch.get("guide", "")])
		for e in ch.enemies:
			if not DB.ENEMIES.has(e):
				issues.append("capitulo %s: inimigo inexistente %s" % [ch.name, e])


func _simulate(filt: String) -> void:
	var battle := Battle.new()
	root.add_child(battle)
	await process_frame
	battle.set_arena(Vector2(680, 470))
	var n := 0
	var t0 := Time.get_ticks_msec()
	for id in DB.BALLS:
		if filt != "" and not str(id).begins_with(filt):
			continue
		n += 1
		print(">> ", id)
		var b := {"level": 30, "stars": 5, "rarity": 8, "frags": 0, "equip": {}}
		var spec: Dictionary = G.ball_spec(id, b)
		var waves := [[G.enemy_spec("ninja_renegado", 20), G.enemy_spec("oni", 20), G.enemy_spec("serpente", 20, true, 0.6)]]
		battle.start([spec], waves)
		var u: Unit = battle.units[0]
		# forca cada skill ativa
		for a in u.actives:
			Skills.cast(battle, u, a.def)
			for k in 8:
				battle._physics_process(1.0 / 30.0)
		# passivas de vida baixa / revive
		u.hp = u.max_hp * 0.1
		battle.deal(null, u, 0.01, {"kind": "dot", "raw": 1.0})
		for k in 30:
			battle._physics_process(1.0 / 30.0)
		# versao transformada das skills
		if not u.dead and u.transformed:
			for a in u.actives:
				Skills.cast(battle, u, a.def)
				for k in 6:
					battle._physics_process(1.0 / 30.0)
		battle.clear()
		await process_frame
	print("simulacao: %d bolinhas em %.1fs" % [n, (Time.get_ticks_msec() - t0) / 1000.0])
	print("QA FIM")
	quit()

extends Node
## Estado do jogador + regras (autoload "Game").

signal changed                 # moedas/gemas/chaves/nivel mudaram
signal team_changed
signal leveled_up(level: int)
signal mission_done(m: Dictionary)

const SAVE_PATH := "user://save.json"
const SLOT_PATH := "user://slot_%d.json"
const VERSION := 3

const MISSIONS := [
	{"id": "stages", "name": "Vença 15 fases", "goal": 15, "gems": 30},
	{"id": "chests", "name": "Abra 30 baús", "goal": 30, "gems": 25},
	{"id": "gacha", "name": "Faça 1 invocação", "goal": 1, "gems": 20},
	{"id": "boss", "name": "Derrote 1 chefe no Modo Chefes", "goal": 1, "gems": 40},
	{"id": "tower", "name": "Suba 3 andares da Torre", "goal": 3, "gems": 30},
	{"id": "pvp", "name": "Lute 3 vezes na Arena", "goal": 3, "gems": 30},
	{"id": "level", "name": "Suba 10 níveis de bolinhas", "goal": 10, "gems": 25},
	{"id": "dungeon", "name": "Complete 2 masmorras", "goal": 2, "gems": 30},
]

var d: Dictionary = {}
var _save_t := 0.0


func _ready() -> void:
	randomize()
	if not load_game():
		new_game()
	daily_reset()
	get_tree().set_auto_accept_quit(false)


func _process(delta: float) -> void:
	_save_t += delta
	if _save_t > 15.0:
		_save_t = 0.0
		save_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		save_game()


# =============================================================================================
# save / load / slots
# =============================================================================================
func new_game() -> void:
	d = {
		"v": VERSION, "name": "Jogador",
		"coins": 300.0, "gems": 400, "keys": 60,
		"level": 1, "xp": 0.0,
		"chapter": 1, "stage": 1, "best": 1, "auto_advance": true,
		"balls": {}, "team": ["raposa", "", ""], "sel": 0, "equip": {},
		"upgrades": {}, "auto_chest": false, "auto_skill": true, "speed": 1, "speed_max": 2,
		"tower": 1, "tower_best": 0,
		"pvp": {"rating": 1000, "tickets": 5, "wins": 0, "losses": 0},
		"boss": {}, "boss_tries": {}, "dungeon": {}, "dungeon_tries": {},
		"day": "", "pity": 0, "pulls": 0, "purchases": {},
		"vip_until": 0, "vip_claim_day": "", "free_day": "",
		"last_time": Time.get_unix_time_from_system(), "offline": {},
		"pending_drop": {}, "mats": {}, "seen": {}, "missions": {}, "mission_claimed": {}, "world_claimed": {},
		"created": Time.get_datetime_string_from_system(), "saved_at": "",
	}
	add_ball("raposa")
	equip(make_item("weapon", 0, 1))


func _ensure() -> void:
	var defaults := {"mats": {}, "upgrades": {}, "boss": {}, "boss_tries": {}, "dungeon": {}, "dungeon_tries": {},
		"purchases": {}, "offline": {}, "pending_drop": {}, "seen": {}, "missions": {}, "mission_claimed": {},
		"world_claimed": {}, "equip": {}, "speed": 1, "speed_max": 2}
	for k in defaults:
		if not d.has(k):
			d[k] = defaults[k]
	for k in ["gems", "keys", "level", "chapter", "stage", "best", "sel", "tower", "tower_best", "pity", "pulls", "speed", "speed_max"]:
		d[k] = int(d.get(k, 0))
	for id in d.balls.keys():
		if not DB.BALLS.has(id):
			d.balls.erase(id)
			continue
		var b: Dictionary = d.balls[id]
		for k in ["level", "stars", "rarity", "frags"]:
			b[k] = int(b.get(k, 0))
		# versao antiga: equipamento por bolinha -> vira do jogador
		if b.has("equip"):
			if d.equip.is_empty() and id == d.team[0]:
				d.equip = b.equip
			b.erase("equip")
	if d.team[0] == "" or not d.balls.has(d.team[0]):
		d.team = [d.balls.keys()[0] if not d.balls.is_empty() else "", "", ""]
	if d.balls.is_empty():
		add_ball("raposa")


func save_game() -> void:
	d.last_time = Time.get_unix_time_from_system()
	d.saved_at = Time.get_datetime_string_from_system()
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not (v is Dictionary):
		return false
	d = v
	_ensure()
	_calc_offline()
	return true


func slot_info(i: int) -> Dictionary:
	var p := SLOT_PATH % i
	if not FileAccess.file_exists(p):
		return {}
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
	if not (v is Dictionary):
		return {}
	return {"saved_at": v.get("saved_at", "?"), "level": int(v.get("level", 1)), "chapter": int(v.get("chapter", 1)),
		"stage": int(v.get("stage", 1)), "balls": (v.get("balls", {}) as Dictionary).size()}


func save_slot(i: int) -> void:
	save_game()
	var f := FileAccess.open(SLOT_PATH % i, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))


func load_slot(i: int) -> bool:
	var p := SLOT_PATH % i
	if not FileAccess.file_exists(p):
		return false
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
	if not (v is Dictionary):
		return false
	d = v
	_ensure()
	save_game()
	changed.emit()
	team_changed.emit()
	return true


## codigo de backup (texto) para copiar e colar em outro aparelho
func export_code() -> String:
	var raw := JSON.stringify(d).to_utf8_buffer()
	var comp := raw.compress(FileAccess.COMPRESSION_GZIP)
	return "BAI1:" + str(raw.size()) + ":" + Marshalls.raw_to_base64(comp)


func import_code(code: String) -> bool:
	code = code.strip_edges()
	if not code.begins_with("BAI1:"):
		return false
	var parts := code.split(":", true, 2)
	if parts.size() < 3:
		return false
	var comp := Marshalls.base64_to_raw(parts[2])
	if comp.is_empty():
		return false
	var raw := comp.decompress(int(parts[1]), FileAccess.COMPRESSION_GZIP)
	var v: Variant = JSON.parse_string(raw.get_string_from_utf8())
	if not (v is Dictionary) or not v.has("balls"):
		return false
	d = v
	_ensure()
	save_game()
	changed.emit()
	team_changed.emit()
	return true


func reset_save() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	new_game()
	changed.emit()
	team_changed.emit()


func today() -> String:
	return Time.get_date_string_from_system()


func daily_reset() -> void:
	if d.get("day", "") == today():
		return
	d.day = today()
	d.pvp.tickets = 5
	d.boss_tries = {}
	d.dungeon_tries = {}
	d.missions = {}
	d.mission_claimed = {}
	save_game()


# =============================================================================================
# missoes diarias e colecao
# =============================================================================================
func progress(id: String, n: int = 1) -> void:
	var before := int(d.missions.get(id, 0))
	d.missions[id] = before + n
	for m in MISSIONS:
		if m.id == id and before < int(m.goal) and before + n >= int(m.goal):
			mission_done.emit(m)


func mission_ready(m: Dictionary) -> bool:
	return int(d.missions.get(m.id, 0)) >= int(m.goal) and not d.mission_claimed.has(m.id)


func claim_mission(m: Dictionary) -> bool:
	if not mission_ready(m):
		return false
	d.mission_claimed[m.id] = true
	add_gems(int(m.gems))
	return true


func missions_pending() -> int:
	var n := 0
	for m in MISSIONS:
		if mission_ready(m):
			n += 1
	return n


## conquistas permanentes: [id, nome, valor atual, meta, gemas]
func achievements() -> Array:
	var best_r := 0
	for id in d.balls:
		best_r = maxi(best_r, int(d.balls[id].rarity))
	var out := []
	for n in [1, 2, 4, 8, 12, 16]:
		out.append(["cap%d" % n, "Conclua %d capítulo(s) da história" % n, chapters_cleared(), n, 50 + n * 15])
	for n in [10, 25, 50, 100, 200, 400, 862]:
		out.append(["col%d" % n, "Tenha %d bolinhas diferentes" % n, d.balls.size(), mini(n, DB.BALLS.size()), 40 + n / 2])
	for r in range(2, 9):
		out.append(["rar%d" % r, "Tenha uma bolinha %s" % DB.rarity(r).name, best_r, r, 30 * r])
	for n in [10, 25, 50, 100, 200]:
		out.append(["tow%d" % n, "Chegue ao andar %d da Torre" % n, int(d.tower_best), n, 30 + n])
	for n in [10, 50, 200]:
		out.append(["pvp%d" % n, "Vença %d lutas de PvP" % n, int(d.pvp.wins), n, 40 + n / 2])
	for n in [10, 25, 50, 75]:
		out.append(["lvl%d" % n, "Chegue ao nível %d da conta" % n, int(d.level), n, 30 + n * 2])
	return out


func ach_ready(a: Array) -> bool:
	return int(a[2]) >= int(a[3]) and not d.get("ach", {}).has(a[0])


func claim_ach(a: Array) -> bool:
	if not ach_ready(a):
		return false
	if not d.has("ach"):
		d.ach = {}
	d.ach[a[0]] = true
	add_gems(int(a[4]))
	return true


## login diario de 7 dias (repete)
const LOGIN_REWARDS := [
	{"gems": 30}, {"keys": 40}, {"gems": 50}, {"coins_h": 3}, {"gems": 80}, {"mat": 2}, {"ball": 3},
]


func login_state() -> Dictionary:
	var last: String = d.get("login_last", "")
	var streak := int(d.get("login_streak", 0))
	return {"can": last != today(), "day": streak % 7}


func claim_login() -> Dictionary:
	var st := login_state()
	if not st.can:
		return {}
	var rw: Dictionary = LOGIN_REWARDS[st.day]
	var res := rw.duplicate()
	if rw.has("gems"):
		add_gems(int(rw.gems))
	if rw.has("keys"):
		add_keys(int(rw["keys"]))
	if rw.has("coins_h"):
		add_coins(stage_reward_coins(float(d.best)) * 80.0 * int(rw.coins_h))
	if rw.has("mat"):
		res.mat_info = roll_mat(clampi(chapters_cleared() / 2, 0, 5), 3 * int(rw.mat))
	if rw.has("ball"):
		var bid := random_ball_of(int(rw.ball))
		add_ball(bid)
		res.ball_id = bid
	d.login_last = today()
	d.login_streak = int(d.get("login_streak", 0)) + 1
	return res


func goals_pending() -> int:
	var n := missions_pending()
	for a in achievements():
		if ach_ready(a):
			n += 1
	if login_state().can:
		n += 1
	return n


## forja: melhora o nivel do item equipado
func forge_cost(it: Dictionary) -> float:
	return item_sell(it) * 6.0


func forge(slot: String) -> bool:
	var it := equipped(slot)
	if it.is_empty() or not spend_coins(forge_cost(it)):
		return false
	it.level = int(it.level) + 1
	team_changed.emit()
	return true


# =============================================================================================
# expedicoes (bolinhas fora de campo trabalham sozinhas)
# =============================================================================================
const EXPEDITIONS := [
	{"id": "curta", "name": "Patrulha", "hours": 1, "mult": 1.0},
	{"id": "media", "name": "Caça ao Tesouro", "hours": 4, "mult": 4.6},
	{"id": "longa", "name": "Grande Jornada", "hours": 8, "mult": 10.0},
]
const EXP_SLOTS := 3


func expeditions() -> Array:
	if not d.has("expd"):
		d.expd = []
	return d.expd


func ball_on_expedition(id: String) -> bool:
	for e in expeditions():
		if e.ball == id:
			return true
	return false


func start_expedition(id: String, kind: Dictionary) -> bool:
	if expeditions().size() >= EXP_SLOTS or ball_on_expedition(id) or id == active_id() or not has_ball(id):
		return false
	d.expd.append({"ball": id, "kind": kind.id, "end": Time.get_unix_time_from_system() + 3600.0 * float(kind.hours), "hours": kind.hours, "mult": kind.mult})
	return true


func expedition_reward(e: Dictionary) -> Dictionary:
	var b := ball(e.ball)
	var r := int(b.get("rarity", 0))
	var g := float(d.best)
	var m := float(e.mult) * (1.0 + 0.25 * r) * (1.0 + int(b.get("level", 1)) * 0.01)
	return {"coins": stage_reward_coins(g) * 6.0 * m, "keys": int(4 * m), "gems": int(3 * m) + r * 2, "mat_tier": clampi(r - 1, 0, 6), "mats": maxi(1, int(m * 0.5))}


func claim_expedition(i: int) -> Dictionary:
	var e: Dictionary = expeditions()[i]
	if Time.get_unix_time_from_system() < float(e.end):
		return {}
	var rw := expedition_reward(e)
	add_coins(rw.coins)
	add_keys(rw["keys"])
	add_gems(rw.gems)
	rw.mat = roll_mat(rw.mat_tier, rw.mats)
	d.expd.remove_at(i)
	return rw


# =============================================================================================
# horda e desafio diario
# =============================================================================================
func horde_waves(n: int = 80) -> Array:
	var out := []
	var kinds := DB.ENEMIES.keys()
	var bosses := DB.BOSSES.keys()
	var base := maxf(3.0, float(d.best) * 0.6)
	for w in n:
		var g := base + w * 1.2
		var list := []
		if (w + 1) % 10 == 0:
			list.append(enemy_spec(bosses[(w / 10) % bosses.size()], g, true, 0.5))
		else:
			for i in 2 + mini(w / 6, 3):
				list.append(enemy_spec(kinds[randi() % kinds.size()], g))
		out.append(list)
	return out


func horde_tries() -> int:
	return 3 - int(d.get("horde_tries", {}).get(today(), 0))


const CHALLENGE_RULES := [
	{"id": "veloz", "name": "Inimigos Velozes", "desc": "O chefe é 60% mais rápido.", "enemy": {"spd": 1.6}},
	{"id": "gigante", "name": "Chefe Gigante", "desc": "O chefe tem o dobro de vida, mas você bate 50% mais forte.", "enemy": {"hp": 2.0}, "player": {"atk": 1.5}},
	{"id": "vidro", "name": "Canhão de Vidro", "desc": "Você causa o triplo de dano, mas tem 40% da vida.", "player": {"atk": 3.0, "hp": 0.4}},
	{"id": "sem_arma", "name": "Mãos Vazias", "desc": "Sua arma não gira; só corpo e skills!", "player": {"no_weapon": 1.0, "atk": 1.6}},
	{"id": "turbo", "name": "Turbo", "desc": "Todo mundo 2x mais rápido.", "enemy": {"spd": 2.0}, "player": {"spd": 2.0}},
	{"id": "tanque", "name": "Fortaleza", "desc": "Você tem 3x vida, mas metade do ataque.", "player": {"hp": 3.0, "atk": 0.5}},
	{"id": "relampago", "name": "Recarga Relâmpago", "desc": "Suas skills recarregam 2x mais rápido.", "player": {"cdr": 0.5}},
]


func challenge_today() -> Dictionary:
	var seed_v := hash(today())
	var rule: Dictionary = CHALLENGE_RULES[absi(seed_v) % CHALLENGE_RULES.size()]
	var bosses := DB.BOSSES.keys()
	bosses.sort()
	var boss: String = bosses[absi(seed_v / 7) % bosses.size()]
	return {"rule": rule, "boss": boss, "done": d.get("challenge_day", "") == today()}


## recompensa por completar a colecao de um anime inteiro
func world_progress(w: String) -> Vector2i:
	var ids := DB.balls_of_world(w)
	var have := 0
	for id in ids:
		if d.balls.has(id):
			have += 1
	return Vector2i(have, ids.size())


func world_reward(w: String) -> int:
	return 50 + 25 * DB.balls_of_world(w).size()


func claim_world(w: String) -> bool:
	var pr := world_progress(w)
	if pr.x < pr.y or d.world_claimed.has(w):
		return false
	d.world_claimed[w] = true
	add_gems(world_reward(w))
	return true


# =============================================================================================
# moedas
# =============================================================================================
func add_coins(v: float) -> void:
	d.coins = float(d.coins) + v
	changed.emit()


func spend_coins(v: float) -> bool:
	if float(d.coins) < v:
		return false
	d.coins = float(d.coins) - v
	changed.emit()
	return true


func add_gems(v: int) -> void:
	d.gems = int(d.gems) + v
	changed.emit()


func spend_gems(v: int) -> bool:
	if int(d.gems) < v:
		return false
	d.gems = int(d.gems) - v
	changed.emit()
	return true


func add_keys(v: int) -> void:
	d.keys = int(d.keys) + v
	changed.emit()


func mat_count(id: String) -> int:
	return int(d.get("mats", {}).get(id, 0))


func add_mat(id: String, n: int) -> void:
	d.mats[id] = maxi(0, mat_count(id) + n)
	changed.emit()


func roll_mat(max_tier: int, n: int) -> Dictionary:
	var t := clampi(randi_range(0, max_tier), 0, DB.EVO_MATS.size() - 1)
	add_mat(DB.EVO_MATS[t].id, n)
	return {"id": DB.EVO_MATS[t].id, "name": DB.EVO_MATS[t].name, "n": n, "tier": t}


func xp_need(lvl: int = -1) -> float:
	if lvl < 0:
		lvl = int(d.level)
	return 40.0 + 25.0 * pow(lvl, 1.5)


func add_xp(v: float) -> void:
	d.xp = float(d.xp) + v
	while float(d.xp) >= xp_need():
		d.xp = float(d.xp) - xp_need()
		d.level = int(d.level) + 1
		add_gems(20)
		leveled_up.emit(int(d.level))
	changed.emit()


func upg(id: String) -> int:
	return int(d.upgrades.get(id, 0))


func upg_cost(u: Dictionary) -> float:
	return float(u.base) * pow(float(u.growth), upg(u.id))


func buy_upgrade(u: Dictionary) -> bool:
	if u.has("max") and upg(u.id) >= int(u.max):
		return false
	if not spend_coins(upg_cost(u)):
		return false
	d.upgrades[u.id] = upg(u.id) + 1
	changed.emit()
	team_changed.emit()
	return true


func chest_level() -> int:
	return 1 + upg("chest")


func gold_mult() -> float:
	return (1.0 + 0.1 * upg("gold")) * (1.2 if is_vip() else 1.0)


func is_vip() -> bool:
	return float(d.get("vip_until", 0)) > Time.get_unix_time_from_system()


func vip_level() -> int:
	var spent := 0
	for id in d.purchases:
		spent += int(d.purchases[id])
	return clampi(spent, 0, 10) + (1 if is_vip() else 0)


## velocidades de batalha disponiveis (2x gratis; 3x e 4x via gamepass)
func speeds() -> Array:
	var out := [1, 2]
	if int(d.speed_max) >= 3:
		out.append(3)
	if int(d.speed_max) >= 4:
		out.append(4)
	return out


# =============================================================================================
# bolinhas
# =============================================================================================
func has_ball(id: String) -> bool:
	return d.balls.has(id)


func ball(id: String) -> Dictionary:
	return d.balls.get(id, {})


func add_ball(id: String) -> Dictionary:
	if not DB.BALLS.has(id):
		return {"new": false, "frags": 0}
	if d.balls.has(id):
		d.balls[id].frags = int(d.balls[id].frags) + DB.DUPE_FRAGS
		changed.emit()
		return {"new": false, "frags": DB.DUPE_FRAGS}
	d.balls[id] = {"level": 1, "stars": 0, "rarity": int(DB.BALLS[id].rarity), "frags": 0}
	if d.team[0] == "":
		d.team[0] = id
		team_changed.emit()
	changed.emit()
	return {"new": true, "frags": 0}


func level_cap(id: String) -> int:
	var b := ball(id)
	return 30 + 10 * int(b.rarity) + 5 * int(b.stars)


func level_cost(id: String) -> float:
	return 12.0 * pow(1.085, int(ball(id).level) - 1)


func level_up(id: String, times: int = 1) -> int:
	var done := 0
	for i in times:
		var b := ball(id)
		if int(b.level) >= level_cap(id) or not spend_coins(level_cost(id)):
			break
		b.level = int(b.level) + 1
		done += 1
	if done > 0:
		progress("level", done)
		team_changed.emit()
	return done


func star_cost(id: String) -> int:
	var s := int(ball(id).stars)
	return DB.STAR_COST[s] if s < DB.STAR_COST.size() else -1


func star_up(id: String) -> bool:
	var b := ball(id)
	var c := star_cost(id)
	if c < 0 or int(b.frags) < c:
		return false
	b.frags = int(b.frags) - c
	b.stars = int(b.stars) + 1
	team_changed.emit()
	changed.emit()
	return true


func ascend_cost_coins(id: String) -> float:
	return 2000.0 * pow(4.0, int(ball(id).rarity))


func ascend_reqs(id: String) -> Array:
	var b := ball(id)
	var r := int(b.rarity)
	if r >= DB.MAX_RARITY:
		return []
	var mat: Dictionary = DB.EVO_MATS[r]
	var boss: String = DB.EVO_BOSS[r]
	return [
		{"text": "Estrelas %d/5" % int(b.stars), "ok": int(b.stars) >= 5},
		{"text": "Fragmentos (cópias) %d/%d" % [int(b.frags), DB.ASCEND_FRAGS], "ok": int(b.frags) >= DB.ASCEND_FRAGS},
		{"text": "%s %d/%d" % [mat.name, mat_count(mat.id), DB.EVO_MAT_COUNT[r]], "ok": mat_count(mat.id) >= DB.EVO_MAT_COUNT[r]},
		{"text": "Derrotar chefe: %s" % DB.boss_name(boss), "ok": boss_tier(boss) >= 1},
		{"text": "Moedas %s" % UI.fmt(ascend_cost_coins(id)), "ok": float(d.coins) >= ascend_cost_coins(id)},
	]


func can_ascend(id: String) -> bool:
	var reqs := ascend_reqs(id)
	if reqs.is_empty():
		return false
	for q in reqs:
		if not q.ok:
			return false
	return true


func ascend(id: String) -> bool:
	if not can_ascend(id):
		return false
	var b := ball(id)
	var r := int(b.rarity)
	spend_coins(ascend_cost_coins(id))
	add_mat(DB.EVO_MATS[r].id, -DB.EVO_MAT_COUNT[r])
	b.frags = int(b.frags) - DB.ASCEND_FRAGS
	b.rarity = r + 1
	b.stars = 0
	team_changed.emit()
	changed.emit()
	return true


func set_active(id: String) -> void:
	if not d.balls.has(id):
		return
	d.team = [id, "", ""]
	d.sel = 0
	team_changed.emit()


func active_id() -> String:
	return d.team[0]


func team_ids() -> Array:
	var id: String = d.team[0]
	return [id] if id != "" and d.balls.has(id) else []


## atributos finais. Para bolinhas do jogador usa o equipamento do jogador; para oponentes, o "b.equip" deles.
func ball_stats(id: String, b: Dictionary = {}) -> Dictionary:
	var own := b.is_empty()
	if own:
		b = ball(id)
	var def: Dictionary = DB.BALLS[id]
	var r := int(b.get("rarity", def.rarity))
	var role: Dictionary = DB.ROLE[def.role]
	var m := pow(1.06, int(b.get("level", 1)) - 1) * (1.0 + 0.1 * int(b.get("stars", 0))) * float(DB.rarity(r).mult)
	var s := {
		"hp": role.hp * m, "atk": role.atk * m, "def": role.def * m, "spd": role.spd,
		"crit": 0.05, "critdmg": 1.5, "dodge": 0.0, "lifesteal": 0.0, "cdr": 0.0, "regen": 0.0, "thorns": 0.0,
		"contact_taken": 0.0, "contact_mult": 1.0,
	}
	var pct := {"atk_pct": 0.0, "hp_pct": 0.0, "def_pct": 0.0, "spd_pct": 0.0}
	var eq: Dictionary = d.equip if own else b.get("equip", {})
	for slot in eq:
		var it: Dictionary = eq[slot]
		if it.is_empty():
			continue
		var v := item_main(it)
		match DB.SLOT_INFO[slot].main:
			"atk": s.atk += v
			"hp": s.hp += v
			"both":
				s.atk += v
				s.hp += v * 6.0
		for k in it.get("subs", {}):
			if pct.has(k):
				pct[k] += float(it.subs[k])
			else:
				s[k] = float(s.get(k, 0.0)) + float(it.subs[k])
		if slot == "weapon" and int(it.get("wtype", 0)) == 0:
			s.contact_mult = 1.5
	var sc := set_counts(eq)
	for sid in sc:
		var bon := set_bonus_of(find_set(sid), int(sc[sid]))
		for k in bon:
			if pct.has(k):
				pct[k] += float(bon[k])
			else:
				s[k] = float(s.get(k, 0.0)) + float(bon[k])
	for p in def.get("passives", []):
		if int(p.get("unlock", 0)) > r:
			continue
		if p.get("type", "") == "stats" and p.has("stats"):
			for k in p.stats:
				var v := float(p.stats[k]) * (1.0 + 0.2 * r)
				if pct.has(k):
					pct[k] += v
				else:
					s[k] = float(s.get(k, 0.0)) + v
	if own:
		pct.atk_pct += 0.05 * upg("atk")
		pct.hp_pct += 0.05 * upg("hp")
	s.atk *= 1.0 + pct.atk_pct
	s.hp *= 1.0 + pct.hp_pct
	s.def *= 1.0 + pct.def_pct
	s.spd *= clampf(1.0 + pct.spd_pct, 0.6, 1.6)
	s.crit = clampf(s.crit, 0.0, 0.85)
	s.dodge = clampf(s.dodge, 0.0, 0.6)
	return s


func ball_power(id: String, b: Dictionary = {}) -> float:
	var s := ball_stats(id, b)
	return (s.hp / 5.0 + s.atk * 3.0 + s.def * 2.0) * (1.0 + s.crit * (s.critdmg - 1.0) + s.dodge + s.lifesteal + s.cdr)


func team_power() -> float:
	var t := 0.0
	for id in team_ids():
		t += ball_power(id)
	return t


func is_ranged(id: String, b: Dictionary = {}) -> bool:
	var eq: Dictionary = d.equip if b.is_empty() else b.get("equip", {})
	var w: Dictionary = eq.get("weapon", {})
	return not w.is_empty() and int(w.get("wtype", 0)) == 1


func ball_spec(id: String, b: Dictionary = {}) -> Dictionary:
	var own := b.is_empty()
	if own:
		b = ball(id)
	var def: Dictionary = DB.BALLS[id]
	var r := int(b.get("rarity", def.rarity))
	return {
		"name": DB.ball_name(id, r), "ball_id": id, "look": def.look, "look_tf": def.get("look_tf_full", {}), "rarity": r,
		"stats": ball_stats(id, {} if own else b), "actives": def.get("actives", []), "passives": def.get("passives", []),
		"color": def.get("color", "#ffffff"), "ranged": is_ranged(id, {} if own else b), "pscale": 1.25, "weapon": def.get("weapon", {}),
	}


# =============================================================================================
# inimigos e fases
# =============================================================================================
func enemy_spec(kind: String, g: float, boss: bool = false, boss_scale: float = 1.0) -> Dictionary:
	var hp := 42.0 * pow(1.062, g - 1.0)
	var atk := 7.0 * pow(1.058, g - 1.0)
	var df := 1.5 * pow(1.06, g - 1.0)
	if boss:
		var bd: Dictionary = DB.BOSSES[kind]
		return {
			"name": bd.name, "look": BallArt.normalize(bd.look), "rarity": int(bd.rarity), "boss": true,
			"stats": {"hp": hp * float(bd.hp_mult) * 0.6 * boss_scale, "atk": atk * float(bd.atk_mult) * 0.8 * sqrt(boss_scale), "def": df * 1.6,
				"spd": 240.0, "crit": 0.08, "critdmg": 1.6, "contact_mult": 1.0},
			"actives": bd.actives, "passives": [], "color": bd.get("color", "#ff6a5a"),
			"weapon": bd.get("weapon", {}).merged({"orbit": 1.35, "spin": 2.6, "power": 0.4}),
		}
	var ed: Dictionary = DB.ENEMIES[kind]
	return {
		"name": ed.name, "look": BallArt.normalize(ed.look), "rarity": clampi(int(g / 30.0), 0, 3),
		"stats": {"hp": hp, "atk": atk, "def": df, "spd": randf_range(250.0, 310.0), "crit": 0.03, "critdmg": 1.5, "contact_mult": 1.0},
		"actives": [], "passives": [], "color": "#ff6a5a", "ranged": randf() < clampf(g / 200.0, 0.0, 0.3),
		"weapon": ed.get("weapon", {}).merged({"count": 1, "orbit": 1.35, "spin": 2.5, "power": 0.3}) if g >= 4.0 else {},
	}


func stage_index(c: int = -1, s: int = -1) -> int:
	if c < 0:
		c = int(d.chapter)
	if s < 0:
		s = int(d.stage)
	return (c - 1) * DB.STAGES_PER_CHAPTER + s


func is_boss_stage(s: int) -> bool:
	return s == DB.STAGES_PER_CHAPTER or s == 10


## capitulos concluidos (fase 20 vencida)
func chapters_cleared() -> int:
	return int((int(d.best) - 1) / DB.STAGES_PER_CHAPTER)


func stage_waves(c: int, s: int) -> Array:
	var ch := DB.chapter(c)
	var loop := int((c - 1) / DB.chapter_count())
	var g := float(stage_index(c, s)) + float(c - 1) * 2.0 + loop * 20.0
	var waves := []
	var pool: Array = ch.enemies
	for w in 3:
		var n := 1 + int(s >= 5) + int(w == 2 and s >= 12) + int(c >= 3 and w == 2)
		var list := []
		if w == 2 and is_boss_stage(s):
			list.append(enemy_spec(ch.boss, g, true, 1.0 if s == DB.STAGES_PER_CHAPTER else 0.45))
			if s == DB.STAGES_PER_CHAPTER:
				waves.append(list)
				continue
			n = 1
		for i in n:
			list.append(enemy_spec(pool[randi() % pool.size()], g + w * 0.5))
		waves.append(list)
	return waves


func stage_reward_coins(g: float) -> float:
	return 15.0 * pow(1.06, g) * gold_mult()


func kill_reward_coins(g: float) -> float:
	return 4.0 * pow(1.06, g) * gold_mult()


func on_stage_win() -> Dictionary:
	var g := stage_index()
	var coins := stage_reward_coins(g)
	var keys := 3 + randi() % 3
	var xp := 10.0 + g * 2.0
	add_coins(coins)
	add_keys(keys)
	add_xp(xp)
	progress("stages")
	var gems := 0
	var cleared_chapter := false
	if is_boss_stage(int(d.stage)):
		gems = 30 if int(d.stage) == DB.STAGES_PER_CHAPTER else 10
		add_gems(gems)
	var was_best := stage_index() >= int(d.best)
	if d.auto_advance or was_best:
		d.stage = int(d.stage) + 1
		if int(d.stage) > DB.STAGES_PER_CHAPTER:
			d.stage = 1
			d.chapter = int(d.chapter) + 1
			cleared_chapter = true
	d.best = maxi(int(d.best), stage_index())
	return {"coins": coins, "keys": keys, "gems": gems, "chapter_clear": cleared_chapter}


func on_stage_lose() -> void:
	d.auto_advance = false
	if int(d.stage) > 1:
		d.stage = int(d.stage) - 1
	elif int(d.chapter) > 1:
		d.chapter = int(d.chapter) - 1
		d.stage = DB.STAGES_PER_CHAPTER


## jogar uma fase especifica do mapa (so ate a melhor alcancada)
func go_stage(c: int, s: int) -> bool:
	if stage_index(c, s) > int(d.best):
		return false
	d.chapter = c
	d.stage = s
	return true


# =============================================================================================
# equipamentos (do jogador) e bau
# =============================================================================================
func make_item(slot: String, r: int, lvl: int) -> Dictionary:
	var it := {"slot": slot, "rarity": r, "level": lvl, "subs": {}}
	if slot == "weapon":
		it.wtype = randi() % 2
	var keys := DB.SUBSTATS.keys()
	keys.shuffle()
	for i in mini(r, 4):
		var k: String = keys[i]
		it.subs[k] = float(DB.SUBSTATS[k].val) * (1.0 + r * 0.5) * randf_range(0.7, 1.3)
	return it


func find_set(id: String) -> Dictionary:
	for s in DB.SETS:
		if s.id == id:
			return s
	return {}


## peca de conjunto lendario (aleatoria se set_id vazio)
func make_set_item(lvl: int, set_id: String = "") -> Dictionary:
	if DB.SETS.is_empty():
		return make_item("ring", 3, lvl)
	var st: Dictionary = find_set(set_id) if set_id != "" else DB.SETS[randi() % DB.SETS.size()]
	var slots: Array = st.pieces.keys()
	var slot: String = slots[randi() % slots.size()]
	var r := clampi(int(st.get("rarity_min", 3)) + (1 if randf() < 0.25 else 0), 0, 8)
	var it := make_item(slot, r, lvl)
	it.set = st.id
	it.name = st.pieces[slot]
	return it


## {set_id: pecas equipadas}
func set_counts(eq: Dictionary) -> Dictionary:
	var out := {}
	for slot in eq:
		var it: Dictionary = eq[slot]
		if it.has("set"):
			out[it.set] = int(out.get(it.set, 0)) + 1
	return out


func set_bonus_of(st: Dictionary, n: int) -> Dictionary:
	var out := {}
	for tier in [2, 4, 6]:
		if n >= tier and st.has("bonus%d" % tier):
			for k in st["bonus%d" % tier]:
				out[k] = float(out.get(k, 0.0)) + float(st["bonus%d" % tier][k])
	return out


func item_main(it: Dictionary) -> float:
	var info: Dictionary = DB.SLOT_INFO[it.slot]
	return float(info.base) * pow(1.055, int(it.level)) * float(DB.EQ_RARITY_MULT[clampi(int(it.rarity), 0, DB.EQ_RARITY_MULT.size() - 1)])


func item_score(it: Dictionary) -> float:
	if it.is_empty():
		return 0.0
	var v := item_main(it)
	var main := v * 3.0
	match DB.SLOT_INFO[it.slot].main:
		"hp": main = v / 5.0
		"both": main = v * 3.0 + v * 6.0 / 5.0
	var sub := 0.0
	for k in it.get("subs", {}):
		sub += float(it.subs[k])
	return main * (1.0 + sub * 2.0) * (1.3 if it.has("set") else 1.0)


func item_sell(it: Dictionary) -> float:
	return 5.0 * pow(1.05, int(it.level)) * (int(it.rarity) + 1)


func slot_unlocked(slot: String) -> bool:
	return int(d.best) >= int(DB.SLOT_INFO[slot].get("unlock_stage", 0))


func equipped(slot: String) -> Dictionary:
	return d.equip.get(slot, {})


## equipa (no jogador) e devolve as moedas da venda do item antigo
func equip(it: Dictionary) -> float:
	var old: Dictionary = d.equip.get(it.slot, {})
	d.equip[it.slot] = it
	var coins := 0.0
	if not old.is_empty():
		coins = item_sell(old)
		add_coins(coins)
	team_changed.emit()
	return coins


func _weighted(w: Array) -> int:
	var tot := 0.0
	for x in w:
		tot += x
	var r := randf() * tot
	for i in w.size():
		r -= w[i]
		if r <= 0.0:
			return i
	return 0


func open_chest() -> Dictionary:
	if int(d.keys) <= 0:
		return {}
	d.keys = int(d.keys) - 1
	progress("chests")
	var L := chest_level()
	var res := {}
	if randf() < 0.07:
		res = {"type": "mat", "mat": roll_mat(clampi(L / 4, 0, 4), 1 + randi() % 2)}
		d.pending_drop = {}
		changed.emit()
		return res
	if randf() < minf(0.15, 0.04 + 0.004 * L):
		var w := [60.0, 26.0, 10.0, 3.2, 0.7, 0.1]
		for i in w.size():
			w[i] *= 1.0 + L * 0.12 * i
		var r := _weighted(w)
		res = {"type": "ball", "id": random_ball_of(r), "rarity": r}
	else:
		var w := [62.0, 24.0, 9.0, 3.5, 1.2, 0.3, 0.06, 0.015, 0.003]
		for i in w.size():
			w[i] *= 1.0 + L * 0.18 * i
		var slots := []
		for s in DB.SLOTS:
			if slot_unlocked(s):
				slots.append(s)
		var slot: String = slots[randi() % slots.size()]
		var lvl := maxi(1, int(d.best) + L * 2 + randi_range(-3, 3))
		if int(d.best) > DB.STAGES_PER_CHAPTER and randf() < minf(0.08, 0.02 + 0.003 * L):
			res = {"type": "item", "item": make_set_item(lvl)}
		else:
			res = {"type": "item", "item": make_item(slot, _weighted(w), lvl)}
	if res.type == "ball":
		res.rarity = int(DB.BALLS[res.id].rarity)
	d.pending_drop = res
	changed.emit()
	return res


func random_ball_of(r: int, worlds: Array = []) -> String:
	for attempt in 2:
		var rr := r
		while rr >= 0:
			var ids := []
			for id in DB.BALLS:
				if int(DB.BALLS[id].rarity) == rr and (worlds.is_empty() or attempt == 1 or worlds.has(DB.BALLS[id].get("world", ""))):
					ids.append(id)
			if not ids.is_empty():
				return ids[randi() % ids.size()]
			rr -= 1
	return DB.BALLS.keys()[0]


# =============================================================================================
# gacha
# =============================================================================================
func banner_unlocked(b: Dictionary) -> bool:
	return chapters_cleared() >= int(b.get("chapter", 0))


func gacha(n: int, banner: Dictionary = {}) -> Array:
	var cost := DB.GACHA_COST_10 if n >= 10 else DB.GACHA_COST_1 * n
	if not spend_gems(cost):
		return []
	progress("gacha")
	var worlds: Array = banner.get("worlds", [])
	var min_r := int(banner.get("min_rarity", 0))
	var out := []
	var got_rare := false
	for i in n:
		d.pity = int(d.pity) + 1
		d.pulls = int(d.pulls) + 1
		var r := _weighted(DB.GACHA_RATES)
		if min_r > 0:
			r = maxi(r, min_r) if randf() < 0.85 else maxi(r, min_r)
		if int(d.pity) >= DB.GACHA_PITY:
			r = maxi(r, 4)
		if n >= 10 and i == n - 1 and not got_rare:
			r = maxi(r, 2)
		if r >= 2:
			got_rare = true
		if r >= 4:
			d.pity = 0
		# banner com destaque: 60% de chance de vir de um dos animes em destaque
		var pool_worlds: Array = worlds if (not worlds.is_empty() and randf() < 0.6) else []
		var id := random_ball_of(r, pool_worlds)
		var res := add_ball(id)
		out.append({"id": id, "rarity": int(DB.BALLS[id].rarity), "new": res.new, "frags": res.frags})
	save_game()
	return out


# =============================================================================================
# modos
# =============================================================================================
func boss_unlocked(i: int) -> bool:
	return int(d.level) >= int(DB.BOSS_RAID[i].level)


func boss_tier(boss: String) -> int:
	return int(d.boss.get(boss, 0))


func boss_tries_left(boss: String) -> int:
	return 3 - int(d.boss_tries.get(boss, 0))


func dungeon_level(id: String) -> int:
	return 1 + int(d.dungeon.get(id, 0))


func dungeon_tries_left(id: String) -> int:
	return 2 - int(d.dungeon_tries.get(id, 0))


## oponente de PvP gerado localmente (assincrono). PvP online real precisaria de servidor.
func pvp_opponent() -> Dictionary:
	var names := ["Ninja_BR", "ZoroPerdido", "SenpaiNotice", "Otaku99", "Nakama_Gamer", "Hokage2077", "MestreKame", "ShinigamiZ", "Fã_do_Clã", "BoladaPerfeita", "ReiDoIdle", "Bolinha_Suprema", "CosmoDourado", "CartaNaManga"]
	var target := team_power() * randf_range(0.8, 1.15)
	var ids := DB.BALLS.keys()
	var id: String = ids[randi() % ids.size()]
	var b := {"level": maxi(1, int(d.best) / 2), "stars": randi() % 3, "rarity": int(DB.BALLS[id].rarity), "frags": 0, "equip": {}}
	for it in 80:
		if ball_power(id, b) >= target:
			break
		b.level = int(b.level) + 1
	return {"name": names[randi() % names.size()], "rating": int(d.pvp.rating) + randi_range(-60, 60), "team": [{"id": id, "b": b}]}


# =============================================================================================
# offline
# =============================================================================================
func offline_cap_hours() -> float:
	return 2.0 + upg("offline") + (2.0 if is_vip() else 0.0)


func _calc_offline() -> void:
	var now := Time.get_unix_time_from_system()
	var dt := clampf(now - float(d.get("last_time", now)), 0.0, offline_cap_hours() * 3600.0)
	if dt < 60.0:
		return
	var g := float(d.best)
	var per_stage := stage_reward_coins(g) + kill_reward_coins(g) * 6.0
	var off: Dictionary = d.get("offline", {})
	off.coins = float(off.get("coins", 0.0)) + per_stage / 45.0 * dt * 0.5
	off.keys = int(off.get("keys", 0)) + int(dt / 120.0)
	off.xp = float(off.get("xp", 0.0)) + (10.0 + g * 2.0) / 45.0 * dt * 0.3
	off.secs = float(off.get("secs", 0.0)) + dt
	d.offline = off


func claim_offline(mult: float = 1.0) -> Dictionary:
	var off: Dictionary = d.get("offline", {})
	if off.is_empty():
		return {}
	add_coins(float(off.get("coins", 0.0)) * mult)
	add_keys(int(int(off.get("keys", 0)) * mult))
	add_xp(float(off.get("xp", 0.0)) * mult)
	d.offline = {}
	return off


func idle_tick(sec: float) -> void:
	var g := float(d.best)
	var off: Dictionary = d.get("offline", {})
	var cap := offline_cap_hours() * 3600.0
	if float(off.get("secs", 0.0)) >= cap:
		return
	var per_stage := stage_reward_coins(g) + kill_reward_coins(g) * 6.0
	off.coins = float(off.get("coins", 0.0)) + per_stage / 45.0 * sec * 0.15
	var before := int(float(off.get("secs", 0.0)) / 240.0)
	off.secs = float(off.get("secs", 0.0)) + sec
	off.keys = int(off.get("keys", 0)) + (int(off.secs / 240.0) - before)
	off.xp = float(off.get("xp", 0.0))
	d.offline = off


# =============================================================================================
# loja
# =============================================================================================
func grant_iap(id: String) -> Dictionary:
	for p in DB.IAP:
		if p.id != id:
			continue
		d.purchases[id] = int(d.purchases.get(id, 0)) + 1
		var gems := int(p.gems) + int(p.get("bonus", 0))
		if gems > 0:
			add_gems(gems)
		if p.has("keys"):
			add_keys(int(p["keys"]))
		var res := {"gems": gems}
		if p.has("ball_rarity"):
			var bid := random_ball_of(int(p.ball_rarity))
			add_ball(bid)
			res.ball = bid
		if p.has("vip_days"):
			d.vip_until = maxf(float(d.vip_until), Time.get_unix_time_from_system()) + 86400.0 * int(p.vip_days)
		if p.has("speed"):
			d.speed_max = maxi(int(d.speed_max), int(p.speed))
			res.speed = int(p.speed)
		save_game()
		changed.emit()
		return res
	return {}


func iap_available(p: Dictionary) -> bool:
	if p.has("speed") and int(d.speed_max) >= int(p.speed):
		return false
	return not (p.get("once", false) and int(d.purchases.get(p.id, 0)) > 0)

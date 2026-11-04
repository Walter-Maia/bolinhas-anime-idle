class_name DB
## Dados do jogo. As bolinhas vem dos arquivos scripts/data/balls_*.gd (formato em docs/CONTENT_SPEC.md)
## e sao reunidas em DB.BALLS na primeira vez que a classe e usada. O mundo (inimigos, chefes, capitulos,
## banners) esta em scripts/data/world.gd.

const WORLD := preload("res://scripts/data/world.gd")
const CORE := preload("res://scripts/data/balls_core.gd")

## arquivos de bolinhas (adicione novos aqui)
const BALL_FILES := [
	"res://scripts/data/balls_a.gd", "res://scripts/data/balls_b.gd", "res://scripts/data/balls_c.gd",
	"res://scripts/data/balls_d.gd", "res://scripts/data/balls_e.gd",
	"res://scripts/data/balls_f1.gd", "res://scripts/data/balls_f2.gd", "res://scripts/data/balls_f3.gd",
	"res://scripts/data/balls_f4.gd", "res://scripts/data/balls_f5.gd", "res://scripts/data/balls_f6.gd",
	"res://scripts/data/balls_f7.gd", "res://scripts/data/balls_f8.gd", "res://scripts/data/balls_f9.gd",
	"res://scripts/data/balls_f10.gd", "res://scripts/data/balls_f11.gd", "res://scripts/data/balls_f12.gd",
	"res://scripts/data/balls_f13.gd", "res://scripts/data/balls_f14.gd", "res://scripts/data/balls_f15.gd",
	"res://scripts/data/balls_f16.gd", "res://scripts/data/balls_f17.gd", "res://scripts/data/balls_f18.gd", "res://scripts/data/balls_f19.gd",
	"res://scripts/data/balls_f20.gd", "res://scripts/data/balls_f21.gd", "res://scripts/data/balls_f22.gd", "res://scripts/data/balls_f23.gd",
	"res://scripts/data/balls_f24.gd", "res://scripts/data/balls_f25.gd", "res://scripts/data/balls_f26.gd",
]

const RARITY := [
	{"name": "Comum", "color": "#a7adb5", "mult": 1.0, "skill": 1.0, "loot": "loot_gray"},
	{"name": "Incomum", "color": "#4fc45c", "mult": 1.35, "skill": 1.2, "loot": "loot_green"},
	{"name": "Raro", "color": "#3c9cff", "mult": 1.8, "skill": 1.45, "loot": "loot_blue"},
	{"name": "Épico", "color": "#b45cf5", "mult": 2.5, "skill": 1.8, "loot": "loot_purple"},
	{"name": "Lendário", "color": "#ffb020", "mult": 3.5, "skill": 2.3, "loot": "loot_gold"},
	{"name": "Mítico", "color": "#ff4a4a", "mult": 5.0, "skill": 3.0, "loot": "loot_red"},
	{"name": "Divino", "color": "#ff6ad5", "mult": 7.0, "skill": 3.8, "loot": "loot_pink"},
	{"name": "Celestial", "color": "#3ae8f0", "mult": 10.0, "skill": 4.8, "loot": "loot_cyan"},
	{"name": "Transcendente", "color": "#f4ecff", "mult": 14.0, "skill": 6.0, "loot": "loot_white"},
]
const MAX_RARITY := 8

const ROLE := {
	"Atacante": {"hp": 120.0, "atk": 18.0, "def": 4.0, "spd": 320.0},
	"Tanque": {"hp": 200.0, "atk": 13.0, "def": 9.0, "spd": 270.0},
	"Velocista": {"hp": 110.0, "atk": 16.0, "def": 4.0, "spd": 380.0},
	"Suporte": {"hp": 150.0, "atk": 13.0, "def": 6.0, "spd": 300.0},
}

const STAR_COST := [10, 20, 30, 40, 60]
const ASCEND_FRAGS := 80
const DUPE_FRAGS := 10

# EVOLUCAO de raridade r -> r+1: 5 estrelas + fragmentos (copias) + cristais EVO_MATS[r] + derrotar EVO_BOSS[r] + moedas
const EVO_MATS := [
	{"id": "cristal_verde", "name": "Cristal Verde", "color": "#4fc45c"},
	{"id": "cristal_azul", "name": "Cristal Azul", "color": "#3c9cff"},
	{"id": "cristal_roxo", "name": "Cristal Roxo", "color": "#b45cf5"},
	{"id": "cristal_dourado", "name": "Cristal Dourado", "color": "#ffb020"},
	{"id": "cristal_rubro", "name": "Cristal Rubro", "color": "#ff4a4a"},
	{"id": "cristal_divino", "name": "Cristal Divino", "color": "#ff6ad5"},
	{"id": "cristal_celeste", "name": "Cristal Celeste", "color": "#3ae8f0"},
	{"id": "essencia_trans", "name": "Essência Transcendente", "color": "#d8c8ff"},
]
const EVO_MAT_COUNT := [10, 20, 30, 45, 60, 80, 100, 130]
const EVO_BOSS := ["serpente", "almirante", "lua_superior", "rei_vazio", "maldicao_especial", "imperador_submundo", "farao_sombrio", "imperador_galactico"]

const STAGES_PER_CHAPTER := 20
const DUNGEONS: Array = WORLD.DUNGEONS
static var ENEMIES: Dictionary = {}
static var BOSSES: Dictionary = {}
static var CHAPTERS: Array = []
static var BOSS_RAID: Array = []
static var BANNERS: Array = []
static var SETS: Array = []
const WORLD_FILES := ["res://scripts/data/world.gd", "res://scripts/data/world_w2.gd", "res://scripts/data/world_w3.gd", "res://scripts/data/world_w4.gd", "res://scripts/data/world_w5.gd"]
const SUMMON_LOOKS: Dictionary = CORE.SUMMON_LOOKS

## todas as bolinhas: id -> definicao (preenchido em _static_init)
static var BALLS: Dictionary = {}
static var WORLDS: Array = []
static var load_errors: Array = []


static func _static_init() -> void:
	for wp in WORLD_FILES:
		if not ResourceLoader.exists(wp):
			continue
		var ws: Variant = load(wp)
		if ws == null:
			load_errors.append("falha ao carregar " + wp)
			continue
		var wc: Dictionary = (ws as Script).get_script_constant_map()
		ENEMIES.merge(wc.get("ENEMIES", {}))
		BOSSES.merge(wc.get("BOSSES", {}))
		CHAPTERS.append_array(wc.get("CHAPTERS", []))
		BOSS_RAID.append_array(wc.get("BOSS_RAID", []))
		BANNERS.append_array(wc.get("BANNERS", []))
	BANNERS.sort_custom(func(a, b): return int(a.chapter) < int(b.chapter))
	if ResourceLoader.exists("res://scripts/data/items.gd"):
		SETS = (load("res://scripts/data/items.gd") as Script).get_script_constant_map().get("SETS", [])
	for id in CORE.DICT:
		_add(id, CORE.DICT[id])
	for path in BALL_FILES:
		if not ResourceLoader.exists(path):
			continue
		var sc: Variant = load(path)
		if sc == null:
			load_errors.append("falha ao carregar " + path)
			continue
		var consts: Dictionary = (sc as Script).get_script_constant_map()
		for b in consts.get("LIST", []):
			if b is Dictionary and b.has("id"):
				_add(b.id, b)
	for id in BALLS:
		var w: String = BALLS[id].get("world", "?")
		if not WORLDS.has(w):
			WORLDS.append(w)
	WORLDS.sort()


static func _add(id: String, src: Dictionary) -> void:
	if BALLS.has(id):
		load_errors.append("id duplicado: " + id)
		return
	var b := src.duplicate(true)
	b.id = id
	b.look = BallArt.normalize(b.get("look", {}))
	if b.has("look_tf"):
		var tf: Dictionary = b.look_tf
		var full = b.look.duplicate(true)
		for k in tf:
			full[k] = tf[k]
		b.look_tf_full = BallArt.normalize(full)
	if not b.has("weapon"):
		b.weapon = WeaponArt.default_for(b)
	b.rarity = clampi(int(b.get("rarity", 0)), 0, 7)
	if not ROLE.has(str(b.get("role", ""))):
		b.role = "Atacante"
	BALLS[id] = b


# ------------------------------------------------------------------------------------------------
# EQUIPAMENTOS (do JOGADOR: valem para a bolinha que estiver em campo; nao aparecem na bolinha)
# ------------------------------------------------------------------------------------------------
const SLOTS := ["weapon", "armor", "helmet", "amulet", "wings", "gloves", "boots", "belt", "ring"]
const SLOT_INFO := {
	"weapon": {"name": "Arma", "main": "atk", "base": 6.0},
	"armor": {"name": "Armadura", "main": "hp", "base": 40.0},
	"helmet": {"name": "Elmo", "main": "hp", "base": 26.0},
	"amulet": {"name": "Amuleto", "main": "atk", "base": 3.5},
	"wings": {"name": "Asas", "main": "both", "base": 4.0, "unlock_stage": 41},
	"gloves": {"name": "Luvas", "main": "atk", "base": 4.0},
	"boots": {"name": "Botas", "main": "hp", "base": 18.0},
	"belt": {"name": "Cinto", "main": "hp", "base": 30.0},
	"ring": {"name": "Anel", "main": "atk", "base": 3.0},
}
const EQ_RARITY_MULT := [1.0, 1.3, 1.7, 2.2, 2.9, 3.8, 5.0, 6.5, 8.5]
const SUBSTATS := {
	"crit": {"name": "Crítico", "val": 0.02, "pct": true},
	"critdmg": {"name": "Dano Crítico", "val": 0.08, "pct": true},
	"dodge": {"name": "Esquiva", "val": 0.015, "pct": true},
	"lifesteal": {"name": "Roubo de Vida", "val": 0.015, "pct": true},
	"atk_pct": {"name": "Ataque", "val": 0.03, "pct": true},
	"hp_pct": {"name": "Vida", "val": 0.04, "pct": true},
	"cdr": {"name": "Recarga", "val": 0.02, "pct": true},
	"spd_pct": {"name": "Velocidade", "val": 0.03, "pct": true},
}
const WEAPON_TYPES := ["Corpo a corpo", "À distância"]

# ------------------------------------------------------------------------------------------------
# GACHA / LOJA
# ------------------------------------------------------------------------------------------------
const GACHA_COST_1 := 100
const GACHA_COST_10 := 900
const GACHA_RATES := [34.0, 28.0, 20.0, 10.5, 5.0, 1.8, 0.52, 0.18]  # % por raridade base (0..7)
const GACHA_PITY := 50  # garante Lendario+ apos 50 tiros sem

# produtos com dinheiro real (ids devem existir no Google Play Console / App Store Connect)
const IAP := [
	{"id": "gems_100", "name": "Punhado de Gemas", "gems": 100, "price": "R$ 1,99", "bonus": 0},
	{"id": "gems_550", "name": "Saco de Gemas", "gems": 500, "price": "R$ 9,90", "bonus": 50},
	{"id": "gems_1200", "name": "Baú de Gemas", "gems": 1000, "price": "R$ 19,90", "bonus": 200},
	{"id": "gems_2600", "name": "Cofre de Gemas", "gems": 2100, "price": "R$ 39,90", "bonus": 500},
	{"id": "gems_6500", "name": "Montanha de Gemas", "gems": 5000, "price": "R$ 89,90", "bonus": 1500},
	{"id": "starter_pack", "name": "Pacote Iniciante", "gems": 500, "price": "R$ 4,90", "bonus": 0, "once": true, "keys": 100, "ball_rarity": 2},
	{"id": "vip_month", "name": "Passe VIP (30 dias)", "gems": 300, "price": "R$ 9,90", "bonus": 0, "vip_days": 30},
	{"id": "speed_x3", "name": "Gamepass Velocidade 3x", "gems": 0, "price": "R$ 7,90", "bonus": 0, "once": true, "speed": 3, "desc": "Libera o botão de batalha 3x para sempre."},
	{"id": "speed_x4", "name": "Gamepass Velocidade 4x", "gems": 0, "price": "R$ 12,90", "bonus": 0, "once": true, "speed": 4, "desc": "Libera o botão de batalha 4x (inclui 3x) para sempre."},
]
const GEM_SHOP := [
	{"id": "keys_50", "name": "50 Chaves", "cost": 40, "keys": 50},
	{"id": "keys_300", "name": "300 Chaves", "cost": 200, "keys": 300},
	{"id": "coins_s", "name": "Bolsa de Moedas", "cost": 30, "coins_hours": 2},
	{"id": "coins_l", "name": "Cofre de Moedas", "cost": 120, "coins_hours": 10},
]

const UPGRADES := [
	{"id": "atk", "name": "Treino de Força", "desc": "+5% ataque da bolinha em campo", "base": 200.0, "growth": 1.35, "per": 0.05},
	{"id": "hp", "name": "Treino de Resistência", "desc": "+5% vida da bolinha em campo", "base": 200.0, "growth": 1.35, "per": 0.05},
	{"id": "gold", "name": "Bolsa Maior", "desc": "+10% moedas ganhas", "base": 300.0, "growth": 1.45, "per": 0.1},
	{"id": "chest", "name": "Nível do Baú", "desc": "Itens melhores e mais chance de bolinhas", "base": 500.0, "growth": 1.6, "per": 1.0},
	{"id": "offline", "name": "Ampulheta", "desc": "+1h de ganho offline (máx. 12h)", "base": 800.0, "growth": 1.7, "per": 1.0, "max": 10},
]


static func rarity(r: int) -> Dictionary:
	return RARITY[clampi(r, 0, RARITY.size() - 1)]


static func rcolor(r: int) -> Color:
	return Color(rarity(r).color)


## valor de um parametro de skill, resolvendo arrays por raridade
static func p(sk: Dictionary, key: String, r: int, def: Variant = 0.0) -> Variant:
	var v: Variant = sk.get(key, def)
	if v is Array:
		var a: Array = v
		if a.is_empty():
			return def
		return a[clampi(r, 0, a.size() - 1)]
	return v


static func ball_name(id: String, r: int) -> String:
	var b: Dictionary = BALLS.get(id, {})
	if b.is_empty():
		return id
	var forms: Array = b.get("forms", [])
	if r < forms.size() and str(forms[r]) != "":
		return "%s · %s" % [b.name, forms[r]]
	return b.name


static func boss_name(id: String) -> String:
	return BOSSES.get(id, {}).get("name", id)


static func chapter(c: int) -> Dictionary:
	return CHAPTERS[(c - 1) % CHAPTERS.size()]


static func chapter_count() -> int:
	return CHAPTERS.size()


static func balls_of_world(w: String) -> Array:
	var out := []
	for id in BALLS:
		if BALLS[id].get("world", "") == w:
			out.append(id)
	return out

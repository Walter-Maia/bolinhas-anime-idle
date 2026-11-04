extends RefCounted
## Mundo 6: inimigos, chefes, capitulos 49-56 do Modo Historia, modo Chefes e banners da sexta leva.

const ENEMIES := {
	"w6_capanga_peste": {"name": "Capanga das Oito Balas Pestilentas", "look": {"skin": "#e8c8a8", "hair": "#2a2a32", "hair_style": "undercut", "outfit": "suit", "outfit_color": "#1a1a22", "outfit_color2": "#4a6a5a", "acc": ["mouth_mask", "fur_collar"], "acc_colors": {"mouth_mask": "#e8e4dc", "fur_collar": "#4a6a5a"}}, "weapon": {"kind": "needle", "color": "#8ad8a8"}},
	"w6_aberracao_cerebro": {"name": "Aberração do Cérebro Exposto", "look": {"skin": "#3a3a48", "hair": "#e89ab0", "hair_style": "curly", "outfit": "none", "acc": ["half_mask", "chains"], "acc_colors": {"half_mask": "#f4f0e8", "chains": "#8a8a94"}}, "weapon": {"kind": "claw", "color": "#2a2a32"}},
	"w6_tita_sorridente": {"name": "Titã Puro do Sorriso Largo", "look": {"skin": "#e8b898", "hair": "#6a4a2a", "hair_style": "mid", "outfit": "none", "acc": ["bandage"], "acc_color": "#c84848"}, "weapon": {"kind": "fist", "color": "#e8b898"}},
	"w6_soldado_continente": {"name": "Soldado do Continente da Braçadeira", "look": {"skin": "#f0d0b0", "hair": "#c8a060", "hair_style": "buzz", "hat": "military", "hat_color": "#5a5a3a", "hat_color2": "#2a2a1a", "outfit": "uniform", "outfit_color": "#6a6a4a", "outfit_color2": "#3a3a2a", "acc": ["armband"], "acc_color": "#c84848"}, "weapon": {"kind": "rifle", "color": "#3a3a3a"}},
	"w6_operario_terno": {"name": "Operário de Terno da Empresa Rival", "look": {"skin": "#f0d8c0", "hair": "#1a1a22", "hair_style": "side_part", "outfit": "suit", "outfit_color": "#2a2a38", "outfit_color2": "#c8c8d0", "acc": ["glasses", "armband"], "acc_colors": {"glasses": "#14101e", "armband": "#d8a040"}}, "weapon": {"kind": "tonfa", "color": "#3a3a48"}},
	"w6_arruaceiro_beco": {"name": "Arruaceiro do Beco de Moletom", "look": {"skin": "#e8c0a0", "hair": "#e8d040", "hair_style": "messy", "hat": "beanie", "hat_color": "#2a2a32", "outfit": "hoodie", "outfit_color": "#4a4a58", "outfit_color2": "#c84848", "acc": ["earrings"], "acc_color": "#c8ccd4"}, "weapon": {"kind": "bat", "color": "#c8a070"}},
	"w6_discipulo_sombra": {"name": "Discípulo da Aliança das Sombras", "look": {"skin": "#e0b890", "hair": "#14101e", "hair_style": "spiky_back", "outfit": "gi", "outfit_color": "#1a1a22", "outfit_color2": "#6a2a8a", "acc": ["headband"], "acc_color": "#6a2a8a"}, "weapon": {"kind": "fist", "color": "#6a2a8a"}},
	"w6_lutador_ragnarok": {"name": "Lutador da Gangue do Crepúsculo", "look": {"skin": "#f0d0b0", "hair": "#d84848", "hair_style": "pompadour", "outfit": "jacket", "outfit_color": "#1a1a2a", "outfit_color2": "#d8a040", "acc": ["scar_x"], "acc_color": "#c84848"}, "weapon": {"kind": "chain", "color": "#a8aab4"}},
	"w6_drone_vigia": {"name": "Drone Vigia do Sistema Oráculo", "look": {"skin": "#c8ccd4", "hair": "#4ad8c8", "hair_style": "dome", "outfit": "cyber", "outfit_color": "#3a4a5a", "outfit_color2": "#4ad8c8", "acc": ["visor", "antennae"], "acc_colors": {"visor": "#4ad8c8", "antennae": "#8a8a94"}}, "weapon": {"kind": "gear", "color": "#4ad8c8"}},
	"w6_arruaceiro_capacete": {"name": "Arruaceiro do Capacete Holográfico", "look": {"skin": "#e8c8a8", "hair": "#3a3a3a", "hair_style": "short", "hat": "knight_helmet", "hat_color": "#f4f4fa", "hat_color2": "#4ad8c8", "outfit": "jacket", "outfit_color": "#3a3a48", "outfit_color2": "#f4f4fa", "acc": ["visor"], "acc_color": "#ff6ad5"}, "weapon": {"kind": "hammer", "color": "#a8aab4"}},
	"w6_monstro_medo": {"name": "Monstro Alado do Medo do Reino", "look": {"skin": "#6a4a8a", "hair": "#3a2a5a", "hair_style": "spiky", "outfit": "none", "acc": ["horns", "devil_wings", "tail"], "acc_colors": {"horns": "#f4e8c8", "devil_wings": "#3a2a5a", "tail": "#6a4a8a"}}, "weapon": {"kind": "claw", "color": "#f4e8c8"}},
	"w6_piloto_reino_vizinho": {"name": "Piloto do Reino Vizinho das Máquinas", "look": {"skin": "#f0d8c0", "hair": "#6a8ad8", "hair_style": "bob", "outfit": "cyber", "outfit_color": "#f4f4fa", "outfit_color2": "#3c6ad8", "acc": ["goggles", "headphones"], "acc_colors": {"goggles": "#ffd23c", "headphones": "#3c6ad8"}}, "weapon": {"kind": "gun", "color": "#3c6ad8"}},
	"w6_demonio_menor": {"name": "Demônio Menor da Raça Sombria", "look": {"skin": "#4a3a5a", "hair": "#1a1222", "hair_style": "none", "outfit": "robe", "outfit_color": "#2a1a3a", "outfit_color2": "#c84848", "acc": ["small_horns", "tail"], "acc_color": "#c84848"}, "weapon": {"kind": "scythe", "color": "#5a4a6a"}},
	"w6_bandido_estrada": {"name": "Bandido da Estrada que Vai Ser Assaltado", "look": {"skin": "#e0b080", "hair": "#4a2a1a", "hair_style": "messy", "outfit": "vest", "outfit_color": "#6a4a2a", "outfit_color2": "#3a2a1a", "acc": ["bandana", "beard"], "acc_colors": {"bandana": "#c84848", "beard": "#4a2a1a"}}, "weapon": {"kind": "axe", "color": "#a8aab4"}},
	"w6_mercenario_porto": {"name": "Mercenário Bêbado do Cais", "look": {"skin": "#d8a878", "hair": "#2a2a2a", "hair_style": "buzz", "hat": "bandana_top", "hat_color": "#3a5a3a", "outfit": "tank", "outfit_color": "#4a5a3a", "acc": ["sunglasses", "goatee"], "acc_colors": {"sunglasses": "#14101e", "goatee": "#2a2a2a"}}, "weapon": {"kind": "rifle", "color": "#2a2a2a"}},
	"w6_yakuza_toquio": {"name": "Yakuza do Clã do Sol Nascente", "look": {"skin": "#f0d0b0", "hair": "#14101e", "hair_style": "slick", "outfit": "suit", "outfit_color": "#f4f4fa", "outfit_color2": "#14101e", "acc": ["sunglasses", "scar_x"], "acc_colors": {"sunglasses": "#14101e", "scar_x": "#c87878"}}, "weapon": {"kind": "dagger", "color": "#c8ccd4"}},
}

## chefes da sexta leva: aparecem no fim dos capitulos 49-56 e no Modo Chefes
const BOSSES := {
	"w6_mestre_reconstrucao": {"name": "Jovem Chefe Mascarado da Reconstrução", "rarity": 6, "hp_mult": 16.0, "atk_mult": 2.6, "color": "#4a8a6a",
		"look": {"skin": "#f0d8c0", "hair": "#3a2a1a", "hair_style": "short", "outfit": "coat", "outfit_color": "#1a2a22", "outfit_color2": "#6a8a7a", "acc": ["mouth_mask", "fur_collar"], "acc_colors": {"mouth_mask": "#e8e4dc", "fur_collar": "#4a6a5a"}},
		"weapon": {"kind": "fist", "color": "#6a8a7a", "count": 2, "spin": 5.0},
		"actives": [
			{"name": "Espinhos do Chão Desmontado", "type": "aoe", "cd": 9.0, "power": 2.6, "fx": "earth_spike", "fx_scale": 0.6, "radius": 120.0, "warn": 0.8, "status": "bleed", "status_dur": 3.0, "status_chance": 0.5, "shake": 6.0},
			{"name": "Bala que Apaga o Poder", "type": "projectile", "cd": 11.0, "power": 1.8, "fx": "bullet", "fx_scale": 0.5, "speed": 620.0, "rotate": true, "hit_fx": "glitch", "target": "strongest", "status": "silence", "status_dur": 3.0, "status_chance": 1.0},
			{"name": "Remontagem do Próprio Corpo", "type": "heal", "cd": 14.0, "power": 0.18, "fx": "resurrection"},
		]},
	"w6_tita_fundador": {"name": "Titã Fundador da Marcha das Muralhas", "rarity": 6, "hp_mult": 17.5, "atk_mult": 2.7, "color": "#e8dcc8",
		"look": {"skin": "#d8c8b0", "hair": "#2a1a12", "hair_style": "wild_long", "outfit": "none", "acc": ["half_mask", "chains", "high_collar"], "acc_colors": {"half_mask": "#f4ece0", "chains": "#a89880", "high_collar": "#c8b8a0"}},
		"weapon": {"kind": "claw", "color": "#f4ece0", "count": 3, "spin": -3.5},
		"actives": [
			{"name": "Passos dos Colossais da Muralha", "type": "rain", "cd": 9.0, "power": 1.5, "count": 6, "fx": "quake", "fx_scale": 0.5, "radius": 60.0, "status": "stun", "status_dur": 0.8, "status_chance": 0.3, "shake": 7.0},
			{"name": "Exército de Titãs Puros", "type": "summon", "cd": 15.0, "power": 0.35, "count": 2, "dur": 8.0, "fx": "summon_rise",
				"summon_look": {"skin": "#e8b898", "hair": "#6a4a2a", "hair_style": "mid", "outfit": "none", "acc": ["bandage"], "acc_color": "#c84848"}},
			{"name": "Grito da Coordenada", "type": "knockback", "cd": 10.0, "power": 2.0, "radius": 170.0, "force": 850.0, "fx": "thunderclap", "fx_scale": 0.55, "status": "weaken", "status_dur": 4.0, "status_chance": 1.0, "shake": 6.0},
		]},
	"w6_rei_mercenario_tranca": {"name": "Rei Mercenário da Trança Longa", "rarity": 6, "hp_mult": 19.0, "atk_mult": 2.8, "color": "#c84848",
		"look": {"skin": "#f0d8c0", "hair": "#14101e", "hair_style": "braid", "outfit": "jacket", "outfit_color": "#1a1a22", "outfit_color2": "#c84848", "acc": ["earrings", "bandage"], "acc_colors": {"earrings": "#ffd23c", "bandage": "#f4f4fa"}},
		"weapon": {"kind": "fist", "color": "#c84848", "count": 2, "spin": 7.5, "power": 0.6},
		"actives": [
			{"name": "Joelhada do Ringue Proibido", "type": "dash", "cd": 7.0, "power": 1.7, "count": 4, "hit_fx": "uppercut", "hit_scale": 0.5, "trail_fx": "blink_out"},
			{"name": "Cotoveladas Cortantes", "type": "multi", "cd": 6.0, "power": 0.9, "count": 6, "interval": 0.09, "fx": "slash_red", "fx_scale": 0.5, "status": "bleed", "status_dur": 3.0, "status_chance": 0.5},
			{"name": "Instinto do Rei da Rua", "type": "buff", "cd": 13.0, "power": 0.0, "dur": 5.0, "buffs": {"dodge": 0.35, "spd_pct": 0.3, "crit": 0.2}, "fx": "aura_red"},
		]},
	"w6_senhor_punho_sombrio": {"name": "Rei Mascarado do Punho Único Sombrio", "rarity": 6, "hp_mult": 20.5, "atk_mult": 2.95, "color": "#ffd23c",
		"look": {"skin": "#8a5a3a", "hair": "#f4f4fa", "hair_style": "long_bangs", "hat": "crown", "hat_color": "#ffd23c", "hat_color2": "#c84848", "outfit": "cape", "outfit_color": "#2a1a12", "outfit_color2": "#ffd23c", "acc": ["full_mask", "necklace"], "acc_colors": {"full_mask": "#f4f4fa", "necklace": "#ffd23c"}},
		"weapon": {"kind": "fist", "color": "#ffd23c", "count": 2, "spin": -6.0},
		"actives": [
			{"name": "Punho Fantasma Ilusório", "type": "teleport", "cd": 7.0, "power": 2.6, "fx": "impact_frame", "fx_scale": 0.5, "target": "weakest"},
			{"name": "Coroa do Movimento Dourado", "type": "orbit", "cd": 11.0, "power": 1.1, "count": 4, "dur": 5.0, "orbit_r": 95.0, "fx": "orb_gold"},
			{"name": "Golpe Final da Aliança Sombria", "type": "strike", "cd": 13.0, "power": 8.0, "fx": "sunburst", "fx_scale": 0.6, "flash": true, "force_crit": true, "shake": 8.0},
		]},
	"w6_fantasma_sem_matiz": {"name": "Fantasma Remendado Sem Matiz", "rarity": 7, "hp_mult": 22.0, "atk_mult": 3.05, "color": "#4ad8c8",
		"look": {"skin": "#e8d0c0", "hair": "#d8d8e0", "hair_style": "cover_eye", "hat": "hood", "hat_color": "#2a2a38", "outfit": "coat", "outfit_color": "#2a2a38", "outfit_color2": "#4ad8c8", "acc": ["cyber_lines", "scar_x", "high_collar"], "acc_colors": {"cyber_lines": "#4ad8c8", "scar_x": "#c8a0a0", "high_collar": "#1a1a22"}},
		"weapon": {"kind": "gun", "color": "#4ad8c8", "count": 2, "spin": 4.0},
		"actives": [
			{"name": "Disparo da Arma Que Julga Roubada", "type": "beam", "cd": 9.0, "power": 3.8, "fx": "beam_ki", "width": 44.0, "ticks": 5, "charge": 0.9, "target": "strongest", "shake": 6.0},
			{"name": "Coeficiente Invisível", "type": "debuff", "cd": 12.0, "power": 0.3, "status": "marked", "status_dur": 5.0, "radius": 0.0, "fx": "hologram"},
			{"name": "Névoa da Tinta Turva", "type": "zone", "cd": 10.0, "power": 0.8, "fx": "poison_cloud", "fx_scale": 0.6, "radius": 125.0, "dur": 4.5, "pull": 60.0, "status": "poison", "status_dur": 3.0, "status_chance": 0.6},
		]},
	"w6_imperatriz_medo": {"name": "Imperatriz Sem Forma do Medo do Reino", "rarity": 7, "hp_mult": 23.5, "atk_mult": 3.15, "color": "#8a4ad8",
		"look": {"skin": "#d8c0d8", "hair": "#5a2a8a", "hair_style": "drills", "tips": "#c84848", "hat": "crown", "hat_color": "#2a1a3a", "hat_color2": "#c84848", "outfit": "dress", "outfit_color": "#2a1a3a", "outfit_color2": "#8a4ad8", "acc": ["horns", "devil_wings", "earrings"], "acc_colors": {"horns": "#1a1222", "devil_wings": "#3a1a5a", "earrings": "#c84848"}},
		"weapon": {"kind": "staff", "color": "#8a4ad8", "count": 2, "spin": 3.5},
		"actives": [
			{"name": "Raio do Pavor Coletivo", "type": "beam", "cd": 9.0, "power": 3.6, "fx": "beam_purple", "width": 50.0, "ticks": 5, "charge": 1.0, "shake": 6.0},
			{"name": "Crias do Medo Sem Pilar", "type": "summon", "cd": 15.0, "power": 0.35, "count": 2, "dur": 8.0, "fx": "spawn_portal",
				"summon_look": {"skin": "#6a4a8a", "hair": "#3a2a5a", "hair_style": "spiky", "outfit": "none", "acc": ["horns", "devil_wings"], "acc_color": "#f4e8c8"}},
			{"name": "Desespero do Reino Inteiro", "type": "debuff", "cd": 12.0, "power": 0.3, "status": "weaken", "status_dur": 5.0, "radius": 0.0, "fx": "curse"},
		]},
	"w6_senhor_inferno_infantil": {"name": "Senhor do Inferno de Aparência Infantil", "rarity": 7, "hp_mult": 25.0, "atk_mult": 3.3, "color": "#3a8a5a",
		"look": {"skin": "#f4e0d0", "hair": "#1a3a2a", "hair_style": "bob", "hat": "beret", "hat_color": "#2a2a4a", "hat_color2": "#3a8a5a", "outfit": "shirt_tie", "outfit_color": "#f4f4fa", "outfit_color2": "#2a2a4a", "acc": ["collar", "ahoge"], "acc_colors": {"collar": "#3a8a5a", "ahoge": "#1a3a2a"}},
		"weapon": {"kind": "orb", "color": "#3a8a5a", "count": 3, "spin": -4.5},
		"actives": [
			{"name": "Brincadeira das Almas Roubadas", "type": "drain", "cd": 7.0, "power": 2.5, "fx": "soul_drain", "fx_scale": 0.6, "heal_pct": 0.45},
			{"name": "Chuva de Caveiras do Inferno", "type": "rain", "cd": 9.0, "power": 1.6, "count": 6, "fx": "necro_skulls", "fx_scale": 0.5, "radius": 55.0, "status": "black_burn", "status_dur": 3.0, "status_chance": 0.4},
			{"name": "Tabuleiro do Mestre Infernal", "type": "timestop", "cd": 16.0, "power": 0.0, "dur": 2.0, "fx": "time_stop"},
		]},
	"w6_ceifador_prateado": {"name": "Ceifador Prateado da Katana do Clã", "rarity": 7, "hp_mult": 26.0, "atk_mult": 3.4, "color": "#d8dde8",
		"look": {"skin": "#f0d8c0", "hair": "#e8e4dc", "hair_style": "slick", "outfit": "suit", "outfit_color": "#14101e", "outfit_color2": "#f4f4fa", "acc": ["sunglasses", "sword_back"], "acc_colors": {"sunglasses": "#14101e", "sword_back": "#d8dde8"}},
		"weapon": {"kind": "katana", "color": "#d8dde8", "count": 1, "spin": 8.0, "power": 0.7},
		"actives": [
			{"name": "Corte Relâmpago Sem Bainha", "type": "dash", "cd": 7.0, "power": 1.9, "count": 4, "hit_fx": "double_slash", "hit_scale": 0.55, "trail_fx": "blink_out"},
			{"name": "Saque Fatal do Ceifador", "type": "execute", "cd": 9.0, "power": 2.6, "fx": "heavy_cleave", "fx_scale": 0.6, "threshold": 0.35},
			{"name": "Defesa da Lâmina Prateada", "type": "shield", "cd": 13.0, "power": 0.22, "dur": 4.0, "invuln": 0.8, "fx": "parry"},
		]},
}

const CHAPTERS := [
	{"name": "Resgate da Garotinha do Chifre", "world": "Academia de Heróis", "enemies": ["w6_capanga_peste", "w6_aberracao_cerebro"], "boss": "w6_mestre_reconstrucao", "guide": "mha2_atravessa_paredes",
		"theme": {"floor": "#f0f4f2", "floor2": "#d8e4de", "accent": "#4a8a6a", "line": "#b4ccc0"},
		"intro": ["A yakuza das máscaras de peste esconde uma menininha.", "O chefe deles desmonta e remonta tudo o que toca.", "Eu atravesso qualquer parede. Hoje vou atravessar até ele!"],
		"boss_line": "Poderes são uma doença. Eu vou curar o mundo inteiro.", "outro": "A garotinha sorriu pela primeira vez. Valeu cada golpe."},
	{"name": "A Marcha Final dos Colossais", "world": "Ilha das Muralhas", "enemies": ["w6_tita_sorridente", "w6_soldado_continente"], "boss": "w6_tita_fundador", "guide": "aot_cachecol_vermelho",
		"theme": {"floor": "#f4f0ea", "floor2": "#e4dcd0", "accent": "#a89070", "line": "#d0c4b0"},
		"intro": ["O chão treme. Milhares de colossais marcham além das muralhas.", "No meio da fumaça, um titã feito de ossos comanda tudo.", "Eu vou te trazer de volta. Nem que seja pela última vez."],
		"boss_line": "Eu sigo em frente. Até o fim do mundo.", "outro": "As muralhas caíram. Mas o céu, finalmente, está livre."},
	{"name": "Guerra Contra a Firma dos Operários", "world": "Colégio das Duas Aparências", "enemies": ["w6_operario_terno", "w6_arruaceiro_beco"], "boss": "w6_rei_mercenario_tranca", "guide": "lookism_dois_corpos",
		"theme": {"floor": "#f4f0f0", "floor2": "#e4d8d8", "accent": "#c84848", "line": "#d4bcbc"},
		"intro": ["Uma empresa de lutadores está engolindo as gangues da cidade.", "O rei dela luta de trança e nunca perdeu uma briga.", "Corpo bonito, corpo feio... os dois vão lutar hoje."],
		"boss_line": "Interessante. Você copia rápido. Mas eu bato mais rápido.", "outro": "A firma recuou. A escola voltou a ser só uma escola."},
	{"name": "Torneio Final da Aliança Sombria", "world": "Dojo da Montanha dos Mestres", "enemies": ["w6_discipulo_sombra", "w6_lutador_ragnarok"], "boss": "w6_senhor_punho_sombrio", "guide": "kenichi_discipulo_fraco",
		"theme": {"floor": "#f6f2e6", "floor2": "#e8e0c8", "accent": "#d8a020", "line": "#d4c8a0"},
		"intro": ["A aliança das sombras armou um torneio numa ilha distante.", "O rei mascarado deles nunca usa o mesmo golpe duas vezes.", "Eu sou o mais fraco do dojo... mas eu não desisto nunca!"],
		"boss_line": "O punho que não mata é só uma dança bonita.", "outro": "Os mestres riram lá do alto. O discípulo venceu de novo."},
	{"name": "Caso do Fantasma Sem Matiz", "world": "Tóquio do Índice Criminal", "enemies": ["w6_drone_vigia", "w6_arruaceiro_capacete"], "boss": "w6_fantasma_sem_matiz", "guide": "psycho_inspetora_novata",
		"theme": {"floor": "#eef4f4", "floor2": "#d4e4e4", "accent": "#3cb4b4", "line": "#b0d0d0"},
		"intro": ["Um criminoso que o sistema simplesmente não consegue ver.", "Ele é feito de pedaços de mais de cento e oitenta pessoas.", "A lei não é a máquina. A lei somos nós. Vamos, equipe."],
		"boss_line": "Se o sistema julga todos, quem julga o sistema?", "outro": "O matiz da cidade clareou. Por enquanto."},
	{"name": "Segunda Invocação ao Reino Sem Pilar", "world": "Terra dos Pilares Mágicos", "enemies": ["w6_monstro_medo", "w6_piloto_reino_vizinho"], "boss": "w6_imperatriz_medo", "guide": "rayearth_guerreira_chama",
		"theme": {"floor": "#f4f0f8", "floor2": "#e2d8ec", "accent": "#8a4ad8", "line": "#ccbce0"},
		"intro": ["Fomos chamadas de volta ao reino mágico. Ele está desmoronando.", "Sem um pilar, o medo do povo ganhou corpo e coroa.", "Desta vez a gente escolhe o próprio destino. Juntas!"],
		"boss_line": "Eu sou o medo de todos vocês. Não podem me apagar.", "outro": "O reino agora se sustenta pelo coração de cada um."},
	{"name": "O Senhor Infernal e o Feitiço Proibido", "world": "Reino dos Feitiços Explosivos", "enemies": ["w6_demonio_menor", "w6_bandido_estrada"], "boss": "w6_senhor_inferno_infantil", "guide": "slayers_feiticeira_ruiva",
		"theme": {"floor": "#f6f0ea", "floor2": "#ece0d0", "accent": "#d85a2a", "line": "#dcc8b0"},
		"intro": ["Um senhor do inferno com cara de criança quer brincar comigo.", "Ele sequestrou meus amigos só pra me obrigar a usar o feitiço proibido.", "Tá bom. Mas depois eu como o banquete inteiro da cidade!"],
		"boss_line": "Que divertido! Mostra o feitiço que pode apagar o mundo!", "outro": "O mundo sobreviveu. Meu estômago, por pouco."},
	{"name": "Lâmina do Clã na Terra do Sol", "world": "Porto Sem Lei da Lagoa Negra", "enemies": ["w6_mercenario_porto", "w6_yakuza_toquio"], "boss": "w6_ceifador_prateado", "guide": "lagoon_duas_maos",
		"theme": {"floor": "#f2f2f0", "floor2": "#dcdcd8", "accent": "#5a6a7a", "line": "#c0c4c8"},
		"intro": ["Um serviço de entrega virou guerra de clãs em Tóquio.", "O espadachim de cabelo prateado corta balas no ar.", "Bala é mais rápida que espada. Vamos tirar a prova."],
		"boss_line": "Proteger a jovem senhora. Esse é meu único caminho.", "outro": "Voltamos pro porto. A neve de Tóquio ficou pra trás."},
]

## modo Chefes (sexta leva): desbloqueio por nivel da conta
const BOSS_RAID := [
	{"boss": "w6_mestre_reconstrucao", "level": 245}, {"boss": "w6_tita_fundador", "level": 251}, {"boss": "w6_rei_mercenario_tranca", "level": 257},
	{"boss": "w6_senhor_punho_sombrio", "level": 263}, {"boss": "w6_fantasma_sem_matiz", "level": 269}, {"boss": "w6_imperatriz_medo", "level": 275},
	{"boss": "w6_senhor_inferno_infantil", "level": 282}, {"boss": "w6_ceifador_prateado", "level": 290},
]

const BANNERS := [
	{"id": "w6_herois_muralhas", "name": "Heróis, Muralhas & Mestres", "desc": "Academia de Heróis, Ilha das Muralhas, Colégio das Duas Aparências e Dojo da Montanha dos Mestres.", "worlds": ["Academia de Heróis", "Ilha das Muralhas", "Colégio das Duas Aparências", "Dojo da Montanha dos Mestres"], "chapter": 52, "color": "#4a8a6a"},
	{"id": "w6_feiticos_porto", "name": "Índices, Pilares & Pólvora", "desc": "Tóquio do Índice Criminal, Pilares Mágicos, Feitiços Explosivos e Lagoa Negra.", "worlds": ["Tóquio do Índice Criminal", "Terra dos Pilares Mágicos", "Reino dos Feitiços Explosivos", "Porto Sem Lei da Lagoa Negra"], "chapter": 56, "color": "#8a4ad8"},
]

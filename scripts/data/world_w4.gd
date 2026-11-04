extends RefCounted
## Mundo 4: inimigos, chefes, capitulos 33-40 do Modo Historia, modo Chefes e banners da quarta leva.

const ENEMIES := {
	"w4_demonio_cinzento": {"name": "Demônio Cinzento do Clã Sombrio", "look": {"skin": "#8a8a94", "hair": "#2a2a32", "hair_style": "none", "outfit": "none", "acc": ["horns", "devil_wings", "star_mark"], "acc_color": "#2a2a32"}, "weapon": {"kind": "claw", "color": "#4a4a54"}},
	"w4_aprendiz_sagrado": {"name": "Aprendiz de Cavaleiro Sagrado", "look": {"skin": "#f0d0b0", "hair": "#c8a060", "hair_style": "short", "hat": "knight_helmet", "hat_color": "#c8ccd4", "hat_color2": "#3c6ad8", "outfit": "armor", "outfit_color": "#c8ccd4", "outfit_color2": "#3c6ad8"}, "weapon": {"kind": "sword", "color": "#d8dde8"}},
	"w4_delinquente_moto": {"name": "Delinquente da Moto Barulhenta", "look": {"skin": "#f0d0b0", "hair": "#e8c040", "hair_style": "pompadour", "outfit": "coat", "outfit_color": "#1a1a2a", "outfit_color2": "#d8c040", "acc": ["mouth_mask"], "acc_color": "#f4f4fa"}, "weapon": {"kind": "bat", "color": "#a8aab4"}},
	"w4_membro_celestial": {"name": "Membro da Gangue Celestial", "look": {"skin": "#e0b890", "hair": "#2a1a1a", "hair_style": "buzz", "outfit": "coat", "outfit_color": "#c84848", "outfit_color2": "#1a1a2a", "acc": ["earrings"], "acc_color": "#ffd23c"}, "weapon": {"kind": "chain", "color": "#8a8a94"}},
	"w4_corvo_assassino": {"name": "Corvo Assassino do Céu Sombrio", "look": {"skin": "#e8d0b8", "hair": "#14101e", "hair_style": "short", "hat": "kasa", "hat_color": "#2a2a32", "outfit": "robe", "outfit_color": "#1a1a22", "outfit_color2": "#5a4a6a", "acc": ["mouth_mask"], "acc_color": "#1a1a22"}, "weapon": {"kind": "staff", "color": "#c8ccd4"}},
	"w4_amanto_invasor": {"name": "Forasteiro Invasor de Cara de Bicho", "look": {"skin": "#7ab86a", "hair": "#3a5a2a", "hair_style": "none", "outfit": "armor", "outfit_color": "#5a6a7a", "acc": ["antennae", "tail"], "acc_color": "#3a5a2a"}, "weapon": {"kind": "spear", "color": "#a8aab4"}},
	"w4_fera_gourmet": {"name": "Fera Gourmet de Nível de Captura Alto", "look": {"skin": "#c88a4a", "hair": "#6a3a1a", "hair_style": "wild_long", "outfit": "none", "acc": ["horns", "tail"], "acc_color": "#f4e8c8"}, "weapon": {"kind": "claw", "color": "#f4e8c8"}},
	"w4_soldado_corporacao": {"name": "Soldado da Corporação Gourmet", "look": {"skin": "#e0c0a0", "hair": "#1a1a22", "hair_style": "undercut", "outfit": "uniform", "outfit_color": "#2a2a38", "outfit_color2": "#c84848", "acc": ["goggles"], "acc_color": "#c84848"}, "weapon": {"kind": "dagger", "color": "#c8ccd4"}},
	"w4_guerreiro_asura": {"name": "Guerreiro do País dos Asura", "look": {"skin": "#d8a878", "hair": "#1a1a1a", "hair_style": "wild_long", "outfit": "armor", "outfit_color": "#4a3a3a", "outfit_color2": "#a84848", "acc": ["shoulder_pads", "scar_x"], "acc_color": "#6a5a4a"}, "weapon": {"kind": "fist", "color": "#a84848"}},
	"w4_saqueador_pneu": {"name": "Saqueador do Deserto de Ombreira Espetada", "look": {"skin": "#e0b080", "hair": "#ff6a2a", "hair_style": "mohawk", "outfit": "vest", "outfit_color": "#4a3a2a", "acc": ["shoulder_pads", "sunglasses"], "acc_color": "#3a3a3a"}, "weapon": {"kind": "axe", "color": "#a8aab4"}},
	"w4_esqueleto_demoniaco": {"name": "Esqueleto do Exército Demoníaco", "look": {"skin": "#e8e4dc", "hair": "#e8e4dc", "hair_style": "none", "outfit": "armor", "outfit_color": "#5a3a6a", "acc": ["half_mask", "small_horns"], "acc_color": "#e8e4dc"}, "weapon": {"kind": "sword", "color": "#a8aab4"}},
	"w4_dragao_menor": {"name": "Dragãozinho do Exército das Feras", "look": {"skin": "#4ab86a", "hair": "#2a6a3a", "hair_style": "spiky", "outfit": "none", "acc": ["horns", "wings", "tail"], "acc_color": "#ffd23c"}, "weapon": {"kind": "claw", "color": "#ffd23c"}},
	"w4_lutador_contratado": {"name": "Lutador Contratado da Empresa Rival", "look": {"skin": "#d8a878", "hair": "#1a1a1a", "hair_style": "buzz", "outfit": "tank", "outfit_color": "#f4f4fa", "acc": ["bandage"], "acc_color": "#f4f4fa"}, "weapon": {"kind": "fist", "color": "#c84848"}},
	"w4_seguranca_corporativo": {"name": "Segurança Corporativo de Terno", "look": {"skin": "#e8c8a8", "hair": "#2a2a2a", "hair_style": "slick", "outfit": "suit", "outfit_color": "#1a1a22", "outfit_color2": "#f4f4fa", "acc": ["sunglasses"], "acc_color": "#14101e"}, "weapon": {"kind": "tonfa", "color": "#3a3a48"}},
	"w4_regular_lanca": {"name": "Regular Lanceiro da Torre", "look": {"skin": "#f0d0b0", "hair": "#4a6ad8", "hair_style": "spiky", "outfit": "jacket", "outfit_color": "#2a3a5a", "outfit_color2": "#ffd23c", "acc": ["armband"], "acc_color": "#ffd23c"}, "weapon": {"kind": "spear", "color": "#ffd23c"}},
	"w4_guarda_real": {"name": "Guarda Real da Família Governante", "look": {"skin": "#f0d8c0", "hair": "#e8dca8", "hair_style": "side_part", "outfit": "uniform", "outfit_color": "#f4f4fa", "outfit_color2": "#c8a040", "acc": ["high_collar"], "acc_color": "#c8a040"}, "weapon": {"kind": "needle", "color": "#c8a040"}},
}

## chefes da quarta leva: aparecem no fim dos capitulos 33-40 e no Modo Chefes
const BOSSES := {
	"w4_mandamento_misericordia": {"name": "Comandante da Misericórdia Sombria", "rarity": 5, "hp_mult": 14.0, "atk_mult": 2.4, "color": "#3a2a4a",
		"look": {"skin": "#f0e0d8", "hair": "#1a1a22", "hair_style": "messy", "outfit": "coat", "outfit_color": "#1a1a22", "outfit_color2": "#6a4a8a", "acc": ["star_mark", "devil_wings"], "acc_color": "#14101e"},
		"weapon": {"kind": "sword", "color": "#2a2234", "count": 2},
		"actives": [
			{"name": "Chamas da Escuridão Total", "type": "zone", "cd": 10.0, "power": 0.7, "fx": "shadow_flames", "fx_scale": 0.6, "radius": 120.0, "dur": 4.5, "pull": 80.0, "status": "black_burn", "status_dur": 3.0, "status_chance": 0.6},
			{"name": "Mandamento do Amor Proibido", "type": "debuff", "cd": 11.0, "power": 0.3, "status": "weaken", "status_dur": 5.0, "radius": 0.0, "fx": "hex_sigil"},
			{"name": "Contra-Golpe Total Invertido", "type": "shield", "cd": 13.0, "power": 0.22, "dur": 4.0, "invuln": 0.8, "fx": "shield_purple"},
		]},
	"w4_rei_impulso_sombrio": {"name": "Rei do Impulso Sombrio", "rarity": 5, "hp_mult": 15.0, "atk_mult": 2.5, "color": "#2a2a38",
		"look": {"skin": "#f2dcc4", "hair": "#f4f4fa", "hair_style": "short", "outfit": "coat", "outfit_color": "#14101e", "outfit_color2": "#c8a040", "acc": ["earrings", "scarf"], "acc_color": "#14101e"},
		"weapon": {"kind": "fist", "color": "#2a2a38", "count": 2, "spin": 6.0},
		"actives": [
			{"name": "Chute Invencível do Vazio", "type": "strike", "cd": 9.0, "power": 6.0, "fx": "impact_frame", "fx_scale": 0.6, "flash": true, "shake": 7.0},
			{"name": "Investida da Gangue Fantasma", "type": "dash", "cd": 7.0, "power": 1.6, "count": 3, "hit_fx": "uppercut", "hit_scale": 0.5, "trail_fx": "smoke_bomb"},
			{"name": "Impulso Sombrio Desperto", "type": "awaken", "cd": 14.0, "power": 0.0, "buffs": {"atk_pct": 0.4, "spd_pct": 0.3}, "aura": "aura_dark", "heal": 0.1},
		]},
	"w4_mestre_imortal_vazio": {"name": "Mestre Imortal do Vazio Eterno", "rarity": 6, "hp_mult": 16.0, "atk_mult": 2.6, "color": "#5a4a6a",
		"look": {"skin": "#f2e0d0", "hair": "#c8b8a0", "hair_style": "long", "outfit": "robe", "outfit_color": "#1a1a22", "outfit_color2": "#8a7a9a", "acc": ["high_collar"], "acc_color": "#3a3a48"},
		"weapon": {"kind": "katana", "color": "#c8ccd4", "count": 1, "spin": 5.0},
		"actives": [
			{"name": "Corte do Professor Imortal", "type": "multi", "cd": 6.0, "power": 1.0, "count": 5, "interval": 0.12, "spread": true, "fx": "slash_purple", "fx_scale": 0.6},
			{"name": "Regeneração da Veia do Planeta", "type": "heal", "cd": 14.0, "power": 0.18, "fx": "resurrection"},
			{"name": "Explosão de Energia Vital", "type": "aoe", "cd": 11.0, "power": 2.6, "fx": "purple_explosion", "fx_scale": 0.5, "radius": 120.0, "warn": 0.9, "shake": 6.0},
		]},
	"w4_devorador_insaciavel": {"name": "Devorador Insaciável do Apetite Negro", "rarity": 6, "hp_mult": 17.0, "atk_mult": 2.7, "color": "#1a1a22",
		"look": {"skin": "#2a2230", "hair": "#14101e", "hair_style": "none", "outfit": "none", "acc": ["horns", "devil_wings", "tail"], "acc_color": "#c84848"},
		"weapon": {"kind": "claw", "color": "#c84848", "count": 3, "spin": -5.0},
		"actives": [
			{"name": "Mordida que Devora Tudo", "type": "drain", "cd": 7.0, "power": 2.4, "fx": "soul_drain", "fx_scale": 0.6, "heal_pct": 0.5},
			{"name": "Estômago do Buraco Negro", "type": "zone", "cd": 11.0, "power": 0.8, "fx": "black_hole_red", "fx_scale": 0.55, "radius": 130.0, "dur": 4.5, "pull": 240.0},
			{"name": "Fome Ancestral", "type": "execute", "cd": 9.0, "power": 2.4, "fx": "claw_red", "fx_scale": 0.6, "threshold": 0.35},
		]},
	"w4_rei_demonio_asura": {"name": "Senhor Demoníaco do Punho das Trevas", "rarity": 6, "hp_mult": 18.0, "atk_mult": 2.8, "color": "#8a2a3a",
		"look": {"skin": "#e0b890", "hair": "#14101e", "hair_style": "wild_long", "hat": "knight_helmet", "hat_color": "#2a1a22", "hat_color2": "#c84848", "outfit": "armor", "outfit_color": "#2a1a22", "outfit_color2": "#c84848", "acc": ["shoulder_pads", "scar_x"], "acc_color": "#6a1a2a"},
		"weapon": {"kind": "fist", "color": "#c84848", "count": 2, "spin": 4.5},
		"actives": [
			{"name": "Mil Socos do Punho Sombrio", "type": "multi", "cd": 6.0, "power": 0.8, "count": 8, "interval": 0.08, "fx": "blunt_hit", "fx_scale": 0.5, "status": "bleed", "status_dur": 3.0, "status_chance": 0.4},
			{"name": "Aura do Demônio Rubro", "type": "knockback", "cd": 9.0, "power": 2.0, "radius": 160.0, "force": 800.0, "fx": "dark_explosion", "fx_scale": 0.5, "status": "stun", "status_dur": 1.2, "status_chance": 1.0, "shake": 6.0},
			{"name": "Ponto Vital Proibido", "type": "debuff", "cd": 12.0, "power": 0.3, "status": "armor_break", "status_dur": 5.0, "radius": 0.0, "fx": "curse"},
		]},
	"w4_sombra_rei_demonio": {"name": "Sombra Encapuzada do Rei Demônio", "rarity": 7, "hp_mult": 19.0, "atk_mult": 2.9, "color": "#4a2a6a",
		"look": {"skin": "#1a1222", "hair": "#14101e", "hair_style": "none", "hat": "hood", "hat_color": "#1a1222", "outfit": "cloak_clouds", "outfit_color": "#1a1222", "outfit_color2": "#7a4ad8", "acc": ["soul_gem"], "acc_color": "#ffd23c"},
		"weapon": {"kind": "orb", "color": "#7a4ad8", "count": 3, "spin": 3.5},
		"actives": [
			{"name": "Mãos Negras do Congelamento", "type": "debuff", "cd": 12.0, "power": 0.3, "status": "freeze", "status_dur": 2.0, "radius": 170.0, "fx": "grasping_hands"},
			{"name": "Toque Sombrio Mortal", "type": "teleport", "cd": 7.0, "power": 2.6, "fx": "void_orb", "fx_scale": 0.5},
			{"name": "Laço das Sombras", "type": "zone", "cd": 10.0, "power": 0.8, "fx": "shadow_tendrils", "fx_scale": 0.6, "radius": 120.0, "dur": 4.5, "pull": 150.0},
		]},
	"w4_conector_verme": {"name": "Conector Mascarado da Seita do Verme", "rarity": 7, "hp_mult": 20.0, "atk_mult": 3.0, "color": "#6ab8a0",
		"look": {"skin": "#f0d8c0", "hair": "#e8e4dc", "hair_style": "messy", "hat": "hood", "hat_color": "#2a2a32", "outfit": "hoodie", "outfit_color": "#2a2a32", "outfit_color2": "#6ab8a0", "acc": ["mouth_mask", "bandage"], "acc_color": "#6ab8a0"},
		"weapon": {"kind": "fist", "color": "#6ab8a0", "count": 2, "spin": 7.0},
		"actives": [
			{"name": "Cópia do Estilo Alheio", "type": "mimic", "cd": 8.0, "power": 1.4},
			{"name": "Avanço Assassino do Verme", "type": "dash", "cd": 7.0, "power": 1.7, "count": 4, "hit_fx": "crit_hit", "hit_scale": 0.5, "trail_fx": "blink_out"},
			{"name": "Golpe na Garganta", "type": "debuff", "cd": 12.0, "power": 0.3, "status": "silence", "status_dur": 3.0, "radius": 0.0, "fx": "glitch"},
		]},
	"w4_rei_supremo_torre": {"name": "Rei Supremo da Torre Dourada", "rarity": 7, "hp_mult": 22.0, "atk_mult": 3.2, "color": "#ffd23c",
		"look": {"skin": "#f4e0c8", "hair": "#e8dca8", "hair_style": "long", "hat": "crown", "hat_color": "#ffd23c", "hat_color2": "#c84848", "outfit": "cape", "outfit_color": "#f4f4fa", "outfit_color2": "#ffd23c", "acc": ["high_collar", "necklace"], "acc_color": "#ffd23c"},
		"weapon": {"kind": "spear", "color": "#ffd23c", "count": 3, "spin": 4.0},
		"actives": [
			{"name": "Lança de Shinsu Real", "type": "beam", "cd": 9.0, "power": 3.6, "fx": "beam_gold", "width": 48.0, "ticks": 5, "charge": 1.0, "shake": 6.0},
			{"name": "Chuva de Lanças Douradas", "type": "rain", "cd": 8.0, "power": 1.5, "count": 6, "fx": "holy_pillar", "radius": 55.0, "warn": 0.6},
			{"name": "Pressão do Governante", "type": "timestop", "cd": 16.0, "power": 0.0, "dur": 2.0, "fx": "time_stop"},
		]},
}

const CHAPTERS := [
	{"name": "Retorno dos Dez Mandamentos", "world": "Reino da Taverna Pecadora", "enemies": ["w4_demonio_cinzento", "w4_aprendiz_sagrado"], "boss": "w4_mandamento_misericordia", "guide": "sins_capitao_ira",
		"theme": {"floor": "#f4eee6", "floor2": "#e4d8c8", "accent": "#c84848", "line": "#d4c0a8"},
		"intro": ["O selo quebrou. O clã sombrio voltou ao reino.", "Dez comandantes, cada um com uma maldição diferente.", "Relaxa, a taverna abre de novo amanhã. Eu garanto."],
		"boss_line": "Por que você me olha com tanta raiva? Isso é ótimo.", "outro": "A cerveja está gelada. Os pecados venceram de novo."},
	{"name": "Batalha Final dos Três Deuses", "world": "Tóquio das Gangues do Tempo", "enemies": ["w4_delinquente_moto", "w4_membro_celestial"], "boss": "w4_rei_impulso_sombrio", "guide": "revengers_chorao_tempo",
		"theme": {"floor": "#f0eef2", "floor2": "#dcd8e4", "accent": "#d8a040", "line": "#c4bcd0"},
		"intro": ["Voltei no tempo mais uma vez. Doze anos atrás.", "O chefe que eu admirava está sendo engolido pela escuridão.", "Eu vou chorar, vou apanhar... mas não vou desistir!"],
		"boss_line": "Não tem mais ninguém pra me segurar.", "outro": "Desta vez, todo mundo voltou pra casa sorrindo."},
	{"name": "Arco da Alma de Prata Final", "world": "Edo dos Forasteiros do Céu", "enemies": ["w4_corvo_assassino", "w4_amanto_invasor"], "boss": "w4_mestre_imortal_vazio", "guide": "gintama_samurai_prata",
		"theme": {"floor": "#eef0f4", "floor2": "#d8dce6", "accent": "#8a9ab8", "line": "#b8c0d0"},
		"intro": ["As naves do céu cobriram Edo inteira.", "O antigo mestre voltou, mas não é mais quem eu conheci.", "Tá, tá, eu luto. Mas depois quero meu leite de morango."],
		"boss_line": "Eu não posso morrer. Essa é minha maldição.", "outro": "A Edo idiota de sempre. E eu continuo sem pagar o aluguel."},
	{"name": "Festival Culinário Sangrento", "world": "Era dos Gourmets", "enemies": ["w4_fera_gourmet", "w4_soldado_corporacao"], "boss": "w4_devorador_insaciavel", "guide": "toriko_cacador_garfo",
		"theme": {"floor": "#f6f0e2", "floor2": "#e8dcc0", "accent": "#e88a2a", "line": "#d8c4a0"},
		"intro": ["O maior festival de culinária do mundo foi atacado!", "Uma fome antiga e sem fundo está devorando tudo.", "Agradeço por todos os ingredientes deste mundo. Itadaki... vamos!"],
		"boss_line": "MAIS... MAIS... ME DÊ MAIS COMIDA!", "outro": "Hora do banquete! Hoje a conta é por minha conta."},
	{"name": "País dos Demônios Asura", "world": "Deserto da Estrela do Norte", "enemies": ["w4_guerreiro_asura", "w4_saqueador_pneu"], "boss": "w4_rei_demonio_asura", "guide": "hokuto_punho_estrela",
		"theme": {"floor": "#f4ece0", "floor2": "#e4d4bc", "accent": "#c84848", "line": "#d4bca0"},
		"intro": ["Atravessei o mar e cheguei à terra dos demônios.", "Lá governa o irmão mais velho do rei conquistador.", "Você ainda não percebeu... mas já está derrotado."],
		"boss_line": "O amor só traz dor. Eu enterrei o meu há muito tempo.", "outro": "O sol voltou a nascer sobre o deserto."},
	{"name": "Batalha do Palácio Celeste", "world": "Ilha dos Monstros e Heróis", "enemies": ["w4_esqueleto_demoniaco", "w4_dragao_menor"], "boss": "w4_sombra_rei_demonio", "guide": "dai_heroi_marca",
		"theme": {"floor": "#eef2f8", "floor2": "#d4e0f0", "accent": "#3c8ad8", "line": "#a8c4e0"},
		"intro": ["O palácio do rei demônio flutua sobre o mundo.", "Uma sombra encapuzada guarda o último portão.", "A marca do dragão está brilhando. Vamos, pessoal!"],
		"boss_line": "Quem olha nos meus olhos não volta a se mexer.", "outro": "A sombra se desfez. O céu da ilha está azul de novo."},
	{"name": "Guerra Contra a Seita do Verme", "world": "Arena dos Duelos Corporativos", "enemies": ["w4_lutador_contratado", "w4_seguranca_corporativo"], "boss": "w4_conector_verme", "guide": "kengan_ashura_niko",
		"theme": {"floor": "#f0f2f0", "floor2": "#d8e0dc", "accent": "#3cb4a0", "line": "#b4ccc4"},
		"intro": ["Uma seita secreta quer dominar os duelos das empresas.", "O líder deles copia qualquer estilo que vê uma vez.", "Contrato assinado. Agora é só luta. Sem desculpas."],
		"boss_line": "Seu estilo é bonito. Agora ele é meu.", "outro": "O contrato foi honrado. A empresa sobrevive mais um ano."},
	{"name": "Expresso do Inferno da Torre", "world": "Torre dos Regulares", "enemies": ["w4_regular_lanca", "w4_guarda_real"], "boss": "w4_rei_supremo_torre", "guide": "tog_irregular_noite",
		"theme": {"floor": "#f2f0e6", "floor2": "#e2dcc4", "accent": "#d8a020", "line": "#d0c49c"},
		"intro": ["O trem do inferno sobe andar por andar.", "No topo espera o rei que governa a torre inteira.", "Eu abri a porta sozinho. Agora vou até o fim."],
		"boss_line": "Irregulares não deveriam existir na minha torre.", "outro": "A porta do topo se abriu. As estrelas estão logo ali."},
]

## modo Chefes (quarta leva): desbloqueio por nivel da conta
const BOSS_RAID := [
	{"boss": "w4_mandamento_misericordia", "level": 155}, {"boss": "w4_rei_impulso_sombrio", "level": 160}, {"boss": "w4_mestre_imortal_vazio", "level": 165},
	{"boss": "w4_devorador_insaciavel", "level": 170}, {"boss": "w4_rei_demonio_asura", "level": 175}, {"boss": "w4_sombra_rei_demonio", "level": 180},
	{"boss": "w4_conector_verme", "level": 185}, {"boss": "w4_rei_supremo_torre", "level": 190},
]

const BANNERS := [
	{"id": "w4_pecados_gangues", "name": "Pecados, Gangues & Banquetes", "desc": "Taverna Pecadora, Gangues do Tempo, Edo dos Forasteiros e Era dos Gourmets.", "worlds": ["Reino da Taverna Pecadora", "Tóquio das Gangues do Tempo", "Edo dos Forasteiros do Céu", "Era dos Gourmets"], "chapter": 36, "color": "#c84848"},
	{"id": "w4_punhos_torres", "name": "Punhos, Heróis & Torres", "desc": "Estrela do Norte, Monstros e Heróis, Duelos Corporativos e Torre dos Regulares.", "worlds": ["Deserto da Estrela do Norte", "Ilha dos Monstros e Heróis", "Arena dos Duelos Corporativos", "Torre dos Regulares"], "chapter": 40, "color": "#ffd23c"},
]

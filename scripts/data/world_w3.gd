extends RefCounted
## Mundo leva 3: capitulos 25 a 32 (Tumba do Rei Esqueleto, Federação da Gosma, Brigada Especial das Chamas,
## Guerra do Cálice Sagrado, Era Feudal das Joias, Linhagem Bizarra, Cidade dos Ghouls, Academia da Verdadeira Cruz).

const ENEMIES := {
	"w3_esqueleto_guerreiro": {"name": "Esqueleto Guerreiro da Tumba", "look": {"skin": "#ece6d8", "hair": "#ece6d8", "hair_style": "none", "hat": "knight_helmet", "hat_color": "#5a5468", "hat_color2": "#8a4cf0", "outfit": "armor", "outfit_color": "#5a5468"}, "weapon": {"kind": "sword", "color": "#c8ccd4"}},
	"w3_cultista_morte": {"name": "Cultista da Seita da Morte", "look": {"skin": "#d8c8b0", "hair": "#2a2232", "hair_style": "short", "hat": "hood", "hat_color": "#2a1a3a", "hat_color2": "#8a4cf0", "outfit": "robe", "outfit_color": "#2a1a3a", "outfit_color2": "#8a4cf0", "acc": ["necklace"], "acc_color": "#ece6d8"}, "weapon": {"kind": "staff", "color": "#8a4cf0"}},
	"w3_orc_invasor": {"name": "Orc Invasor Faminto", "look": {"skin": "#7aa858", "hair": "#3a4a2a", "hair_style": "mohawk", "outfit": "armor", "outfit_color": "#6a5a3a", "acc": ["small_horns"], "acc_color": "#f0e8d0"}, "weapon": {"kind": "axe", "color": "#9aa6ba"}},
	"w3_homem_lagarto": {"name": "Homem-Lagarto do Pântano", "look": {"skin": "#5aa08a", "hair": "#2a5a4a", "hair_style": "none", "outfit": "vest", "outfit_color": "#8a6a3a", "acc": ["tail"], "acc_color": "#5aa08a"}, "weapon": {"kind": "spear", "color": "#c8d0dc"}},
	"w3_infernal": {"name": "Infernal em Combustão", "look": {"skin": "#2a1a1a", "hair": "#ff6a2a", "hair_style": "flame", "tips": "#ffd23c", "outfit": "none", "acc": ["flame_forehead", "horns"], "acc_color": "#ff8a2a"}, "weapon": {"kind": "claw", "color": "#ff8a2a"}},
	"w3_fanatico_branco": {"name": "Fanático de Manto Branco", "look": {"skin": "#f2d8c0", "hair": "#f4f4fa", "hair_style": "short", "hat": "hood", "hat_color": "#f4f4fa", "hat_color2": "#ffb020", "outfit": "robe", "outfit_color": "#f4f4fa", "outfit_color2": "#ffb020", "acc": ["cross"], "acc_color": "#ffb020"}, "weapon": {"kind": "dagger", "color": "#ffb020"}},
	"w3_soldado_dente": {"name": "Soldado de Dente de Dragão", "look": {"skin": "#e8e0cc", "hair": "#e8e0cc", "hair_style": "none", "outfit": "armor", "outfit_color": "#a89a80", "acc": ["small_horns"], "acc_color": "#e8e0cc"}, "weapon": {"kind": "sword", "color": "#e8e0cc"}},
	"w3_assassino_mascarado": {"name": "Assassino da Máscara de Caveira", "look": {"skin": "#3a3240", "hair": "#1a1a22", "hair_style": "none", "hat": "hood", "hat_color": "#1a1a22", "hat_color2": "#4a4a58", "outfit": "cape", "outfit_color": "#1a1a22", "outfit_color2": "#4a4a58", "acc": ["full_mask"], "acc_color": "#f0ece0"}, "weapon": {"kind": "dagger", "color": "#c8ccd4"}},
	"w3_youkai_faminto": {"name": "Youkai Faminto da Floresta", "look": {"skin": "#a87acc", "hair": "#4a2a5a", "hair_style": "wild_long", "outfit": "kimono", "outfit_color": "#5a3a3a", "acc": ["horns", "fox_ears"], "acc_color": "#4a2a5a"}, "weapon": {"kind": "claw", "color": "#f0e8d0"}},
	"w3_inseto_venenoso": {"name": "Inseto Venenoso do Miasma", "look": {"skin": "#5a6a3a", "hair": "#2a3a1a", "hair_style": "none", "acc": ["antennae", "wings"], "acc_color": "#9ac848"}, "weapon": {"kind": "needle", "color": "#9ac848"}},
	"w3_zumbi_vampiro": {"name": "Zumbi Vampírico", "look": {"skin": "#8a9a7a", "hair": "#3a3a2a", "hair_style": "messy", "outfit": "shirt_tie", "outfit_color": "#6a6a5a", "acc": ["bandage"], "acc_color": "#d42a30"}, "weapon": {"kind": "claw", "color": "#d42a30"}},
	"w3_valentao_espirito": {"name": "Valentão do Espírito Lutador", "look": {"skin": "#f2c79a", "hair": "#1d1a22", "hair_style": "pompadour", "outfit": "uniform", "outfit_color": "#2a2a48", "outfit_color2": "#ffd23c", "acc": ["chains"], "acc_color": "#ffd23c"}, "weapon": {"kind": "fist", "color": "#b05cf5"}},
	"w3_ghoul_mascarado": {"name": "Ghoul Mascarado da Árvore", "look": {"skin": "#e8d8c8", "hair": "#2a2a34", "hair_style": "messy", "hat": "hood", "hat_color": "#2a2a34", "hat_color2": "#d42a30", "outfit": "hoodie", "outfit_color": "#2a2a34", "acc": ["full_mask"], "acc_color": "#f0ece0"}, "weapon": {"kind": "claw", "color": "#d42a30"}},
	"w3_investigador_maleta": {"name": "Investigador da Maleta", "look": {"skin": "#f2d0b0", "hair": "#4a3a2a", "hair_style": "side_part", "outfit": "coat", "outfit_color": "#e8e0d0", "outfit_color2": "#2a2a34", "acc": ["glasses"]}, "weapon": {"kind": "spear", "color": "#9aa6ba"}},
	"w3_demonio_inferior": {"name": "Demônio Inferior de Gehena", "look": {"skin": "#4a6ab8", "hair": "#1a2a5a", "hair_style": "spiky", "outfit": "none", "acc": ["horns", "tail", "devil_wings"], "acc_color": "#1a2a5a"}, "weapon": {"kind": "claw", "color": "#5ab8ff"}},
	"w3_carnical_possuido": {"name": "Carniçal Possuído", "look": {"skin": "#8aa8a0", "hair": "#2a3a3a", "hair_style": "wild_long", "outfit": "robe", "outfit_color": "#3a4a4a", "acc": ["small_horns", "chains"], "acc_color": "#5ab8ff"}, "weapon": {"kind": "axe", "color": "#5ab8ff"}},
}

## chefes: aparecem no fim dos capitulos e no Modo Chefes
const BOSSES := {
	"w3_profeta_osseo": {"name": "Profeta da Seita do Dragão Ósseo", "rarity": 4, "hp_mult": 12.0, "atk_mult": 2.2, "color": "#8a4cf0",
		"look": {"skin": "#d8c8b0", "hair": "#d8c8b0", "hair_style": "bald", "outfit": "robe", "outfit_color": "#2a1a3a", "outfit_color2": "#8a4cf0", "acc": ["necklace", "chains"], "acc_color": "#ece6d8"},
		"weapon": {"kind": "staff", "color": "#ece6d8", "count": 1, "orbit": 1.5, "spin": 3.0, "power": 0.6},
		"actives": [
			{"name": "Dragão de Ossos Ancestral", "type": "summon", "cd": 14.0, "power": 0.45, "count": 1, "dur": 8.0, "fx": "summon_rise",
				"summon_look": {"skin": "#ece6d8", "hair": "#ece6d8", "hair_style": "none", "acc": ["horns", "wings"], "acc_color": "#ece6d8"}},
			{"name": "Pérola da Morte Negra", "type": "zone", "cd": 10.0, "power": 0.6, "fx": "shadow_flames", "radius": 110.0, "dur": 4.0, "pull": 80.0, "status": "weaken", "status_dur": 3.0, "status_chance": 0.8},
			{"name": "Toque Necrótico", "type": "drain", "cd": 7.0, "power": 2.4, "fx": "soul_drain", "fx_scale": 0.6, "heal_pct": 0.5},
		]},
	"w3_marionetista_mascaras": {"name": "Lorde Marionetista das Mil Máscaras", "rarity": 4, "hp_mult": 13.0, "atk_mult": 2.3, "color": "#c8a0ff",
		"look": {"skin": "#f0e4d8", "hair": "#5a3a8a", "hair_style": "slick", "outfit": "coat", "outfit_color": "#2a1a3a", "outfit_color2": "#ffd23c", "acc": ["half_mask", "earrings"], "acc_color": "#ffd23c"},
		"weapon": {"kind": "needle", "color": "#c8a0ff", "count": 3, "orbit": 1.4, "spin": 5.0, "power": 0.4},
		"actives": [
			{"name": "Fios da Marionete", "type": "stretch", "cd": 6.0, "power": 1.2, "count": 3, "range": 260.0, "hit_fx": "whip_crack", "hit_scale": 0.5, "arm": "#c8a0ff", "status": "slow", "status_dur": 2.5, "status_chance": 0.6},
			{"name": "Baile das Máscaras", "type": "debuff", "cd": 11.0, "power": 0.5, "status": "marked", "status_dur": 5.0, "radius": 0.0, "fx": "hex_sigil"},
			{"name": "Exército de Fantoches", "type": "summon", "cd": 15.0, "power": 0.35, "count": 2, "dur": 7.0, "fx": "spawn_portal"},
		]},
	"w3_evangelista_chama": {"name": "Evangelista da Chama Primordial", "rarity": 5, "hp_mult": 14.0, "atk_mult": 2.4, "color": "#ffb020",
		"look": {"skin": "#f4ece0", "hair": "#f4f4fa", "hair_style": "long", "hat": "hood", "hat_color": "#f4f4fa", "hat_color2": "#ffd23c", "outfit": "robe", "outfit_color": "#f4f4fa", "outfit_color2": "#ffd23c", "acc": ["halo", "cross"], "acc_color": "#ff8a2a"},
		"weapon": {"kind": "staff", "color": "#ffb020", "count": 2, "orbit": 1.55, "spin": -3.5, "power": 0.55},
		"actives": [
			{"name": "Coluna da Chama Original", "type": "aoe", "cd": 8.0, "power": 2.2, "fx": "flame_pillar", "fx_scale": 0.6, "radius": 80.0, "warn": 0.7, "status": "burn", "status_dur": 3.0, "status_chance": 0.8},
			{"name": "Círculo de Adolla", "type": "zone", "cd": 12.0, "power": 0.7, "fx": "fire_ring", "radius": 120.0, "dur": 4.0, "on_self": true, "status": "black_burn", "status_dur": 3.0, "status_chance": 0.5},
			{"name": "Passo da Fumaça Sagrada", "type": "teleport", "cd": 9.0, "power": 2.6, "fx": "slash_fire", "fx_scale": 0.6},
		]},
	"w3_padre_calice": {"name": "Padre Negro do Cálice Corrompido", "rarity": 5, "hp_mult": 15.0, "atk_mult": 2.5, "color": "#d42a30",
		"look": {"skin": "#e8c8a8", "hair": "#3a2a22", "hair_style": "short", "outfit": "robe", "outfit_color": "#1a1a22", "outfit_color2": "#d42a30", "acc": ["cross"], "acc_color": "#d8c8a0"},
		"weapon": {"kind": "dagger", "color": "#c8ccd4", "count": 3, "orbit": 1.45, "spin": 5.5, "power": 0.4},
		"actives": [
			{"name": "Chaves Negras", "type": "projectile", "cd": 5.0, "power": 1.2, "fx": "magic_missile", "fx_scale": 0.5, "count": 3, "arc": 0.5, "speed": 460.0, "rotate": true, "pierce": true},
			{"name": "Lama do Cálice Negro", "type": "zone", "cd": 11.0, "power": 0.7, "fx": "shadow_tendrils", "radius": 120.0, "dur": 5.0, "pull": 120.0, "status": "poison", "status_dur": 3.0, "status_chance": 0.7},
			{"name": "Punho do Oitavo Sacramento", "type": "knockback", "cd": 9.0, "power": 2.0, "radius": 140.0, "force": 700.0, "fx": "impact_frame", "fx_scale": 0.6},
		]},
	"w3_lider_bando_sete": {"name": "Líder do Bando dos Sete Mercenários", "rarity": 5, "hp_mult": 16.0, "atk_mult": 2.6, "color": "#5ab8ff",
		"look": {"skin": "#e8b888", "hair": "#1a1a22", "hair_style": "braid", "outfit": "armor", "outfit_color": "#3a3a48", "outfit_color2": "#c8a060", "acc": ["star_mark"], "acc_color": "#5a3aa8"},
		"weapon": {"kind": "greatsword", "color": "#c8ccd4", "count": 1, "orbit": 1.6, "spin": 3.0, "power": 0.9},
		"actives": [
			{"name": "Alabarda do Dragão Trovejante", "type": "strike", "cd": 12.0, "power": 6.0, "fx": "heavy_cleave", "fx_scale": 0.7, "flash": true, "shake": 6.0},
			{"name": "Relâmpago dos Fragmentos", "type": "chain", "cd": 7.0, "power": 1.5, "count": 5, "hit_fx": "lightning_strike", "hit_scale": 0.5, "status": "stun", "status_dur": 0.8, "status_chance": 0.3},
			{"name": "Fim do Contrato", "type": "execute", "cd": 10.0, "power": 2.0, "fx": "scythe_reap", "fx_scale": 0.6, "threshold": 0.3},
		]},
	"w3_supremo_pilar": {"name": "Supremo Homem do Pilar de Pedra", "rarity": 6, "hp_mult": 17.0, "atk_mult": 2.7, "color": "#ffd23c",
		"look": {"skin": "#e8c8a8", "hair": "#2a1a3a", "hair_style": "wild_long", "hat": "turban", "hat_color": "#e8e0cc", "hat_color2": "#ffd23c", "outfit": "cape", "outfit_color": "#e8e0cc", "outfit_color2": "#ffd23c", "acc": ["earrings", "necklace"], "acc_color": "#ffd23c"},
		"weapon": {"kind": "sword", "color": "#f4f4fa", "count": 2, "orbit": 1.4, "spin": 6.0, "power": 0.55},
		"actives": [
			{"name": "Lâminas Luminosas", "type": "multi", "cd": 5.0, "power": 0.9, "count": 6, "interval": 0.1, "spread": true, "fx": "slash_gold"},
			{"name": "Dança das Lâminas de Luz", "type": "orbit", "cd": 11.0, "power": 1.1, "count": 4, "dur": 5.0, "orbit_r": 90.0, "shape": "blade", "shape_color": "#f4f4fa"},
			{"name": "Absorção Celular", "type": "drain", "cd": 8.0, "power": 2.6, "fx": "life_steal", "fx_scale": 0.6, "heal_pct": 0.6},
		]},
	"w3_carrasco_alicate": {"name": "Carrasco do Alicate Treze", "rarity": 6, "hp_mult": 18.0, "atk_mult": 2.8, "color": "#d42a30",
		"look": {"skin": "#e8d0b8", "hair": "#e8e0d0", "hair_style": "buzz", "outfit": "tank", "outfit_color": "#f4f4fa", "acc": ["full_mask", "chains"], "acc_color": "#d42a30"},
		"weapon": {"kind": "claw", "color": "#d42a30", "count": 3, "orbit": 1.6, "spin": -4.5, "power": 0.5},
		"actives": [
			{"name": "Mil Menos Sete", "type": "debuff", "cd": 10.0, "power": 0.6, "status": "armor_break", "status_dur": 5.0, "radius": 150.0, "fx": "claw_red"},
			{"name": "Carapaça Escarlate", "type": "dash", "cd": 7.0, "power": 1.4, "count": 3, "hit_fx": "claw_red", "hit_scale": 0.5, "trail_fx": "slash_red", "status": "bleed", "status_dur": 3.0, "status_chance": 0.6},
			{"name": "Sessão de Tortura", "type": "execute", "cd": 11.0, "power": 2.2, "fx": "shatter_death", "fx_scale": 0.6, "threshold": 0.35},
		]},
	"w3_deus_chamas_azuis": {"name": "Deus Demônio das Chamas Azuis", "rarity": 7, "hp_mult": 20.0, "atk_mult": 3.0, "color": "#3c9cff",
		"look": {"skin": "#d8e0f0", "hair": "#2a3a8a", "hair_style": "flame", "tips": "#5ab8ff", "hat": "crown", "hat_color": "#1a1a3a", "hat_color2": "#3c9cff", "outfit": "cape", "outfit_color": "#1a1a3a", "outfit_color2": "#3c9cff", "acc": ["horns", "tail", "devil_wings"], "acc_color": "#3c9cff"},
		"weapon": {"kind": "orb", "color": "#3c9cff", "count": 3, "orbit": 1.5, "spin": 4.0, "power": 0.6},
		"actives": [
			{"name": "Noite Azul", "type": "zone", "cd": 12.0, "power": 0.9, "fx": "eclipse", "fx_scale": 0.6, "radius": 150.0, "dur": 5.0, "pull": 150.0, "status": "burn", "status_dur": 3.0, "status_chance": 0.7},
			{"name": "Inferno de Gehena", "type": "breath", "cd": 7.0, "power": 1.0, "fx": "flamethrower_blue", "range": 220.0, "angle": 0.9, "ticks": 5},
			{"name": "Possessão Demoníaca", "type": "teleport", "cd": 9.0, "power": 3.0, "fx": "big_explosion_blue", "fx_scale": 0.45, "shake": 6.0},
		]},
}

## capitulos 25 a 32 do Modo Historia. "guide" = bolinha que narra (id).
const CHAPTERS := [
	{"name": "Cemitério da Cidade-Fortaleza", "world": "Tumba do Rei Esqueleto", "enemies": ["w3_esqueleto_guerreiro", "w3_cultista_morte"], "boss": "w3_profeta_osseo", "guide": "overlord_rei_esqueleto",
		"theme": {"floor": "#eeeaf2", "floor2": "#dcd6e6", "accent": "#8a4cf0", "line": "#b8acd0"},
		"intro": ["Mortos-vivos estão saindo do cemitério da cidade.", "Uma seita quer criar um dragão feito só de ossos.", "Um aventureiro discreto resolve isso. Vamos."],
		"boss_line": "A morte é a única verdade. Ajoelhe-se diante dela!", "outro": "A seita caiu. Ninguém precisa saber quem eu sou de verdade."},
	{"name": "Floresta Grande dos Monstros", "world": "Federação da Gosma", "enemies": ["w3_orc_invasor", "w3_homem_lagarto"], "boss": "w3_marionetista_mascaras", "guide": "slime_lorde_gosma",
		"theme": {"floor": "#e8f4f0", "floor2": "#cfe8e4", "accent": "#4ac8e8", "line": "#a0d0d8"},
		"intro": ["Um exército de orcs famintos invadiu a floresta.", "Alguém de máscara está puxando os fios de tudo isso.", "Relaxa, eu como os problemas. Literalmente!"],
		"boss_line": "Vocês dançam tão bem nos meus fios...", "outro": "A federação está segura. Hora de construir mais casas!"},
	{"name": "Túneis Ardentes do Subsolo", "world": "Brigada Especial das Chamas", "enemies": ["w3_infernal", "w3_fanatico_branco"], "boss": "w3_evangelista_chama", "guide": "ff_pe_diabo",
		"theme": {"floor": "#f6ece2", "floor2": "#ecd8c4", "accent": "#ff6a2a", "line": "#e0b898"},
		"intro": ["Pessoas estão virando chamas vivas pela cidade.", "Fanáticos de branco servem a alguém nos túneis.", "Eu vou ser um herói! Pé no acelerador!"],
		"boss_line": "A chama primordial vai purificar este mundo.", "outro": "A brigada apagou o incêndio. Por hoje."},
	{"name": "Igreja da Colina Fria", "world": "Guerra do Cálice Sagrado", "enemies": ["w3_soldado_dente", "w3_assassino_mascarado"], "boss": "w3_padre_calice", "guide": "fate_rei_espada_invisivel",
		"theme": {"floor": "#eef0f6", "floor2": "#d8dcea", "accent": "#3c6ad8", "line": "#a8b4d8"},
		"intro": ["A guerra pelo cálice começou de novo.", "Um padre estranho observa tudo do alto da colina.", "Pela minha espada, este cálice não cairá em mãos erradas."],
		"boss_line": "Seu sofrimento é o mais belo dos sermões.", "outro": "O cálice foi destruído. Que nenhum desejo nasça dele."},
	{"name": "Monte Sagrado da Barreira", "world": "Era Feudal das Joias", "enemies": ["w3_youkai_faminto", "w3_inseto_venenoso"], "boss": "w3_lider_bando_sete", "guide": "inu_meio_youkai",
		"theme": {"floor": "#f2eee0", "floor2": "#e4dcc4", "accent": "#d84a3a", "line": "#d0bca0"},
		"intro": ["Os fragmentos da joia caíram nas mãos de mercenários.", "Sete guerreiros voltaram dos mortos para lutar.", "Hmph! Fica atrás de mim e não atrapalha!"],
		"boss_line": "Minha alabarda já cortou mil. Você é o próximo.", "outro": "Mais um fragmento recuperado. Falta pouco."},
	{"name": "Ruínas dos Homens do Pilar", "world": "Linhagem Bizarra", "enemies": ["w3_zumbi_vampiro", "w3_valentao_espirito"], "boss": "w3_supremo_pilar", "guide": "jojo_estrela",
		"theme": {"floor": "#f2ecf6", "floor2": "#e2d6ec", "accent": "#b05cf5", "line": "#c8b0e0"},
		"intro": ["Seres antigos despertaram de dentro das pedras.", "O mais forte deles quer ser perfeito sob o sol.", "Que saco... Mas eu não vou fugir."],
		"boss_line": "Eu sou o ápice de todas as criaturas!", "outro": "Ele foi parar no espaço. E parou de pensar."},
	{"name": "Galho da Árvore Azul", "world": "Cidade dos Ghouls", "enemies": ["w3_ghoul_mascarado", "w3_investigador_maleta"], "boss": "w3_carrasco_alicate", "guide": "ghoul_centopeia",
		"theme": {"floor": "#f0eeee", "floor2": "#e0dada", "accent": "#d42a30", "line": "#d0b8b8"},
		"intro": ["Uma organização de ghouls tomou um bairro inteiro.", "Seu carrasco coleciona dedos com um alicate.", "Quanto é mil menos sete? Eu não vou mais esquecer."],
		"boss_line": "Vamos brincar de contar até mil?", "outro": "O café está aberto de novo. Um café, por favor."},
	{"name": "Noite das Chamas Azuis", "world": "Academia da Verdadeira Cruz", "enemies": ["w3_demonio_inferior", "w3_carnical_possuido"], "boss": "w3_deus_chamas_azuis", "guide": "exo_chamas_azuis",
		"theme": {"floor": "#e8eef8", "floor2": "#ccdaf0", "accent": "#3c9cff", "line": "#a0bce0"},
		"intro": ["Os portões de Gehena se abriram sobre a academia.", "O pai de todos os demônios quer este mundo.", "Eu sou filho dele... e vou derrotá-lo como exorcista!"],
		"boss_line": "Volte para casa, meu filho. Queime comigo!", "outro": "As chamas azuis agora protegem em vez de destruir."},
]

## modo Chefes: desbloqueio por nivel da conta
const BOSS_RAID := [
	{"boss": "w3_profeta_osseo", "level": 110}, {"boss": "w3_marionetista_mascaras", "level": 115}, {"boss": "w3_evangelista_chama", "level": 120},
	{"boss": "w3_padre_calice", "level": 126}, {"boss": "w3_lider_bando_sete", "level": 132}, {"boss": "w3_supremo_pilar", "level": 138},
	{"boss": "w3_carrasco_alicate", "level": 144}, {"boss": "w3_deus_chamas_azuis", "level": 150},
]

## banners do gacha. "chapter": capitulo da historia que precisa estar concluido para liberar.
const BANNERS := [
	{"id": "w3_reinos_isekai", "name": "Reinos Além do Portal", "desc": "Tumba do Rei Esqueleto, Federação da Gosma, Brigada das Chamas e Cálice Sagrado.", "worlds": ["Tumba do Rei Esqueleto", "Federação da Gosma", "Brigada Especial das Chamas", "Guerra do Cálice Sagrado"], "chapter": 28, "color": "#8a4cf0"},
	{"id": "w3_linhagens_malditas", "name": "Linhagens Malditas", "desc": "Era Feudal das Joias, Linhagem Bizarra, Cidade dos Ghouls e Academia da Verdadeira Cruz.", "worlds": ["Era Feudal das Joias", "Linhagem Bizarra", "Cidade dos Ghouls", "Academia da Verdadeira Cruz"], "chapter": 32, "color": "#3c9cff"},
]

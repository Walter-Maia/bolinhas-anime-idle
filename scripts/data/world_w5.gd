extends RefCounted
## Mundo 5: inimigos, chefes, capitulos 41-48 do Modo Historia, modo Chefes e banners da quinta leva.

const ENEMIES := {
	"w5_lutador_regional": {"name": "Lutador da Eliminatória Regional", "look": {"skin": "#ecc8a4", "hair": "#2a2230", "hair_style": "buzz", "outfit": "tank", "outfit_color": "#f4f4fa", "outfit_color2": "#3a6ad8", "acc": ["headband"], "acc_color": "#3a6ad8"}, "weapon": {"kind": "fist", "color": "#e8c0a0"}},
	"w5_agente_profano": {"name": "Agente da Coroa Profana", "look": {"skin": "#e8d0bc", "hair": "#14101e", "hair_style": "slick", "outfit": "suit", "outfit_color": "#1a1a24", "outfit_color2": "#c84848", "acc": ["sunglasses"], "acc_color": "#14101e"}, "weapon": {"kind": "dagger", "color": "#c84848"}},
	"w5_goblin_andar": {"name": "Goblin do Andar Superior", "look": {"skin": "#7ab84a", "hair": "#3a4a2a", "hair_style": "none", "outfit": "none", "acc": ["elf_ears", "tail"], "acc_color": "#3a4a2a"}, "weapon": {"kind": "bat", "color": "#8a6a4a"}},
	"w5_aventureiro_rival": {"name": "Aventureiro da Família Rival", "look": {"skin": "#f0d0b0", "hair": "#8a5a2a", "hair_style": "messy", "outfit": "armor", "outfit_color": "#6a6a78", "outfit_color2": "#c8a040", "acc": ["scarf"], "acc_color": "#c84848"}, "weapon": {"kind": "spear", "color": "#a8aab4"}},
	"w5_soldado_monoolho": {"name": "Soldado do Robô de Um Olho", "look": {"skin": "#6a8a5a", "hair": "#3a4a3a", "hair_style": "none", "outfit": "armor", "outfit_color": "#5a7a4a", "outfit_color2": "#3a4a3a", "acc": ["visor", "shoulder_pads"], "acc_color": "#ff3a5a"}, "weapon": {"kind": "rifle", "color": "#4a5a4a"}},
	"w5_piloto_coordenado": {"name": "Piloto da Frota Coordenada", "look": {"skin": "#f0d8c0", "hair": "#c8a040", "hair_style": "side_part", "outfit": "uniform", "outfit_color": "#f4f4fa", "outfit_color2": "#3a6ad8", "acc": ["visor"], "acc_color": "#3a9cff"}, "weapon": {"kind": "gun", "color": "#8a94a8"}},
	"w5_monstro_mecanico": {"name": "Monstro Mecânico de Batalha", "look": {"skin": "#8a6a9a", "hair": "#3a2a4a", "hair_style": "none", "outfit": "armor", "outfit_color": "#5a3a6a", "acc": ["horns", "goggles"], "acc_color": "#ffd23c"}, "weapon": {"kind": "claw", "color": "#c8a0ff"}},
	"w5_soldado_mascara_ferro": {"name": "Soldado da Máscara de Ferro", "look": {"skin": "#c8ccd4", "hair": "#6a6a78", "hair_style": "none", "hat": "knight_helmet", "hat_color": "#4a4a58", "hat_color2": "#2a2a38", "outfit": "armor", "outfit_color": "#4a4a58", "acc": ["full_mask"], "acc_color": "#8a8a98"}, "weapon": {"kind": "axe", "color": "#8a8a98"}},
	"w5_pivo_rival": {"name": "Pivô Grandão do Time Rival", "look": {"skin": "#d8a878", "hair": "#1a1a22", "hair_style": "buzz", "outfit": "tank", "outfit_color": "#f4f4fa", "outfit_color2": "#c82a2a", "acc": ["armband"], "acc_color": "#c82a2a"}, "weapon": {"kind": "orb", "color": "#ff8a2a"}},
	"w5_zagueiro_brutal": {"name": "Zagueiro Brutal da Seleção Nórdica", "look": {"skin": "#f4dcc8", "hair": "#e8dca8", "hair_style": "short", "outfit": "shirt_tie", "outfit_color": "#ffd23c", "outfit_color2": "#3a6ad8", "acc": ["armband"], "acc_color": "#3a6ad8"}, "weapon": {"kind": "orb", "color": "#f4f4fa"}},
	"w5_goleiro_muralha": {"name": "Goleiro Muralha do Norte", "look": {"skin": "#ecd0b4", "hair": "#8a5a2a", "hair_style": "messy", "hat": "cap", "hat_color": "#2a2a38", "outfit": "jacket", "outfit_color": "#3a8a4a", "outfit_color2": "#14101e", "acc": ["bandage"], "acc_color": "#f4f4fa"}, "weapon": {"kind": "shield", "color": "#3a8a4a"}},
	"w5_chef_elite_central": {"name": "Chef da Elite Central", "look": {"skin": "#f0d8c4", "hair": "#2a2a38", "hair_style": "undercut", "hat": "chef", "hat_color": "#f4f4fa", "outfit": "coat", "outfit_color": "#14101e", "outfit_color2": "#c8a040", "acc": ["armband"], "acc_color": "#c8a040"}, "weapon": {"kind": "dagger", "color": "#d8dde8"}},
	"w5_jurado_severo": {"name": "Jurado Severo do Paladar", "look": {"skin": "#e8c8a8", "hair": "#a8a8b4", "hair_style": "slick", "outfit": "suit", "outfit_color": "#4a3a2a", "outfit_color2": "#c84848", "acc": ["glasses", "mustache"], "acc_color": "#4a4a58"}, "weapon": {"kind": "fan", "color": "#c84848"}},
	"w5_modificado_uniao": {"name": "Modificado da União Secreta", "look": {"skin": "#d8c8c0", "hair": "#4a4a58", "hair_style": "undercut", "outfit": "jacket", "outfit_color": "#2a2a38", "outfit_color2": "#c84848", "acc": ["cyber_lines"], "acc_color": "#ff3a3a"}, "weapon": {"kind": "claw", "color": "#c84848"}},
	"w5_nobre_corrompido": {"name": "Nobre Corrompido do Sangue", "look": {"skin": "#f4e8ec", "hair": "#e8dca8", "hair_style": "long", "outfit": "cape", "outfit_color": "#1a1222", "outfit_color2": "#a82a3a", "acc": ["earrings"], "acc_color": "#a82a3a"}, "weapon": {"kind": "whip", "color": "#a82a3a"}},
}

## chefes da quinta leva: aparecem no fim dos capitulos 41-48 e no Modo Chefes
const BOSSES := {
	"w5_conspirador_coroa": {"name": "Conspirador Imortal da Coroa Profana", "rarity": 5, "hp_mult": 14.0, "atk_mult": 2.4, "color": "#c84848",
		"look": {"skin": "#ecd8c4", "hair": "#14101e", "hair_style": "long_bangs", "outfit": "suit", "outfit_color": "#f4f4fa", "outfit_color2": "#c84848", "acc": ["high_collar", "earrings"], "acc_color": "#c84848"},
		"weapon": {"kind": "staff", "color": "#c84848", "count": 2, "spin": 4.5},
		"actives": [
			{"name": "Contrato do Poder Emprestado", "type": "debuff", "cd": 10.0, "power": 0.4, "status": "weaken", "status_dur": 5.0, "radius": 0.0, "fx": "hex_sigil"},
			{"name": "Golpe do Deus Falso", "type": "teleport", "cd": 7.0, "power": 2.4, "fx": "impact_frame", "fx_scale": 0.55, "shake": 5.0},
			{"name": "Chuva de Lanças Rubras", "type": "rain", "cd": 9.0, "power": 1.3, "count": 4, "fx": "laser_red", "radius": 50.0, "warn": 0.6},
		]},
	"w5_minotauro_negro": {"name": "Minotauro Negro do Duelo Eterno", "rarity": 5, "hp_mult": 15.0, "atk_mult": 2.5, "color": "#3a2a2a",
		"look": {"skin": "#3a2a2a", "hair": "#14101e", "hair_style": "wild_long", "outfit": "armor", "outfit_color": "#2a1a1a", "outfit_color2": "#c84848", "acc": ["horns", "scar_x", "tail"], "acc_color": "#e8e4dc"},
		"weapon": {"kind": "greatsword", "color": "#2a2230", "count": 2, "spin": 3.5, "power": 0.8},
		"actives": [
			{"name": "Investida do Touro Negro", "type": "dash", "cd": 7.0, "power": 2.2, "count": 2, "hit_fx": "heavy_cleave", "hit_scale": 0.6, "shake": 6.0},
			{"name": "Rugido da Masmorra", "type": "knockback", "cd": 10.0, "power": 1.8, "radius": 150.0, "force": 750.0, "fx": "quake", "fx_scale": 0.55, "status": "stun", "status_dur": 1.2, "status_chance": 1.0},
			{"name": "Corte do Rival Destinado", "type": "strike", "cd": 13.0, "power": 6.0, "fx": "slash_red", "fx_scale": 0.7, "flash": true},
		]},
	"w5_comandante_mascarado": {"name": "Comandante Mascarado do Fim da Humanidade", "rarity": 6, "hp_mult": 16.0, "atk_mult": 2.6, "color": "#f4f4fa",
		"look": {"skin": "#f4e4d4", "hair": "#e8dca8", "hair_style": "long", "outfit": "uniform", "outfit_color": "#f4f4fa", "outfit_color2": "#3a3a58", "acc": ["half_mask", "high_collar"], "acc_color": "#f4f4fa"},
		"weapon": {"kind": "rifle", "color": "#8a94a8", "count": 2, "spin": 3.0},
		"actives": [
			{"name": "Enxame de Drones Remotos", "type": "projectile", "cd": 6.0, "power": 1.0, "fx": "laser_blue", "fx_scale": 0.5, "count": 6, "arc": 1.4, "speed": 380.0, "homing": true, "rotate": true},
			{"name": "Canhão do Juízo Final", "type": "beam", "cd": 11.0, "power": 3.6, "fx": "beam_purple", "width": 48.0, "ticks": 5, "charge": 1.1, "shake": 6.0},
			{"name": "Profecia do Fim", "type": "debuff", "cd": 12.0, "power": 0.3, "status": "marked", "status_dur": 5.0, "radius": 0.0, "fx": "curse"},
		]},
	"w5_doutor_inferno": {"name": "Doutor Inferno da Ilha das Máscaras", "rarity": 6, "hp_mult": 17.0, "atk_mult": 2.7, "color": "#6a2ac0",
		"look": {"skin": "#e8d0c0", "hair": "#e8e4dc", "hair_style": "wild_long", "outfit": "cape", "outfit_color": "#3a8a4a", "outfit_color2": "#6a2ac0", "acc": ["beard", "fur_collar"], "acc_color": "#e8e4dc"},
		"weapon": {"kind": "wand", "color": "#6a2ac0", "count": 2},
		"actives": [
			{"name": "Exército de Monstros Mecânicos", "type": "summon", "cd": 14.0, "power": 0.35, "count": 2, "dur": 8.0, "fx": "spawn_portal",
				"summon_look": {"skin": "#8a6a9a", "hair": "#3a2a4a", "hair_style": "none", "outfit": "armor", "outfit_color": "#5a3a6a", "acc": ["horns", "goggles"], "acc_color": "#ffd23c"}},
			{"name": "Bombardeio dos Foguetes", "type": "rain", "cd": 8.0, "power": 1.4, "count": 5, "fx": "rocket", "radius": 55.0, "warn": 0.7},
			{"name": "Pulso Eletromagnético Maligno", "type": "nova", "cd": 10.0, "power": 2.2, "fx": "emp_blast", "fx_scale": 0.6, "radius": 140.0, "status": "silence", "status_dur": 2.5, "status_chance": 0.8},
		]},
	"w5_as_imbativel": {"name": "Ás Número Um do Colégio Imbatível", "rarity": 6, "hp_mult": 18.0, "atk_mult": 2.8, "color": "#c82a2a",
		"look": {"skin": "#e0b890", "hair": "#1a1a22", "hair_style": "buzz", "outfit": "tank", "outfit_color": "#f4f4fa", "outfit_color2": "#c82a2a", "acc": ["armband"], "acc_color": "#c82a2a"},
		"weapon": {"kind": "orb", "color": "#ff8a2a", "count": 1, "orbit": 1.5, "spin": 6.5, "power": 0.9},
		"actives": [
			{"name": "Infiltração Sem Defesa", "type": "dash", "cd": 6.0, "power": 1.8, "count": 3, "hit_fx": "hit_spark", "hit_scale": 0.55, "trail_fx": "haste"},
			{"name": "Pressão da Quadra Inteira", "type": "buff", "cd": 13.0, "dur": 6.0, "buffs": {"atk_pct": 0.4, "spd_pct": 0.3, "dodge": 0.15}, "fx": "aura_red"},
			{"name": "Enterrada do Campeão", "type": "aoe", "cd": 10.0, "power": 2.8, "fx": "ground_slam", "fx_scale": 0.6, "radius": 110.0, "warn": 0.8, "shake": 7.0},
		]},
	"w5_lobo_gelado": {"name": "Lobo Gelado do Chute Assassino", "rarity": 6, "hp_mult": 19.0, "atk_mult": 2.9, "color": "#8ad8ff",
		"look": {"skin": "#f4e4d8", "hair": "#f0e8b8", "hair_style": "long", "outfit": "shirt_tie", "outfit_color": "#ffd23c", "outfit_color2": "#2a5ab8", "acc": ["armband", "scarf"], "acc_color": "#2a5ab8"},
		"weapon": {"kind": "orb", "color": "#f4f4fa", "count": 2, "spin": -7.0, "power": 0.7},
		"actives": [
			{"name": "Chute Assassino do Norte", "type": "projectile", "cd": 6.0, "power": 3.2, "fx": "ice_lance", "fx_scale": 0.7, "speed": 560.0, "pierce": true, "rotate": true, "hit_fx": "ice_shatter", "hit_scale": 0.5, "status": "freeze", "status_dur": 1.2, "status_chance": 0.5},
			{"name": "Carrinho da Nevasca", "type": "breath", "cd": 9.0, "power": 1.0, "fx": "frost_breath", "range": 220.0, "angle": 0.9, "ticks": 4, "status": "slow", "status_dur": 3.0, "status_chance": 0.8},
			{"name": "Lesão Calculada", "type": "execute", "cd": 11.0, "power": 2.4, "fx": "crit_hit", "fx_scale": 0.6, "threshold": 0.3},
		]},
	"w5_diretor_central": {"name": "Diretor Central da Gastronomia Pura", "rarity": 6, "hp_mult": 20.0, "atk_mult": 3.0, "color": "#14101e",
		"look": {"skin": "#f0dcc8", "hair": "#14101e", "hair_style": "slick", "outfit": "suit", "outfit_color": "#f4f4fa", "outfit_color2": "#14101e", "acc": ["high_collar"], "acc_color": "#14101e"},
		"weapon": {"kind": "dagger", "color": "#d8dde8", "count": 3, "spin": 5.5},
		"actives": [
			{"name": "Decreto da Culinária Proibida", "type": "debuff", "cd": 10.0, "power": 0.4, "status": "silence", "status_dur": 3.0, "radius": 0.0, "fx": "rune_red"},
			{"name": "Faca do Paladar Absoluto", "type": "multi", "cd": 7.0, "power": 0.9, "count": 6, "interval": 0.1, "spread": true, "fx": "dagger_flurry", "fx_scale": 0.55},
			{"name": "Banquete da Elite", "type": "drain", "cd": 9.0, "power": 2.4, "fx": "soul_drain", "fx_scale": 0.6, "heal_pct": 0.45},
		]},
	"w5_herdeiro_traidor": {"name": "Herdeiro Traidor do Clã Sangrento", "rarity": 7, "hp_mult": 22.0, "atk_mult": 3.2, "color": "#a82a3a",
		"look": {"skin": "#f4e8ec", "hair": "#f0e0a8", "hair_style": "long", "outfit": "coat", "outfit_color": "#1a1222", "outfit_color2": "#a82a3a", "acc": ["high_collar", "earrings", "devil_wings"], "acc_color": "#a82a3a"},
		"weapon": {"kind": "sword", "color": "#a82a3a", "count": 2, "spin": 4.5, "power": 0.75},
		"actives": [
			{"name": "Campo de Sangue Nobre", "type": "zone", "cd": 11.0, "power": 0.9, "fx": "black_hole_red", "fx_scale": 0.6, "radius": 140.0, "dur": 5.0, "pull": 180.0, "status": "bleed", "status_dur": 3.0, "status_chance": 0.5},
			{"name": "Dominação Mental", "type": "debuff", "cd": 13.0, "power": 0.3, "status": "stun", "status_dur": 1.5, "radius": 170.0, "fx": "eclipse"},
			{"name": "Lâmina do Sangue Proibido", "type": "strike", "cd": 12.0, "power": 7.0, "fx": "slash_red", "fx_scale": 0.75, "flash": true, "force_crit": true, "shake": 8.0},
		]},
}

const CHAPTERS := [
	{"name": "Torneio da Coroa Profana", "world": "Torneio do Colegial Divino", "enemies": ["w5_lutador_regional", "w5_agente_profano"], "boss": "w5_conspirador_coroa", "guide": "gohs_macaco_bastao",
		"theme": {"floor": "#f6f0ea", "floor2": "#e8dcd2", "accent": "#c84848", "line": "#d8c0b4"},
		"intro": ["O torneio nacional promete realizar qualquer desejo do campeão.", "Mas tem gente comprando poder emprestado dos deuses.", "Sem regras, só porrada! Vem que eu tô animado!"],
		"boss_line": "Deuses, humanos... todos são peças do meu tabuleiro.", "outro": "A coroa caiu. O torneio continua limpo!"},
	{"name": "Duelo no Andar Nove", "world": "Cidade da Torre Labirinto", "enemies": ["w5_goblin_andar", "w5_aventureiro_rival"], "boss": "w5_minotauro_negro", "guide": "danmachi_coelho_branco",
		"theme": {"floor": "#f2f0ea", "floor2": "#e0dacc", "accent": "#d85a3a", "line": "#c8bca8"},
		"intro": ["A masmorra embaixo da torre está mais agitada hoje.", "Dizem que um touro negro espera por um rival há muito tempo.", "Eu quero alcançar quem eu admiro. Não vou fugir de novo!"],
		"boss_line": "MUUUUHH! Finalmente... o duelo que eu esperava!", "outro": "Subi de nível. Um passo mais perto dela."},
	{"name": "Batalha Final da Estrela Fria", "world": "Guerra do Século Espacial", "enemies": ["w5_soldado_monoolho", "w5_piloto_coordenado"], "boss": "w5_comandante_mascarado", "guide": "gundam_piloto_branco",
		"theme": {"floor": "#eef0f6", "floor2": "#d8dcea", "accent": "#3a6ad8", "line": "#b0b8d4"},
		"intro": ["A colônia espacial virou arma apontada para a Terra.", "Um comandante mascarado quer o fim da humanidade inteira.", "Esse robô branco... eu sei pilotar melhor do que ninguém!"],
		"boss_line": "A humanidade não merece o futuro. Eu sou a prova.", "outro": "As estrelas silenciaram. Ainda há um lugar para voltar."},
	{"name": "Ataque da Ilha das Máscaras", "world": "Liga dos Super Robôs", "enemies": ["w5_monstro_mecanico", "w5_soldado_mascara_ferro"], "boss": "w5_doutor_inferno", "guide": "superrobo_deus_demonio_z",
		"theme": {"floor": "#f2eef6", "floor2": "#e0d8ea", "accent": "#d84848", "line": "#c8bcd8"},
		"intro": ["Monstros mecânicos atacando o laboratório de novo!", "Um doutor maluco quer dominar o mundo com seu exército de ferro.", "Unir! Agora eu sou um deus ou um demônio!"],
		"boss_line": "Ha ha ha! O mundo inteiro será meu!", "outro": "A ilha afundou. O punho de ferro venceu!"},
	{"name": "Jogo Contra os Imbatíveis", "world": "Quadra da Enterrada Ruiva", "enemies": ["w5_pivo_rival"], "boss": "w5_as_imbativel", "guide": "slam_genio_ruivo",
		"theme": {"floor": "#f6efe4", "floor2": "#ead8c0", "accent": "#ff6a2a", "line": "#dcc0a0"},
		"intro": ["O time mais forte do país está do outro lado da quadra.", "O ás deles nunca perdeu um jogo no colegial.", "Eu sou um gênio! Rebote é comigo!"],
		"boss_line": "...Eu ainda não aprendi o que é perder.", "outro": "Toca aqui! Foi o melhor jogo das nossas vidas."},
	{"name": "Copa Mundial Juvenil", "world": "Campo dos Super Artilheiros", "enemies": ["w5_zagueiro_brutal", "w5_goleiro_muralha"], "boss": "w5_lobo_gelado", "guide": "tsubasa_capitao_asa",
		"theme": {"floor": "#eef6ec", "floor2": "#d4e8d0", "accent": "#3ab45a", "line": "#b0d0a8"},
		"intro": ["A copa do mundo juvenil começou e o campo parece infinito.", "Tem um atacante nórdico que machuca quem entra na frente.", "A bola é minha amiga! Vamos jogar com o coração!"],
		"boss_line": "Meu chute não perdoa. Saiam da frente ou quebrem.", "outro": "Gol! A bola rolou do jeito certo."},
	{"name": "Revolução da Mesa Central", "world": "Academia do Duelo Culinário", "enemies": ["w5_chef_elite_central", "w5_jurado_severo"], "boss": "w5_diretor_central", "guide": "soma_chef_ruivo",
		"theme": {"floor": "#f8f2e8", "floor2": "#ecdcc4", "accent": "#e8a040", "line": "#dcc8a8"},
		"intro": ["O novo diretor proibiu toda receita que não for da elite.", "Os clubes de culinária estão sendo fechados um por um.", "Quer apostar num duelo? Meu tempero de bairro não perde!"],
		"boss_line": "Gastronomia é para poucos. O resto é lixo.", "outro": "Valeu pela refeição! A cozinha é de todo mundo."},
	{"name": "Despertar do Sangue Antigo", "world": "Mansão do Nobre Adormecido", "enemies": ["w5_modificado_uniao", "w5_nobre_corrompido"], "boss": "w5_herdeiro_traidor", "guide": "noblesse_nobre_dorminhoco",
		"theme": {"floor": "#f4eef0", "floor2": "#e4d6dc", "accent": "#a82a3a", "line": "#d0b8c0"},
		"intro": ["Acordei de um sono de oitocentos anos. O mundo mudou.", "Um herdeiro traidor vendeu os segredos do clã à União.", "...Traga-me um chá. Depois eu resolvo isso."],
		"boss_line": "O líder dos nobres é um velho cansado. O trono é meu.", "outro": "Silêncio na mansão. O chá ainda está quente."},
]

## modo Chefes (quinta leva): desbloqueio por nivel da conta
const BOSS_RAID := [
	{"boss": "w5_conspirador_coroa", "level": 195}, {"boss": "w5_minotauro_negro", "level": 201}, {"boss": "w5_comandante_mascarado", "level": 207},
	{"boss": "w5_doutor_inferno", "level": 213}, {"boss": "w5_as_imbativel", "level": 219}, {"boss": "w5_lobo_gelado", "level": 226},
	{"boss": "w5_diretor_central", "level": 233}, {"boss": "w5_herdeiro_traidor", "level": 240},
]

const BANNERS := [
	{"id": "w5_torres_robos", "name": "Torres & Robôs Gigantes", "desc": "Colegial Divino, Torre Labirinto, Século Espacial e Super Robôs.", "worlds": ["Torneio do Colegial Divino", "Cidade da Torre Labirinto", "Guerra do Século Espacial", "Liga dos Super Robôs"], "chapter": 44, "color": "#3a6ad8"},
	{"id": "w5_quadras_banquetes", "name": "Quadras, Banquetes & Nobreza", "desc": "Enterrada Ruiva, Super Artilheiros, Duelo Culinário e Nobre Adormecido.", "worlds": ["Quadra da Enterrada Ruiva", "Campo dos Super Artilheiros", "Academia do Duelo Culinário", "Mansão do Nobre Adormecido"], "chapter": 48, "color": "#a82a3a"},
]

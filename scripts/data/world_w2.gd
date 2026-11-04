extends RefCounted
## Mundo 2: inimigos, chefes, capitulos 17-24 do Modo Historia, modo Chefes e banners da segunda leva.

const ENEMIES := {
	"w2_apostolo": {"name": "Apóstolo Faminto", "look": {"skin": "#b89a8a", "hair": "#2a1a1a", "hair_style": "wild_long", "outfit": "none", "acc": ["horns", "tail"], "acc_color": "#4a2a2a"}, "weapon": {"kind": "claw", "color": "#e8dcc8"}},
	"w2_mercenario": {"name": "Mercenário da Guerra dos Cem Anos", "look": {"skin": "#e8c0a0", "hair": "#5c3a1e", "hair_style": "messy", "hat": "knight_helmet", "hat_color": "#6a6a78", "hat_color2": "#8a2a2a", "outfit": "armor", "outfit_color": "#5a5a68"}, "weapon": {"kind": "axe", "color": "#a8aab4"}},
	"w2_piloto_imperial": {"name": "Piloto do Mecha Imperial", "look": {"skin": "#f0d0b0", "hair": "#c8a040", "hair_style": "slick", "outfit": "uniform", "outfit_color": "#e8e4f0", "outfit_color2": "#6a2ac0", "acc": ["visor"], "acc_color": "#b05cf5"}, "weapon": {"kind": "rifle", "color": "#6a7488"}},
	"w2_mago_espadas": {"name": "Mago do Reino das Espadas", "look": {"skin": "#e8d0c0", "hair": "#2a2a38", "hair_style": "undercut", "outfit": "cloak_clouds", "outfit_color": "#2a2a3a", "outfit_color2": "#9aa6ba", "acc": ["chains"], "acc_color": "#6a6a78"}, "weapon": {"kind": "book", "color": "#3a3a4a"}},
	"w2_demonio_inferior": {"name": "Demônio de Baixo Escalão", "look": {"skin": "#4a3a5a", "hair": "#1a1222", "hair_style": "spiky", "outfit": "none", "acc": ["horns", "devil_wings", "tail"], "acc_color": "#1a1222"}, "weapon": {"kind": "claw", "color": "#c8a0ff"}},
	"w2_xama_rival": {"name": "Xamã Rival do Torneio", "look": {"skin": "#e8c098", "hair": "#3a2a1a", "hair_style": "ponytail", "hat": "bandana_top", "hat_color": "#c84848", "outfit": "robe", "outfit_color": "#7a5a3a", "acc": ["necklace"], "acc_color": "#ffd23c"}, "weapon": {"kind": "staff", "color": "#8a5a2a"}},
	"w2_espirito_errante": {"name": "Espírito Errante", "look": {"skin": "#d8e8f4", "hair": "#a8c0e0", "hair_style": "long", "outfit": "kimono", "outfit_color": "#f4f4fa", "outfit_color2": "#a8c0e0", "acc": ["halo"], "acc_color": "#a8e0ff"}, "weapon": {"kind": "feather", "color": "#c8e0ff"}},
	"w2_digibicho_selvagem": {"name": "Digibicho Selvagem", "look": {"skin": "#6ab8e8", "hair": "#f4f4fa", "hair_style": "spiky", "outfit": "none", "acc": ["small_horns", "tail"], "acc_color": "#f4f4fa"}, "weapon": {"kind": "claw", "color": "#f4f4fa"}},
	"w2_digibicho_virus": {"name": "Digibicho Vírus", "look": {"skin": "#5a3a6a", "hair": "#1a1a2a", "hair_style": "mohawk", "outfit": "cyber", "outfit_color": "#1a1a2a", "outfit_color2": "#c84848", "acc": ["devil_wings", "cyber_lines"], "acc_color": "#c84848"}, "weapon": {"kind": "gear", "color": "#c84848"}},
	"w2_anjo_menor": {"name": "Anjo Invasor Menor", "look": {"skin": "#3a3a48", "hair": "#14101e", "hair_style": "none", "outfit": "none", "acc": ["full_mask", "halo"], "acc_color": "#ff6a2a"}, "weapon": {"kind": "spear", "color": "#ff6a2a"}},
	"w2_mecha_produzido": {"name": "Gigante Produzido em Série", "look": {"skin": "#f4f4fa", "hair": "#d8d0e8", "hair_style": "none", "outfit": "armor", "outfit_color": "#e8e4f0", "acc": ["visor", "wings"], "acc_color": "#d8d0e8"}, "weapon": {"kind": "greatsword", "color": "#c8ccd4"}},
	"w2_mecha_bestial": {"name": "Mecha Bestial do Rei", "look": {"skin": "#7a6a5a", "hair": "#3a2a1a", "hair_style": "big_spiky", "outfit": "armor", "outfit_color": "#5a4a3a", "acc": ["horns", "goggles"], "acc_color": "#c8a040"}, "weapon": {"kind": "fist", "color": "#8a7a6a"}},
	"w2_esqueleto_andar": {"name": "Esqueleto do Andar Perdido", "look": {"skin": "#e8e4dc", "hair": "#e8e4dc", "hair_style": "none", "outfit": "armor", "outfit_color": "#6a5a4a", "acc": ["half_mask"], "acc_color": "#e8e4dc"}, "weapon": {"kind": "sword", "color": "#a8aab4"}},
	"w2_jogador_vermelho": {"name": "Jogador Cursor Vermelho", "look": {"skin": "#e8c8a8", "hair": "#1d1a22", "hair_style": "cover_eye", "hat": "hood", "hat_color": "#2a1a1a", "outfit": "cloak_clouds", "outfit_color": "#2a1a1a", "outfit_color2": "#d42a30", "acc": ["mouth_mask"], "acc_color": "#d42a30"}, "weapon": {"kind": "dagger", "color": "#d42a30"}},
}

## chefes da segunda leva: aparecem no fim dos capitulos 17-24 e no Modo Chefes
const BOSSES := {
	"w2_falcao_noite": {"name": "Falcão da Noite Eterna", "rarity": 4, "hp_mult": 12.0, "atk_mult": 2.2, "color": "#3a2a5a",
		"look": {"skin": "#f0e8ec", "hair": "#14101e", "hair_style": "wild_long", "hat": "knight_helmet", "hat_color": "#1a1222", "hat_color2": "#6b2cc0", "outfit": "armor", "outfit_color": "#1a1222", "outfit_color2": "#6b2cc0", "acc": ["devil_wings"], "acc_color": "#1a1222"},
		"weapon": {"kind": "sword", "color": "#c8d0dc", "count": 1},
		"actives": [
			{"name": "Eclipse do Sacrifício", "type": "zone", "cd": 10.0, "power": 0.7, "fx": "eclipse", "fx_scale": 0.6, "radius": 130.0, "dur": 4.5, "pull": 120.0},
			{"name": "Marca do Sacrifício", "type": "debuff", "cd": 9.0, "power": 0.4, "status": "marked", "status_dur": 5.0, "radius": 0.0, "fx": "curse"},
			{"name": "Ruptura do Espaço", "type": "teleport", "cd": 7.0, "power": 2.4, "fx": "dark_explosion", "fx_scale": 0.45},
		]},
	"w2_principe_fortaleza": {"name": "Príncipe Frio da Fortaleza Celeste", "rarity": 4, "hp_mult": 13.0, "atk_mult": 2.3, "color": "#b05cf5",
		"look": {"skin": "#f6e0d0", "hair": "#e8dca8", "hair_style": "side_part", "outfit": "cape", "outfit_color": "#f4f4fa", "outfit_color2": "#6a2ac0", "acc": ["necklace"], "acc_color": "#ffd23c"},
		"weapon": {"kind": "flag", "color": "#6a2ac0", "count": 2},
		"actives": [
			{"name": "Bomba Esférica de Luz", "type": "aoe", "cd": 12.0, "power": 2.6, "fx": "implosion", "fx_scale": 0.55, "radius": 120.0, "warn": 0.9, "shake": 6.0},
			{"name": "Ordem Irrecusável", "type": "debuff", "cd": 11.0, "power": 0.3, "status": "silence", "status_dur": 3.0, "radius": 0.0, "fx": "hex_sigil"},
			{"name": "Bombardeio Orbital", "type": "rain", "cd": 8.0, "power": 1.3, "count": 4, "fx": "laser_pink", "radius": 50.0},
		]},
	"w2_rei_demonio_espadas": {"name": "Rei Demônio da Gravidade Sombria", "rarity": 5, "hp_mult": 14.0, "atk_mult": 2.4, "color": "#4a3a8a",
		"look": {"skin": "#d8d0e8", "hair": "#14101e", "hair_style": "spiky_long", "outfit": "coat", "outfit_color": "#14101e", "outfit_color2": "#c8a0ff", "acc": ["horns", "devil_wings"], "acc_color": "#14101e"},
		"weapon": {"kind": "greatsword", "color": "#2a2234", "count": 2},
		"actives": [
			{"name": "Abismo Gravitacional", "type": "zone", "cd": 10.0, "power": 0.8, "fx": "black_hole", "fx_scale": 0.55, "radius": 120.0, "dur": 4.0, "pull": 220.0},
			{"name": "Pressão do Rei Demônio", "type": "knockback", "cd": 8.0, "power": 1.8, "radius": 150.0, "force": 700.0, "fx": "purple_explosion", "fx_scale": 0.5, "status": "slow", "status_dur": 2.5, "status_chance": 1.0},
			{"name": "Sentença das Trevas", "type": "execute", "cd": 9.0, "power": 2.2, "fx": "scythe_purple", "fx_scale": 0.6, "threshold": 0.3},
		]},
	"w2_senhor_espirito_fogo": {"name": "Senhor do Espírito Flamejante", "rarity": 5, "hp_mult": 15.0, "atk_mult": 2.5, "color": "#ff6a2a",
		"look": {"skin": "#f2d0b0", "hair": "#3a2a2a", "hair_style": "long", "outfit": "cape", "outfit_color": "#f4f4fa", "outfit_color2": "#ff6a2a", "acc": ["earrings", "star_mark"], "acc_color": "#ffd23c"},
		"weapon": {"kind": "orb", "color": "#ff6a2a", "count": 3},
		"actives": [
			{"name": "Mão do Espírito de Fogo", "type": "breath", "cd": 7.0, "power": 1.0, "fx": "fire_breath", "range": 220.0, "angle": 0.9, "ticks": 4, "status": "burn", "status_dur": 3.0, "status_chance": 0.8},
			{"name": "Gigante de Chamas", "type": "summon", "cd": 14.0, "power": 0.35, "count": 1, "dur": 8.0, "fx": "flame_pillar",
				"summon_look": {"skin": "#ff8a2a", "hair": "#ffd23c", "hair_style": "flame", "outfit": "none", "acc": ["horns"], "acc_color": "#ffd23c"}},
			{"name": "Coroa de Mil Anos", "type": "orbit", "cd": 11.0, "power": 1.1, "count": 5, "dur": 5.0, "orbit_r": 90.0, "fx": "spirit_flame"},
		]},
	"w2_conde_vampiro_digital": {"name": "Conde Vampiro da Névoa Digital", "rarity": 5, "hp_mult": 16.0, "atk_mult": 2.5, "color": "#c84848",
		"look": {"skin": "#e8e0ec", "hair": "#e8dca8", "hair_style": "slick", "outfit": "cape", "outfit_color": "#1a1a2a", "outfit_color2": "#c84848", "acc": ["half_mask", "devil_wings"], "acc_color": "#2a1a2a"},
		"weapon": {"kind": "whip", "color": "#c84848", "count": 2},
		"actives": [
			{"name": "Revoada Noturna", "type": "projectile", "cd": 5.0, "power": 1.0, "fx": "bat", "fx_scale": 0.5, "count": 5, "arc": 1.0, "speed": 340.0, "homing": true},
			{"name": "Beijo da Névoa", "type": "drain", "cd": 8.0, "power": 2.2, "fx": "life_steal", "fx_scale": 0.6, "heal_pct": 0.5},
			{"name": "Canção de Ninar Sombria", "type": "debuff", "cd": 13.0, "power": 0.3, "status": "sleep", "status_dur": 3.0, "radius": 160.0, "fx": "shadow_tendrils"},
		]},
	"w2_anjo_octaedro": {"name": "Anjo Octaedro de Cristal Azul", "rarity": 6, "hp_mult": 17.0, "atk_mult": 2.6, "color": "#3c9cff",
		"look": {"skin": "#5ab8f0", "hair": "#3c9cff", "hair_style": "none", "outfit": "none", "acc": ["halo", "soul_gem"], "acc_color": "#ff3a3a"},
		"weapon": {"kind": "shield", "color": "#ff8a2a", "count": 2},
		"actives": [
			{"name": "Canhão de Partículas", "type": "beam", "cd": 9.0, "power": 3.2, "fx": "beam_gold", "width": 46.0, "ticks": 5, "charge": 1.0, "shake": 5.0},
			{"name": "Barreira do Coração Absoluto", "type": "shield", "cd": 15.0, "power": 0.25, "dur": 5.0, "invuln": 1.0, "fx": "force_field"},
			{"name": "Broca de Cristal", "type": "aoe", "cd": 11.0, "power": 2.0, "fx": "ice_spikes", "fx_scale": 0.6, "radius": 100.0, "warn": 0.8},
		]},
	"w2_rei_antiespiral": {"name": "Rei Anti-Espiral do Vazio", "rarity": 7, "hp_mult": 19.0, "atk_mult": 2.8, "color": "#2ff0ff",
		"look": {"skin": "#1a1a2a", "hair": "#14101e", "hair_style": "none", "outfit": "cyber", "outfit_color": "#14101e", "outfit_color2": "#2ff0ff", "acc": ["cyber_lines", "visor"], "acc_color": "#2ff0ff"},
		"weapon": {"kind": "gear", "color": "#2ff0ff", "count": 3},
		"actives": [
			{"name": "Labirinto do Espaço Infinito", "type": "zone", "cd": 11.0, "power": 0.9, "fx": "void_orb", "fx_scale": 0.7, "radius": 140.0, "dur": 5.0, "pull": 160.0},
			{"name": "Estrelas Arremessadas", "type": "rain", "cd": 8.0, "power": 1.5, "count": 5, "fx": "star_fall", "radius": 55.0, "warn": 0.6},
			{"name": "Desespero Absoluto", "type": "debuff", "cd": 12.0, "power": 0.3, "status": "weaken", "status_dur": 5.0, "radius": 0.0, "fx": "glitch"},
		]},
	"w2_ceifador_esqueleto": {"name": "Ceifador Esqueleto do Andar Setenta e Cinco", "rarity": 7, "hp_mult": 20.0, "atk_mult": 3.0, "color": "#e8e4dc",
		"look": {"skin": "#e8e4dc", "hair": "#e8e4dc", "hair_style": "none", "outfit": "armor", "outfit_color": "#4a3a3a", "acc": ["half_mask", "horns", "tail"], "acc_color": "#e8e4dc"},
		"weapon": {"kind": "scythe", "color": "#e8e4dc", "count": 2, "spin": 5.0},
		"actives": [
			{"name": "Foice Dupla Ceifadora", "type": "multi", "cd": 6.0, "power": 1.0, "count": 6, "interval": 0.1, "spread": true, "fx": "scythe_reap", "fx_scale": 0.6},
			{"name": "Golpe Final do Chefe de Andar", "type": "execute", "cd": 10.0, "power": 2.6, "fx": "shatter_death", "fx_scale": 0.6, "threshold": 0.35},
			{"name": "Pisão da Centopeia de Ossos", "type": "knockback", "cd": 9.0, "power": 2.0, "radius": 160.0, "force": 850.0, "fx": "ground_slam", "fx_scale": 0.6, "shake": 6.0},
		]},
}

const CHAPTERS := [
	{"name": "Fortaleza do Eclipse", "world": "Era do Eclipse", "enemies": ["w2_apostolo", "w2_mercenario"], "boss": "w2_falcao_noite", "guide": "berserk_espadachim_negro",
		"theme": {"floor": "#f0ece6", "floor2": "#ddd4cc", "accent": "#a84848", "line": "#c8b4a8"},
		"intro": ["A marca na minha nuca está sangrando de novo.", "Os apóstolos vêm atrás de quem carrega o sacrifício.", "Eu não paro de lutar. Nunca."],
		"boss_line": "Tudo foi para realizar meu sonho. Até você.", "outro": "O eclipse passou... mas a jornada continua."},
	{"name": "Rebelião da Ordem Negra", "world": "Império dos Reis Sagrados", "enemies": ["w2_piloto_imperial"], "boss": "w2_principe_fortaleza", "guide": "geass_principe_exilado",
		"theme": {"floor": "#f2eef6", "floor2": "#ddd4ea", "accent": "#9a4ad8", "line": "#c0b0d8"},
		"intro": ["O império quer pintar o mundo inteiro de uma cor só.", "Meu irmão comanda uma fortaleza que flutua no céu.", "Só quem está disposto a ser atingido pode atirar. Xeque."],
		"boss_line": "Eu não desejo nada. Por isso nunca perco.", "outro": "O tabuleiro virou. A rebelião venceu."},
	{"name": "Invasão do Reino das Espadas", "world": "Reino dos Trevos", "enemies": ["w2_mago_espadas", "w2_demonio_inferior"], "boss": "w2_rei_demonio_espadas", "guide": "bc_antimagia",
		"theme": {"floor": "#eef2e6", "floor2": "#d8e2cc", "accent": "#3cb46a", "line": "#b0c8a0"},
		"intro": ["O reino vizinho fez pacto com demônios!", "Sem magia nenhuma, eu ainda tenho minha espada.", "Meu negócio é não desistir! Bora!"],
		"boss_line": "Ajoelhem. A gravidade obedece só a mim.", "outro": "Mais um passo rumo ao título de Rei Mago!"},
	{"name": "Aldeia dos Patchs", "world": "Torneio dos Xamãs", "enemies": ["w2_xama_rival", "w2_espirito_errante"], "boss": "w2_senhor_espirito_fogo", "guide": "shaman_fones_laranja",
		"theme": {"floor": "#f6efe2", "floor2": "#e8dcc4", "accent": "#ff8a2a", "line": "#d8c0a0"},
		"intro": ["O torneio que escolhe o Rei dos Xamãs chegou à aldeia.", "Meu irmão de mil anos quer o trono para apagar os humanos.", "Relaxa, no fim tudo dá certo."],
		"boss_line": "Humanos são uma praga. Eu vou purificar este mundo.", "outro": "Uma noite tranquila sob as estrelas. Que bom."},
	{"name": "Ilha dos Arquivos", "world": "Mundo dos Digibichos", "enemies": ["w2_digibicho_selvagem", "w2_digibicho_virus"], "boss": "w2_conde_vampiro_digital", "guide": "digi_oculos_coragem",
		"theme": {"floor": "#eaf4f8", "floor2": "#cfe6f0", "accent": "#ff8a2a", "line": "#a8d0e0"},
		"intro": ["Fomos sugados para dentro do mundo digital!", "Um conde vampiro espalhou névoa por toda a ilha.", "Coragem, pessoal! Hora de digievoluir!"],
		"boss_line": "Crianças escolhidas... que sangue delicioso.", "outro": "A névoa sumiu. O sol digital voltou a brilhar!"},
	{"name": "Fortaleza da Cidade Subterrânea", "world": "Geo-Cidade Três", "enemies": ["w2_anjo_menor", "w2_mecha_produzido"], "boss": "w2_anjo_octaedro", "guide": "eva_piloto_relutante",
		"theme": {"floor": "#eef0f4", "floor2": "#d8dce8", "accent": "#7a4ad8", "line": "#b4b8d0"},
		"intro": ["Alerta de anjo! Todos para os abrigos!", "Um cristal azul gigante está perfurando até a base.", "Eu não posso fugir. Eu não posso fugir. Eu não posso fugir."],
		"boss_line": "...", "outro": "Você não precisa sorrir sozinho. Estamos aqui."},
	{"name": "Batalha Além das Galáxias", "world": "Galáxia da Broca Espiral", "enemies": ["w2_mecha_bestial"], "boss": "w2_rei_antiespiral", "guide": "ttgl_cavador",
		"theme": {"floor": "#f4eee6", "floor2": "#e4d8c8", "accent": "#ff5a3a", "line": "#d8b8a0"},
		"intro": ["Saímos do subterrâneo e agora vamos até as estrelas!", "Um rei do vazio quer apagar toda evolução espiral.", "Quem você pensa que eu sou?! Minha broca vai furar o céu!"],
		"boss_line": "A evolução sem limite destrói o universo. Desistam.", "outro": "A broca furou o céu. O futuro é nosso!"},
	{"name": "Andar Setenta e Cinco", "world": "Castelo Flutuante Virtual", "enemies": ["w2_esqueleto_andar", "w2_jogador_vermelho"], "boss": "w2_ceifador_esqueleto", "guide": "sao_espadachim_negro",
		"theme": {"floor": "#eef2f6", "floor2": "#d6e0ea", "accent": "#4a8ad8", "line": "#a8c0d8"},
		"intro": ["Se a vida zerar aqui, zera lá fora também.", "O chefe do andar setenta e cinco já derrubou muita gente.", "Troca comigo! Duas lâminas, sem hesitar."],
		"boss_line": "CRRRK... CRRRK... (ossos rangendo)", "outro": "Andar liberado! Faltam só vinte e cinco."},
]

## modo Chefes (segunda leva): desbloqueio por nivel da conta
const BOSS_RAID := [
	{"boss": "w2_falcao_noite", "level": 70}, {"boss": "w2_principe_fortaleza", "level": 74}, {"boss": "w2_rei_demonio_espadas", "level": 78},
	{"boss": "w2_senhor_espirito_fogo", "level": 82}, {"boss": "w2_conde_vampiro_digital", "level": 87}, {"boss": "w2_anjo_octaedro", "level": 92},
	{"boss": "w2_rei_antiespiral", "level": 98}, {"boss": "w2_ceifador_esqueleto", "level": 105},
]

const BANNERS := [
	{"id": "w2_eclipse_coroas", "name": "Eclipses & Coroas", "desc": "Era do Eclipse, Império, Reino dos Trevos e Xamãs.", "worlds": ["Era do Eclipse", "Império dos Reis Sagrados", "Reino dos Trevos", "Torneio dos Xamãs"], "chapter": 20, "color": "#a84848"},
	{"id": "w2_espirais_virtuais", "name": "Espirais & Mundos Virtuais", "desc": "Digibichos, Geo-Cidade, Broca Espiral e Castelo Virtual.", "worlds": ["Mundo dos Digibichos", "Geo-Cidade Três", "Galáxia da Broca Espiral", "Castelo Flutuante Virtual"], "chapter": 24, "color": "#2ff0ff"},
]

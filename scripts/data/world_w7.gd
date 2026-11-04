extends RefCounted
## Mundo 7: inimigos, chefes, capitulos 57-64 do Modo Historia, modo Chefes e banners da setima leva.

const ENEMIES := {
	"w7_slime_ensopado": {"name": "Gosma Gelatinosa Boa de Ensopado", "look": {"skin": "#8ad8c8", "hair": "#6ab8a8", "hair_style": "dome", "outfit": "none", "acc": ["antennae"], "acc_color": "#4a9a8a"}, "weapon": {"kind": "orb", "color": "#8ad8c8"}},
	"w7_armadura_viva": {"name": "Armadura Viva do Corredor Escuro", "look": {"skin": "#5a5a68", "hair": "#2a2a32", "hair_style": "none", "hat": "knight_helmet", "hat_color": "#6a6a78", "hat_color2": "#2a2a32", "outfit": "armor", "outfit_color": "#6a6a78", "outfit_color2": "#3a3a48", "acc": ["shoulder_pads"], "acc_color": "#4a4a58"}, "weapon": {"kind": "sword", "color": "#a8aab4", "count": 2}},
	"w7_vampiro_rosa_cruz": {"name": "Vampiro Soldado da Ordem Rosa", "look": {"skin": "#f0e4e8", "hair": "#2a1a22", "hair_style": "slick", "outfit": "coat", "outfit_color": "#2a1a22", "outfit_color2": "#c83a5a", "acc": ["high_collar", "cross"], "acc_color": "#c83a5a"}, "weapon": {"kind": "claw", "color": "#c83a5a"}},
	"w7_inquisidor_ferro": {"name": "Inquisidor de Ferro do Vaticano", "look": {"skin": "#f0d8c0", "hair": "#3a3a48", "hair_style": "buzz", "outfit": "robe", "outfit_color": "#f4f4fa", "outfit_color2": "#c8a040", "acc": ["cross", "visor"], "acc_colors": {"cross": "#c8a040", "visor": "#3a8ad8"}}, "weapon": {"kind": "gun", "color": "#4a4a58"}},
	"w7_cavaleiro_apocalipse": {"name": "Cavaleiro do Apocalipse Alado", "look": {"skin": "#e8e4f0", "hair": "#f4f4fa", "hair_style": "none", "outfit": "armor", "outfit_color": "#e8e4f0", "outfit_color2": "#c83a3a", "acc": ["wings", "halo", "full_mask"], "acc_colors": {"wings": "#f4f4fa", "halo": "#ffd23c", "full_mask": "#c8ccd4"}}, "weapon": {"kind": "spear", "color": "#f4f4fa"}},
	"w7_nobre_sanguessuga": {"name": "Nobre Sanguessuga de Capa Branca", "look": {"skin": "#f6ecf0", "hair": "#d8d8e8", "hair_style": "long", "outfit": "uniform", "outfit_color": "#f4f4fa", "outfit_color2": "#c83a5a", "acc": ["high_collar", "earrings"], "acc_colors": {"high_collar": "#f4f4fa", "earrings": "#c83a5a"}}, "weapon": {"kind": "sword", "color": "#c83a5a"}},
	"w7_capanga_terno": {"name": "Capanga Engravatado do Chefão", "look": {"skin": "#e8c8a8", "hair": "#1a1a22", "hair_style": "slick", "hat": "fedora", "hat_color": "#2a2a32", "hat_color2": "#c84848", "outfit": "suit", "outfit_color": "#2a2a32", "outfit_color2": "#f4f4fa", "acc": ["sunglasses"], "acc_color": "#14101e"}, "weapon": {"kind": "gun", "color": "#3a3a48", "count": 2}},
	"w7_clone_falho": {"name": "Clone Falho do Laboratório Secreto", "look": {"skin": "#d8e8c8", "hair": "#c8d8a8", "hair_style": "bob", "outfit": "lab_coat", "outfit_color": "#f4f4fa", "outfit_color2": "#8ab86a", "acc": ["bandage"], "acc_color": "#f4f4fa"}, "weapon": {"kind": "bottle", "color": "#8ab86a"}},
	"w7_martelo_carne": {"name": "Pássaro Martelo-de-Carne do Abismo", "look": {"skin": "#c86a5a", "hair": "#6a2a2a", "hair_style": "spiky_back", "outfit": "none", "acc": ["wings", "tail"], "acc_colors": {"wings": "#8a3a3a", "tail": "#6a2a2a"}}, "weapon": {"kind": "claw", "color": "#f4e8c8"}},
	"w7_hollow_vila": {"name": "Morador Oco da Vila dos Desejos", "look": {"skin": "#d8c098", "hair": "#8a6a4a", "hair_style": "curly", "outfit": "robe", "outfit_color": "#a88a5a", "outfit_color2": "#6a4a2a", "acc": ["fox_ears", "tail", "necklace"], "acc_colors": {"fox_ears": "#c89a6a", "tail": "#c89a6a", "necklace": "#e8c040"}}, "weapon": {"kind": "staff", "color": "#c8a060"}},
	"w7_ciborgue_refugiado": {"name": "Ciborgue Refugiado Rebelde", "look": {"skin": "#d8b898", "hair": "#2a2a32", "hair_style": "buzz", "outfit": "cyber", "outfit_color": "#3a4a5a", "outfit_color2": "#4ad8c8", "acc": ["cyber_lines", "goggles"], "acc_colors": {"cyber_lines": "#4ad8c8", "goggles": "#ffb43c"}}, "weapon": {"kind": "rifle", "color": "#5a6a7a"}},
	"w7_tanque_pensante": {"name": "Tanque Pensante Desertor", "look": {"skin": "#6a8ad8", "hair": "#3a5aa8", "hair_style": "none", "outfit": "armor", "outfit_color": "#4a6ab8", "outfit_color2": "#f4f4fa", "acc": ["antennae", "visor"], "acc_colors": {"antennae": "#f4f4fa", "visor": "#ffd23c"}}, "weapon": {"kind": "gun", "color": "#f4f4fa", "count": 2}},
	"w7_palhaco_pivete": {"name": "Pivete da Gangue dos Palhaços", "look": {"skin": "#f0d0b0", "hair": "#8a3ad8", "hair_style": "mohawk", "outfit": "jacket", "outfit_color": "#3a2a5a", "outfit_color2": "#ffd23c", "acc": ["clown_nose", "chains"], "acc_colors": {"clown_nose": "#ff3a3a", "chains": "#a8aab4"}}, "weapon": {"kind": "bat", "color": "#a8aab4"}},
	"w7_soldado_exercito": {"name": "Soldado do Exército de Capacete Laser", "look": {"skin": "#e0c0a0", "hair": "#2a2a22", "hair_style": "buzz", "hat": "military", "hat_color": "#4a5a3a", "hat_color2": "#2a3a22", "outfit": "uniform", "outfit_color": "#4a5a3a", "outfit_color2": "#2a3a22", "acc": ["visor"], "acc_color": "#ff3a3a"}, "weapon": {"kind": "rifle", "color": "#3a3a3a"}},
	"w7_dragao_soldado": {"name": "Dragão Soldado de Escamas Rubras", "look": {"skin": "#c83a3a", "hair": "#6a1a1a", "hair_style": "spiky", "outfit": "none", "acc": ["horns", "wings", "tail"], "acc_colors": {"horns": "#f4e8c8", "wings": "#8a1a2a", "tail": "#a82a2a"}}, "weapon": {"kind": "claw", "color": "#f4e8c8"}},
	"w7_dragao_cavaleiro": {"name": "Dragão Cavaleiro da Prata Menor", "look": {"skin": "#e8e8f0", "hair": "#b8b8c8", "hair_style": "slick", "outfit": "armor", "outfit_color": "#c8ccd4", "outfit_color2": "#5a5ad8", "acc": ["small_horns", "wings"], "acc_colors": {"small_horns": "#5a5ad8", "wings": "#c8ccd4"}}, "weapon": {"kind": "greatsword", "color": "#c8ccd4"}},
}

## chefes da setima leva: aparecem no fim dos capitulos 57-64 e no Modo Chefes
const BOSSES := {
	"w7_leao_alado_desejo": {"name": "Leão Alado Devorador de Desejos", "rarity": 6, "hp_mult": 16.0, "atk_mult": 2.6, "color": "#ffd23c",
		"look": {"skin": "#e8c070", "hair": "#c88a2a", "hair_style": "wild_long", "tips": "#f4f0d8", "outfit": "none", "acc": ["wings", "tail", "fur_collar", "halo"], "acc_colors": {"wings": "#f4f0e0", "tail": "#c88a2a", "fur_collar": "#c88a2a", "halo": "#ffd23c"}},
		"weapon": {"kind": "claw", "color": "#ffd23c", "count": 3, "orbit": 1.5, "spin": -5.0, "power": 0.6},
		"actives": [
			{"name": "Banquete do Desejo Infinito", "type": "drain", "cd": 8.0, "power": 2.4, "fx": "soul_drain", "fx_scale": 0.6, "heal_pct": 0.45},
			{"name": "Rugido do Labirinto Dourado", "type": "knockback", "cd": 10.0, "power": 2.0, "radius": 170.0, "force": 750.0, "fx": "sunburst", "fx_scale": 0.55, "status": "stun", "status_dur": 1.0, "status_chance": 0.8, "shake": 6.0},
			{"name": "Pacto do Demônio Faminto", "type": "summon", "cd": 15.0, "power": 0.35, "count": 2, "dur": 10.0, "fx": "spawn_portal",
				"summon_look": {"skin": "#e8d890", "hair": "#c8a040", "hair_style": "none", "outfit": "none", "acc": ["wings", "horns"], "acc_colors": {"wings": "#f4f0e0", "horns": "#c88a2a"}}},
		]},
	"w7_mago_chamas_rosa": {"name": "Mago Fumante da Ordem Rosa Cruz", "rarity": 6, "hp_mult": 17.0, "atk_mult": 2.7, "color": "#ff6a2a",
		"look": {"skin": "#f0dcd0", "hair": "#14101e", "hair_style": "long", "outfit": "coat", "outfit_color": "#14101e", "outfit_color2": "#c83a5a", "acc": ["glasses", "high_collar", "cross"], "acc_colors": {"glasses": "#c8ccd4", "high_collar": "#14101e", "cross": "#c83a5a"}},
		"weapon": {"kind": "book", "color": "#c83a5a", "count": 2, "orbit": 1.6, "spin": 3.0, "power": 0.5},
		"actives": [
			{"name": "Salamandra do Inferno Escarlate", "type": "breath", "cd": 7.0, "power": 1.0, "fx": "flamethrower", "range": 240.0, "angle": 0.7, "ticks": 5, "status": "burn", "status_dur": 3.0, "status_chance": 0.6},
			{"name": "Círculo de Fogo da Rosa", "type": "zone", "cd": 11.0, "power": 0.8, "fx": "fire_ring", "fx_scale": 0.6, "radius": 130.0, "dur": 4.5, "pull": 60.0, "status": "burn", "status_dur": 2.0, "status_chance": 0.4},
			{"name": "Bola de Fogo do Cachimbo", "type": "projectile", "cd": 6.0, "power": 2.6, "fx": "fireball", "fx_scale": 0.6, "speed": 520.0, "hit_r": 26.0, "rotate": true, "aoe": 70.0, "hit_fx": "big_explosion", "hit_scale": 0.4, "count": 3, "arc": 0.6},
		]},
	"w7_progenitor_coroa": {"name": "Progenitor Ancestral da Coroa de Sangue", "rarity": 6, "hp_mult": 18.0, "atk_mult": 2.8, "color": "#c8203a",
		"look": {"skin": "#f8f0f0", "hair": "#e8e8f4", "hair_style": "long_bangs", "tips": "#c8203a", "hat": "crown", "hat_color": "#c8203a", "hat_color2": "#ffd23c", "outfit": "cape", "outfit_color": "#f4f4fa", "outfit_color2": "#c8203a", "acc": ["high_collar", "earrings", "devil_wings"], "acc_colors": {"high_collar": "#c8203a", "earrings": "#ffd23c", "devil_wings": "#8a1a2a"}},
		"weapon": {"kind": "scythe", "color": "#c8203a", "count": 2, "orbit": 1.55, "spin": 4.5, "power": 0.6},
		"actives": [
			{"name": "Lâminas de Sangue Milenar", "type": "orbit", "cd": 10.0, "power": 0.9, "count": 5, "dur": 5.0, "orbit_r": 95.0, "shape": "blade", "shape_color": "#c8203a"},
			{"name": "Sede do Primeiro Progenitor", "type": "execute", "cd": 9.0, "power": 2.6, "fx": "scythe_reap", "fx_scale": 0.6, "threshold": 0.35, "status": "bleed", "status_dur": 3.0, "status_chance": 0.7},
			{"name": "Lua Vermelha Desperta", "type": "awaken", "cd": 14.0, "power": 0.0, "buffs": {"atk_pct": 0.35, "lifesteal": 0.15, "spd_pct": 0.2}, "aura": "aura_red", "heal": 0.12},
		]},
	"w7_clonador_imortal": {"name": "Gênio Clonador da Pedra Eterna", "rarity": 6, "hp_mult": 19.0, "atk_mult": 2.9, "color": "#8ad84a",
		"look": {"skin": "#f4e4d0", "hair": "#e8d890", "hair_style": "bob", "outfit": "shirt_tie", "outfit_color": "#f4f4fa", "outfit_color2": "#8ad84a", "acc": ["soul_gem", "cyber_lines", "collar"], "acc_colors": {"soul_gem": "#4ad8a8", "cyber_lines": "#8ad84a", "collar": "#8ad84a"}},
		"weapon": {"kind": "orb", "color": "#8ad84a", "count": 4, "orbit": 1.7, "spin": 3.5, "power": 0.45},
		"actives": [
			{"name": "Exército de Cópias Perfeitas", "type": "summon", "cd": 14.0, "power": 0.4, "count": 3, "dur": 10.0, "fx": "hologram",
				"summon_look": {"skin": "#f4e4d0", "hair": "#e8d890", "hair_style": "bob", "outfit": "shirt_tie", "outfit_color": "#f4f4fa", "outfit_color2": "#8ad84a"}},
			{"name": "Ilusão do Deus Falso", "type": "debuff", "cd": 11.0, "power": 0.3, "status": "sleep", "status_dur": 2.5, "radius": 0.0, "fx": "hex_sigil"},
			{"name": "Cérebro Gigante Explosivo", "type": "aoe", "cd": 10.0, "power": 2.8, "fx": "plasma_explosion", "fx_scale": 0.5, "radius": 120.0, "hit_delay": 0.3, "warn": 0.9, "shake": 6.0},
		]},
	"w7_fundador_vila_oca": {"name": "Fundador Sorridente da Vila dos Desejos", "rarity": 7, "hp_mult": 20.0, "atk_mult": 3.0, "color": "#d8a040",
		"look": {"skin": "#3a2a2a", "hair": "#f4ece0", "hair_style": "wild_long", "hat": "hood", "hat_color": "#6a4a3a", "outfit": "cloak_clouds", "outfit_color": "#4a3a2a", "outfit_color2": "#d8a040", "acc": ["half_mask", "necklace", "tail"], "acc_colors": {"half_mask": "#f4ece0", "necklace": "#d8a040", "tail": "#4a3a2a"}},
		"weapon": {"kind": "staff", "color": "#d8a040", "count": 2, "orbit": 1.5, "spin": -4.0, "power": 0.55},
		"actives": [
			{"name": "Valor do Desejo Cobrado", "type": "gamble", "cd": 8.0, "power": 2.2, "fx": "orb_gold", "fx_scale": 0.6, "jackpot_buffs": {"atk_pct": 0.3, "crit": 0.2}},
			{"name": "Maldição da Subida", "type": "debuff", "cd": 11.0, "power": 0.3, "status": "poison", "status_dur": 5.0, "radius": 0.0, "fx": "curse"},
			{"name": "Lago Dourado da Vila", "type": "zone", "cd": 12.0, "power": 0.8, "fx": "whirlpool", "fx_scale": 0.6, "radius": 130.0, "dur": 5.0, "pull": 200.0, "status": "slow", "status_dur": 2.0, "status_chance": 0.5},
		]},
	"w7_revolucionario_rosto": {"name": "Revolucionário do Rosto Esculpido", "rarity": 7, "hp_mult": 22.0, "atk_mult": 3.1, "color": "#4ad8c8",
		"look": {"skin": "#e8d8c8", "hair": "#2a2a3a", "hair_style": "side_part", "hair2": "#4ad8c8", "outfit": "jacket", "outfit_color": "#4a3a2a", "outfit_color2": "#2a2a3a", "acc": ["cyber_lines", "scarf", "armband"], "acc_colors": {"cyber_lines": "#4ad8c8", "scarf": "#8a8a94", "armband": "#c84848"}},
		"weapon": {"kind": "dagger", "color": "#c8ccd4", "count": 2, "orbit": 1.35, "spin": 7.0, "power": 0.6},
		"actives": [
			{"name": "Rede Coletiva dos Refugiados", "type": "chain", "cd": 7.0, "power": 2.0, "count": 6, "hit_fx": "electrified", "hit_scale": 0.5, "status": "stun", "status_dur": 0.8, "status_chance": 0.4},
			{"name": "Invasão do Cérebro Alheio", "type": "debuff", "cd": 12.0, "power": 0.3, "status": "silence", "status_dur": 3.0, "radius": 0.0, "fx": "glitch"},
			{"name": "Mergulho Cibernético", "type": "teleport", "cd": 6.0, "power": 2.6, "fx": "emp_blast", "fx_scale": 0.5},
		]},
	"w7_massa_mutante": {"name": "Massa Mutante do Poder Descontrolado", "rarity": 7, "hp_mult": 24.0, "atk_mult": 3.2, "color": "#e86a8a",
		"look": {"skin": "#e8a0a0", "hair": "#2a1a1a", "hair_style": "messy", "outfit": "cape", "outfit_color": "#c81a2a", "outfit_color2": "#8a8a94", "acc": ["chains", "cyber_lines", "bandage"], "acc_colors": {"chains": "#8a8a94", "cyber_lines": "#ff4a6a", "bandage": "#f4f4fa"}},
		"weapon": {"kind": "fist", "color": "#e86a8a", "count": 3, "orbit": 1.6, "spin": 5.5, "power": 0.65},
		"actives": [
			{"name": "Tentáculos de Carne Viva", "type": "stretch", "cd": 6.0, "power": 1.4, "count": 4, "range": 320.0, "hit_fx": "blunt_hit", "hit_scale": 0.5, "arm": "#e8a0a0"},
			{"name": "Explosão Psíquica Absoluta", "type": "nova", "cd": 11.0, "power": 3.0, "fx": "nuke", "fx_scale": 0.5, "radius": 170.0, "extra_fx": "quake", "shake": 9.0},
			{"name": "Crescimento Sem Controle", "type": "awaken", "cd": 15.0, "power": 0.0, "buffs": {"atk_pct": 0.45, "def_pct": 0.25}, "aura": "aura_pink", "heal": 0.15},
		]},
	"w7_monarca_dragao_rubro": {"name": "Monarca Dragão do Céu Rubro", "rarity": 7, "hp_mult": 26.0, "atk_mult": 3.4, "color": "#c81a3a",
		"look": {"skin": "#f4e4e0", "hair": "#c81a3a", "hair_style": "spiky_long", "tips": "#14101e", "hat": "crown", "hat_color": "#14101e", "hat_color2": "#c81a3a", "outfit": "armor_gold", "outfit_color": "#2a1a22", "outfit_color2": "#c81a3a", "acc": ["horns", "devil_wings", "tail", "shoulder_pads"], "acc_colors": {"horns": "#14101e", "devil_wings": "#c81a3a", "tail": "#8a1a2a", "shoulder_pads": "#ffd23c"}},
		"weapon": {"kind": "greatsword", "color": "#c81a3a", "count": 2, "orbit": 1.6, "spin": 4.0, "power": 0.7},
		"actives": [
			{"name": "Sopro do Dragão Soberano", "type": "beam", "cd": 9.0, "power": 4.0, "fx": "beam_purple", "width": 52.0, "ticks": 5, "charge": 1.0, "shake": 7.0},
			{"name": "Chuva de Meteoros Carmesim", "type": "rain", "cd": 9.0, "power": 1.6, "count": 7, "fx": "meteor", "fx_scale": 0.5, "radius": 60.0, "warn": 0.6, "status": "burn", "status_dur": 3.0, "status_chance": 0.5},
			{"name": "Domínio do Tempo Dracônico", "type": "timestop", "cd": 16.0, "power": 0.0, "dur": 2.0, "fx": "time_stop"},
		]},
}

const CHAPTERS := [
	{"name": "O Leão Alado do Fundo do Labirinto", "world": "Masmorra do Ensopado", "enemies": ["w7_slime_ensopado", "w7_armadura_viva"], "boss": "w7_leao_alado_desejo", "guide": "meshi_cavaleiro_gourmet",
		"theme": {"floor": "#f6f0e2", "floor2": "#e8dcc4", "accent": "#d8a040", "line": "#d4c4a0"},
		"intro": ["A masmorra está crescendo. Algo lá no fundo quer devorar desejos.", "Uma fera alada concede tudo... e cobra a alma.", "Calma, pessoal! Primeiro a gente cozinha a gosma, depois salva o mundo."],
		"boss_line": "Diga-me o seu desejo. Eu vou comê-lo inteirinho.", "outro": "A masmorra está quieta. Hora de provar o ensopado de leão."},
	{"name": "A Rosa Cruz Ataca o Vaticano", "world": "Vaticano da Lua Vermelha", "enemies": ["w7_vampiro_rosa_cruz", "w7_inquisidor_ferro"], "boss": "w7_mago_chamas_rosa", "guide": "trinity_padre_desastrado",
		"theme": {"floor": "#f4eef0", "floor2": "#e4d4d8", "accent": "#c83a5a", "line": "#d4b8c0"},
		"intro": ["A ordem secreta da rosa colocou fogo em Roma.", "Um mago calmo, de cachimbo na boca, comanda as chamas.", "Ai, ai... eu só queria um chá com treze cubos de açúcar."],
		"boss_line": "Tudo queima no fim, padre. Até a sua fé.", "outro": "A fumaça se dissipou. A lua voltou a ser só uma lua."},
	{"name": "Catástrofe da Trombeta Final", "world": "Ruínas do Serafim Final", "enemies": ["w7_cavaleiro_apocalipse", "w7_nobre_sanguessuga"], "boss": "w7_progenitor_coroa", "guide": "seraph_orfao_asura",
		"theme": {"floor": "#f4f0f2", "floor2": "#e2d8dc", "accent": "#c8203a", "line": "#d0bcc4"},
		"intro": ["A trombeta tocou de novo e os cavaleiros desceram do céu.", "O progenitor mais antigo saiu do trono para reclamar o mundo.", "Eu vou exterminar todos eles. E trazer minha família de volta."],
		"boss_line": "Mil anos de sangue. Você é só mais um gole.", "outro": "As ruínas ainda estão de pé. E a família também."},
	{"name": "O Mistério do Clone Imortal", "world": "Riviera do Ladrão Cavalheiro", "enemies": ["w7_capanga_terno", "w7_clone_falho"], "boss": "w7_clonador_imortal", "guide": "lupin_neto_casaca",
		"theme": {"floor": "#f0f4ec", "floor2": "#dce6d4", "accent": "#8ad84a", "line": "#bcd0b0"},
		"intro": ["Alguém roubou a pedra da vida eterna antes de mim. Que falta de educação!", "Um gênio baixinho quer clonar o mundo inteiro.", "Vou pegar a pedra, a garota e o avião. Nessa ordem."],
		"boss_line": "Eu sou Deus. Você é só uma cópia mal feita.", "outro": "O inspetor chegou atrasado de novo. Tchauzinho!"},
	{"name": "Vila Oca da Sexta Camada", "world": "Abismo das Camadas Malditas", "enemies": ["w7_martelo_carne", "w7_hollow_vila"], "boss": "w7_fundador_vila_oca", "guide": "abyss_menina_apito",
		"theme": {"floor": "#f4f0e4", "floor2": "#e4dcc4", "accent": "#d8a040", "line": "#d4c8a4"},
		"intro": ["Na sexta camada existe uma vila onde tudo tem um valor.", "O fundador sorridente cobra cada desejo com o próprio corpo.", "A gente não volta mais pra cima. Então vamos até o fundo!"],
		"boss_line": "Aqui, até a sua dor tem preço. E eu vou cobrar.", "outro": "A vila desmoronou. O caminho para baixo está aberto."},
	{"name": "Os Onze Individualistas", "world": "Seção Nove Cibernética", "enemies": ["w7_ciborgue_refugiado", "w7_tanque_pensante"], "boss": "w7_revolucionario_rosto", "guide": "gits_major_optica",
		"theme": {"floor": "#eef2f4", "floor2": "#d8e2e8", "accent": "#4ad8c8", "line": "#b4c8d0"},
		"intro": ["Um vírus de rede está transformando ciborgues em revolucionários.", "O líder deles tem um rosto esculpido à mão e um cérebro na rede de todos.", "Seção Nove, em posição. Ninguém atira antes de mim."],
		"boss_line": "Eu não quero um país. Quero uma rede onde ninguém fica para trás.", "outro": "A rede está quieta. Mas o fantasma dele ainda sussurra lá dentro."},
	{"name": "O Despertar no Estádio Olímpico", "world": "Neo-Tóquio das Motos Vermelhas", "enemies": ["w7_palhaco_pivete", "w7_soldado_exercito"], "boss": "w7_massa_mutante", "guide": "akira_lider_capsula",
		"theme": {"floor": "#f4eeee", "floor2": "#e6d6d6", "accent": "#e83a4a", "line": "#d4b8b8"},
		"intro": ["O estádio olímpico virou o centro de uma explosão de carne e luz.", "Meu amigo não consegue mais controlar o próprio corpo.", "Ei, parceiro! Essa moto vermelha ainda é minha, ouviu?"],
		"boss_line": "Me ajuda... eu não consigo parar de crescer!", "outro": "A cidade explodiu de novo. Mas a moto sobreviveu."},
	{"name": "Guerra dos Lordes Dragões", "world": "Céu dos Dragões Carmesim", "enemies": ["w7_dragao_soldado", "w7_dragao_cavaleiro"], "boss": "w7_monarca_dragao_rubro", "guide": "ragna_matador_futuro",
		"theme": {"floor": "#f6eeee", "floor2": "#e8d4d4", "accent": "#c81a3a", "line": "#d8b8bc"},
		"intro": ["O céu ficou vermelho. Os lordes dragões declararam guerra total.", "No topo do exército voa o monarca que domina o próprio tempo.", "Eu já vi esse futuro. Desta vez eu mudo o final."],
		"boss_line": "Humanos são comida. Matadores são sobremesa.", "outro": "O último dragão caiu. O futuro carmesim finalmente é nosso."},
]

## modo Chefes (setima leva): desbloqueio por nivel da conta
const BOSS_RAID := [
	{"boss": "w7_leao_alado_desejo", "level": 295}, {"boss": "w7_mago_chamas_rosa", "level": 301}, {"boss": "w7_progenitor_coroa", "level": 307},
	{"boss": "w7_clonador_imortal", "level": 314}, {"boss": "w7_fundador_vila_oca", "level": 320}, {"boss": "w7_revolucionario_rosto", "level": 327},
	{"boss": "w7_massa_mutante", "level": 333}, {"boss": "w7_monarca_dragao_rubro", "level": 340},
]

const BANNERS := [
	{"id": "w7_ensopado_vampiros", "name": "Ensopados, Vampiros & Ladrões", "desc": "Masmorra do Ensopado, Vaticano da Lua Vermelha, Ruínas do Serafim e Riviera do Ladrão Cavalheiro.", "worlds": ["Masmorra do Ensopado", "Vaticano da Lua Vermelha", "Ruínas do Serafim Final", "Riviera do Ladrão Cavalheiro"], "chapter": 60, "color": "#c83a5a"},
	{"id": "w7_abismo_dragoes", "name": "Abismos, Ciborgues & Dragões", "desc": "Camadas Malditas, Seção Nove, Neo-Tóquio das Motos e Céu dos Dragões Carmesim.", "worlds": ["Abismo das Camadas Malditas", "Seção Nove Cibernética", "Neo-Tóquio das Motos Vermelhas", "Céu dos Dragões Carmesim"], "chapter": 64, "color": "#c81a3a"},
]

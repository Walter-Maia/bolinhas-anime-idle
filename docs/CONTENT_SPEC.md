# Especificação de conteúdo — Bolinhas Anime Idle

Cada grupo de bolinhas fica num arquivo `scripts/data/balls_<grupo>.gd`:

```gdscript
extends RefCounted
## <animes deste arquivo>

const LIST := [
	{
		"id": "gash_raio", "name": "Garoto do Livro Vermelho", "world": "Mundo dos Mamodos",
		"rarity": 1, "role": "Atacante", "color": "#ffd23c",
		"lore": "Uma frase curta e divertida.",
		"look": {...}, "look_tf": {...},
		"actives": [ {...}, {...} ],
		"passives": [ {...} ],
		"forms": ["", "", "", "Forma X", "Forma X", "Forma Y", "Forma Z", "Forma Z", "Forma Final"],
	},
]
```

## Regras gerais
- **Nomes sempre paródia em PT-BR** (nada de nomes oficiais de personagens, golpes ou animes). Ex.: Rasengan → "Esfera Espiral", Getsuga → "Presa Lunar", Kamehameha → "Onda Kame". Dá pra lembrar o original, mas não copiar.
- `id`: snake_case ASCII, único no jogo inteiro, prefixado pela franquia (`khr_`, `madoka_`, `cdz_`...).
- `world`: nome paródia fixo da franquia (dado na tarefa). Use exatamente o mesmo texto em todas as bolinhas da franquia.
- `rarity` base 0..7 (0 Comum, 1 Incomum, 2 Raro, 3 Épico, 4 Lendário, 5 Mítico, 6 Divino, 7 Celestial). 8 (Transcendente) é só por evolução — nunca base.
- `role`: "Atacante" | "Tanque" | "Velocista" | "Suporte".
- `color`: cor hex do "elemento" do personagem (usada em tiros e brilhos).
- `lore`: 1 frase.
- 1 a 3 `actives`, 1 a 3 `passives`. **Toda bolinha precisa de pelo menos uma skill ou passiva com `"unlock"` acima da raridade base** (algo que só libera evoluindo). Personagens fortes podem ter 3 ativas.
- **Varie muito**: use tipos de skill diferentes entre personagens da mesma franquia, e aproveite os tipos novos (orbit, zone, drain, debuff, execute, awaken, knockback, teleport, mimic, gamble).
- Transformações clássicas (bankai, super saiyajin, modo sábio, mão do diabo...) → passiva `low_hp` com `"transform": true` **ou** ativa `awaken`, e as ativas ganham `"alt"` (versão transformada com outro `fx`/cor e `power_mult`). **O `alt` deve trocar o `fx` para algo de cor bem diferente** (ex.: azul → vermelho/preto/dourado) para dar contraste.
- `forms`: 9 strings (uma por raridade 0..8), "" quando não há forma nova. Opcional mas desejado.
- Sintaxe: GDScript `const` → só literais. Strings com aspas duplas, números float com ponto (`2.0`), vírgula final permitida. Nada de funções/variáveis. Acentos UTF-8 OK. Não use aspas duplas dentro das strings.
- Qualquer número de skill pode ser um Array por raridade (índice 0..8; se o array for menor, usa o último). Ex.: `"count": [1, 1, 2, 2, 3, 3, 4, 4, 5]`.

## Visual (`look`) — as bolinhas NÃO têm rosto
Só pele/corpo, cabelo, roupa e acessórios. Caracterize bem pelo cabelo, chapéu, roupa e acessórios.

| campo | valores |
|---|---|
| `skin` | cor hex do corpo (pele) — ex.: "#f6d0a8", "#e8b888", "#6cc04a" (verde), "#c84848" |
| `hair` | cor hex |
| `hair_style` | `none` `bald` `short` `buzz` `messy` `spiky` `big_spiky` `spiky_long` `flame` `long` `wild_long` `twintail` `pigtails` `ponytail` `bun` `braid` `bob` `hime` `afro` `mohawk` `curly` `slick` `side_part` `undercut` `cover_eye` `dome` |
| `tips` | cor hex opcional das pontas (estilos espetados) |
| `hair2` | cor hex opcional de uma mecha |
| `hat` | `none` `straw` `military` `witch` `fedora` `top_hat` `crown` `beanie` `cap` `beret` `chef` `turban` `hood` `cat_hood` `gold_helmet` `knight_helmet` `bandana_top` |
| `hat_color`, `hat_color2` | cores hex do chapéu (principal e detalhe) |
| `outfit` | `none` `gi` `vest` `cape` `checker` `robe` `coat` `uniform` `sailor` `suit` `shirt_tie` `armor` `armor_gold` `hoodie` `kimono` `jacket` `cyber` `dress` `tank` `cloak_clouds` `lab_coat` `scarf_coat` |
| `outfit_color`, `outfit_color2` | cor principal e de detalhe da roupa |
| `acc` | lista de acessórios (abaixo) |
| `acc_color` | cor hex usada por acessórios coloridos (ribbon, bandana, headband, flower, bow, scarf, collar, cape...) |

Acessórios (`acc`): `headband` (bandana ninja com placa), `headband_slash` (placa riscada), `bandana`, `tiara`, `scarf`, `earrings`, `glasses`, `sunglasses`, `goggles`, `headphones`, `mouth_mask`, `half_mask` (máscara de osso meia face), `full_mask`, `blindfold`, `visor`, `horns`, `small_horns`, `cat_ears`, `bunny_ears`, `fox_ears`, `halo`, `antennae`, `elf_ears`, `ribbon` (laço grande), `hairclip`, `flower`, `pacifier` (chupeta no peito), `puzzle_pendant` (pingente piramidal dourado), `soul_gem` (gema no peito/cabeça), `cross`, `chains`, `chainsaw` (motosserra saindo da testa), `cyber_lines` (linhas neon no corpo), `collar`, `necklace`, `wings`, `devil_wings`, `tail`, `flame_forehead` (chama na testa), `third_eye_band` (bandana com olho na testa), `star_mark`, `bandage`, `bell`, `card` (carta na mão/flutuando), `sword_back` (espada nas costas), `hammer`, `eyepatch`, `ahoge` (fio de cabelo rebelde), `scar_x` (cicatriz em X).

Estilos extras de cabelo: `spiky_back` (espetos para trás), `pompadour` (topete), `drills` (cachos em parafuso).

`look_tf` (opcional): campos que mudam quando transforma (ex.: `{"hair": "#ffd23c", "acc": ["half_mask"]}`). Se trocar `acc`, liste a lista completa nova.

## Arma (`weapon`) — OBRIGATÓRIA na leva nova
A bolinha quica sozinha pela arena; a arma fica **girando em volta dela** e causa dano a quem encostar.
```
"weapon": {"kind": "katana", "color": "#d8dde8", "count": 2, "orbit": 1.45, "spin": 4.0, "power": 0.55}
```
- `kind`: `sword` `katana` `greatsword` `dagger` `kunai` `shuriken` `spear` `trident` `scythe` `hammer` `axe` `staff` `wand` `bow` `gun` `rifle` `fan` `card` `book` `chain` `orb` `shield` `fist` `claw` `whip` `tonfa` `chainsaw` `bat` `umbrella` `guitar` `flag` `needle` `gear` `feather` `rose` `bomb` `bottle`
- `color`: cor principal da arma. `count` 1–4 (quantas giram), `orbit` 1.2–1.9 (distância em raios da bolinha), `spin` 1.5–9 rad/s (positivo horário, negativo anti-horário), `power` 0.25–1.0 (multiplicador do ATK por toque).
- Escolha a arma icônica do personagem (Levi → 2 `katana` da tropa; Reborn → `gun`; Tsuna → `fist` com chama; Hisoka → `card`; Kurapika → `chain`).

## Skills ativas (`actives`)
Campos comuns: `name`, `type`, `cd` (s), `power` (multiplicador do ATK), `desc`, opcional `unlock` (raridade mínima), `alt` (versão transformada: qualquer campo + `power_mult`, `speed_mult`), `target` (`nearest` padrão, `strongest`, `random`, `weakest`), `status`, `status_dur`, `status_chance`, `shake`.

| type | o que faz | params extras |
|---|---|---|
| `projectile` | dispara projéteis | `fx`, `fx_scale`, `speed`, `hit_r`, `rotate` (bool: sprite aponta na direção), `pierce`, `hit_fx`, `hit_scale`, `aoe` (raio de explosão), `count`, `arc` (abertura em radianos para leque/escopeta), `homing` |
| `beam` | feixe reto até a parede | `fx` (beam_ki, beam_gold, beam_purple), `width`, `ticks`, `charge` |
| `breath` | cone na direção do alvo | `fx` (fire_breath, frost_breath, flamethrower*, water_jet*), `range`, `angle`, `ticks` |
| `aoe` | área no alvo | `fx`, `fx_scale`, `radius`, `hit_delay`, `extra_fx`, `extra_scale`, `warn` (s de aviso vermelho antes do impacto) |
| `nova` | área em volta de si | `fx`, `fx_scale`, `radius`, `extra_fx` |
| `rain` | vários golpes em inimigos aleatórios | `fx`, `fx_scale`, `radius`, `count` |
| `dash` | investida (pode encadear); a arma gira 4× mais rápido e acerta tudo no caminho | `count`, `hit_fx`, `hit_scale`, `trail_fx` |
| `hook` | dispara um gancho/corrente no inimigo e se puxa até ele girando a arma (acerta tudo no caminho) | `count` (puxões encadeados), `hit_fx`, `hit_scale`, `arm` (cor do cabo) |
| `multi` | vários golpes no alvo | `count`, `interval`, `fx`, `fx_scale`, `spread` (bool: alvo aleatório a cada golpe) |
| `stretch` | braço/corrente que estica até o alvo | `count`, `range`, `hit_fx`, `hit_scale`, `arm` (cor hex do braço/corrente) |
| `chain` | raio que pula entre inimigos | `count`, `hit_fx`, `hit_scale` |
| `summon` | invoca aliados temporários | `count`, `dur`, `fx`, `power` (fração dos atributos), `summon_look` (um look completo inline, opcional) |
| `shield` | escudo = power × vida máx | `dur`, `invuln` (s de imunidade), `fx` |
| `buff` | bônus temporário | `dur`, `buffs` ({`atk_pct`,`spd_pct`,`def_pct`,`crit`,`dodge`,`lifesteal`,`contact_pct`}), `fx` |
| `heal` | cura (power = % vida máx) | `fx` |
| `timestop` | congela todos os inimigos | `dur`, `fx` |
| `strike` | golpe único enorme | `fx`, `fx_scale`, `flash` (bool), `force_crit` |
| `orbit` | lâminas/orbes girando em volta por `dur` s, ferem ao tocar | `count`, `dur`, `orbit_r` (raio), `fx` (sprite de cada orbe) **ou** `shape` (`petal`, `blade`, `card`, `feather`, `chain`, `bubble`, `star`) + `shape_color` |
| `zone` | área persistente que dá dano por tick | `fx` (de preferência em loop: poison_cloud, black_hole, whirlpool, shadow_flames, storm_cloud, eclipse, rune_circle, magic_circle...), `fx_scale`, `radius`, `dur`, `pull` (força de puxar, 0-300), `on_self` (bool) |
| `drain` | dano + cura de `heal_pct` do dano | `fx`, `fx_scale`, `heal_pct` |
| `debuff` | aplica status em área ou em todos | `status` (weaken, armor_break, marked, silence, slow, poison...), `status_dur`, `radius` (0 = todos), `fx` |
| `execute` | golpe no inimigo com menos vida; ×3 se abaixo de `threshold` | `fx`, `fx_scale`, `threshold` |
| `awaken` | se transforma pelo resto da luta (1x) | `buffs`, `aura` (fx de aura), `heal` |
| `knockback` | empurra tudo em volta | `radius`, `force`, `fx`, `fx_scale` |
| `teleport` | some e reaparece no alvo batendo | `fx` (impacto), `fx_scale` |
| `mimic` | usa uma skill aleatória de outra bolinha do jogo | — (power multiplica) |
| `gamble` | multiplicador aleatório 0.3×–5×; jackpot dá buff | `fx`, `fx_scale`, `jackpot_buffs` |

## Passivas (`passives`)
Campos: `name`, `type`, `desc`, opcional `unlock`.

| type | params |
|---|---|
| `stats` | `stats` ({`atk_pct`,`hp_pct`,`def_pct`,`spd_pct`,`crit`,`critdmg`,`dodge`,`lifesteal`,`cdr`,`regen`,`thorns`,`contact_taken` (negativo = menos dano)}) |
| `low_hp` | `threshold`, `heal`, `buffs`, `aura`, `transform` (bool), `grow` (escala), `stun_all` (s) |
| `on_hit` | `chance`, `status`, `status_dur` |
| `on_kill` | `summon` (1) e `max_summons`, **ou** `heal` (fração) |
| `stack` | `atk_pct` por acerto, `max` |
| `revive` | `heal` (fração ao reviver, 1x por luta), `fx` |
| `berserk` | `atk_pct` máximo ganho conforme perde vida |
| `periodic` | `every` (s), `skill` (uma skill ativa completa, inline) |
| `shield_start` | `shield` (fração da vida) |
| `first_strike` | `buffs`, `dur` (s no início da luta) |
| `execute` | `threshold`, `bonus` (dano extra contra inimigos com pouca vida) |
| `on_crit` | `heal` (fração do dano) e/ou `status`, `status_dur` |
| `counter` | `chance`, `power` (contra-ataca ao esquivar/ser atingido) |
| `aura_dmg` | `radius`, `power` (dano por segundo em quem chegar perto) |
| `reflect` | `pct` (reflete parte de todo dano recebido) |

Qualquer passiva pode ter `"immune": ["burn", "stun", ...]`.

## Status
`burn`, `black_burn`, `poison`, `bleed`, `freeze`, `stun`, `slow`, `weaken` (−30% ATK), `armor_break` (−50% DEF), `marked` (+30% dano recebido), `silence` (sem skills), `petrify`, `sleep` (atordoado até levar dano).

## Efeitos (`fx`, `hit_fx`, `extra_fx`, `aura`, `trail_fx`)
Só use nomes desta lista:

acid_splash arcane_missiles arrow arrow_pink aura_blue aura_cyan aura_dark aura_fox aura_gold aura_green aura_pink aura_purple aura_red aura_white ball_lightning ball_lightning_gold bat beam_gold beam_ki beam_purple big_explosion big_explosion_blue black_hole black_hole_red blessing blink_in blink_out blizzard_vortex blunt_hit boulder bullet butterfly cartoon_pow chain_lightning charge_gold charge_up claw_red claw_swipe crit_hit curse dagger_flurry dark_explosion disc_black disc_blue disc_gold disc_pink disc_purple divine_shield double_slash earth_spike eclipse electrified emp_blast emp_pink energy_core feather_black feather_burst fire_breath fire_ring fire_tornado fireball fireball_black fireball_blue fireball_pink firework flame_pillar flamethrower flamethrower_black flamethrower_blue flying_skull force_field freeze frost_breath frost_nova geyser ghost glitch grasping_hands grenade ground_slam halo hammer_smash haste heal heal_aoe heal_pink healing_bloom heavy_cleave hex_sigil hit_flash hit_spark hologram holy_pillar holy_pillar_pink ice_crystal ice_lance ice_lance_pink ice_shatter ice_spikes icicle_fall impact_frame implosion laser_blue laser_gold laser_grid laser_pink laser_red leaf_storm life_steal lightning_gold lightning_purple lightning_red lightning_strike magic_circle magic_missile mana_burst meteor muzzle_shotgun necro_skulls nuke orb_fox orb_gold orb_purple orb_spiral parry plasma_ball plasma_explosion plasma_shot plasma_shot_red poison_cloud poof portal purple_explosion quake resurrection ricochet rocket root_snare rune_circle rune_red scythe_purple scythe_reap shadow_flames shadow_tendrils shatter_death shield_block shield_purple slash_blue slash_fire slash_gold slash_pink slash_purple slash_red small_explosion smite smoke_bomb snake soul_drain soul_rise spark_arc spawn_portal spear_sweep spell_charge spin_slash spin_slash_green spirit_flame splash spore_burst star_fall storm_cloud summon_rise sunburst sword_slash thorns thrust thunderclap time_stop tornado uppercut vine_whip void_orb void_orb_red warp_in warp_out water_jet water_jet_blue water_orb wave_fire wave_water whip_crack whirlpool wisp wisp_pink zap_hit

Dicas de escala (arena ~680×470 px, bolinha com raio ~36): explosões grandes (`big_explosion`, `nuke`, `dark_explosion`) `fx_scale` 0.35–0.55; impactos 0.4–0.7; orbes como projétil 0.4–0.8; auras são ajustadas sozinhas.

## Balanceamento
- `power` típico: projétil único 2.0–3.5; multi por golpe 0.6–1.2; strike 4–14 (cd alto); beam 3–5; zone 0.4–1.0 por tick; heal 0.12–0.35.
- `cd` 4–16 s. Mais forte = mais recarga.
- Raridades altas não precisam de power absurdo: o jogo já multiplica pela raridade.

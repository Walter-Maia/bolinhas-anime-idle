#!/usr/bin/env node
// Exporta efeitos do pixelfx (third_party/pixelfx) como sprite sheets otimizadas para o Godot.
//
//   node tools/export_fx.mjs            exporta tudo
//   node tools/export_fx.mjs orb_blue   exporta so os nomes passados
//
// Para cada efeito: renderiza a N fps, corta o retangulo vazio (bbox de todos os frames), limita a duracao,
// grava assets/fx/<nome>.png e regenera scripts/data/fx_data.gd com frame size, colunas, fps, loop e pivot.
// Paletas: qualquer ramp escuro->claro de cores hex (o pixelfx recolore o efeito sem mexer no codigo).

import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { writeFileSync, mkdirSync, readFileSync, existsSync } from "node:fs";

const HERE = dirname(fileURLToPath(import.meta.url));
const PROJECT = join(HERE, "..");
const PFX = join(PROJECT, "third_party", "pixelfx");
const { loadEffect, renderFrames } = await import("file://" + join(PFX, "tools", "lib", "fxlib.mjs").replace(/\\/g, "/"));
const { encodePNG } = await import("file://" + join(PFX, "tools", "lib", "png.mjs").replace(/\\/g, "/"));

// ---------- paletas extras (anime) ----------
const P = {
  spiral: ["#06123a", "#0d2a78", "#1450c0", "#2a86f0", "#62bcff", "#a8e2ff", "#e2f6ff", "#ffffff"], // esfera espiral
  fox: ["#2a0404", "#5c0808", "#9a1206", "#d42a08", "#ff5a14", "#ff9a3a", "#ffd88a", "#fff6e0"], // manto da raposa
  purple: ["#12041e", "#2e0a4a", "#52127e", "#8020b8", "#b040f0", "#d888ff", "#f4d4ff", "#ffffff"],
  gold: ["#1e1206", "#4a2c08", "#86520c", "#c48412", "#f0b424", "#ffe066", "#fff6c4", "#ffffff"],
  ki: ["#04122a", "#0a2a5e", "#105aa8", "#1a8ae0", "#4ec2ff", "#a4e8ff", "#e8fbff", "#ffffff"],
  blood: ["#14040a", "#3a0a14", "#6a101c", "#a01824", "#d42a30", "#ff5a50", "#ff9a8a", "#ffe0da"],
  hollow: ["#050308", "#140a10", "#2a0c14", "#4a0e1a", "#7a1020", "#b01828", "#e83a3a", "#ffb0a0"],
  black: ["#020204", "#0a0810", "#14101e", "#1e1830", "#2c2444", "#3e3460", "#5a4c84", "#8070b0"],
  water: ["#081830", "#0e2e5a", "#14508c", "#1c76bc", "#36a2e0", "#78ccf4", "#c4ecff", "#ffffff"],
  fire: ["#1f0b10", "#4a1118", "#8c1d1c", "#cc3a1a", "#f2701f", "#ffae35", "#ffe27a", "#fff8d6"],
  ice: ["#0c1430", "#162c5c", "#1f4f94", "#2f7fcc", "#58b4ec", "#9bdcff", "#d8f4ff", "#ffffff"],
  electric: ["#0a0f2e", "#172a78", "#2550d0", "#3f8cff", "#7cc8ff", "#c8f0ff", "#ffffff"],
  volt: ["#24160a", "#5e3a0c", "#a8680f", "#e8a218", "#ffd23c", "#fff08a", "#ffffff"],
  green: ["#0c1a0e", "#163418", "#225224", "#357530", "#4f9a3a", "#7cc048", "#b4e070", "#e4ffb0"],
  pink: ["#1a0516", "#3d0a33", "#701560", "#b0228f", "#f53cd1", "#ff86e6", "#ffd2f6", "#ffffff"],
  shadow: ["#050308", "#0f0a18", "#1c1230", "#2c1a4a", "#432468", "#5e3290", "#8048b8", "#a970e0"],
  gray: ["#101014", "#24242c", "#3c3c48", "#5a5a68", "#80808e", "#a8a8b4", "#d4d4dc", "#ffffff"],
  rar_green: ["#06200c", "#0c3c16", "#146024", "#20903a", "#36c454", "#7cf08c", "#c8ffd0", "#ffffff"],
  rar_blue: ["#061430", "#0c2a60", "#14489c", "#1e70d8", "#3c9cff", "#88c8ff", "#d0ecff", "#ffffff"],
  rar_purple: ["#14062a", "#2c0c56", "#4a1490", "#7024c8", "#a04af0", "#c88aff", "#ecd4ff", "#ffffff"],
  rar_gold: ["#1e1206", "#4a2c08", "#86520c", "#c48412", "#f0b424", "#ffe066", "#fff6c4", "#ffffff"],
  neon: ["#1a0516", "#3d0a33", "#701560", "#b0228f", "#f53cd1", "#ff86e6", "#ffd2f6", "#ffffff"],
  cyber: ["#041418", "#08303a", "#0c5260", "#108088", "#18b4b0", "#4ce8d8", "#b4fff0", "#ffffff"],
  prism: ["#2a2440", "#5a4c84", "#8a7cc0", "#b8a8f0", "#e0d4ff", "#f4ecff", "#fffaff", "#ffffff"],
  rar_red:["#1e0408", "#4a0810", "#86101a", "#c41a24", "#f03a3a", "#ff7a6a", "#ffc8bc", "#ffffff"],
};

// name: [id, { palette, fps, maxT (segundos), seed, opts }]
const FX = {
  // --- orbes / projeteis ---
  orb_spiral: ["arcane/arcane-orb", { palette: P.spiral }],
  orb_fox: ["arcane/arcane-orb", { palette: P.fox }],
  orb_purple: ["arcane/arcane-orb", { palette: P.purple }],
  orb_gold: ["arcane/arcane-orb", { palette: P.gold }],
  void_orb: ["shadow/void-orb", {}],
  plasma_ball: ["lightning/plasma-ball", { palette: P.electric }],
  ball_lightning: ["lightning/ball-lightning", {}],
  fireball: ["fire/fireball", {}],
  fireball_blue: ["fire/fireball", { palette: P.ki }],
  ice_lance: ["ice/ice-lance", {}],
  disc_black: ["projectiles/energy-disc", { palette: P.hollow }],
  disc_blue: ["projectiles/energy-disc", { palette: P.water }],
  disc_gold: ["projectiles/energy-disc", { palette: P.gold }],
  laser_gold: ["projectiles/laser-bolt", { palette: P.volt }],
  plasma_shot: ["projectiles/plasma-shot", {}],
  plasma_shot_red: ["projectiles/plasma-shot", { palette: P.blood }],
  water_orb: ["water/water-orb", {}],
  magic_missile: ["projectiles/magic-missile", { maxT: 1.2 }],
  // --- feixes / soprros ---
  beam_ki: ["arcane/arcane-beam", { palette: P.ki }],
  beam_purple: ["arcane/arcane-beam", { palette: P.purple }],
  beam_gold: ["arcane/arcane-beam", { palette: P.gold }],
  fire_breath: ["fire/fire-breath", {}],
  frost_breath: ["ice/frost-breath", {}],
  water_jet: ["water/water-jet", {}],
  // --- impactos ---
  hit_spark: ["impacts/hit-spark", { fps: 20 }],
  hit_flash: ["impacts/hit-flash", { fps: 20 }],
  crit_hit: ["impacts/crit-hit", { fps: 20 }],
  blunt_hit: ["impacts/blunt-hit", { fps: 20 }],
  zap_hit: ["lightning/zap-hit", { fps: 20 }],
  cartoon_pow: ["explosions/cartoon-pow", { fps: 20 }],
  impact_frame: ["impacts/impact-frame", { fps: 20 }],
  shield_block: ["impacts/shield-block", {}],
  // --- explosoes / aoe ---
  plasma_explosion: ["explosions/plasma-explosion", {}],
  purple_explosion: ["explosions/plasma-explosion", { palette: P.purple }],
  small_explosion: ["explosions/small-explosion", { maxT: 1.4 }],
  big_explosion: ["explosions/big-explosion", { maxT: 1.8 }],
  dark_explosion: ["shadow/dark-explosion", { maxT: 1.8 }],
  implosion: ["explosions/implosion", {}],
  frost_nova: ["ice/frost-nova", { maxT: 1.8 }],
  ice_spikes: ["ice/ice-spikes", { maxT: 2 }],
  freeze: ["ice/freeze", { maxT: 2 }],
  icicle_fall: ["ice/icicle-fall", {}],
  lightning_strike: ["lightning/lightning-strike", { maxT: 1.4 }],
  lightning_red: ["lightning/lightning-strike", { maxT: 1.4, palette: P.blood }],
  chain_lightning: ["lightning/chain-lightning", {}],
  thunderclap: ["lightning/thunderclap", {}],
  spark_arc: ["lightning/spark-arc", {}],
  earth_spike: ["nature/earth-spike", { maxT: 2 }],
  quake: ["nature/quake", { maxT: 1.8 }],
  wave_water: ["water/wave-crash", { maxT: 2 }],
  wave_fire: ["water/wave-crash", { maxT: 2, palette: P.fire }],
  fire_tornado: ["fire/fire-tornado", {}],
  fire_ring: ["fire/fire-ring", { maxT: 2 }],
  meteor: ["fire/meteor", { maxT: 2.4 }],
  holy_pillar: ["holy/holy-pillar", { maxT: 2 }],
  smite: ["holy/smite", { maxT: 1.8 }],
  sunburst: ["holy/sunburst", {}],
  star_fall: ["arcane/star-fall", {}],
  time_stop: ["arcane/time-stop", { maxT: 2.4 }],
  mana_burst: ["arcane/mana-burst", {}],
  black_hole: ["shadow/black-hole", {}],
  shadow_tendrils: ["shadow/shadow-tendrils", { maxT: 2.2 }],
  grasping_hands: ["shadow/grasping-hands", { maxT: 2.2 }],
  shadow_flames: ["shadow/shadow-flames", {}],
  life_steal: ["shadow/life-steal", {}],
  leaf_storm: ["nature/leaf-storm", {}],
  tornado: ["nature/tornado", {}],
  blizzard_vortex: ["ice/blizzard-vortex", {}],
  poison_cloud: ["nature/poison-cloud", { maxT: 2 }],
  // --- golpes ---
  sword_slash: ["melee/sword-slash", { fps: 20 }],
  slash_blue: ["melee/sword-slash", { fps: 20, palette: P.water }],
  slash_fire: ["melee/sword-slash", { fps: 20, palette: P.fire }],
  double_slash: ["melee/double-slash", { fps: 20 }],
  slash_red: ["melee/double-slash", { fps: 20, palette: P.blood }],
  spin_slash: ["melee/spin-slash", { fps: 20 }],
  spin_slash_green: ["melee/spin-slash", { fps: 20, palette: P.green }],
  dagger_flurry: ["melee/dagger-flurry", { fps: 20 }],
  claw_swipe: ["melee/claw-swipe", { fps: 20 }],
  scythe_reap: ["melee/scythe-reap", { fps: 20 }],
  heavy_cleave: ["melee/heavy-cleave", { fps: 20, maxT: 1.2 }],
  thrust: ["melee/thrust", { fps: 20 }],
  uppercut: ["melee/uppercut", { fps: 20 }],
  hammer_smash: ["melee/hammer-smash", { fps: 20, maxT: 1.2 }],
  // --- status / auras ---
  st_burning: ["status/burning", {}],
  st_frozen: ["status/frozen", {}],
  st_stunned: ["status/stunned", {}],
  st_slowed: ["status/slowed", {}],
  st_poisoned: ["status/poisoned", {}],
  st_bleeding: ["status/bleeding", {}],
  aura_fox: ["status/rage", { palette: P.fox }],
  aura_gold: ["status/rage", { palette: P.gold }],
  aura_dark: ["status/rage", { palette: P.hollow }],
  aura_blue: ["status/rage", { palette: P.electric }],
  aura_purple: ["status/rage", { palette: P.purple }],
  aura_green: ["status/rage", { palette: P.green }],
  electrified: ["lightning/electrified", {}],
  haste: ["status/haste", {}],
  divine_shield: ["holy/divine-shield", {}],
  shield_purple: ["holy/divine-shield", { palette: P.purple }],
  force_field: ["scifi/force-field", {}],
  heal: ["holy/heal", {}],
  heal_aoe: ["holy/heal-aoe", { maxT: 2 }],
  healing_bloom: ["nature/healing-bloom", { maxT: 2 }],
  halo: ["holy/halo", {}],
  spirit_flame: ["fire/spirit-flame", {}],
  // --- spawn / morte ---
  poof: ["spawn/poof", {}],
  shatter_death: ["spawn/shatter-death", { maxT: 1.6 }],
  soul_rise: ["spawn/soul-rise", { maxT: 2 }],
  summon_rise: ["spawn/summon-rise", { maxT: 2.2, palette: P.shadow }],
  warp_in: ["scifi/warp-in", { maxT: 1.6 }],
  blink_in: ["arcane/blink-in", {}],
  blink_out: ["arcane/blink-out", {}],
  spawn_portal: ["spawn/spawn-portal", { maxT: 2.4 }],
  // --- pickups / ui ---
  chest_open: ["pickups/chest-open", {}],
  coin_spin: ["pickups/coin-spin", { fps: 12 }],
  gem_spin: ["pickups/gem-spin", { fps: 12 }],
  key_glint: ["pickups/key-glint", { fps: 12 }],
  crystal_shard: ["pickups/crystal-shard", { fps: 12 }],
  power_star: ["pickups/power-star", { fps: 12 }],
  xp_orb: ["pickups/xp-orb", { fps: 12 }],
  potion: ["pickups/potion", { fps: 12 }],
  collect_burst: ["pickups/collect-burst", {}],
  loot_gray: ["pickups/loot-beam", { palette: P.gray }],
  loot_green: ["pickups/loot-beam", { palette: P.rar_green }],
  loot_blue: ["pickups/loot-beam", { palette: P.rar_blue }],
  loot_purple: ["pickups/loot-beam", { palette: P.rar_purple }],
  loot_gold: ["pickups/loot-beam", { palette: P.rar_gold }],
  loot_red: ["pickups/loot-beam", { palette: P.rar_red }],
  level_up: ["ui/level-up", {}],
  confetti: ["ui/confetti", {}],
  coin_collect: ["ui/coin-collect", {}],
  // --- raridades novas ---
  loot_pink: ["pickups/loot-beam", { palette: P.pink }],
  loot_cyan: ["pickups/loot-beam", { palette: P.cyber }],
  loot_white: ["pickups/loot-beam", { palette: P.prism }],
  // --- pacote 2: mais poderes ---
  flame_pillar: ["fire/flame-pillar", { maxT: 2 }],
  flamethrower: ["fire/flamethrower", {}],
  flamethrower_blue: ["fire/flamethrower", { palette: P.ki }],
  flamethrower_black: ["fire/flamethrower", { palette: P.black }],
  fireball_black: ["fire/fireball", { palette: P.black }],
  fireball_pink: ["fire/fireball", { palette: P.pink }],
  geyser: ["water/geyser", { maxT: 2 }],
  whirlpool: ["water/whirlpool", {}],
  splash: ["water/splash", {}],
  water_jet_blue: ["water/water-jet", { palette: P.ice }],
  ice_crystal: ["ice/ice-crystal", {}],
  ice_shatter: ["ice/ice-shatter", {}],
  ice_lance_pink: ["ice/ice-lance", { palette: P.pink }],
  storm_cloud: ["lightning/storm-cloud", {}],
  charge_up: ["lightning/charge-up", { maxT: 1.6 }],
  charge_gold: ["lightning/charge-up", { maxT: 1.6, palette: P.gold }],
  lightning_gold: ["lightning/lightning-strike", { maxT: 1.4, palette: P.volt }],
  lightning_purple: ["lightning/lightning-strike", { maxT: 1.4, palette: P.purple }],
  ball_lightning_gold: ["lightning/ball-lightning", { palette: P.volt }],
  thorns: ["nature/thorns", { maxT: 1.8 }],
  vine_whip: ["nature/vine-whip", {}],
  root_snare: ["nature/root-snare", { maxT: 2 }],
  spore_burst: ["nature/spore-burst", { maxT: 2 }],
  acid_splash: ["nature/acid-splash", { maxT: 2 }],
  boulder: ["nature/boulder", {}],
  emp_blast: ["scifi/emp-blast", {}],
  emp_pink: ["scifi/emp-blast", { palette: P.neon }],
  glitch: ["scifi/glitch", {}],
  hologram: ["scifi/hologram", {}],
  laser_grid: ["scifi/laser-grid", {}],
  energy_core: ["scifi/energy-core", {}],
  warp_out: ["scifi/warp-out", { maxT: 1.6 }],
  arcane_missiles: ["arcane/arcane-missiles", {}],
  portal: ["arcane/portal", {}],
  rune_circle: ["arcane/rune-circle", {}],
  rune_red: ["arcane/rune-circle", { palette: P.blood }],
  magic_circle: ["arcane/magic-circle-cast", { maxT: 2 }],
  spell_charge: ["arcane/spell-charge", {}],
  feather_burst: ["holy/feather-burst", { maxT: 2 }],
  feather_black: ["holy/feather-burst", { maxT: 2, palette: P.black }],
  resurrection: ["holy/resurrection", { maxT: 2.4 }],
  blessing: ["holy/blessing", {}],
  heal_pink: ["holy/heal", { palette: P.pink }],
  holy_pillar_pink: ["holy/holy-pillar", { maxT: 2, palette: P.pink }],
  hex_sigil: ["shadow/hex-sigil", { maxT: 2.4 }],
  necro_skulls: ["shadow/necro-skulls", {}],
  eclipse: ["shadow/eclipse", {}],
  soul_drain: ["shadow/soul-drain", {}],
  curse: ["shadow/curse", { maxT: 2.4 }],
  void_orb_red: ["shadow/void-orb", { palette: P.blood }],
  black_hole_red: ["shadow/black-hole", { palette: P.blood }],
  grenade: ["explosions/grenade", { maxT: 1.6 }],
  nuke: ["explosions/nuke", { maxT: 2.2 }],
  firework: ["explosions/firework-burst", { maxT: 1.8 }],
  smoke_bomb: ["explosions/smoke-bomb", { maxT: 1.8 }],
  big_explosion_blue: ["explosions/big-explosion", { maxT: 1.8, palette: P.ki }],
  ground_slam: ["impacts/ground-slam", { maxT: 1.6 }],
  parry: ["impacts/parry", { fps: 20 }],
  ricochet: ["impacts/ricochet", { fps: 20 }],
  arrow: ["projectiles/arrow", {}],
  arrow_pink: ["projectiles/arrow", { palette: P.pink }],
  bullet: ["projectiles/bullet-tracer", {}],
  rocket: ["projectiles/rocket", {}],
  muzzle_shotgun: ["projectiles/muzzle-shotgun", { maxT: 1.2 }],
  laser_red: ["projectiles/laser-bolt", { palette: P.blood }],
  laser_blue: ["projectiles/laser-bolt", { palette: P.ki }],
  laser_pink: ["projectiles/laser-bolt", { palette: P.pink }],
  disc_pink: ["projectiles/energy-disc", { palette: P.pink }],
  disc_purple: ["projectiles/energy-disc", { palette: P.purple }],
  whip_crack: ["melee/whip-crack", { fps: 20 }],
  spear_sweep: ["melee/spear-sweep", { fps: 20 }],
  slash_purple: ["melee/sword-slash", { fps: 20, palette: P.purple }],
  slash_gold: ["melee/double-slash", { fps: 20, palette: P.gold }],
  slash_pink: ["melee/spin-slash", { fps: 20, palette: P.pink }],
  claw_red: ["melee/claw-swipe", { fps: 20, palette: P.blood }],
  scythe_purple: ["melee/scythe-reap", { fps: 20, palette: P.purple }],
  // criaturas (invocacoes/orbitas)
  bat: ["critters/bat", {}],
  ghost: ["critters/ghost", {}],
  snake: ["critters/snake", {}],
  wisp: ["critters/wisp", {}],
  wisp_pink: ["critters/wisp", { palette: P.pink }],
  flying_skull: ["critters/flying-skull", {}],
  butterfly: ["critters/butterfly", {}],
  // status novos
  st_cursed: ["status/cursed", {}],
  st_charmed: ["status/charmed", {}],
  st_confused: ["status/confused", {}],
  st_sleep: ["status/sleep", {}],
  st_petrified: ["status/petrified", { maxT: 2 }],
  aura_red: ["status/rage", { palette: P.blood }],
  aura_pink: ["status/rage", { palette: P.pink }],
  aura_white: ["status/rage", { palette: P.prism }],
  aura_cyan: ["status/rage", { palette: P.cyber }],
};

const OUT = join(PROJECT, "assets", "fx");
mkdirSync(OUT, { recursive: true });
const DATA_FILE = join(PROJECT, "scripts", "data", "fx_data.gd");
mkdirSync(dirname(DATA_FILE), { recursive: true });

// mantem o que ja foi exportado quando so alguns nomes forem passados
let data = {};
const META_JSON = join(OUT, "_meta.json");
if (existsSync(META_JSON)) data = JSON.parse(readFileSync(META_JSON, "utf8"));

const only = process.argv.slice(2);
const names = only.length ? only : Object.keys(FX);
const MAX_W = 2048;
let totalPx = 0;

for (const name of names) {
  const [id, o] = FX[name] ?? [];
  if (!id) { console.error(`?? ${name}`); continue; }
  try {
    const fx = await loadEffect(id, join(PFX, "src", "fx"));
    const options = { ...(o.opts ?? {}) };
    if (o.palette) options.palette = o.palette;
    const fps = o.fps ?? 15;
    const r = renderFrames(fx, { fps, bg: "none", actor: false, seed: o.seed, options });
    let frames = r.frames;
    if (o.maxT) frames = frames.filter((f) => f.t <= o.maxT + 1e-6);
    // tira frames vazios do fim
    const empty = (f) => { for (let i = 3; i < f.clear.length; i += 4) if (f.clear[i] > 8) return false; return true; };
    while (frames.length > 1 && empty(frames[frames.length - 1])) frames.pop();
    // bbox da uniao
    let x0 = r.w, y0 = r.h, x1 = -1, y1 = -1;
    for (const f of frames) {
      const c = f.clear;
      for (let y = 0; y < r.h; y++) for (let x = 0; x < r.w; x++) {
        if (c[(y * r.w + x) * 4 + 3] > 8) { if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y; }
      }
    }
    if (x1 < 0) { x0 = 0; y0 = 0; x1 = 1; y1 = 1; }
    x0 = Math.max(0, x0 - 1); y0 = Math.max(0, y0 - 1); x1 = Math.min(r.w - 1, x1 + 1); y1 = Math.min(r.h - 1, y1 + 1);
    const fw = x1 - x0 + 1, fh = y1 - y0 + 1, n = frames.length;
    const cols = Math.max(1, Math.min(n, Math.floor(MAX_W / fw), Math.ceil(Math.sqrt(n * fh / fw))));
    const rows = Math.ceil(n / cols), W = cols * fw, H = rows * fh;
    const img = new Uint8ClampedArray(W * H * 4);
    frames.forEach((f, i) => {
      const cx = (i % cols) * fw, cy = Math.floor(i / cols) * fh;
      for (let y = 0; y < fh; y++) for (let x = 0; x < fw; x++) {
        const s = ((y + y0) * r.w + (x + x0)) * 4, d = ((cy + y) * W + (cx + x)) * 4;
        img[d] = f.clear[s]; img[d + 1] = f.clear[s + 1]; img[d + 2] = f.clear[s + 2]; img[d + 3] = f.clear[s + 3];
      }
    });
    writeFileSync(join(OUT, name + ".png"), encodePNG(W, H, img));
    const [ox, oy] = fx.meta.origin;
    data[name] = { w: fw, h: fh, cols, n, fps, loop: !!fx.meta.loop, px: ox - x0, py: oy - y0, src: id };
    totalPx += W * H;
    console.log(`${name.padEnd(18)} ${id.padEnd(28)} ${n}f ${fw}x${fh} sheet ${W}x${H}`);
  } catch (e) {
    console.error(`${name} FALHOU: ${e.stack ?? e}`);
  }
}
writeFileSync(META_JSON, JSON.stringify(data));

// gera o GDScript com os metadados
const lines = Object.entries(data).sort().map(([k, v]) =>
  `\t"${k}": {"w": ${v.w}, "h": ${v.h}, "cols": ${v.cols}, "n": ${v.n}, "fps": ${v.fps}, "loop": ${v.loop}, "px": ${v.px}, "py": ${v.py}},`);
writeFileSync(DATA_FILE,
  `# GERADO por tools/export_fx.mjs a partir do pixelfx - nao edite a mao.\nclass_name FxData\n\nconst D := {\n${lines.join("\n")}\n}\n`);
console.log(`ok: ${Object.keys(data).length} efeitos, ${(totalPx * 4 / 1048576).toFixed(1)} MB RGBA nesta exportacao`);

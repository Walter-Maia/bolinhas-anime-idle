#!/usr/bin/env node
// Gera os sons do jogo (WAV 16-bit mono 22050 Hz) em assets/audio. Sintese simples em codigo, sem assets externos.
//   node tools/gen_audio.mjs
import { writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const SR = 22050;
const OUT = join(dirname(fileURLToPath(import.meta.url)), "..", "assets", "audio");
mkdirSync(OUT, { recursive: true });

function wav(name, samples) {
  const n = samples.length, buf = Buffer.alloc(44 + n * 2);
  buf.write("RIFF", 0); buf.writeUInt32LE(36 + n * 2, 4); buf.write("WAVE", 8); buf.write("fmt ", 12);
  buf.writeUInt32LE(16, 16); buf.writeUInt16LE(1, 20); buf.writeUInt16LE(1, 22); buf.writeUInt32LE(SR, 24);
  buf.writeUInt32LE(SR * 2, 28); buf.writeUInt16LE(2, 32); buf.writeUInt16LE(16, 34); buf.write("data", 36); buf.writeUInt32LE(n * 2, 40);
  for (let i = 0; i < n; i++) buf.writeInt16LE(Math.max(-1, Math.min(1, samples[i])) * 30000 | 0, 44 + i * 2);
  writeFileSync(join(OUT, name + ".wav"), buf);
}
const len = (s) => new Float32Array(Math.floor(s * SR));
let seed = 7;
const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647) * 2 - 1;
const osc = {
  sq: (p, duty = 0.5) => ((p % 1) < duty ? 1 : -1),
  tri: (p) => 1 - 4 * Math.abs((p % 1) - 0.5),
  sin: (p) => Math.sin(p * Math.PI * 2),
  saw: (p) => 2 * (p % 1) - 1,
};
// tom com envelope ADSR simples e glissando
function tone(buf, t0, dur, f0, f1, vol, wave = "sq", duty = 0.5, a = 0.005, r = 0.6) {
  const s0 = Math.floor(t0 * SR), n = Math.floor(dur * SR);
  let ph = 0;
  for (let i = 0; i < n && s0 + i < buf.length; i++) {
    const k = i / n, f = f0 + (f1 - f0) * k;
    ph += f / SR;
    const env = Math.min(1, i / (a * SR + 1)) * (k < 1 - r ? 1 : (1 - k) / r);
    buf[s0 + i] += osc[wave](ph, duty) * vol * env;
  }
}
function noise(buf, t0, dur, vol, lp = 0.5) {
  const s0 = Math.floor(t0 * SR), n = Math.floor(dur * SR);
  let y = 0;
  for (let i = 0; i < n && s0 + i < buf.length; i++) {
    y += (rnd() - y) * lp;
    buf[s0 + i] += y * vol * (1 - i / n);
  }
}
const N = { C: 0, D: 2, E: 4, F: 5, G: 7, A: 9, B: 11 };
const freq = (note) => { const m = note.match(/([A-G])(#?)(\d)/); return 440 * Math.pow(2, (N[m[1]] + (m[2] ? 1 : 0) + (+m[3] - 4) * 12 - 9) / 12); };

// ---------- efeitos
let b;
b = len(0.06); tone(b, 0, 0.06, 1400, 1100, 0.35, "sq", 0.25); wav("click", b);
b = len(0.12); noise(b, 0, 0.09, 0.6, 0.6); tone(b, 0, 0.1, 180, 70, 0.5, "tri"); wav("hit", b);
b = len(0.08); noise(b, 0, 0.06, 0.35, 0.9); tone(b, 0, 0.06, 900, 500, 0.2, "sq", 0.3); wav("hit_weapon", b);
b = len(0.25); noise(b, 0, 0.12, 0.7, 0.7); tone(b, 0, 0.22, 900, 300, 0.4, "sq", 0.3); tone(b, 0.02, 0.2, 1800, 600, 0.2, "sq", 0.2); wav("crit", b);
b = len(0.32); tone(b, 0, 0.3, 300, 1200, 0.32, "sq", 0.4); tone(b, 0.05, 0.25, 600, 2000, 0.18, "tri"); wav("skill", b);
b = len(0.6); noise(b, 0, 0.5, 0.8, 0.25); tone(b, 0, 0.5, 120, 40, 0.6, "tri"); wav("explosion", b);
b = len(0.2); tone(b, 0, 0.08, freq("B5"), freq("B5"), 0.3, "sq", 0.25); tone(b, 0.07, 0.13, freq("E6"), freq("E6"), 0.3, "sq", 0.25); wav("coin", b);
b = len(0.5); noise(b, 0, 0.12, 0.4, 0.5); ["C5", "E5", "G5", "C6"].forEach((n, i) => tone(b, 0.1 + i * 0.07, 0.2, freq(n), freq(n), 0.25, "tri")); wav("chest", b);
b = len(0.35); tone(b, 0, 0.35, 70, 90, 0.5, "tri"); noise(b, 0, 0.35, 0.25, 0.1); wav("shake", b);
b = len(0.8); noise(b, 0, 0.2, 0.5, 0.8); ["C5", "G5", "C6", "E6", "G6"].forEach((n, i) => tone(b, 0.05 + i * 0.06, 0.4, freq(n), freq(n), 0.22, "sq", 0.25)); wav("open", b);
b = len(1.4); ["C5", "E5", "G5", "C6", "E6", "G6", "C7"].forEach((n, i) => tone(b, i * 0.08, 0.6, freq(n), freq(n), 0.2, "sq", 0.3)); tone(b, 0.6, 0.8, freq("C6"), freq("C6"), 0.25, "tri"); wav("fanfare", b);
b = len(0.9); ["G4", "C5", "E5", "G5", "C6"].forEach((n, i) => tone(b, i * 0.1, 0.35, freq(n), freq(n), 0.25, "sq", 0.5)); wav("levelup", b);
b = len(1.0); ["C5", "E5", "G5"].forEach((n, i) => tone(b, i * 0.12, 0.2, freq(n), freq(n), 0.25, "sq", 0.5)); tone(b, 0.38, 0.6, freq("C6"), freq("C6"), 0.28, "sq", 0.5); wav("win", b);
b = len(0.9); ["G4", "E4", "C4"].forEach((n, i) => tone(b, i * 0.18, 0.3, freq(n), freq(n) * 0.97, 0.25, "tri")); wav("lose", b);
b = len(0.4); tone(b, 0, 0.4, 200, 900, 0.3, "saw"); noise(b, 0.1, 0.3, 0.3, 0.4); wav("transform", b);
b = len(0.15); tone(b, 0, 0.15, 900, 1400, 0.22, "tri"); wav("heal", b);
b = len(0.18); tone(b, 0, 0.18, 500, 200, 0.25, "sq", 0.5); noise(b, 0, 0.1, 0.2, 0.9); wav("swoosh", b);

// ---------- musicas (loops)
function song(name, bpm, lead, bass, bars, vol = 0.12) {
  const beat = 60 / bpm, total = bars * 4 * beat, buf = len(total);
  // lead: string de notas por colcheia ("C5 . E5 G5 ..."), "." = pausa
  const ln = lead.trim().split(/\s+/), bn = bass.trim().split(/\s+/);
  for (let i = 0; i < bars * 8; i++) {
    const n = ln[i % ln.length]; if (n !== ".") tone(buf, i * beat / 2, beat / 2 * 0.9, freq(n), freq(n), vol, "sq", 0.25, 0.005, 0.5);
  }
  for (let i = 0; i < bars * 4; i++) {
    const n = bn[i % bn.length]; if (n !== ".") tone(buf, i * beat, beat * 0.95, freq(n), freq(n), vol * 1.2, "tri", 0.5, 0.01, 0.3);
  }
  for (let i = 0; i < bars * 8; i++) noise(buf, i * beat / 2, 0.03, i % 2 === 0 ? 0.08 : 0.04, 0.9);
  wav(name, buf);
}
song("music_home", 104,
  "E5 . G5 A5 G5 E5 D5 . C5 . D5 E5 G5 . E5 . A5 . G5 E5 D5 C5 D5 . E5 . D5 C5 A4 . C5 .",
  "C3 G3 A2 E3 F2 C3 G2 D3", 8, 0.1);
song("music_battle", 140,
  "A4 C5 E5 A5 G5 E5 C5 E5 F4 A4 C5 F5 E5 C5 A4 C5 G4 B4 D5 G5 F5 D5 B4 D5 E5 . E5 G5 A5 . B5 .",
  "A2 A2 F2 F2 G2 G2 E2 E2", 8, 0.1);
console.log("ok audio ->", OUT);

# Bolinhas Anime Idle

Idle mobile (Godot 4.7, retrato) em que personagens de anime viram **bolinhas sem rosto** que quicam sozinhas pela
arena com uma **arma girando em volta**, causando dano ao encostar e soltando skills inspiradas nos animes.

**Jogar no navegador (celular ou PC):** https://walter-maia.github.io/bolinhas-anime-idle/
**Baixar (APK Android / Windows):** aba [Releases](https://github.com/Walter-Maia/bolinhas-anime-idle/releases)

## Conteúdo
- **Mais de 860 bolinhas de ~90 animes** (e crescendo), 9 raridades: Comum → Incomum → Raro → Épico → Lendário →
  Mítico → Divino → Celestial → Transcendente, com formas evoluídas nomeadas.
- **Combate**: bolinhas quicam pelas paredes (sem perseguir), armas orbitando (37 tipos), 28 tipos de skill
  (projétil, feixe, sopro, domínio, órbita, gancho, teleporte, cópia, aposta...), 15 tipos de passiva,
  13 status, transformações com aura e versões "alt" das skills. Efeitos no estilo fofo desenhados em código.
- **Modo História**: 32 capítulos (um por anime) com mapa de 20 fases, diálogos, tela VS e chefe por capítulo;
  depois do último capítulo recomeça em Difícil / Pesadelo / Inferno.
- **Modos**: Chefes (32), Torre Infinita, Masmorras diárias, PvP, Expedições (bolinhas fora de campo trazem
  prêmios), Horda Sem Fim e Desafio Diário com regras especiais.
- **Evolução**: nível (moedas), estrelas (cópias), subir raridade exige cópias + cristais + derrotar um chefe.
- **Equipamentos do jogador** (9 espaços, valem para qualquer bolinha em campo), **30 conjuntos lendários** com
  bônus de 2/4/6 peças, forja.
- **Gacha** com banners liberados pela história, banner de evento semanal, pity e animação de abertura.
- **Metas**: missões diárias, conquistas, login de 7 dias, recompensa por completar a coleção de um anime.
- Save automático, 3 espaços de save e backup por código. Som e música gerados em código.
- Compras em **modo teste** (nada é cobrado); a integração real exige o plugin Google Play Billing.

## Estrutura
```
scripts/core/       db (dados/carregador), game (estado/regras), ball_art (arte das bolinhas), ui, audio, billing
scripts/data/       balls_*.gd (bolinhas), world*.gd (capítulos/chefes/banners), items.gd (conjuntos)
scripts/battle/     batalha, unidade, skills, armas, efeitos fofos (cute_fx), projéteis, órbitas, zonas
scripts/ui/         tela principal, história, coleção, gacha, telas e popups
docs/CONTENT_SPEC.md   especificação para criar bolinhas novas (visual, armas, skills, efeitos)
tools/              qa.gd, balance.gd, sheet.gd, bake_balls.gd, artcheck.gd, gen_audio.mjs, export_fx.mjs, publish.sh
third_party/pixelfx/   base de efeitos (MIT) usada nas recompensas e no pipeline de sprites
```

## Ferramentas
```
godot --headless --path . --script res://tools/qa.gd                 # valida e simula todas as bolinhas
godot --headless --path . --script res://tools/balance.gd            # ritmo de progressão
godot --headless --path . --script res://tools/sheet.gd -- out.png file:balls_b 8 0 40   # folha de visuais
godot --headless --path . --script res://tools/bake_balls.gd         # pré-gera as texturas
bash tools/publish.sh v0.x.y "notas"                                 # QA + exports + Pages + release
```

Nomes de personagens e golpes são paródias. Efeitos: pixelfx (MIT). Fonte: Pixelify Sans (OFL).

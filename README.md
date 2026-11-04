# Bolinhas Anime Idle (Godot 4.7, mobile retrato)

Idle de bolinhas com poderes inspirados em animes. Uma bolinha ativa por vez luta sozinha numa arena,
quicando e usando skills; o baú dá equipamentos (que não aparecem na bolinha) e às vezes bolinhas novas.

## Rodar
Abra a pasta no Godot 4.7 e aperte F5. A janela de teste é 450x800 (o jogo é 720x1280 em retrato).

## O que tem
- **32 bolinhas** em 6 raridades (Comum → Mítico), cada uma com skills ativas e passivas próprias,
  transformações com pouca vida (ex.: Manto da Raposa deixa a Esfera Espiral vermelha, mais forte e mais rápida)
  e **formas evoluídas** com nome próprio (ex.: "Modo Sábio").
- **Skills que melhoram com a raridade**: mais dano, mais projéteis/golpes, menos recarga, e skills/passivas
  extras que só **desbloqueiam** em raridades altas.
- **Evolução** (aba Bolinhas → detalhes):
  - nível (moedas) e estrelas (fragmentos = cópias da mesma bolinha);
  - **subir de raridade** exige: 5 estrelas + fragmentos + **cristais de evolução** (baú, masmorras, chefes, torre)
    + **derrotar um chefe específico** no Modo Chefes + moedas.
- **Equipamentos** em 9 espaços (arma corpo a corpo/à distância, armadura, elmo, amuleto, asas, luvas, botas, cinto, anel),
  raridade, nível e atributos extras. Baú com nível, Auto (equipa o melhor e vende o pior).
- **Modos**: História (capítulos com chefes), Chefes (desbloqueiam por nível da conta), Torre Infinita,
  Masmorras diárias (ouro, chaves, fragmentos/cristais), PvP assíncrono, ganhos idle/offline (ampulheta).
- **Gacha** com chances visíveis e garantia (pity), **Loja** com pacotes de gemas, VIP e presente diário.

## Estrutura
```
scripts/core/db.gd         dados: raridades, bolinhas, skills, chefes, capítulos, loja  <- adicione bolinhas aqui
scripts/core/game.gd       estado, save, evolução, baú, gacha, modos (autoload "Game")
scripts/core/ball_art.gd   arte HD das bolinhas gerada em código (cabelo, olhos, acessórios)
scripts/core/pixel_art.gd  ícones pixel da UI
scripts/core/billing.gd    compras (autoload "Billing")
scripts/battle/            arena, unidade, skills, projéteis, efeitos
scripts/ui/                tela principal e menus
assets/fx/                 sprite sheets dos efeitos (geradas do pixelfx)
third_party/pixelfx/       repositório base dos efeitos (ignorado pelo Godot)
tools/export_fx.mjs        exporta/recolore efeitos do pixelfx para assets/fx
```

### Nova bolinha
Copie um bloco em `DB.BALLS`. O visual sai do campo `look` (base, hair, hair_style, eyes, eye_color, extras,
lower...). Skills usam os tipos documentados no topo do `db.gd`.

### Novo efeito visual
Adicione uma linha em `FX` no `tools/export_fx.mjs` (id do pixelfx + paleta opcional) e rode
`node tools/export_fx.mjs <nome>`. Depois use o nome no campo `fx` de uma skill.

### Capturas de teste (dev)
`Godot_console.exe --path . -- --shot=C:/tmp/a.png --wait=6 --give --use=monarca --stage=2-10 --screen=balls`

## Para publicar (Android)
1. Editor → Projeto → Exportar → instale os *export templates* e configure o Android SDK/JDK.
2. **Compras reais**: instale o plugin oficial GodotGooglePlayBilling, crie no Play Console produtos com os mesmos
   ids de `DB.IAP` e **valide os recibos num servidor** antes de entregar as gemas. Sem o plugin a loja roda em MODO TESTE.
3. **PvP online** e anti-trapaça precisam de backend (o save hoje é local em `user://save.json`).
4. Os nomes são paródias ("Shinobi da Raposa", "Esfera Espiral"...). Evite nomes, personagens e logos oficiais
   de animes, senão a loja pode remover o app por direitos autorais.

Efeitos: pixelfx (MIT) — ver `third_party/pixelfx/LICENSE` e `NOTICE.md`. Fonte: Pixelify Sans (OFL).

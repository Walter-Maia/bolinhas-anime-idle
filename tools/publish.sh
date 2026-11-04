#!/usr/bin/env bash
# Pipeline de publicacao: QA -> bake -> export (web, android, windows) -> commit/push -> GitHub Pages -> release.
#   bash tools/publish.sh v0.3.1 "Notas curtas da versao"
set -e
VER="$1"; NOTES="$2"
G="/c/Users/walti/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
ROOT="/c/Users/walti/OneDrive/Documentos/jogo-bolinha"
cd "$ROOT"

echo "== QA"
timeout 1500 "$G" --headless --path . --script res://tools/qa.gd > build/qa.log 2>&1 || true
grep -E "^QA|validacao|simulacao" build/qa.log
ERR=$(grep -c "SCRIPT ERROR" build/qa.log || true)
echo "erros de script: $ERR"
if [ "$ERR" != "0" ]; then echo "QA falhou, abortando"; exit 1; fi

echo "== bake"
timeout 900 "$G" --headless --path . --script res://tools/bake_balls.gd 2>&1 | grep bake
timeout 600 "$G" --headless --path . --import > /dev/null 2>&1

echo "== export"
timeout 900 "$G" --headless --path . --export-release "Web" build/web/index.html > /dev/null 2>&1
timeout 900 "$G" --headless --path . --export-release "Android" build/android/BolinhasAnimeIdle.apk > /dev/null 2>&1
timeout 900 "$G" --headless --path . --export-release "Windows" build/windows/BolinhasAnimeIdle.exe > /dev/null 2>&1
ls -la build/web/index.pck build/android/BolinhasAnimeIdle.apk build/windows/BolinhasAnimeIdle.exe

echo "== git"
git add -A
git -c user.name="Walter-Maia" -c user.email="waltinholuizpb@gmail.com" commit -q -m "$VER: $NOTES

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" || true
git push -q

echo "== pages"
P="$ROOT/build/pages"
rm -rf "$P"; mkdir -p "$P"; cp -r build/web/. "$P/"; touch "$P/.nojekyll"
( cd "$P" && git init -q && git checkout -q -b gh-pages && git add -A && git -c user.name="Walter-Maia" -c user.email="waltinholuizpb@gmail.com" commit -q -m "web $VER" && git remote add origin https://github.com/Walter-Maia/bolinhas-anime-idle.git && git push -q -f origin gh-pages )

echo "== release"
cd build
cp android/BolinhasAnimeIdle.apk BolinhasAnimeIdle-Android.apk
powershell -NoProfile -Command "Compress-Archive -Force -Path windows\\BolinhasAnimeIdle.exe -DestinationPath BolinhasAnimeIdle-Windows.zip; Compress-Archive -Force -Path web\\* -DestinationPath BolinhasAnimeIdle-Web.zip"
printf '%s\n\n**Android:** baixe o APK e instale (permita fontes desconhecidas).\n**Navegador:** https://walter-maia.github.io/bolinhas-anime-idle/\n**Windows:** extraia o zip e abra o .exe.\n\n🤖 Generated with [Claude Code](https://claude.com/claude-code)\n' "$NOTES" > notes.md
gh release create "$VER" BolinhasAnimeIdle-Android.apk BolinhasAnimeIdle-Windows.zip BolinhasAnimeIdle-Web.zip --repo Walter-Maia/bolinhas-anime-idle --title "Bolinhas Anime Idle $VER" --notes-file notes.md
echo "== ok $VER"

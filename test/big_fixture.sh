#!/bin/bash
# 大量テスト用フィクスチャ生成 (日本語・英語・記号混在、約460件)。
# 使い捨て想定。既定 /tmp/tff-big、毎回作り直し (冪等・決定的)。
# 使い方: ./test/big_fixture.sh [DIR] → cd DIR → vim で :Tff
set -eu

ROOT="${1:-/tmp/tff-big}"
rm -rf "$ROOT"
mkdir -p "$ROOT"
cd "$ROOT"

t() { touch -- "$1"; }

# --- 構造 ---
mkdir -p docs/設計書 docs/議事録 docs/日報 \
  src/components src/utils src/コンポーネント \
  symbols "space dir/inner space" \
  legacy/.git/objects/pack \
  深い/階層/の/さらに/奥 logs data/dotfiles

# --- 日本語 ---
t docs/設計書/要件定義書_v2.3_最終版_改訂3.md
t docs/設計書/基本設計_画面一覧.xlsx
t docs/設計書/API仕様書_詳細設計.md
t docs/設計書/レビュー指摘_#42_未対応分.txt
t docs/日報/日報_山田太郎.txt
t src/コンポーネント/お知らせバナー.jsx
t src/コンポーネント/利用規約ダイアログ.vue
t src/utils/日付フォーマット.py
t 深い/階層/の/さらに/奥/最深部ファイル_到達確認.txt
t "全角＿Ｔｅｓｔ＿ファイル．ｔｘｔ"
t ひらがな_あいうえお_かきくけこ.txt
t カタカナ_アイウエオ_サシスセソ.md

# --- 英語 (表記ゆれ・拡張子いろいろ) ---
t README.md
t Readme.txt
t readme_lower.md
t CHANGELOG.md
t Makefile
t makefile.local
t Dockerfile
t docker-compose.yml
t src/components/UserProfile.vue
t src/components/user-profile.test.js
t src/components/UserProfileStories.jsx
t src/utils/string-utils.ts
t src/utils/StringUtils_test.py

# --- 記号・空白・edge ---
t "symbols/space in name.txt"
t "symbols/[brackets].md"
t "symbols/(parens).txt"
t "symbols/{braces}.log"
t "symbols/a+b=c.txt"
t "symbols/100%_coverage.txt"
t "symbols/price_¥1,000.md"
t "symbols/semi;colon.txt"
t "symbols/quote'file.txt"
t symbols/-leading-dash.txt
t 'symbols/back\slash.txt'
t symbols/under_score__double.txt
t symbols/dot.dot.dot.md
t symbols/★重要★_タスク.txt
t symbols/→_next_steps.md
t "symbols/※注意※_免責事項.txt"
t symbols/♥_favorite.md
t symbols/📝_絵文字メモ.md
t "space dir/inner space/white  space  file.txt"

# --- dotfiles (列挙されるか観察用) ---
t data/dotfiles/.hidden_config
t data/dotfiles/.env.sample
t .root_hidden

# --- .git除外の確認用 (表示されないはず) ---
t legacy/.git/objects/pack/pack-abc123.pack
t legacy/.git/COMMIT_EDITMSG
t legacy/移行メモ.txt

# --- 量産 (決定的・連番) ---
for i in $(seq -w 1 60); do t "docs/日報/日報_山田_$i.txt"; done
for i in $(seq -w 1 30); do t "docs/議事録/2024-02-${i}_定例_第${i}回.md"; done
for i in $(seq -w 1 40); do t "src/components/Button_$i.vue"; t "src/components/ボタン_$i.jsx"; t "src/components/★widget-$i.ts"; done
for i in $(seq -w 1 100); do t "logs/app-2024-03-$i.log"; done
for i in $(seq -w 1 50); do t "data/data_$i.json"; t "data/設定_$i.yaml"; done

n=$(find "$ROOT" -type f | wc -l)
d=$(find "$ROOT" -type d | wc -l)
echo "generated: $n files, $d dirs under $ROOT"
echo 'try: cd '"$ROOT"' && vim (then :Tff; e.g. queries: 議事 / ★ / user / space / .hidden)'

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

echo "[tdd-green-with-jscpd] Running /tdd-green"
claude -p "/tdd-green" | cat
echo "[tdd-green-with-jscpd] /tdd-green finished"

echo "[tdd-green-with-jscpd] Running jscpd after green"
J_OUT=""
if [ -d "$repo_root/frontend" ]; then
  set +e
  J_OUT=$(cd "$repo_root/frontend" && npm run -s dup 2>&1)
  J_EXIT=$?
  set -e
  echo "$J_OUT"
  echo "[tdd-green-with-jscpd] Generating HTML report"
  ( cd "$repo_root/frontend" && npm run -s dup:report ) || true
else
  J_OUT="frontend directory not found"
  J_EXIT=0
fi

PROMPT=$(cat <<'EOF'
次の jscpd 実行結果は、/tdd-green の実装直後に計測したものです。
この結果を踏まえて、重複コードのホットスポットがないか確認し、必要なら最小限の追加リファクタ候補を提案してください。
（すぐに手を入れるべき箇所/後回しで良い箇所を分けてください）

jscpd 出力:
EOF
)

PROMPT="$PROMPT
```
$J_OUT
```

備考: HTML レポートは reports/jscpd/html/index.html に保存済み。"

echo "[tdd-green-with-jscpd] Asking Claude to review jscpd output"
claude -p "$PROMPT" | cat

echo "[tdd-green-with-jscpd] Done"



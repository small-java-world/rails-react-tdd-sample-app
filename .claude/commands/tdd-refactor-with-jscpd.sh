#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

echo "[tdd-refactor-with-jscpd] Baseline jscpd before refactor"
BASE_OUT=""
if [ -d "$repo_root/frontend" ]; then
  set +e
  BASE_OUT=$(cd "$repo_root/frontend" && npm run -s dup 2>&1)
  BASE_EXIT=$?
  set -e
  echo "$BASE_OUT"
else
  BASE_OUT="frontend directory not found"
  BASE_EXIT=0
fi

BASE_PROMPT=$(cat <<'EOF'
以下は /tdd-refactor 開始前の jscpd 結果です。重複の発生箇所を要約し、優先度順にリファクタ対象を洗い出してください。
（変更規模が小さく効果が大きい箇所を上位に）

前ベース jscpd 出力:
EOF
)
BASE_PROMPT="$BASE_PROMPT
```
$BASE_OUT
```
"

echo "[tdd-refactor-with-jscpd] Asking Claude for refactor plan based on baseline"
claude -p "$BASE_PROMPT" | cat

echo "[tdd-refactor-with-jscpd] Running /tdd-refactor"
claude -p "/tdd-refactor" | cat
echo "[tdd-refactor-with-jscpd] /tdd-refactor finished"

echo "[tdd-refactor-with-jscpd] jscpd after refactor"
AFTER_OUT=""
if [ -d "$repo_root/frontend" ]; then
  set +e
  AFTER_OUT=$(cd "$repo_root/frontend" && npm run -s dup 2>&1)
  AFTER_EXIT=$?
  set -e
  echo "$AFTER_OUT"
  echo "[tdd-refactor-with-jscpd] Generating HTML report"
  ( cd "$repo_root/frontend" && npm run -s dup:report ) || true
else
  AFTER_OUT="frontend directory not found"
  AFTER_EXIT=0
fi

AFTER_PROMPT=$(cat <<'EOF'
以下は /tdd-refactor 完了後の jscpd 結果です。リファクタリングによる重複削減効果を定量的に評価し、残課題があれば次のイテレーションでの対応案を提示してください。

事後 jscpd 出力:
EOF
)
AFTER_PROMPT="$AFTER_PROMPT
```
$AFTER_OUT
```

備考: HTML レポートは reports/jscpd/html/index.html に保存済み。"

echo "[tdd-refactor-with-jscpd] Asking Claude to evaluate improvements"
claude -p "$AFTER_PROMPT" | cat

echo "[tdd-refactor-with-jscpd] Done"



# /kairo-tasks 生成時に適用するルール（jscpd 連動）

適用条件
- tsumiki のカスタムスラッシュコマンド `/kairo-tasks` を実行して、タスク文書（例: `docs/tasks/<feature>-tasks.md`）を生成する際

目的
- 生成されたタスクを TDD サイクルに沿って実行する間、jscpd を計画的に使い、Claude の判断材料とする

必須指針（生成文書に反映されるべき観点）
- jscpd 実行タイミング（TDD 連動）を明示する
  - `/tdd-green` の直後
  - `/tdd-refactor` の開始前
  - `/tdd-refactor` の完了後（HTML レポートで効果検証）
- 実行手順の最小例を示す（過度に長くしない）
  - `cd frontend && npm run dup && npm run dup:report`
  - レポート出力: `reports/jscpd/html/index.html`
- tsumiki カスタムコマンド（任意の近道）を案内する
  - `/tdd-green-with-jscpd`: Green 後に jscpd 実行 → Claude に要約を依頼
  - `/tdd-refactor-with-jscpd`: Refactor 前後で jscpd 実行 → 事前計画/事後評価を依頼
- 生成文書内で重複を避ける
  - 同等のセクションが既に存在する場合は新設しない

禁止事項
- `.claude/commands/*`（配布テンプレ）の直接改変
- 自動スクリプトで生成物を改変（ポストプロセス）

備考
- 上記は「生成時に考慮すべき指針」。実行自体はプロジェクトルートで `claude -p "/<command>"` により行う

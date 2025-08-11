# CLAUDE ガイドライン（/kairo-tasks 連携: jscpd + レビュー依頼）

このプロジェクトでは、Tsumiki 配布のコマンド定義（`.claude/commands/*`）や生成物（`docs/tasks/*.md`）は直接変更しません。

本プロジェクトでは、jscpd を TDD サイクルと連動させ、tsumiki/Claude Code が結果を見て次の作業を行う流れにします。

- /tdd-green の実行「直後」に jscpd を実行し、その結果を Claude に渡してホットスポット確認と軽微な改善方針を得る
- /tdd-refactor の「開始前」に jscpd を実行し、現状の重複を基準化してリファクタ計画を得る
- /tdd-refactor の「完了後」に jscpd を実行し、削減効果を確認して残課題を抽出する

## 1) jscpd 重複コードチェック（TDD 連動）

最小の実行手順と出力先を示すこと。必要以上に長くしないこと。詳細ルールは「docs/rules/kairo-tasks-jscpd-rules.md」を参照してください。

```bash
cd frontend
npm run dup
npm run dup:report  # reports/jscpd/html/index.html
```

補足（短文）:
- `dup` は `src` と `../backend` を対象に実行します
- 閾値・除外パターンは `frontend/package.json` の `dup:*` で調整
 - 実行タイミング（推奨）:
   - `/tdd-green` 完了“直後”に実行（新規実装による重複が出ていないか確認）
   - `/tdd-refactor` “開始前”に実行（現状の重複を基準化）
   - `/tdd-refactor` “完了後”に実行（重複削減の効果を HTML レポートで検証）

## 2) Cursor レビュー依頼テンプレート（全タスク共通）

各タスク（見出し `#### TASK-xxx:`）について、以下の 2 種類の簡潔なテンプレートを生成すること。
- `/tdd-green` 用
- `/tdd-refactor` 用

テンプレートはコピペしやすいプレーンテキストのコードブロック（```text）で出力。

例（TASK-００１; 他タスクも同形式で番号のみ差し替え）:

#### TASK-００１ /tdd-green 用
```text
TASK-００１ に対する /tdd-green の成果物をレビューしてください。

対象:
- 機能: ユーザープリファレンス UI の最小実装（Theme / Refresh Interval / Display Density）
- 変更ファイル（例）:
  - frontend/src/UserPreferences.jsx
  - frontend/src/UserPreferences.test.jsx

確認観点:
- 要件の満たし方
- Red → Green の成立（テストの妥当性）
- 命名・責務分割・可読性
```

#### TASK-００１ /tdd-refactor 用
```text
TASK-００１ に対する /tdd-refactor の成果物をレビューしてください。

対象:
- 重複排除・命名改善・責務整理のリファクタリング

確認観点:
- 動作維持（テストはグリーン）
- 重複削減・見通し・拡張性
```

注意:
- タスクは文書中の `#### TASK-(\d{3,}):` を列挙して自動生成（TASK-００１〜の全件）
- 見出しと順序は既存文書に合わせる
- 既に当該セクションが存在する場合は再生成しない

---

メンテナンス方針:
- `.claude/commands/*` は変更しない
- 本ガイド内の方針に従って、/kairo-tasks の出力（`docs/tasks/*.md`）へ必要最小限のセクションを含める

補助コマンド（任意）:
- `/tdd-green-with-jscpd`: /tdd-green 実行後に jscpd 実行 → 結果を Claude に渡して確認
- `/tdd-refactor-with-jscpd`: /tdd-refactor 前後で jscpd 実行 → 事前計画と事後評価を Claude に渡して確認

## タスク実行ガイド（参照用）

- 実行場所: リポジトリのルート
- 1タスクあたりの流れ（例: TASK-001）
  1. 要件・テスト雛形: `claude -p "/tdd-requirements"` → `claude -p "/tdd-testcases"`
  2. Red: `claude -p "/tdd-red"`
  3. Green + 重複チェック: `claude -p "/tdd-green-with-jscpd"`
  4. Refactor（前後で重複計測）: `claude -p "/tdd-refactor-with-jscpd"`
  5. 完了確認: `claude -p "/tdd-verify-complete"`

- レポート: `reports/jscpd/html/index.html`

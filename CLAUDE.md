# CLAUDE ガイドライン（/kairo-tasks 連携: jscpd + レビュー依頼）

このプロジェクトでは、Tsumiki 配布のコマンド定義（`.claude/commands/*`）や生成物（`docs/tasks/*.md`）は直接変更しません。

代わりに、/kairo-tasks を実行した際に生成される `docs/tasks/<feature>-tasks.md` に、以下のセクションを必ず含めてください。

- 挿入位置: 「実行コマンド例」セクションの直後（見出し `##`/`###` を問わず）。該当見出しがない場合は、文書末尾に追加。
- 二重挿入の回避: 同一見出しが既に存在する場合は重複させない。

## 1) jscpd 重複コードチェック

最小の実行手順と出力先を示すこと。必要以上に長くしないこと。

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

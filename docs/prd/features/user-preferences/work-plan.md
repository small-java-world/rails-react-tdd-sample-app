# Work Plan — User Preferences (feature/user-preferences)

## 目的（運用方針）
- 本ワークプランは、ホスト OS 上の Claude Code CLI から Tsumiki コマンド（`/kairo-*`, `/tdd-*`, `/rev-*`）を呼び出し、TDD の Red → Green → Refactor を推進することを目的とする。
- CLI の実行場所は常に `rails-react-tdd-sample-app/` 直下（リポジトリルート）。コンテナ操作は `docker compose exec` を用いる。
- 代表例:
  ```bash
  # タスク分割
  claude -p "/kairo-tasks"
  # → ESC で中断 → "User Preferences を3〜5タスクへ分割" を追加入力

  # Red/Green/Refactor の1サイクル
  claude -p "/tdd-red"
  # → ESC で中断 → "スライス1（設定UI＋即時反映）の失敗テストを生成" を追加入力
  claude -p "/tdd-green"
  # → ESC で中断 → "スライス1を最小変更でGreen化" を追加入力
  claude -p "/tdd-refactor"
  # → ESC で中断 → "命名/重複/構成を整理" を追加入力
  ```

時系列の実行手順（Tsumikiのタスク分割を前提）。

- 前段: 要件定義（/kairo-requirements）
  ```bash
  # 子リポ直下で実行
  claude -p "/kairo-requirements"
  # → ESC で中断 → 次を追加入力
  # 対象: User Preferences の要件定義
  # 編集先: docs/prd/features/user-preferences/requirements.md
  # 参照コンテキスト: docs/prd/features/user-preferences/ と frontend/src/
  # 期待: UI(Theme/Interval/Density) の即時反映・永続化(localStorage)・リセット、受け入れ条件の具体化
  ```

- 0. 準備（ブランチ/起動確認）
  ```bash
  git switch feature/user-preferences
  docker compose up -d --build
  docker compose ps
  ```

- 1. タスク分割（/kairo-tasks）
  ```bash
  claude -p "/kairo-tasks"
  # → ESC で中断 → "User Preferences を3〜5タスクへ分割" を追加入力
  # 例: テーマ切替 / 自動更新間隔 / 表示密度 / 永続化(localStorage) / リセット
  ```
  - Tasks (generated):
    1) Theme 切替と即時反映（light/dark、`<html data-theme>`）
    2) 自動更新間隔の選択（Off/5/10/30s）と即時反映
    3) 表示密度（compact/standard）の切替と即時反映
    4) 永続化（localStorage 保存/読込）
    5) リセット（既定値へ戻す）

- 2. Red一覧（/tdd-testcases）
  ```bash
  claude -p "/tdd-testcases"
  # → ESC で中断 → "User Preferences のRed一覧を作成" を追加入力
  # 観点: UI切替の即時反映 / 永続化の保存/読込 / リセットの既定値復元
  ```
  - Testcases (generated):
    - UI: Theme を変更すると即時に `<html data-theme>` が更新される
    - UI: 自動更新間隔 (Off/5/10/30s) を選ぶと内部状態が即時反映される
    - UI: 表示密度 (compact/standard) を選ぶと即時反映される
    - Persist: Theme/Interval/Density を保存し、再ロード時に読み込まれる (localStorage)
    - Reset: 「リセット」で既定値 (light / Off / standard) に戻る

- 3. スライス1: 設定UIと即時反映
  - 失敗テストを追加 → 最小実装 → リファクタ
  ```bash
  claude -p "/tdd-red"
  # → ESC で中断 → "スライス1（設定UI＋即時反映）の失敗テストを生成" を追加入力
  claude -p "/tdd-green"
  # → ESC で中断 → "スライス1を最小変更でGreen化" を追加入力
  claude -p "/tdd-refactor"
  # → ESC で中断 → "命名/重複/構成を整理" を追加入力
  ```
  - テスト実行
  ```bash
  docker compose exec frontend sh -lc "npm test -- --run"
  ```

- 4. スライス2: 永続化（localStorage）
  ```text
  /tdd-red スライス2（保存/読込）の失敗テストを生成
  /tdd-green スライス2を最小変更でGreen化
  /tdd-refactor スライス2の整理
  ```
  ```bash
  docker compose exec frontend sh -lc "npm test -- --run"
  ```

- 5. スライス3: リセット（デフォルトへ戻す）
  ```text
  /tdd-red スライス3（リセット）の失敗テストを生成
  /tdd-green スライス3を最小変更でGreen化
  /tdd-refactor スライス3の整理
  ```
  ```bash
  docker compose exec frontend sh -lc "npm test -- --run"
  ```

- 6. ドキュメント/PRD更新
  ```bash
  # 変更差分を反映
  git add -A
  git commit -m "docs(user-preferences): update PRD and notes"
  git push origin feature/user-preferences
  ```

- 7. RSpec/統合確認（必要に応じて）
  ```bash
  docker compose exec backend bash -lc "RAILS_ENV=test bundle exec rspec --format documentation"
  curl -i http://localhost:3000/health | sed -n '1,20p'
  ```

- 8. 仕上げ（PR作成）
  ```bash
  gh pr create --fill --head feature/user-preferences || true
  # GitHub UIでも可
  ```

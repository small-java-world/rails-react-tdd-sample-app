# Tsumiki タスク実行設計（ESC 追加情報テンプレ付き）

適用範囲
- `/kairo-tasks` によって生成された `docs/tasks/<feature>-tasks.md` をもとに、TDD で各タスクを進める具体手順
- 追加情報は Claude Code CLI でコマンド実行後に ESC キーで追記（プロンプト補足）

前提
- 実行場所はリポジトリのルート
- コマンドは `claude -p "/<command>"`
- jscpd は `cd frontend && npm run dup`（必要に応じて `dup:report`）

推奨フロー（1 タスクあたり）
1) 要件/テスト雛形
   - `claude -p "/tdd-requirements"`
   - `claude -p "/tdd-testcases"`
2) Red（失敗テスト）
   - `claude -p "/tdd-red"`
3) Green（最小実装）→ 直後に jscpd → ESC 追記
   - `claude -p "/tdd-green"`
   - `cd frontend && npm run dup && npm run dup:report`
   - 直後に ESC で以下テンプレを貼って追加情報を渡す
4) Refactor（前後で jscpd 計測 + ESC 追記）
   - 前: `cd frontend && npm run dup`
   - `claude -p "/tdd-refactor"`
   - 後: `cd frontend && npm run dup:report`
   - 事前/事後で ESC 追記テンプレを使い、計画と効果を渡す
5) 完了確認
   - `claude -p "/tdd-verify-complete"`

ESC 追加情報テンプレ

- Green 直後 用
```text
[ESC: 追加情報 /tdd-green 後]
TASK: TASK-XXX（例: TASK-001）
目的: 最小実装で要求を満たしつつ、重複の新規発生有無をチェック
変更概要: （例）UserPreferences.jsx 追加、App.jsx 統合、テスト追記
jscpd 要約: Clones: N, Duplicated lines: x%（該当ファイル/範囲があれば記載）
判断: （例）即時対応せず /tdd-refactor で共通化予定／今は命名改善のみ
次アクション: （例）/tdd-refactor 前にベースライン計測
```

- Refactor 前（ベースライン） 用
```text
[ESC: 追加情報 /tdd-refactor 前（ベースライン）]
TASK: TASK-XXX
現状把握: jscpd 結果（クローンの位置/規模/影響）
方針: 効果大・変更小の順で 2〜3 件（共通関数化／重複排除／責務分離）
制約: 動作維持（既存テストは Green）／命名と責務の一貫性
計画: 手順の箇条書き（安全にコミットを分ける）
```

- Refactor 後（効果検証） 用
```text
[ESC: 追加情報 /tdd-refactor 後（効果検証）]
TASK: TASK-XXX
結果: jscpd Before→After（クローン数/duplicated lines% の差分）
変更点: 実施したリファクタ（共通化/命名改善/責務分離 等）
残課題: 次イテレーション候補（任意）
```

ショートカット（任意）
- `claude -p "/tdd-green-with-jscpd"`（Green→jscpd→要約まで）
- `claude -p "/tdd-refactor-with-jscpd"`（前後計測→計画/効果要約）

補足
- jscpd HTML レポート: `reports/jscpd/html/index.html`
- 大きな重複がない場合は、Refactor 計画に回すのが安全

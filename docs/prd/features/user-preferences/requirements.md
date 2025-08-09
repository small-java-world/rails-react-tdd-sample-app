# Feature PRD — User Preferences

## 概要
利用者が React フロントエンドアプリケーションで個人設定を変更し、ブラウザ再読込後も設定が保持される機能を実装する。

## Outcome
- 利用者が自分の使いやすい設定（テーマ/自動更新間隔/表示密度）を選び、次回以降も維持できる
- 設定変更は即座にUIに反映される
- 設定はブラウザのlocalStorageに永続化される

## Success Metrics
- 主要設定は3クリック以内に変更可能
- 設定変更は即座に画面に反映される（1秒以内）
- 設定は再訪時も保持（localStorage利用）
- リセット機能で既定値に戻せる

## 詳細仕様

### 1. テーマ切替（Theme）
- **UI**: `<select>` でlight/darkを選択
- **反映**: `<html data-theme="light|dark">` 属性を即座に更新
- **永続化**: localStorageキー `userPreferences.theme`
- **既定値**: `light`

### 2. 自動更新間隔（Auto Refresh）
- **UI**: `<select>` でOff/5s/10s/30sを選択
- **反映**: 内部タイマーを即座に再設定（現在のSystem timeの更新間隔）
- **永続化**: localStorageキー `userPreferences.refreshInterval`
- **既定値**: `Off`（1000ms固定）

### 3. 表示密度（Display Density）
- **UI**: `<select>` でcompact/standardを選択
- **反映**: CSS class `density-compact|density-standard` を `<body>` に適用
- **永続化**: localStorageキー `userPreferences.density`
- **既定値**: `standard`

### 4. リセット機能
- **UI**: 「Reset to Default」ボタン
- **動作**: 全設定を既定値に戻し、localStorageをクリア
- **確認**: confirm()ダイアログで確認

## 技術要件
- **フレームワーク**: React 18 (hooks使用)
- **永続化**: localStorage (JSON形式)
- **テスト**: Vitest + @testing-library/react
- **CSS**: 既存のApp.cssに追加

## Scenarios（ユーザーストーリー）
1. **テーマ切替**: 「ダークモードにしたい」→ Theme選択→即座に背景が暗くなる
2. **自動更新**: 「時刻を5秒ごとに更新したい」→ Interval選択→タイマー間隔変更
3. **表示密度**: 「コンパクトな表示にしたい」→ Density選択→余白が狭くなる
4. **永続化**: ブラウザを閉じて再開→前回の設定が復元される
5. **リセット**: 「初期状態に戻したい」→ Reset→全て既定値に戻る

## Thin Slices
1) **設定UIと即時反映**: 3つの`<select>`とResetボタン、選択時の即座反映
2) **設定の永続化**: localStorage保存/読込、ページ読込時の復元
3) **リセット機能**: 既定値への復元とlocalStorageクリア

## 受け入れ条件
- [ ] Theme選択でdata-theme属性が即座に変更される
- [ ] Interval選択でSystem time更新間隔が変更される  
- [ ] Density選択でbodyのCSSクラスが変更される
- [ ] 設定はlocalStorageに保存される
- [ ] ページ再読込で設定が復元される
- [ ] Resetで全設定が既定値に戻る
- [ ] 各機能にVitest単体テストが存在する

## 非機能要件
- 設定変更のレスポンス: 100ms以内
- localStorage容量: 1KB以内
- ブラウザ対応: Chrome/Firefox/Safari最新版

# jscpd 対応 作業記録

- 目的: フロントエンド/バックエンド全体で重複コード検出を手軽に実行できるようにする
- ツール: jscpd
- 対象: `frontend/src` および `backend/` 配下（Ruby/YAML 含む）

## 実施内容
- フロントエンドに jscpd を開発依存として追加
  - 実行: `cd frontend && npm i -D jscpd`
- `frontend/package.json` に jscpd 実行用スクリプトを追加
  - `dup:frontend`: フロントエンド（`src`）対象
  - `dup:backend`: ルート相対 `../backend` 対象
  - `dup`: 上記 2 つを連続実行
  - `dup:report`: HTML レポートを `../reports/jscpd/html/` に出力
- 無視パターンを明示
  - `**/node_modules/**`, `**/coverage/**`, `**/dist/**`, `**/.git/**`
- しきい値 `--threshold 2` を暫定設定（超過で失敗扱い）

## 追加した npm スクリプト（抜粋）
- dup:frontend: `jscpd --reporters console --threshold 2 --ignore "**/node_modules/**" --ignore "**/coverage/**" --ignore "**/dist/**" --ignore "**/.git/**" src`
- dup:backend: `jscpd --reporters console --threshold 2 --ignore "**/node_modules/**" --ignore "**/coverage/**" --ignore "**/dist/**" --ignore "**/.git/**" ../backend`（注: frontend から実行する）
- dup: `npm run dup:frontend && npm run dup:backend`
- dup:report: `jscpd --reporters console,html --output ../reports/jscpd --ignore "**/node_modules/**" --ignore "**/coverage/**" --ignore "**/dist/**" --ignore "**/.git/**" src ../backend`

## 実行方法
1) フロントエンド直下へ移動して実行
   - `cd frontend`
   - 重複チェック（frontend+backend）: `npm run dup`
   - HTML レポート出力（`reports/jscpd/html/index.html`）: `npm run dup:report`
2) backend 直下から単独で解析したい場合（代替コマンド）
   - ルート/任意場所で: `npx -y jscpd --reporters console --threshold 2 --ignore "**/node_modules/**" --ignore "**/coverage/**" --ignore "**/dist/**" --ignore "**/.git/**" backend`

## 実行結果（初回）
- `dup` 実行時、フロント/バックエンドともクローン検出 0 件（0%）
- `dup:report` 実行時、HTML レポートが `reports/jscpd/html/` に生成されることを確認

## 運用メモ
- 閾値調整: 厳しくする場合は `--threshold 1` などへ、CI でエラーにしない場合は閾値を上げるか reporters を調整
- 対象/除外調整: 追加の除外は `--ignore` 追記、解析対象を絞る場合は引数パスを限定
- 言語対応: jscpd は複数言語（JS/TS/JSX/TSX/Ruby/CSS/HTML 等）に対応し、現設定で自動判別

## 変更ファイル
- `frontend/package.json`（scripts・devDependencies 追加）

## 参考
- ルートの `jscpd .md`（連携ガイド）

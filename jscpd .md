# /tdd-refactor × jscpd 連携ガイド（TypeScript & Ruby on Rails 対応）

このドキュメントは、[tsumiki](https://github.com/classmethod/tsumiki) の `/tdd-refactor` コマンドに  
[**jscpd**](https://github.com/kucherenko/jscpd) を組み合わせ、TypeScript と Ruby (Rails) プロジェクトで  
重複コードを検出・削減するための運用方法をまとめたものです。

---

## 1. 前提

- Tsumiki がプロジェクトに導入済みで、`.claude/commands/` 以下に `/tdd-refactor` が存在すること
- Node.js 環境があり、npm / npx コマンドが利用可能なこと
- TypeScript / JavaScript / Ruby コードが混在していても OK（jscpd はマルチ言語対応）

---

## 2. jscpd の導入

```bash
npm install --save-dev jscpd

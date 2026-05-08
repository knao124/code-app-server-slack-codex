# code-app-server-slack-codex

Slackを情報hubとして、Codexを常駐メンバーのように動かすための設計・実装リポジトリです。

MVPでは、GCE上でSlack Botを常時稼働させ、プロジェクトチャンネル・日報チャンネル・運用チャンネルでの依頼をCodex実行ジョブへ変換します。Codexは日報、相談、進捗報告、作業結果のスレッド返信をSlack上のチャンネルで行います。

## Current Status

- 設計初版作成
- インフラはTerraformで作成する方針
- 実行基盤はGCEを想定
- GitHub public repository作成済み

## Documents

- [Design index](docs/01_design/README.md)

# code-app-server-slack-codex

Slackを情報hubとして、CodexベースのAgentを常駐メンバーのように動かすための設計・実装リポジトリです。

MVPでは、GCE上でSlack Agent Runtimeを常時稼働させ、プロジェクトチャンネル・日報チャンネル・運用チャンネルでの依頼をCodex実行ジョブへ変換します。repoの中心は単一Botではなく、複数Agentが組み合わせて使えるSkill群です。

## Current Status

- 設計初版作成
- インフラはTerraformで作成する方針
- 実行基盤はGCEを想定
- GitHub public repository作成済み

## Documents

- [Design index](docs/01_design/README.md)

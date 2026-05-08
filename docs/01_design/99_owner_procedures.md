# Owner Procedures

このプロジェクトでオーナーに依頼する手続きの一覧。

## Completed

### GitHub Repository

public repoは作成済み。

```text
https://github.com/knao124/code-app-server-slack-codex
```

## Now

### Terraform CLI

ローカル環境には `terraform` CLIが未導入。Terraform実装・検証前に導入する。

## Before Terraform Apply

### GCP Project

必要情報:

- GCP project id
- billingが有効か
- Terraform state用GCS bucketを既存で使うか、新規作成するか
- region/zone

推奨初期値:

```text
region: asia-northeast1
zone: asia-northeast1-b
```

### Local GCP Auth

Terraform実行者の認証が必要。

候補:

```sh
gcloud auth login
gcloud auth application-default login
```

CIでTerraformを回す場合はWorkload Identity Federationを検討する。

## Before Slack Bot Run

### Slack App Creation

必要情報:

- Slack workspace
- Bot display name
- 日報投稿先channel
- project channel allowlist
- operations channel
- owner Slack user ID

必要token:

- Bot User OAuth Token
- App-Level Token for Socket Mode
- Signing Secret if Events API is used

### Slack Scopes

MVP候補:

- `app_mentions:read`
- `chat:write`
- `channels:history`
- `groups:history`
- `users:read`
- `connections:write`

## Before GitHub Work

### GitHub Access

BotがGitHub repoを扱うための認証が必要。

候補:

- fine-grained personal access token
- GitHub App

MVPではfine-grained tokenから開始できる。長期運用ではGitHub Appの方がよい。

## Before Codex Execution

### Codex/OpenAI Credentials

GCE上のBotがCodexを実行するための認証が必要。

必要なものは採用するexecutor方式で変わる。

- Codex SDKを使う場合: SDKが要求する認証情報
- Codex CLIを使う場合: CLI loginまたはAPI key方式
- App Serverを使う場合: app-server起動と認証方式

secret valueはGoogle Secret Managerへ入れる。

# Infrastructure: Terraform and GCE

## Direction

インフラはTerraformで作成・変更する。

初期構成は単一GCE VMを中心にする。Slack Socket Modeを使えば外部HTTP endpointやLoad BalancerをMVPで持たなくてよい。

## GCP Resources

MVPでTerraform管理するresource:

- GCE instance
- service account for agent runtime
- IAM bindings
- Secret Manager secrets
- persistent disk for bot state
- firewall rules for SSH or IAP
- Cloud Logging/Monitoring basics
- optional Artifact Registry
- optional Cloud Scheduler/Pub/Sub

## Network Model

MVP:

```text
GCE VM
  outbound -> Slack API
  outbound -> OpenAI/Codex endpoints
  outbound -> GitHub
  outbound -> Google APIs

No inbound app port required when Socket Mode is used.
```

SSHは次のどちらかに寄せる。

1. IAP SSH
2. 管理者IPだけ許可したSSH

推奨はIAP SSH。

## Secret Management

Secret Managerに置くもの:

- Slack bot token
- Slack app token for Socket Mode
- Slack signing secret if Events API is used
- OpenAI/Codex credential or service credential
- GitHub token or GitHub App credential
- owner Slack user ID

Terraformではsecret containerを作る。secret valueは原則Terraform stateへ入れない。

初期投入は `gcloud secrets versions add` で行う。

## VM Runtime

推奨:

- Debian or Ubuntu LTS
- Docker
- systemd
- Google Ops Agent
- application logs to stdout/stderr

起動方式:

```text
systemd service
  ExecStart=docker run ...
```

または初期は直接runtimeを入れて実行する。

## Persistent Storage

Bot状態は永続ディスクに置く。

```text
/srv/slack-codex/data/bot.sqlite
/srv/slack-codex/data/artifacts/
/srv/slack-codex/workspaces/
```

バックアップ:

- daily snapshot
- SQLite dump to GCS

MVPではsnapshotから開始し、必要ならGCS backupを追加する。

## Terraform Layout

```text
infra/terraform/
├── README.md
├── envs/
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars.example
│       └── variables.tf
└── modules/
    ├── bot_vm/
    ├── secrets/
    └── logging/
```

## Terraform Backend

Terraform stateはGCS backendを推奨する。

必要resource:

- GCS bucket for Terraform state
- bucket versioning
- restricted IAM

bootstrap手順は別途必要。

## Required GCP APIs

- Compute Engine API
- IAM API
- Secret Manager API
- Cloud Logging API
- Cloud Monitoring API
- Cloud Resource Manager API
- Artifact Registry API if container image is used
- Cloud Scheduler API if scheduler is managed outside the bot process
- Pub/Sub API if Cloud Scheduler sends Pub/Sub messages

## Deployment Flow

初期想定:

```text
1. TerraformでGCE/SA/Secrets/Diskを作る
2. Slack/GitHub/OpenAI系secret valueを投入する
3. VMへagent runtimeをdeployする
4. systemd serviceを起動する
5. Slackチャンネルmentionとthread返信で疎通確認する
```

## Environment Variables

Agent runtimeに渡す候補:

```text
SLACK_BOT_TOKEN
SLACK_APP_TOKEN
SLACK_SIGNING_SECRET
SLACK_OWNER_USER_ID
SLACK_DAILY_REPORT_CHANNEL_ID
CODEX_EXECUTOR_KIND
OPENAI_API_KEY
GITHUB_TOKEN
BOT_DATA_DIR
BOT_WORKSPACE_DIR
```

secretはVM起動時にSecret Managerから読む。平文 `.env` は本番VMに置かない方針。

## Cost Control

初期は小さいVMで十分。

候補:

- e2-small
- e2-medium

Codex実行で重いビルドやテストを走らせる場合は、repoごとに必要スペックを見直す。

## Future Infra Options

- Cloud Run: public endpoint運用にする場合
- Cloud SQL PostgreSQL: 複数worker化する場合
- Cloud Tasks/Pub/Sub: job queueを外出しする場合
- Artifact Registry + GitHub Actions: container build/deployを自動化する場合
- Managed Instance Group: 可用性を上げる場合

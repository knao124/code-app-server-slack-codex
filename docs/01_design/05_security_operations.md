# Security and Operations

## Security Goals

Slack上の便利さを優先しつつ、Codexが危険な操作を勝手に実行しないようにする。

守るもの:

- Slack workspaceの会話
- GitHub repositories
- GCP resources
- secrets
- production environments
- ownerの意思決定権限

## Authorization

初期はallowlist方式にする。

- owner user ID
- allowed channels
- allowed project channels
- allowed GitHub repositories

Agent Runtimeがinviteされていないチャンネルは読まない。

## Command Policy

操作をrisk levelで分類する。

### Low Risk

- 質問への回答
- read-only調査
- GitHub issue/PRの閲覧
- Slack threadへの返信

自動実行可。

### Medium Risk

- repo clone/fetch
- test/lint実行
- branch作成
- draft PR作成

許可済みrepoなら自動実行可。ただしログを残す。

### High Risk

- push
- PR作成
- Terraform plan
- secret nameの列挙
- 外部APIへの変更リクエスト

原則owner承認を要求する。

### Critical Risk

- Terraform apply
- production deploy
- destructive git command
- secret value閲覧
- PR merge
- 権限/IAM変更

必ずowner承認を要求する。

## Approval UX

Slackの依頼元threadまたはoperations channel threadで承認依頼を出す。チャンネル外の個別通知は使わない。

含める情報:

- job id
- requested action
- reason
- command or API action
- expected impact
- approve/reject buttons

承認は短いTTLを持つ。期限切れなら再確認する。

## Audit Log

保存対象:

- Slack event id
- requester
- requested command
- Codex prompt summary
- executed tool/command summary
- approval status
- output artifact path
- Slack message links

MVPではSQLiteに保存し、将来Cloud LoggingやBigQueryへ拡張する。

## Secrets

ルール:

- repoにsecretを置かない。
- Terraform stateにsecret valueを入れない。
- Secret Managerからruntimeで読む。
- Slackにsecret valueを投稿しない。
- Codex promptにsecret valueを渡さない。

## Incident Response

Bot暴走時の停止方法:

1. Slack App tokenをrevokeする。
2. GCE systemd serviceを停止する。
3. Secret Manager上のtokenを無効化する。
4. pending jobをDBで停止状態にする。

Terraformで用意したいもの:

- service account単位で権限を絞る
- VM stop権限をownerが持つ
- logsを確認できる

## Monitoring

見るべき指標:

- Slack event受信数
- job success/failure count
- queue length
- pending approval count
- daily report success/failure
- Codex execution duration
- process restart count

MVPではCloud Loggingとsystemd statusから開始する。

## Data Retention

初期方針:

- Slack message copy: 必要最小限
- job metadata: 90日
- artifacts: 30日
- audit log: 180日

保存期間は運用開始後に見直す。

# MVP Plan

## Phase 0: Repository and Design

成果:

- public GitHub repo
- design docs under `docs/01_design`
- Terraform layout decision
- owner procedures list

## Phase 1: Slack Echo Bot

成果:

- Slack App作成
- Socket Mode接続
- DM/mention受信
- 3秒以内ACK
- thread返信

完了条件:

- ownerがDMで送ったメッセージにBotが返信できる。
- project channelでmentionしたらthreadに返信できる。

## Phase 2: Job Queue and State

成果:

- SQLite schema
- job queue
- event deduplication
- Slack thread mapping
- worker process

完了条件:

- Slack eventがjobになり、非同期workerが処理する。
- 再起動後も未完了jobを復元できる。

## Phase 3: Codex Executor

成果:

- `CodexExecutor` interface
- executor adapterの初期実装
- job resultのSlack投稿
- progress update

完了条件:

- Slackから依頼した調査タスクをCodexが実行し、結果をthreadに返せる。

## Phase 4: Daily Report

成果:

- daily report scheduler
- job履歴から日報生成
- 日報チャンネル投稿

完了条件:

- 毎日指定時刻にBotが日報を投稿する。

## Phase 5: Approval Flow

成果:

- risk classification
- owner DM approval
- approve/reject buttons
- audit log

完了条件:

- high/critical actionでBotが止まり、owner承認後だけ続行する。

## Phase 6: Terraform GCE Deployment

成果:

- Terraform prod environment
- GCE VM
- service account
- Secret Manager
- persistent disk
- logging
- deployment runbook

完了条件:

- owner PCを閉じていてもBotがSlackに常駐する。

## Phase 7: Project Channel Awareness

成果:

- allowed channel設定
- project channelの要約
- ブロッカー検知
- 必要時の相談投稿

完了条件:

- Botがプロジェクトチャンネルの進捗を読み、自分に関係する相談や日報へ反映できる。

## Suggested Initial Implementation Stack

現時点の推奨:

- Language: TypeScript or Python
- Slack SDK: official Slack SDK
- Queue/DB: SQLite
- Runtime: Docker + systemd on GCE
- Infra: Terraform
- Secrets: Google Secret Manager

TypeScriptはSlack SDKやBot実装の相性がよい。PythonはCodex/agent周辺の実装がしやすい。初期はどちらでもよいが、Slack event-driven botとしてはTypeScriptを第一候補にする。

## First Acceptance Scenario

```text
User -> Slack DM:
  明日の朝までにこのrepoの構成を調べて日報に入れて

Bot:
  受け取りました。調査ジョブを開始します。

Bot -> thread:
  調査中です。READMEとdocsを確認しています。

Bot -> thread:
  調査が完了しました。要点は...

Next daily report:
  今日やったこと
  - repo構成を調査し、...
```

# System Architecture

## Summary

Slack Agent Runtimeを主役にし、Codexを裏側の実行エンジンとして扱う。Runtimeは単一人格ではなく、複数Agent profileをSlackに常駐させる。

```text
Slack workspace
  |  channel mention / thread reply / slash command / scheduled event
  v
Slack ingress
  |  ACK immediately
  v
Job queue
  |  async processing
  v
Agent controller
  |  agent routing, policy, memory, schedules
  v
Agent runtime
  |  agent profile + skill registry
  v
Codex executor adapter
  |  codex sdk / app-server / cli
  v
Workspace repositories and tools

Agent controller
  |  post progress, questions, daily reports
  v
Slack egress
```

## Components

### Slack Ingress

Slackからの入力を受け取る。

- app mention
- project channel message
- thread reply
- slash command
- interactive button/modal
- schedule trigger

MVPではSocket Modeを優先する。GCE側にpublic HTTPS endpointを開けずにSlackからのイベントを受け取れるため、初期運用が簡単になる。

### Job Queue

Slack event handlerは3秒以内にACKする必要があるため、Codex処理を同期実行しない。

MVP候補:

- 単一VM内のSQLite-backed queue
- Redis
- Cloud Tasks
- Pub/Sub

初期は単一GCE VMなので、SQLite-backed queueで十分。GCE再起動に耐えるため、SQLiteは永続ディスク上に置く。

### Agent Controller

Slack eventをどのAgentへ渡すかを決める。人格や職能そのものはAgent profileに寄せ、controllerはrouting、policy、state管理を担う。

責務:

- Slack eventを内部commandへ変換する。
- 新規チャンネルメッセージが処理対象かをmention gateで判定する。
- 誰からの依頼か、どのチャンネルか、どのプロジェクトか、どのAgent宛てかを判定する。
- Codex実行が必要か、普通の会話応答で済むかを判定する。
- 作業進捗、日報、相談をSlackへ投稿する。
- 承認が必要な操作を止め、ユーザーへ確認する。
- Agent状態、会話状態、ジョブ状態、Slack thread mappingを保存する。

### Agent Runtime

常駐Agentを実行する。

Agent profileは次を持つ。

- agent id
- display name
- home channels
- enabled skills
- permissions
- schedule
- memory scope
- Codex executor policy

MVPでは1つのAgent profileから始めるが、設計上は複数Agentを同じruntimeで動かせるようにする。

### Skill Registry

SkillはAgentから呼び出される機能単位。

初期Skill:

- conversation
- task execution
- progress reporting
- daily report
- decision facilitation
- project awareness
- GitHub awareness
- approval and audit

SkillはSlack投稿やCodex実行に直接密結合しない。Agent RuntimeがSkill呼び出しを調停し、Slack EgressやCodex Executor Adapterへ渡す。

### Codex Executor Adapter

Codex実行部分を差し替え可能にする。

候補:

1. Codex SDK
   - Agent Runtimeからプログラム的にCodexを扱う本命候補。
   - 長期的には最も自然。
2. `codex exec`
   - MVPで使いやすい。
   - 1依頼1ジョブの非対話実行に向く。
3. `codex app-server`
   - JSON-RPCでthread/turnを扱える。
   - 現時点ではexperimental扱いなので、外部公開や本番強依存は避ける。

設計上は `CodexExecutor` interfaceを作り、MVPでは実装しやすいものから始める。

### State Store

MVPではSQLiteを使う。

保存対象:

- Slack user/channel/thread mapping
- agent profiles
- agent-channel bindings
- skill invocation history
- job status
- Codex task metadata
- daily report items
- pending approvals
- memory snippets
- project subscriptions

将来、複数worker化する場合はCloud SQL PostgreSQLへ移行する。

### Scheduler

日報、定期巡回、リマインドを実行する。

MVP候補:

- Bot process内scheduler
- systemd timer
- Cloud Scheduler + Pub/Sub

TerraformでCloud Schedulerを作れる構成にしておく。ただしMVPでは単一Bot process内schedulerから始めてもよい。

## Runtime Process Model

MVPの単一VM構成:

```text
systemd
  |
  +-- slack-codex-bot.service
        |
        +-- Slack Socket Mode client
        +-- agent runtime
        +-- skill registry
        +-- async worker
        +-- scheduler
        +-- Codex executor subprocess/client
        +-- SQLite database on persistent disk
```

## Repository Layout Proposal

```text
.
├── docs/
│   └── 01_design/
├── app/
│   ├── slack_ingress/
│   ├── agent_controller/
│   ├── agent_runtime/
│   ├── skill_registry/
│   ├── codex_executor/
│   ├── storage/
│   └── scheduler/
├── infra/
│   └── terraform/
│       ├── envs/
│       │   └── prod/
│       └── modules/
│           ├── bot_vm/
│           ├── secrets/
│           └── logging/
└── scripts/
```

## Initial Deployment Target

- Cloud: Google Cloud
- Compute: GCE
- OS: Ubuntu LTS or Debian
- Process manager: systemd
- Packaging: Docker image or Python/Node runtime installed by startup script
- Secrets: Google Secret Manager
- Logs: Cloud Logging
- Source: GitHub public repository, private secrets only in Secret Manager

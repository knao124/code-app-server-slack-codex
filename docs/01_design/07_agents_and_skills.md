# Agents and Skills

## Purpose

このプロジェクトは、Slackに単一のCodex botを置くためだけのものではない。

目指す形は、複数の常駐Agentが同じSkill群を組み合わせて、Slack上で人間メンバーと同じプロトコルで働くこと。

## Core Model

```text
Agent Profile
  = identity
  + home channels
  + enabled skills
  + permissions
  + schedule
  + memory scope
```

```text
Skill
  = reusable capability
  + input schema
  + output events
  + permission requirements
  + audit policy
```

Agentは「中間管理職」や「作業者」として直接ハードコードしない。中間管理職的な振る舞いも、作業者的な振る舞いも、Skillの組み合わせで作る。

## Skill Catalog

### conversation

Slack channel/threadで会話する。

入力:

- Slack event
- thread history
- agent profile

出力:

- Slack reply
- task request
- decision request

### task_execution

作業依頼をCodex実行ジョブに変換する。

入力:

- task request
- repository context
- acceptance criteria

出力:

- job created
- progress event
- completion event
- failure event

### progress_reporting

進捗をSlack threadへ報告する。

入力:

- job event
- previous report
- Slack thread context

出力:

- progress message
- blocker message
- completion summary

### daily_report

日報を生成して投稿する。

入力:

- completed jobs
- active jobs
- pending decisions
- GitHub updates
- project channel highlights

出力:

- daily report message

### decision_facilitation

判断待ちや承認待ちをチャンネル上で扱う。

入力:

- risk classification
- missing permission
- design alternatives
- blocked job

出力:

- decision request thread
- approval request
- selected option

### project_awareness

許可されたチャンネルを読み、進捗、相談、ブロッカーを拾う。

入力:

- allowed channel history
- configured project mapping

出力:

- highlight
- blocker
- suggested task
- daily report item

### github_awareness

GitHubの状態を読み、Slack上の作業や報告に変換する。

入力:

- issue
- pull request
- review
- CI status
- branch status

出力:

- task suggestion
- review summary
- CI failure report

### approval_and_audit

危険操作を止め、承認と監査ログを管理する。

入力:

- proposed action
- risk level
- requester
- agent profile

出力:

- approval request
- audit record
- allowed or rejected action

## Example Agent Profiles

### Project Coordinator Agent

目的:

- プロジェクトチャンネルに常駐し、進捗、相談、ブロッカー、日報を扱う。

Skills:

- conversation
- progress_reporting
- daily_report
- decision_facilitation
- project_awareness
- github_awareness

### Developer Agent

目的:

- Slack上の依頼を実装・調査・レビュー作業へ変換する。

Skills:

- conversation
- task_execution
- progress_reporting
- github_awareness
- approval_and_audit

### Reviewer Agent

目的:

- PR、設計、差分、テスト結果をレビューし、チャンネル上で指摘や判断材料を出す。

Skills:

- conversation
- github_awareness
- decision_facilitation
- approval_and_audit

### Reporter Agent

目的:

- 日報、週報、プロジェクト横断の要約を出す。

Skills:

- daily_report
- project_awareness
- github_awareness
- progress_reporting

## MVP Profile

MVPでは、まず1つのAgentを常駐させる。

```text
agent_id: codex_worker
home_channels:
  - project channel allowlist
  - daily report channel
  - operations channel
skills:
  - conversation
  - task_execution
  - progress_reporting
  - daily_report
  - decision_facilitation
  - approval_and_audit
```

ただし、DB schema、config、routingは最初から複数Agentを前提にする。

## Routing Rules

Slack eventは次の順でAgentへroutingする。

1. 明示mentionされたAgent
2. threadに紐づいた既存Agent
3. channelのdefault Agent
4. operations channelのfallback Agent

複数Agentが反応できる場合は、controllerが1つに絞る。複数Agentに同時応答させる場合は明示commandを必要にする。

## State Requirements

保存するもの:

- agent profile
- skill enablement
- agent-channel binding
- thread-agent binding
- skill invocation history
- approval history
- memory scope

これにより、Agentを増やしてもSlack protocol、Codex executor、監査ログを再利用できる。

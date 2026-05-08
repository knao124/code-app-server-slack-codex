# 01 Design

このディレクトリは、Slack常駐Codex-based Agent Runtimeの初期設計を管理する。

## Documents

- [00 Slack Conversation Examples](00_slack_conversation_examples.md)
- [00 Product Brief](00_product_brief.md)
- [01 System Architecture](01_system_architecture.md)
- [02 Slack Protocol](02_slack_protocol.md)
- [03 Codex Worker](03_codex_worker.md)
- [04 Infrastructure Terraform GCE](04_infra_terraform_gce.md)
- [05 Security Operations](05_security_operations.md)
- [06 MVP Plan](06_mvp_plan.md)
- [07 Agents and Skills](07_agents_and_skills.md)
- [99 Owner Procedures](99_owner_procedures.md)

## Design Flow

設計は次の順序で進める。

1. Slack conversation examplesで、実現したい会話を具体的に書く。
2. 具体例から、ユーザーが求めている要求を抽出する。
3. 要求を、実装が満たすべき検証可能な要件へ抽象化する。
4. 要件に沿って、Agent Runtime、Skill、Slack protocol、Codex executor、infraのアーキテクチャを決める。

現時点では、具体例を先に追加し、既存のProduct BriefとSystem Architectureは後続でこの流れに合わせて再整理する。

## Design Principles

- Slackを主UIにする。CodexアプリやローカルPCの前にSlackがある。
- Agentは人間の部下と同じプロトコルで動く。日報、進捗報告、相談、スレッドでの議論をSlack上で行う。
- repoの成果物は単一Botの振る舞いではなく、複数の常駐Agentが組み合わせて使えるSkill群として設計する。
- Codexは裏側の実行エンジンとして扱い、Slack protocol、Agent Runtime、ジョブ管理、権限、記憶、スケジュールは別レイヤーで持つ。
- GCE上で常時稼働させ、ユーザーPCの稼働状態に依存しない。
- インフラはTerraformで再現可能にする。

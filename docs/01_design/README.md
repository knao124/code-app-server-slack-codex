# 01 Design

このディレクトリは、Slack常駐Codex botの初期設計を管理する。

## Documents

- [00 Product Brief](00_product_brief.md)
- [01 System Architecture](01_system_architecture.md)
- [02 Slack Protocol](02_slack_protocol.md)
- [03 Codex Worker](03_codex_worker.md)
- [04 Infrastructure Terraform GCE](04_infra_terraform_gce.md)
- [05 Security Operations](05_security_operations.md)
- [06 MVP Plan](06_mvp_plan.md)
- [99 Owner Procedures](99_owner_procedures.md)

## Design Principles

- Slackを主UIにする。CodexアプリやローカルPCの前にSlackがある。
- Botは人間の部下と同じプロトコルで動く。日報、進捗報告、相談、スレッドでの議論をSlack上で行う。
- Codexは裏側の実行エンジンとして扱い、Slack Bot、ジョブ管理、権限、記憶、スケジュールは別レイヤーで持つ。
- GCE上で常時稼働させ、ユーザーPCの稼働状態に依存しない。
- インフラはTerraformで再現可能にする。

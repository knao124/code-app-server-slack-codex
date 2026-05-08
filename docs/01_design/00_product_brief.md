# Product Brief

## Goal

SlackにCodexが常駐し、人間の部下と同じように報告・相談・作業依頼を行える状態を作る。

ユーザーは常にPCを開いているわけではないため、Codexとの接点をCodexアプリではなくSlackに寄せる。Slack上で日報、進捗、相談、作業指示、レビュー依頼、意思決定を扱う。

## Target Users

- オーナー: knao124
- Slack上で協働する人間メンバー
- Slack常駐のCodex-based Agent

## Product Skills

このrepoのゴールは、単一の「Codex bot」を作ることではなく、Slackに常駐する複数Agentが組み合わせて使えるSkill群を実装すること。

### Conversation Skill

Slackのチャンネルとthreadを会話プロトコルとして扱い、相談、追加指示、確認、完了報告を同じ場所に残す。

### Task Execution Skill

Slack上の依頼を調査、設計、実装、テスト、レビューなどの作業ジョブに変換し、Codex executorへ渡す。

### Progress Reporting Skill

作業中の状態、見つかった事実、次にやること、ブロッカーをSlack threadに投稿する。

### Daily Report Skill

ジョブ履歴、Slackでの相談、GitHub/CIの状態から日報を生成し、日報チャンネルへ投稿する。

### Decision Facilitation Skill

判断待ち、権限不足、設計判断、承認待ちを該当チャンネルまたは運用チャンネルに起票し、ownerや関係者の意思決定を待つ。

### Project Awareness Skill

許可されたプロジェクトチャンネルの報告、相談、ブロッカーを読み、関連する作業や日報へ反映する。

### GitHub Awareness Skill

GitHub issue、PR、CI、review、branch状態を読み、必要な作業・報告・相談へ変換する。

### Approval and Audit Skill

危険な操作をrisk levelで分類し、承認、実行記録、成果物、Slack message linkを監査ログに残す。

## Agent Composition

AgentはSkillの組み合わせとして定義する。

例:

- Project Coordinator Agent: Conversation、Progress Reporting、Daily Report、Decision Facilitation、Project Awarenessを使う。
- Developer Agent: Conversation、Task Execution、Progress Reporting、GitHub Awareness、Approval and Auditを使う。
- Reviewer Agent: Conversation、GitHub Awareness、Decision Facilitation、Approval and Auditを使う。
- Reporter Agent: Daily Report、Project Awareness、GitHub Awarenessを使う。

同じSlack workspaceに複数Agentが常駐しても、Skill実装、権限、監査ログ、ジョブ管理を共有できるようにする。

## Non-goals for MVP

- 完全自律で本番反映する。
- Agentごとに別々の実装を持つ。
- 中間管理職Agentや作業者Agentを最初から固定ロールとしてハードコードする。
- 全Slackチャンネルを無制限に読む。
- ユーザー承認なしで危険なローカルコマンドやインフラ変更を実行する。
- 最初から複数ワークスペースや複数組織に対応する。
- Slack Marketplace公開を目指す。

## MVP Definition

MVPは次を満たせばよい。

- Slackチャンネル上のmention、thread返信、slash commandを受け取れる。
- Slack eventを3秒以内にACKし、処理は非同期ジョブ化する。
- 新規チャンネルメッセージを処理対象にする条件として、Codex/Agentへの明示mentionを要求できる。
- Agent profileを少なくとも1つ定義し、利用Skillと常駐チャンネルを設定できる。
- Codex実行ジョブを作成し、結果をSlack threadへ返す。
- 日報チャンネルへ毎日1回投稿できる。
- 作業中に判断が必要な場合、該当チャンネルまたは運用チャンネルで相談できる。
- TerraformでGCE、service account、Secret Manager、loggingの土台を作れる。

## References

- OpenAI Codex Slack integration: https://developers.openai.com/codex/integrations/slack
- OpenAI Codex App Server: https://developers.openai.com/codex/app-server
- OpenAI Codex SDK: https://developers.openai.com/codex/sdk
- Slack Events API: https://docs.slack.dev/apis/events-api/
- Slack Socket Mode: https://docs.slack.dev/apis/events-api/using-socket-mode
- Slack chat.postMessage: https://docs.slack.dev/reference/methods/chat.postMessage

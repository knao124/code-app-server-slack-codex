# Product Brief

## Goal

SlackにCodexが常駐し、人間の部下と同じように報告・相談・作業依頼を行える状態を作る。

ユーザーは常にPCを開いているわけではないため、Codexとの接点をCodexアプリではなくSlackに寄せる。Slack上で日報、進捗、相談、作業指示、レビュー依頼、意思決定を扱う。

## Target Users

- オーナー: knao124
- Slack上で協働する人間メンバー
- Slack常駐のCodex bot

## Primary Use Cases

1. ユーザーがSlackのプロジェクトチャンネルでCodexに相談する。
2. ユーザーがプロジェクトチャンネルでCodexに作業を依頼する。
3. Codexが作業中の進捗をSlack threadに投稿する。
4. Codexが判断待ち、権限不足、設計判断の必要性を該当チャンネルのthreadで相談する。
5. Codexが毎日決まった時間に日報を投稿する。
6. Codexが他メンバーのSlack報告を読み、関連タスクやブロッカーを把握する。
7. CodexがGitHub issue/PR/CIなどの外部状態を見て、Slack上に必要な報告を出す。

## Non-goals for MVP

- 完全自律で本番反映する。
- 全Slackチャンネルを無制限に読む。
- ユーザー承認なしで危険なローカルコマンドやインフラ変更を実行する。
- 最初から複数ワークスペースや複数組織に対応する。
- Slack Marketplace公開を目指す。

## MVP Definition

MVPは次を満たせばよい。

- Slackチャンネル上のmention、thread返信、slash commandを受け取れる。
- Slack eventを3秒以内にACKし、処理は非同期ジョブ化する。
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

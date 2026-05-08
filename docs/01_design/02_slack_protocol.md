# Slack Protocol

## Design Intent

Codex botは「ツール」ではなくSlack上の常駐メンバーとして振る舞う。

そのため、Botの発話は次のSlack作法に従う。

- 作業依頼にはthreadで返す。
- 判断が必要な相談もチャンネルのthreadで行う。
- 個人宛ての確認が必要な場合も、該当チャンネルまたは運用チャンネルでownerをmentionする。
- 日報は人間と同じ日報チャンネルに投稿する。
- 長い実行ログを垂れ流さず、要約、差分、次アクションを中心に投稿する。

## Event Sources

### Project Channel Mention

用途:

- プロジェクトチャンネルでの作業依頼
- プロジェクトチャンネルでの設計相談
- 他メンバーとの会話にBotを参加させる

### Thread Reply

用途:

- 既存依頼への追加指示
- Codexからの進捗報告への返答
- 判断待ちへの回答

### Operations Channel

用途:

- 複数プロジェクトにまたがる運用相談
- 承認待ち通知
- 権限不足や実行環境の異常報告
- ownerだけでなく関係者が見える形での意思決定

### Project Channel Watch

用途:

- 他メンバーの日報や進捗の把握
- ブロッカー検知
- Codexが関係するタスクの拾い上げ

MVPでは明示的にinviteされたチャンネルのみ読む。

### Slash Commands

候補:

- `/codex ask ...`
- `/codex status`
- `/codex daily`
- `/codex pause`
- `/codex resume`

MVPでは必須ではない。チャンネルmentionとthread返信だけでも開始できる。

## Message Categories

### Request

ユーザーまたはメンバーからCodexへの依頼。

例:

```text
@codex-worker このissueを調べて、実装方針を出して
```

Botの応答:

```text
受け取りました。調査してこのスレッドに戻します。
```

その後、同じthreadに進捗・結果を投稿する。

### Progress Update

長い作業の途中報告。

投稿内容:

- 今やっていること
- 見つかった事実
- 次にやること
- ブロッカーがあるか

### Decision Request

Botが自律判断できない場合の相談。

投稿先:

- 依頼元が明確なら、元のproject channel thread
- 横断的な運用判断なら、operations channel thread
- owner判断が必要なら、上記thread内でownerをmention

必要要素:

- 判断が必要な理由
- 選択肢
- 推奨案
- 放置した場合の扱い

### Daily Report

日報チャンネルに投稿する。

初期フォーマット:

```text
今日やったこと
- ...

進行中
- ...

詰まり・相談
- ...

明日やること
- ...
```

Botの日報は、実行ジョブ、相談、レビュー、未完了タスクから自動生成する。

## Slack Thread Mapping

内部jobとSlack threadを対応づける。

```text
job_id
slack_team_id
slack_channel_id
slack_thread_ts
slack_root_message_ts
requester_user_id
project_key
status
```

## ACK and Async Rule

Slack event受信時は、外部APIやCodex実行を待たずにACKする。

処理フロー:

```text
receive event
validate signature or socket payload
deduplicate event_id
enqueue job
ack
worker processes job
post/update Slack thread
```

## Required Slack Scopes

MVP候補:

- `app_mentions:read`
- `chat:write`
- `channels:history`
- `groups:history`
- `users:read`
- `commands` if slash commands are enabled
- `connections:write` if Socket Mode is used

実際のscopeはSlack App作成時に最小権限へ絞る。

## Rate Limit Policy

- 同一threadへの進捗投稿は間引く。
- 長文は要約して投稿する。
- 詳細ログは内部DBまたはartifactに保存し、Slackにはリンクか要約を出す。
- Slack API rate limit時はretry-afterに従って再試行する。

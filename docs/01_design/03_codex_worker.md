# Codex Worker

## Role

Codex Workerは、Slackから来た依頼を実際の調査・設計・実装・レビュー作業へ変換する。

Slack Botは人間とのプロトコルを担い、Codex Workerは作業実行を担う。

## Execution Modes

### Conversation Mode

軽い相談、設計相談、質問への回答。

- Slack DMやthreadを会話履歴として渡す。
- 外部repo変更はしない。
- 必要なら「作業ジョブへ昇格しますか」と確認する。

### Task Mode

調査、設計、実装、テスト、PR作成などの作業。

- job_idを発行する。
- 作業ディレクトリを作る。
- GitHub repoをclone/fetchする。
- 必要なコマンドを実行する。
- Slack threadに進捗を返す。
- 完了時に成果物、差分、テスト結果、未解決事項を投稿する。

### Scheduled Mode

日報、定期巡回、ブロッカー確認。

- 前回実行以降のジョブ履歴を見る。
- GitHub/Slack/CIの状態を見て要約する。
- 日報チャンネルへ投稿する。

## Executor Adapter Interface

想定interface:

```text
start_task(request) -> task_handle
stream_events(task_handle) -> events
cancel_task(task_handle) -> result
resume_task(task_handle, user_input) -> result
```

adapter実装候補:

- `CodexSdkExecutor`
- `CodexCliExecutor`
- `CodexAppServerExecutor`

## App Server Usage Position

`codex app-server` は、Codex thread/turnを外部プロセスから扱える点でこの用途と相性がよい。

ただし現時点ではexperimental扱いのため、設計上はadapterの1つに留める。Slack Bot全体をApp Server固有protocolへ強く結合しない。

## Workspace Management

Codex Workerは作業ごとにworkspaceを分ける。

```text
/srv/slack-codex/
├── data/
│   ├── bot.sqlite
│   └── artifacts/
└── workspaces/
    └── jobs/
        └── <job_id>/
```

GitHub repoを扱う場合:

- repo cloneは `/srv/slack-codex/workspaces/repos/<owner>/<repo>` にcacheする。
- jobごとにworktreeを切る。
- 作業branchは `codex/<slug>` にする。
- destructive commandは禁止または承認必須にする。

## Approval Model

Codex Workerは次の操作で承認を要求する。

- `terraform apply`
- production環境への変更
- secret閲覧
- destructive git command
- GitHubへのpush
- PR merge
- Slackで広範囲にmentionする投稿
- 課金・外部サービス変更

承認はSlack interactive buttonまたはowner DMで行う。

## Progress Events

workerは内部eventを発行する。

```text
job.accepted
job.started
job.progress
job.needs_decision
job.command_started
job.command_finished
job.completed
job.failed
```

Slack投稿はAgent Controllerがeventを整形して行う。

## Daily Report Source

日報は次から生成する。

- completed jobs
- in-progress jobs
- failed jobs
- pending approvals
- unanswered decision requests
- subscribed GitHub issue/PR updates
- subscribed Slack project channel highlights

## Failure Handling

Codex実行が失敗した場合:

- Slack threadに失敗理由を投稿する。
- retry可能か判定する。
- retry不能ならownerに相談する。
- job statusをfailedへ更新する。
- command outputなどの詳細はartifactへ保存する。

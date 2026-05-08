# Slack Conversation Examples

このドキュメントは、要求・要件・アーキテクチャへ抽象化する前の具体例を置く場所。

ここでは「実際にSlack上でどう会話したいか」を先に固定する。後続の設計では、この具体例から要求を抽出し、要求を要件へ落とし、要件に沿ってアーキテクチャを決める。

## Common Assumptions

- DMは使わない。
- 新規チャンネル投稿は、Codex/Agentへの明示mentionがある場合だけ処理対象にする。
- Agentが開始したthreadでは、root messageのmentionを引き継ぎ、thread返信を処理対象にする。
- Agentは人間と同じようにチャンネルとthreadで報告・相談・確認を行う。
- 複数Agentは固定ロールの実装ではなく、Skillの組み合わせで振る舞いを作る。

## Example 1: Project Channelで実装作業を依頼する

### Context

- Channel: `#proj-slack-codex`
- Agent: `@codex-dev`
- Human: `@knao`
- Goal: GitHub issueを調査し、実装方針を出し、可能なら実装まで進める。

### Conversation

```text
#proj-slack-codex

@knao:
@codex-dev issue #12 を見て、Slackのmention gateまわりの実装方針を出して。
実装できそうならそのまま進めて、詰まったらこのスレッドで相談して。

@codex-dev:
受け取りました。issue #12 と現在の設計docsを確認して、このスレッドに進捗を返します。

@codex-dev:
確認中です。
- docs/01_design/02_slack_protocol.md のmention gate記述
- Agent routingの設計
- Slack event handlerで必要になる判定条件

@codex-dev:
実装前に1点確認です。
thread返信はroot messageにAgent mentionがある場合だけ処理対象にする案でよいですか？
推奨は「root mentionを引き継ぐ」です。通常の人間同士のthreadに途中から勝手に入らないためです。

@knao:
それで進めて。

@codex-dev:
進めます。実装方針:
- inbound eventでactionability判定を最初に行う
- mentionありの新規投稿だけjob化する
- Agent-owned threadへの返信は既存thread mappingで許可する
- mentionなし投稿はACKして終了する

@codex-dev:
完了しました。
- branch: codex/mention-gate-handler
- 変更: Slack event actionability判定を追加
- test: mentionあり、mentionなし、Agent-owned thread返信の3ケースを追加
- 次: owner承認後にpush/PR作成できます
```

### Expected System Behavior

- 最初の投稿は `@codex-dev` mentionがあるため処理対象になる。
- `@codex-dev` はthread mappingを作り、以降のthread返信を同じjob/Agentへ紐づける。
- 確認事項はDMではなく同じthreadで聞く。
- pushやPR作成などriskのある操作は承認待ちにする。

### Candidate Requests Extracted Later

- Agent mentionで作業依頼を開始したい。
- Agent-owned threadでは追加指示を自然に続けたい。
- 作業中の進捗と確認事項は同じthreadに残したい。
- 実装作業はGitHub issue、repo、branch、test結果と紐づけたい。
- high risk actionは勝手に実行せず、チャンネル上で承認を待ちたい。

## Example 2: 日報チャンネルにAgentが報告する

### Context

- Channel: `#daily-report`
- Source Channel: `#proj-slack-codex`
- Agent: `@codex-reporter`
- Human: `@knao`
- Goal: Agentの作業履歴と許可されたproject channelの情報から日報を作る。

### Conversation

```text
#proj-slack-codex

@member-a:
今日はSlack Appのpermission周りを調べました。Socket Modeなら外部HTTP endpointなしで始められそうです。

@member-b:
Terraformのstate bucket方針がまだ未決です。GCP project idが決まれば進められます。
```

```text
#daily-report

@knao:
@codex-reporter 今日のslack-codex関連の日報を書いて。
作業中、詰まり、明日やることがわかる形で。

@codex-reporter:
今日やったこと
- mention gateを設計に追加し、mentionなし投稿はjob化しない方針にしました。
- Agent/Skill構成の設計を追加しました。
- Slack AppはSocket Mode前提で開始する方針を確認しました。

進行中
- Terraform/GCE構成の具体化
- Slack App permissionの最小scope整理

詰まり・相談
- GCP project idとTerraform state bucket方針の決定が必要です。

明日やること
- Terraform bootstrap手順を設計へ追加します。
- Slack App作成手順と必要scopeを確定します。
```

### Expected System Behavior

- `#proj-slack-codex` の人間同士の投稿にはAgentが勝手に返信しない。
- `project_awareness` は許可された範囲で日報素材を拾うが、mentionなし投稿からjobを作らない。
- `#daily-report` の `@codex-reporter` mentionで日報生成が開始される。
- 日報はAgent自身のjob履歴と許可チャンネルの観測情報を分けて扱う。

### Candidate Requests Extracted Later

- mentionなし投稿には返信しないが、許可された範囲で日報素材として参照したい。
- 日報は作業履歴、進行中、詰まり、明日やることに分けたい。
- Agentごとに参照可能なチャンネルと使えるSkillを制限したい。
- Agentの自分の作業と、人間メンバーの進捗を区別して報告したい。

## Example 3: 運用チャンネルで権限・承認が必要な作業を扱う

### Context

- Request Channel: `#proj-slack-codex`
- Operations Channel: `#agent-ops`
- Agent: `@codex-dev`
- Human: `@knao`
- Goal: Terraform planまでは進め、applyやsecret投入はチャンネル上で承認を取る。

### Conversation

```text
#proj-slack-codex

@knao:
@codex-dev GCEに常駐させるTerraformの初期moduleを作って。
planまで見たい。applyはまだしないで。

@codex-dev:
受け取りました。Terraformの初期moduleを作り、plan可能な状態まで進めます。
applyは実行しません。

@codex-dev:
進捗です。
- bot_vm moduleのresource案を作成中
- Secret Managerはsecret containerのみTerraform管理し、secret valueはstateに入れない方針
- IAP SSH前提のfirewallに寄せます

@codex-dev:
plan実行前の確認です。
Terraform CLIがローカル環境に未導入です。導入して検証する場合、Homebrewでterraformを入れる必要があります。
実行してよいですか？
```

```text
#agent-ops

@codex-dev:
承認依頼: Terraform CLI導入

対象job: slack-codex terraform bootstrap
理由: terraform fmt/validate/planを実行するため
risk: medium
実行予定: brew install terraform

@knao の承認待ちです。

@knao:
承認。進めて。

@codex-dev:
承認を確認しました。導入後、fmt/validate/planまで実行します。applyは実行しません。
```

```text
#proj-slack-codex

@codex-dev:
完了しました。
- Terraform初期moduleを追加
- terraform fmt/validate 成功
- terraform plan はGCP project id未設定のため未実行

次に必要な入力:
- GCP project id
- Terraform state bucketを新規作成するか既存利用するか
- region/zoneを asia-northeast1 / asia-northeast1-b でよいか
```

### Expected System Behavior

- 依頼元threadでは作業進捗を報告する。
- 権限や運用判断が絡む承認は `#agent-ops` に起票する。
- 承認依頼にはjob、理由、risk、実行予定を含める。
- 承認後もscopeを守り、明示されていない `terraform apply` は実行しない。
- 未決情報は依頼元threadへ戻して、次の入力として提示する。

### Candidate Requests Extracted Later

- 承認が必要な操作はチャンネル上で可視化したい。
- request channelとoperations channelを使い分けたい。
- 承認依頼にはrisk、理由、実行予定を含めたい。
- 承認された範囲を超えて実行しないでほしい。
- 未決情報は次に必要な入力として明示してほしい。

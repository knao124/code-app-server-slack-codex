# prod

GCE上でSlack常駐Codex botを動かすproduction環境。

## Bootstrap Inputs

Terraform実装前に確定するもの:

- `project_id`
- `region`
- `zone`
- Terraform state用GCS bucket名
- Bot用GCE machine type
- Slack日報チャンネルID
- owner Slack user ID

## Backend

Terraform backendはGCSを想定する。backend blockはbucket作成後に追加する。

## Commands

```sh
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

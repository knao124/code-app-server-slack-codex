variable "project_id" {
  description = "GCP project ID that hosts the Slack Codex bot."
  type        = string
}

variable "region" {
  description = "Default GCP region."
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "Default GCP zone."
  type        = string
  default     = "asia-northeast1-b"
}

variable "bot_name" {
  description = "Base name for bot runtime resources."
  type        = string
  default     = "slack-codex-bot"
}

variable "machine_type" {
  description = "GCE machine type for the initial single-VM deployment."
  type        = string
  default     = "e2-small"
}

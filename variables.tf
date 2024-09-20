variable "bid_price" {
  default = 0.002000
}

variable "slack_webhook" {
  default = ""
}

variable "region" {
  default = "us-east-iad-1"
}

variable "token" {
  type      = string
  sensitive = true
}

variable "type" {
  type    = string
  default = "gen1"
}

variable "server_count" {
  type    = string
  default = 1
}

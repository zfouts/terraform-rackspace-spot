terraform {
  required_providers {
    spot = {
      source  = "rackerlabs/spot"
      version = "0.1.0"
    }
  }
}

locals {
  cloudspace_name = "${try(length(var.cloudspace_prefix) > 0 ? var.cloudspace_prefix : var.type)}-${var.region}"
}

provider "spot" {
  token = var.token
}

resource "spot_cloudspace" "this" {
  cloudspace_name    = local.cloudspace_name
  region             = var.region
  hacontrol_plane    = false
  preemption_webhook = var.slack_webhook
  deployment_type    = var.type
  wait_until_ready   = false
}

data "spot_serverclasses" "all" {
  filters = [
    {
      name   = "resources.memory"
      values = [">${try(var.minimum_size, 8)}GB"]
    }
  ]
}

data "spot_serverclass" "this" {
  for_each = toset(data.spot_serverclasses.all.names)
  name     = each.key
}

# Dynamic spotnodepool resource with additional logic for gen2 deployment_type

resource "spot_spotnodepool" "dynamic" {
  for_each = var.dynamic_spotnodepool ? {
    for name, details in data.spot_serverclass.this : name => details
    if details.region == var.region &&
    details.status.spot_pricing.hammer_price_per_hour <= var.bid_price &&
    details.status.spot_pricing.market_price_per_hour <= var.bid_price &&
    !can(regex("^${var.static_server_class}", name)) &&
    !(var.type == "gen2" && can(regex("\\.bm2\\.", name)))
  } : {}

  cloudspace_name      = local.cloudspace_name
  server_class         = each.key
  bid_price            = var.bid_price
  desired_server_count = var.server_count
}

# Static spotnodepool resource with additional logic for gen2 deployment_type
resource "spot_spotnodepool" "static" {
  for_each = var.static_spotnodepool && !(var.type == "gen2" && can(regex("\\.bm\\.", var.static_server_class))) ? {
    static_pool = {
      cloudspace_name      = local.cloudspace_name
      server_class         = var.static_server_class
      bid_price            = var.static_bid_price
      desired_server_count = var.static_server_count
    }
  } : {}

  cloudspace_name      = each.value.cloudspace_name
  server_class         = each.value.server_class
  bid_price            = each.value.bid_price
  desired_server_count = each.value.desired_server_count
}

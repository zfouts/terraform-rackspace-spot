terraform {
  required_providers {
    spot = {
      source  = "rackerlabs/spot"
      version = "0.1.0"
    }
  }
}

locals {
  cloudspace_name = "${var.region}-cloudspace"
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
}

data "spot_serverclasses" "all" {
  filters = [
    {
      name   = "resources.memory"
      values = [">16GB"]
    }
  ]
}

data "spot_serverclass" "this" {
  for_each = toset(data.spot_serverclasses.all.names)
  name     = each.key
}

resource "spot_spotnodepool" "this" {
  for_each = {
    for name, details in data.spot_serverclass.this : name => details
    if details.region == var.region &&
    details.status.spot_pricing.hammer_price_per_hour <= var.bid_price &&
    details.status.spot_pricing.market_price_per_hour <= var.bid_price
  }

  cloudspace_name      = local.cloudspace_name
  server_class         = each.key
  bid_price            = var.bid_price
  desired_server_count = var.server_count
}

resource "null_resource" "wait_for_cloudspace" {
  provisioner "local-exec" {
    command = "sleep 600"
  }

  depends_on = [spot_cloudspace.this]
}

data "spot_kubeconfig" "this" {
  cloudspace_name = local.cloudspace_name

  depends_on = [null_resource.wait_for_cloudspace]
}

resource "local_file" "kubeconfig_yaml" {
  content  = data.spot_kubeconfig.this.raw
  filename = "${path.module}/kubeconfig-${local.cloudspace_name}.yaml"

  depends_on = [data.spot_kubeconfig.this]
}


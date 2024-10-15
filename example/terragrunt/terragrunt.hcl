terraform {
  source = "../../"
}

include "common" {
  path = "common.hcl"
  merge_strategy = "deep"
}


inputs = {
  # Cloudspace wide settings
  cloudspace_prefix    = "example"
  region               = "us-central-ord-1"
  type                 = "gen2"

  ## Dynamic nodes based on price/ram
  dynamic_spotnodepool = true
  minimum_size         = 8
  server_count         = 4
  bid_price            = 1.50

  ## Static nodes
  static_spotnodepool  = true
  static_server_class  = "mh.vs1.xlarge-ord"
  static_bid_price     = 1.50
  static_server_count  = 2
}


# Rackspace Kubernetes Spot Price Terraform Module

This Terraform module provisions a Kubernetes cluster in [Rackspace Spot](https://spot.rackspace.com), enabling users to specify bid prices for spot instances and leverage cost savings. It also integrates optional Slack notifications for instance preemption events.

## Features

- Creates a Rackspace cloudspace with configurable bid price limits for spot instances.
- Dynamically filters available server classes based on resource requirements (e.g., memory size).
- Supports both **dynamic** and **static** spot node pools, with configurable deployment types (`gen1`, `gen2`).
- Automatically generates a Kubernetes `kubeconfig` file for cluster access.
- Integrates Slack webhook notifications for instance preemption events.

## Usage

### Example

```hcl
module "rackspace_k8s_spot" {
  source              = "./path/to/module"
  region              = "us-east-iad-1"
  token               = "your-spot-api-token"
  slack_webhook       = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
  type                = "gen1"
  bid_price           = 0.005
  server_count        = 3
  dynamic_spotnodepool = true
  static_spotnodepool  = false
}
```

### Inputs

| Name                   | Description                                              | Type     | Default             | Required |
|------------------------|----------------------------------------------------------|----------|---------------------|----------|
| `bid_price`            | Maximum bid price per hour (in USD) for spot instances.  | `number` | `0.002`             | no       |
| `slack_webhook`        | Slack webhook URL for preemption notifications.           | `string` | `""`                | no       |
| `region`               | Rackspace region where the cloudspace will be deployed.  | `string` | `"us-east-iad-1"`   | no       |
| `token`                | Rackspace Spot API token for authentication.             | `string` | n/a                 | yes      |
| `type`                 | Deployment type (`gen1`, `gen2`).                         | `string` | `"gen1"`            | no       |
| `server_count`         | Desired number of spot instances in the dynamic node pool.| `number` | `1`                 | no       |
| `cloudspace_prefix`    | Prefix for the cloudspace name.                           | `string` | `""`                | no       |
| `minimum_size`         | Minimum memory size (in GB) for server classes.           | `number` | `8`                 | no       |
| `dynamic_spotnodepool` | Enable dynamic spot node pool.                            | `bool`   | `true`              | no       |
| `static_spotnodepool`  | Enable static spot node pool.                             | `bool`   | `false`             | no       |
| `static_server_class`  | Server class for static node pool.                        | `string` | `"m5.large"`        | no       |
| `static_bid_price`     | Bid price for the static node pool.                       | `number` | `0.002`             | no       |
| `static_server_count`  | Number of servers for the static node pool.               | `number` | `1`                 | no       |

### Outputs

| Name               | Description                                    |
|--------------------|------------------------------------------------|
| `kubeconfig_yaml`  | Kubernetes `kubeconfig` file for cluster access.|
| `cloudspace_name`  | The name of the created cloudspace.            |

## Requirements

| Name          | Version  |
|---------------|----------|
| Terraform     | >= 1.0.0 |
| Spot Provider | >= 0.1.0 |

### Providers

| Name   | Version |
|--------|---------|
| spot   | 0.1.0   |

## Resources

- **Cloudspace**: Creates a Rackspace cloudspace in the specified region.
- **Dynamic Node Pool**: Provisions servers dynamically based on bid price and server class filters.
- **Static Node Pool**: Allows for static provisioning of spot instances with specified server classes and bid prices.
- **Kubernetes Config**: Generates a `kubeconfig` file for cluster access.
- **Slack Notifications**: Sends Slack alerts on instance preemption.

## How it works

1. **Cloudspace Creation**: Provisions a cloudspace in the chosen Rackspace region.
2. **Dynamic Spot Instances**: Filters server classes by memory size and compares current prices to your bid price, creating instances that meet the criteria.
3. **Static Spot Instances**: Creates a fixed node pool with specified server classes and bid prices.
4. **Kubernetes Configuration**: Generates a `kubeconfig` file for Kubernetes cluster access.
5. **Preemption Notifications**: Sends notifications to a Slack channel on instance preemption (if a webhook is provided).



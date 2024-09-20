# Rackspace Kubernetes Spot Price Terraform Module

This Terraform module provisions a Kubernetes cluster in [Rackspace Spot](https://spot.rackspace.com), allowing users to specify bid prices for spot instances and leverage cost savings. It also integrates optional Slack notifications for preemption events.

## Features

- Creates a Rackspace cloudspace with the ability to set a maximum bid price for spot instances.
- Filters available server classes based on resource requirements (e.g., memory > 16GB).
- By default, provisions **2 instances** of any server class that meets the filter criteria.
- Generates a Kubernetes `kubeconfig` for cluster access.
- Supports Slack webhook integration for preemption notifications.

## Usage

### Example

```hcl
module "rackspace_k8s_spot" {
  source        = "./path/to/module"
  region        = "us-east-iad-1"
  token         = "your-spot-api-token"
  slack_webhook = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
  type          = "gen1"
  bid_price     = 0.005
  server_count  = 3
}
```

### Inputs

| Name            | Description                                         | Type     | Default             | Required |
|-----------------|-----------------------------------------------------|----------|---------------------|----------|
| `bid_price`     | Maximum bid price per hour (in USD) for spot instances. | `number` | `0.002000`          | no       |
| `slack_webhook` | Slack webhook URL for preemption notifications.      | `string` | `""`                | no       |
| `region`        | The Rackspace region where the cloudspace will be deployed. | `string` | `"us-east-iad-1"`   | no       |
| `token`         | Your Rackspace Spot API token for authentication.    | `string` | n/a                 | yes      |
| `type`          | Type of deployment (e.g., `gen1`, `gen2`).           | `string` | `"gen1"`            | no       |
| `server_count`  | Desired number of spot instances in the node pool.   | `string` | `1`                 | no       |

### Outputs

| Name                  | Description                              |
|-----------------------|------------------------------------------|
| `kubeconfig_yaml`      | Kubernetes `kubeconfig` file for accessing the cluster. |
| `cloudspace_name`      | The name of the created cloudspace.      |

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

- `spot_cloudspace`: Creates a Rackspace cloudspace in the specified region.
- `spot_spotnodepool`: Provisions **2 instances** by default for any server class that meets the filter criteria, based on bid price and server class filters.
- `null_resource.wait_for_cloudspace`: Adds a delay to ensure the cloudspace is fully created before proceeding.
- `local_file.kubeconfig_yaml`: Generates and stores a Kubernetes `kubeconfig` file for cluster access.
- `spot_kubeconfig`: Fetches the `kubeconfig` for the created cloudspace.

## How it works

1. **Cloudspace Creation**: The module provisions a cloudspace in the specified Rackspace region.
2. **Spot Instances**: Filters server classes based on memory (> 16GB) and compares the current spot prices to your bid price. By default, 2 instances are created for any server class that meets the criteria.
3. **Kubernetes Configuration**: Generates a `kubeconfig` file for accessing the Kubernetes cluster.
4. **Preemption Alerts**: Sends Slack notifications when instances are preempted (if a webhook URL is provided).

# Azure Log Analytics Workspace Terraform Module

Deploy an Azure Log Analytics Workspace in an existing resource group, with optional diagnostic settings and Log Analytics solutions.

## Requirements

Terraform >= 1.3.0 and AzureRM >= 4.0, < 5.0.

## Usage

From a Terraform configuration in a sibling directory:

~~~hcl
provider "azurerm" {
  features {}
}

module "log_analytics_workspace" {
  source = "../terraform-azure-log-analytics-workspace-module"

  resource_group_name        = "rg-monitoring"
  workspace_name             = "example-monitoring-la"
  retention_in_days          = 90
  enable_diagnostic_settings = false

  tags = {
    Environment = "Development"
    Project     = "example"
  }
}
~~~

After publishing to GitHub, replace the local source with
git::https://github.com/YOUR_GITHUB_USERNAME/terraform-azure-log-analytics-workspace-module.git?ref=YOUR_RELEASE_TAG,
using your actual account and release tag.

## Naming and tags

workspace_name is used exactly as supplied. When empty, the module joins the nonempty
project, region, env, and la components with hyphens and lowercases the result.
For example, project = "example", location eastus, and env = "dev" produce
example-eastus-dev-la. The default environment is PROD.

The location defaults to the existing resource group's location. The optional
region_code map supplies custom naming abbreviations; otherwise the Azure location
name is used directly.

Tags are optional and accept arbitrary keys and values. The module adds Name,
CreatedBy = "Terraform", and Location; caller-supplied tags override these defaults.

## Configuration notes

- Configure the AzureRM provider and credentials in the calling configuration.
- Configure SKU, retention, ingestion quotas, managed identity, local authentication,
  and internet ingestion/query access through the inputs below.
- Diagnostic settings are enabled by default and target the workspace itself unless
  an external destination workspace is supplied. The example disables them for a
  minimal deployment. Select categories supported by the target resource.
- Solutions deploy only when solutions_enabled = true.
- Customer-managed key infrastructure must be configured separately when required.
- The current resources use lifecycle { ignore_changes = all }. Terraform creates
  them, but subsequent configuration changes to existing resources are ignored.
- The legacy public_network_access_for_query input is currently unused. Configure
  query access with internet_query_enabled.

## Inputs

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| resource_group_name | The name of the existing resource group to deploy the resources | string | Required |
| location | The Azure region to deploy the resources (defaults to resource group's region if not specified) | string | null |
| workspace_name | The exact workspace name. If empty, generates a name from project, region, and env. | string | "" |
| sku | The SKU of the Log Analytics Workspace (e.g., PerGB2018, CapacityReservation) | string | "PerGB2018" |
| reservation_capacity_in_gb_per_day | The capacity reservation level in GB/day for CapacityReservation SKU (100, 200, 300, 400, 500, 1000, 2000, 5000) | number | null |
| retention_in_days | The workspace data retention in days (30 to 730) | number | 90 |
| daily_quota_gb | The daily ingestion quota in GB (-1 for unlimited) | number | -1 |
| public_network_access_for_query | Whether to allow public network access for querying | bool | false |
| local_authentication_disabled | Whether to enforce Azure AD authentication (disables local authentication) | bool | true |
| identity_type | The type of managed identity (None, SystemAssigned, UserAssigned) | string | "SystemAssigned" |
| identity_ids | The list of User Assigned Identity IDs (required if identity_type is UserAssigned) | list(string) | [] |
| enable_diagnostic_settings | Whether to enable diagnostic settings for the Log Analytics Workspace | bool | true |
| diagnostic_log_categories | List of log categories to enable for diagnostic settings | list(string) | ["Audit"] |
| diagnostic_metric_categories | List of metric categories to enable for diagnostic settings | list(string) | ["AllMetrics"] |
| log_analytics_destination_workspace_id | The ID of the Log Analytics Workspace to send diagnostic logs to (if applicable) | string | null |
| log_analytics_destination_type | The type of destination for the logs (e.g., Dedicated, Shared, or null) | string | null |
| storage_account_id | The ID of the storage account for diagnostic settings (if applicable) | string | null |
| eventhub_name | The name of the Event Hub for diagnostic settings (if applicable) | string | null |
| eventhub_authorization_rule_id | The ID of the Event Hub authorization rule for diagnostic settings (if applicable) | string | null |
| solutions_enabled | Whether to enable Log Analytics solutions | bool | false |
| solutions | List of Log Analytics solutions to deploy (e.g., VMInsights, SQLAssessment) | list(string) | [] |
| allow_resource_only_permissions | Whether to allow resource-only permissions for the Log Analytics Workspace | bool | false |
| cmk_for_query_forced | Whether to force customer-managed keys for query operations | bool | false |
| internet_ingestion_enabled | Whether to enable internet ingestion for the Log Analytics Workspace | bool | true |
| internet_query_enabled | Whether to enable internet query for the Log Analytics Workspace | bool | true |
| region_code | Optional map of Azure locations to naming abbreviations. Unmapped locations use the Azure location name. | map(string) | {} |
| tags | Optional tags applied to the workspace and solutions. Caller values override automatic tags. | map(string) | {} |
| project | Project name | string | "" |
| env | Environment name | string | "PROD" |

## Outputs

| Name | Description |
| --- | --- |
| log_analytics_workspace_id | The Azure resource ID of the workspace. |
| log_analytics_workspace_name | The workspace name. |

## Development

Run terraform fmt -check, terraform init -backend=false, and terraform validate
before submitting changes.

## Maintainer

Mocktar Tairou


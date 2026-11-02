
variable "resource_group_name" {
  description = "The name of the existing resource group to deploy the resources"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy the resources (defaults to resource group's region if not specified)"
  type        = string
  default     = null
}
variable "workspace_name" {
  description = "The exact workspace name. If empty, generates a name from project, region, and env."
  type        = string
  default     = ""
}


variable "sku" {
  description = "The SKU of the Log Analytics Workspace (e.g., PerGB2018, CapacityReservation)"
  type        = string
  default     = "PerGB2018"
}


variable "reservation_capacity_in_gb_per_day" {
  description = "The capacity reservation level in GB/day for CapacityReservation SKU (100, 200, 300, 400, 500, 1000, 2000, 5000)"
  type        = number
  default     = null
}

variable "retention_in_days" {
  description = "The workspace data retention in days (30 to 730)"
  type        = number
  default     = 90
}

variable "daily_quota_gb" {
  description = "The daily ingestion quota in GB (-1 for unlimited)"
  type        = number
  default     = -1
}


variable "public_network_access_for_query" {
  description = "Whether to allow public network access for querying"
  type        = bool
  default     = false
}

variable "local_authentication_disabled" {
  description = "Whether to enforce Azure AD authentication (disables local authentication)"
  type        = bool
  default     = true
}

variable "identity_type" {
  description = "The type of managed identity (None, SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "The list of User Assigned Identity IDs (required if identity_type is UserAssigned)"
  type        = list(string)
  default     = []
}

variable "enable_diagnostic_settings" {
  description = "Whether to enable diagnostic settings for the Log Analytics Workspace"
  type        = bool
  default     = true
}

variable "diagnostic_log_categories" {
  description = "List of log categories to enable for diagnostic settings"
  type        = list(string)

  default = ["Audit"]
}

variable "diagnostic_metric_categories" {
  description = "List of metric categories to enable for diagnostic settings"
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "log_analytics_destination_workspace_id" {
  description = "The ID of the Log Analytics Workspace to send diagnostic logs to (if applicable)"
  type        = string
  default     = null
}

variable "log_analytics_destination_type" {
  description = "The type of destination for the logs (e.g., Dedicated, Shared, or null)"
  type        = string
  default     = null
}

variable "storage_account_id" {
  description = "The ID of the storage account for diagnostic settings (if applicable)"
  type        = string
  default     = null
}

variable "eventhub_name" {
  description = "The name of the Event Hub for diagnostic settings (if applicable)"
  type        = string
  default     = null
}

variable "eventhub_authorization_rule_id" {
  description = "The ID of the Event Hub authorization rule for diagnostic settings (if applicable)"
  type        = string
  default     = null
}


variable "solutions_enabled" {
  description = "Whether to enable Log Analytics solutions"
  type        = bool
  default     = false
}

variable "solutions" {
  description = "List of Log Analytics solutions to deploy (e.g., VMInsights, SQLAssessment)"
  type        = list(string)
  default     = []
}

variable "allow_resource_only_permissions" {
  description = "Whether to allow resource-only permissions for the Log Analytics Workspace"
  type        = bool
  default     = false
}

variable "cmk_for_query_forced" {
  description = "Whether to force customer-managed keys for query operations"
  type        = bool
  default     = false
}

variable "internet_ingestion_enabled" {
  description = "Whether to enable internet ingestion for the Log Analytics Workspace"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether to enable internet query for the Log Analytics Workspace"
  type        = bool
  default     = true
}

variable "region_code" {
  description = "Optional map of Azure locations to naming abbreviations. Unmapped locations use the Azure location name."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Optional tags applied to the workspace and solutions. Caller values override automatic tags."
  type        = map(string)
  default     = {}
}
variable "project" {
  type        = string
  description = "Project name"
  default     = ""
}

variable "env" {
  type        = string
  description = "Environment name"
  default     = "PROD"
}


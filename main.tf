locals {
  resource_group_name = var.resource_group_name
  location            = var.location != null ? var.location : data.azurerm_resource_group.existing.location
  region              = lookup(var.region_code, local.location, local.location)
  base_name           = lower(join("-", compact([var.project, local.region, var.env, "la"])))
  workspace_name      = var.workspace_name != "" ? var.workspace_name : local.base_name
}

data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}
# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.workspace_name
  resource_group_name = local.resource_group_name
  location            = local.location

  allow_resource_only_permissions = var.allow_resource_only_permissions
  cmk_for_query_forced            = var.cmk_for_query_forced
  internet_ingestion_enabled      = var.internet_ingestion_enabled
  internet_query_enabled          = var.internet_query_enabled



  # SKU and Capacity Reservation
  sku                                = var.sku
  reservation_capacity_in_gb_per_day = var.sku == "CapacityReservation" ? var.reservation_capacity_in_gb_per_day : null

  # Data Retention and Quota
  retention_in_days = var.retention_in_days
  daily_quota_gb    = var.daily_quota_gb


  # Authentication
  local_authentication_enabled = !var.local_authentication_disabled

  # Managed Identity
  dynamic "identity" {
    for_each = var.identity_type != "None" ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }


  tags = merge(
    {
      "Name"      = "${local.workspace_name}"
      "CreatedBy" = "Terraform"
      "Location"  = "${local.region}"
    },
    var.tags,
  )

  lifecycle {
    ignore_changes = all
  }

}

# Diagnostic Settings for the Log Analytics Workspace
resource "azurerm_monitor_diagnostic_setting" "law" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${local.workspace_name}-diagnostics"
  target_resource_id         = azurerm_log_analytics_workspace.main.id
  log_analytics_workspace_id = var.log_analytics_destination_workspace_id != null ? var.log_analytics_destination_workspace_id : azurerm_log_analytics_workspace.main.id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_metric" {
    for_each = var.diagnostic_metric_categories
    content {
      category = enabled_metric.value
    }
  }

  log_analytics_destination_type = var.log_analytics_destination_type != null ? var.log_analytics_destination_type : null

  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id

  lifecycle {
    ignore_changes = all
  }

}

# Deploy Log Analytics Solutions (e.g., VMInsights, SQLAssessment)
resource "azurerm_log_analytics_solution" "solutions" {
  for_each = var.solutions_enabled ? toset(var.solutions) : toset([])

  solution_name         = each.key
  resource_group_name   = local.resource_group_name
  location              = local.location
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = local.workspace_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/${each.key}"
  }

  tags = merge(
    {
      "Name"      = each.key
      "CreatedBy" = "Terraform"
      "Location"  = "${local.region}"
    },
    var.tags,
  )

  lifecycle {
    ignore_changes = all
  }
}



// IAM: Create and assign a Check Point VNet peering custom role.

data "azurerm_subscription" "current" {}

// Local values used throughout the configuration.
locals {
  checkpoint_vnet_peering_role_name        = "CheckPoint-VNet-Peering-Role"
  checkpoint_vnet_peering_role_description = "Allow VNet peering on the scoped subscriptions."
  checkpoint_vnet_peering_role_actions = [
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
    "Microsoft.Network/virtualNetworks/peer/action"
  ]

  checkpoint_sp_object_id = coalesce(
    length(trimspace(var.checkpoint_sp_object_id)) > 0 ? trimspace(var.checkpoint_sp_object_id) : null,
    length(trimspace(var.isv_sp_object_id)) > 0 ? trimspace(var.isv_sp_object_id) : null,
    azuread_service_principal.checkpoint.object_id
  )
}


// Create the Check Point service principal
resource "azuread_application" "checkpoint" {
  display_name = "CheckPoint-VNetPeering"
}

resource "azuread_service_principal" "checkpoint" {
  client_id = azuread_application.checkpoint.client_id
}

resource "time_sleep" "wait_for_checkpoint_sp_replication" {
  depends_on = [azuread_service_principal.checkpoint]

  create_duration = "45s"
}

resource "azurerm_role_definition" "checkpoint_vnet_peering" {
  name        = local.checkpoint_vnet_peering_role_name
  scope       = data.azurerm_subscription.current.id
  description = local.checkpoint_vnet_peering_role_description

  permissions {
    actions          = local.checkpoint_vnet_peering_role_actions
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = var.assignable_scopes
}

resource "azurerm_role_assignment" "checkpoint_vnet_peering_assignment" {
  for_each = toset(var.assignable_scopes)

  scope              = each.value
  role_definition_id = azurerm_role_definition.checkpoint_vnet_peering.role_definition_resource_id
  principal_id       = local.checkpoint_sp_object_id
  principal_type     = "ServicePrincipal"

  depends_on = [
    time_sleep.wait_for_checkpoint_sp_replication,
    azurerm_role_definition.checkpoint_vnet_peering
  ]

  lifecycle {
    precondition {
      condition     = local.checkpoint_sp_object_id != null
      error_message = "Set checkpoint_sp_object_id (preferred) or isv_sp_object_id (legacy)."
    }
  }
}

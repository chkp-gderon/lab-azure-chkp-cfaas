// IAM: Create and assign a Check Point VNet peering custom role.

data "azurerm_subscription" "current" {}

// Local values used throughout the configuration.
locals {
  checkpoint_vnet_peering_role_name        = "CheckPoint-VNet-Peering-Role"
  checkpoint_vnet_peering_role_description = "Allow VNet peering on the scoped resources."
  checkpoint_vnet_peering_role_actions = [
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
    "Microsoft.Network/virtualNetworks/peer/action"
  ]

  checkpoint_sp_object_id = trimspace(var.checkpoint_sp_object_id) != "" ? trimspace(var.checkpoint_sp_object_id) : (
    trimspace(var.isv_sp_object_id) != "" ? trimspace(var.isv_sp_object_id) : null
  )

  # By default, create role assignments at each assignable scope. When
  # role_assignment_scopes is provided, allow more granular scopes such as VNets.
  checkpoint_role_assignment_scopes = length(var.role_assignment_scopes) > 0 ? var.role_assignment_scopes : var.assignable_scopes
}


// NOTE: Creation of the Check Point Azure AD application/service-principal
// has been removed. Provide an existing service principal object ID via
// `checkpoint_sp_object_id` (preferred) or `isv_sp_object_id` (legacy).

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
  for_each = local.checkpoint_sp_object_id != null ? toset(local.checkpoint_role_assignment_scopes) : []

  scope              = each.value
  role_definition_id = azurerm_role_definition.checkpoint_vnet_peering.role_definition_resource_id
  principal_id       = local.checkpoint_sp_object_id
  principal_type     = "ServicePrincipal"

  depends_on = [azurerm_role_definition.checkpoint_vnet_peering]

  # Role assignments are only created when a Check Point service principal
  # object ID is provided via `checkpoint_sp_object_id` or `isv_sp_object_id`.
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "checkpoint_service_principal" {
  value = {
    client_id    = azuread_application.checkpoint.client_id
    object_id    = azuread_service_principal.checkpoint.object_id
    display_name = azuread_application.checkpoint.display_name
  }
  description = "Check Point service principal details"
}

output "vnets" {
  value = { for k, v in azurerm_virtual_network.vnet : k => {
    id            = v.id
    name          = v.name
    address_space = v.address_space
  } }
}

output "vms" {
  value = { for k, v in azurerm_linux_virtual_machine.vm : k => {
    id        = v.id
    name      = v.name
    public_ip = try(azurerm_public_ip.pip[k].ip_address, null)
    nic_id    = azurerm_network_interface.nic[k].id
  } }
}

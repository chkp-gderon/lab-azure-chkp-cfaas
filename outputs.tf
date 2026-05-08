output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "checkpoint_service_principal" {
  value = {
    object_id = trimspace(var.checkpoint_sp_object_id) != "" ? trimspace(var.checkpoint_sp_object_id) : (
      trimspace(var.isv_sp_object_id) != "" ? trimspace(var.isv_sp_object_id) : null
    )
  }
  description = "Check Point service principal object ID (provided). Client ID/display name not managed by this template."
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

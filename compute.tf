resource "azurerm_public_ip" "pip" {
  for_each = { for name, vm in var.vms : name => vm if vm.public }

  name                = "${local.name_prefix}-${each.key}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "nic-${local.name_prefix}-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet["${local.name_prefix}-${each.value.vnet}-${each.value.subnet}"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.pip[each.key].id, null)
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vms

  name                  = "${local.name_prefix}-${each.key}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  size                  = var.vm_size
  admin_username        = var.admin_username
  tags                  = local.common_tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  computer_name = each.key
}

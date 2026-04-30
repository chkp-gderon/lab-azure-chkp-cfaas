resource "azurerm_resource_group" "rg" {
  name     = local.name_prefix
  location = var.location
  tags     = local.common_tags
}

locals {
  name_prefix = "${var.environment}-${var.project_name}"

  subnet_list = flatten([
    for vname, v in var.vnets : [
      for sname, scidr in v.subnets : {
        vnet = vname
        name = sname
        cidr = scidr
      }
    ]
  ])

  repo = var.repo_name != "" ? var.repo_name : basename(abspath(path.root))

  common_tags = {
    created_by  = "terraform"
    environment = var.environment
    project     = var.project_name
    github_repo = local.repo
  }
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnets
  name                = "${local.name_prefix}-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = each.value.address_space
  tags = local.common_tags
}

resource "azurerm_network_security_group" "bastion" {
  name                = "${local.name_prefix}-nsg-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = { for s in local.subnet_list : "${local.name_prefix}-${s.vnet}-${s.name}" => s }

  name                 = "${local.name_prefix}-${each.value.vnet}-${each.value.name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet].name
  address_prefixes     = [each.value.cidr]
}

resource "azurerm_subnet_network_security_group_association" "bastion_assoc" {
  for_each = { for s in local.subnet_list : "${local.name_prefix}-${s.vnet}-${s.name}" => s if s.vnet == "qa-dep" && s.name == "public" }

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.bastion.id
}


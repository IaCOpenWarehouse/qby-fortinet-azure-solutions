##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Deployment of the virtual network
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${replace(replace(var.vnet, ".", "-"), "/", "-")}-${azurerm_resource_group.resourcegroup.location}"
  address_space       = [var.vnet]
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "snet-${replace(replace(var.subnet["1"], ".", "-"), "/", "-")}-fgt-External"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet["1"]]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "snet-${replace(replace(var.subnet["2"], ".", "-"), "/", "-")}-fgt-Internal"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet["2"]]
}

resource "azurerm_subnet" "subnet3" {
  name                 = "snet-${replace(replace(var.subnet["3"], ".", "-"), "/", "-")}-fgt-HASync"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet["3"]]
}

resource "azurerm_subnet" "subnet4" {
  name                 = "snet-${replace(replace(var.subnet["4"], ".", "-"), "/", "-")}-fgt-Management"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet["4"]]
}

resource "azurerm_subnet" "subnet5" {
  name                 = "snet-${replace(replace(var.subnet["5"], ".", "-"), "/", "-")}-fgt-Protected-A"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet["5"]]
}

resource "azurerm_subnet" "subnet6" {
  name                 = "snet-${replace(replace(var.subnet["6"], ".", "-"), "/", "-")}-fgt-Protected-B"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet["6"]]
}

resource "azurerm_subnet_route_table_association" "subnet5rt" {
  subnet_id      = azurerm_subnet.subnet5.id
  route_table_id = azurerm_route_table.protectedaroute.id
}

resource "azurerm_route_table" "protectedaroute" {
  name                = "rt-${azurerm_subnet.subnet5.name}"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name

  route {
    name                   = "VirtualNetwork"
    address_prefix         = var.vnet
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.lb_internal_ipaddress
  }
  route {
    name           = "Subnet"
    address_prefix = var.subnet["5"]
    next_hop_type  = "VnetLocal"
  }
  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.lb_internal_ipaddress
  }
}

resource "azurerm_subnet_route_table_association" "subnet6rt" {
  subnet_id      = azurerm_subnet.subnet6.id
  route_table_id = azurerm_route_table.protectedbroute.id
}

resource "azurerm_route_table" "protectedbroute" {
  name                = "rt-${azurerm_subnet.subnet6.name}"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name

  route {
    name                   = "VirtualNetwork"
    address_prefix         = var.vnet
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.lb_internal_ipaddress
  }
  route {
    name           = "Subnet"
    address_prefix = var.subnet["6"]
    next_hop_type  = "VnetLocal"
  }
  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.lb_internal_ipaddress
  }
}


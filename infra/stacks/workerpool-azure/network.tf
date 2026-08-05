resource "azurerm_resource_group" "this" {
  name     = "rg-ami-resilience-azure"
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "ami-res-azure-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "worker" {
  name                 = "worker"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]

  # Explicit opt-in to default outbound: the worker is egress-only (pulls from
  # Spacelift + downloads.spacelift.dev) and nothing allowlists its source IP.
  # Azure is retiring the implicit default for new subnets, so we set it here.
  default_outbound_access_enabled = true
}

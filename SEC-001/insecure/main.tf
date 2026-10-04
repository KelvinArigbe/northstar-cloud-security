terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "northstar_prod" {
  name     = "rg-northstar-prod"
  location = "West Europe"
}

resource "azurerm_storage_account" "customer_data" {
  name                     = "northstarcustomerdata"
  resource_group_name      = azurerm_resource_group.northstar_prod.name
  location                 = azurerm_resource_group.northstar_prod.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = true
}

resource "azurerm_storage_container" "documents" {
  name                  = "customer-documents"
  storage_account_name  = azurerm_storage_account.customer_data.name
  container_access_type = "blob"
}

resource "azurerm_network_security_group" "web_nsg" {
  name                = "nsg-web-prod"
  location            = azurerm_resource_group.northstar_prod.location
  resource_group_name = azurerm_resource_group.northstar_prod.name

  security_rule {
    name                       = "Allow-Management"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Web"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_key_vault" "production" {
  name                = "kv-northstar-prod"
  location            = azurerm_resource_group.northstar_prod.location
  resource_group_name = azurerm_resource_group.northstar_prod.name
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  sku_name            = "standard"

  purge_protection_enabled = false
}

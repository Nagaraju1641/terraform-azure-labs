terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "5d238160-84ec-4e4e-bc10-adc105349c75"
}

resource "azurerm_resource_group" "rg" {
  name     = "terraform-network-rg"
  location = "Central India"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "terraform-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [
    "10.0.0.0/16"
  ]
}

resource "azurerm_subnet" "subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = [
    "10.0.1.0/24"
  ]
}

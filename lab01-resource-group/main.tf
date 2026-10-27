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
  name     = "terraform-lab-rg"
  location = "Central India"
}

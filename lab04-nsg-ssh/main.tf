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
}

# Resource Group

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# VNet

resource "azurerm_virtual_network" "vnet" {

  name                = "terraform-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.0.0.0/16"]
}

# Subnet

resource "azurerm_subnet" "subnet" {

  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24"]
}

# NSG

resource "azurerm_network_security_group" "nsg" {

  name                = "terraform-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# SSH Rule

resource "azurerm_network_security_rule" "ssh" {

  name      = "allow-ssh"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = azurerm_resource_group.rg.name

  network_security_group_name = azurerm_network_security_group.nsg.name
}

# NSG Association

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {

  subnet_id = azurerm_subnet.subnet.id

  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Public IP

resource "azurerm_public_ip" "pip" {

  name                = "terraform-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
}

# NIC

resource "azurerm_network_interface" "nic" {

  name                = "terraform-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {

    name = "internal"

    subnet_id = azurerm_subnet.subnet.id

    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Oracle Linux VM

resource "azurerm_linux_virtual_machine" "vm" {

  name = "terraform-ol-vm"

  resource_group_name = azurerm_resource_group.rg.name

  location = azurerm_resource_group.rg.location

  size = var.vm_size

  admin_username = var.admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {

    username = var.admin_username

    public_key = file("/home/tammana/.ssh/id_rsa.pub")
  }

  os_disk {

    caching = "ReadWrite"

    storage_account_type = "Standard_LRS"
  }

  source_image_reference {

    publisher = "Oracle"

    offer = "Oracle-Linux"

    sku = "ol97-lvm-gen2"

    version = "latest"
  }
}

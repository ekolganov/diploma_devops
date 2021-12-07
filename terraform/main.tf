terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}_RG"
  location = var.location
  tags = {
    owner = "Maxim_Cherepennikov@epam.com"
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.prefix}-k8s"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-k8s"

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name       = "node"
    node_count = var.node_count
    vm_size    = "Standard_D2as_v4"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    owner = "Maxim_Cherepennikov@epam.com"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}CR"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    owner = "Maxim_Cherepennikov@epam.com"
  }
}

resource "azurerm_virtual_network" "vn" {
  name                = "agentpool-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    owner = "Maxim_Cherepennikov@epam.com"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                   = "${var.prefix}Pool"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  sku                    = "Standard_D2as_v4"
  instances              = 1
  admin_username         = "max"
  single_placement_group = false
  overprovision          = false

  admin_ssh_key {
    username   = "max"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "agentpool"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }

  tags = {
    owner = "Maxim_Cherepennikov@epam.com"
  }
}
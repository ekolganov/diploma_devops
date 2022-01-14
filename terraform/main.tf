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
  name     = "${var.my_name}_RG"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.my_name}-k8s"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.my_name}-k8s"

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "${var.my_name}"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name       = "node"
    node_count = 1
    vm_size    = "Standard_B4ms"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    source = "terraform"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.my_name}CR"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    source = "terraform"
  }
}

resource "azurerm_virtual_network" "vn" {
  name                = "agentpool-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    source = "terraform"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                   = "${var.my_name}Pool"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  sku                    = "Standard_B2ms"
  instances              = 1
  admin_username         = "${var.my_name}"
  single_placement_group = false
  overprovision          = false

  admin_ssh_key {
    username   = "${var.my_name}"
    public_key = file("${var.ssh_public_key}")
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
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
    source = "terraform"
  }
}


#/*
# PGSQL
resource "azurerm_postgresql_server" "ekpgsql" {
  name                = "ek-psqlserver"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "B_Gen5_1"
  
  storage_mb            = 5120
  backup_retention_days = 7
  geo_redundant_backup_enabled  = false

  administrator_login          = var.pg_admin_name
  administrator_login_password = var.pg_admin_pswd
  version                      = "11"
  ssl_enforcement_enabled      = false
  
  public_network_access_enabled = true

}


resource "azurerm_postgresql_database" "dbprod" {
  name                = "dbprod"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.ekpgsql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}


resource "azurerm_postgresql_database" "dbdev" {
  name                = "dbdev"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.ekpgsql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
#*/

















/*
# Jenkins vm
resource "azurerm_public_ip" "public_ip" {
  name                = "public_ip_jenkins"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    source = "terraform"
  }
}


resource "azurerm_network_security_group" "nsg" {
  name                = "nsg_allow_ssh_http"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
   }


  tags = {
    source = "terraform"
  }
}


resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-jenkins"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    source = "terraform"
  }
}


resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_linux_virtual_machine" "jenkins" {
  name                   = "${var.my_name}-jenkins"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  size                   = "Standard_B2ms"
  admin_username         = "${var.my_name}"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "${var.my_name}"
    public_key = file("${var.ssh_public_key}")
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  computer_name                   = "jenkins"
  disable_password_authentication = true

  tags = {
    source = "terraform"
  }
}
*/

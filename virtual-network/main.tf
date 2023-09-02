terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}
variable "env_details" {
  type = object({
    subscription_id = string
    hd_location = string
    tag = string
  })
}

variable "vnet_details" {
  type = object({
    vnet_rg_name = string
    vnet_name = string
    vnet_cidr = set(string)
    subnet_name = string
    subnet_cidr =set(string)
  })
}

variable "vm_details" {
  type = object({
    vm_rg_name = string
    vm_nodes_name = set(string)
    vm_image_info =object({
      sku    = string
      offer  = string
      publisher = string
      version = string
     }) 
     vm_storage_info = object({
       managed_disk_type =string
     })
  })
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "${var.env_details.subscription_id}"
}

resource "azurerm_resource_group" "hd-vnet-rg" {
  name     = "${var.vnet_details.vnet_rg_name}"
  location = "${var.env_details.hd_location}"
}

resource "azurerm_virtual_network" "hd-vnet" {
    name                = "${var.vnet_details.vnet_name}"
    location            = azurerm_resource_group.hd-vnet-rg.location
    resource_group_name = azurerm_resource_group.hd-vnet-rg.name
    address_space       = "${var.vnet_details.vnet_cidr}"

    tags = {
     environment = "${var.env_details.tag}"
    }
}
resource "azurerm_subnet" "hd_subnet" {
    name                 = "${var.vnet_details.subnet_name}"
    resource_group_name  = azurerm_resource_group.hd-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hd-vnet.name
    address_prefixes     = "${var.vnet_details.subnet_cidr}"
}

resource "azurerm_resource_group" "hd-vm-rg" {
  name     = "${var.vm_details.vm_rg_name}"
  location = "${var.env_details.hd_location}"
}


resource "azurerm_network_interface" "hd-vm-nic" {
  for_each = var.vm_details.vm_nodes_name
  name                = "${var.env_details.tag}-nic-${each.value}"
  location            = azurerm_resource_group.hd-vm-rg.location
  resource_group_name = azurerm_resource_group.hd-vm-rg.name

  ip_configuration {
    name                          = "${var.env_details.tag}-ip-config"
    subnet_id                     = azurerm_subnet.hd_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "hd-vm" {
  for_each = var.vm_details.vm_nodes_name
  name                  = "${var.env_details.tag}-vm-${each.value}"
  location              = azurerm_resource_group.hd-vm-rg.location
  resource_group_name   = azurerm_resource_group.hd-vm-rg.name
  network_interface_ids = [azurerm_network_interface.hd-vm-nic[each.value].id]
  vm_size               = "Standard_B2s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.vm_details.vm_image_info.publisher}"
    offer     = "${var.vm_details.vm_image_info.offer}"
    sku       = "${var.vm_details.vm_image_info.sku}"
    version   = "${var.vm_details.vm_image_info.version}"
  }
  storage_os_disk {
    name              = "vm-osdisk-${each.value}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.vm_details.vm_storage_info.managed_disk_type}"
  }
  os_profile {
    computer_name  = "${each.value}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "${var.env_details.tag}"
  }
}
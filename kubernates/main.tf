# Configure the Azure provider
variable "subscription_id" {
  type = string
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "${var.subscription_id}"
}

variable "prefix" {
  default = "tkm"
}
variable "vm_details" {
  type = object({
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
variable "user_names" {
  description = "IAM usernames"
  type        = set(string)
  default     = ["cp", "node-1", "node-2"]
} 
resource "azurerm_resource_group" "main" {
  name = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = "euw-dev-052-dai-net"
  virtual_network_name = "euw-dev-052-dai-learnedroutes"
  address_prefixes     = ["10.118.178.144/28"]
}

resource "azurerm_network_interface" "main" {
  for_each = var.user_names
  name                = "${var.prefix}-nic-${each.value}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-ip-config"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  for_each = var.user_names
  name                  = "${var.prefix}-vm-${each.value}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main[each.value].id]
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
    environment = "staging"
  }
}
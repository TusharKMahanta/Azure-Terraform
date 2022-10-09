# Configure the Azure provider
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
  features {}
  subscription_id = "f7b95d20-4cec-465d-a2b2-6e9227f0772f"
}
resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "West Europe"
}
terraform {
  required_version = ">= 1.5.0"

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

resource "azurerm_resource_group" "devops" {
  name     = "sit722-week10-terraform-rg"
  location = "Australia East"

  tags = {
    project    = "SIT722"
    managed_by = "Terraform"
  }
}
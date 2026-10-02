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


# =========================================================
# Resource Group
# =========================================================

resource "azurerm_resource_group" "devops" {
  name     = "sit722-week10-terraform-rg"
  location = "Australia East"

  tags = {
    project    = "SIT722"
    managed_by = "Terraform"
  }
}


# =========================================================
# Azure Container Registry
# =========================================================

resource "azurerm_container_registry" "acr" {
  name                = "movinisit722w10acr2026"
  resource_group_name = azurerm_resource_group.devops.name
  location            = azurerm_resource_group.devops.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    project    = "SIT722"
    managed_by = "Terraform"
  }
}


# =========================================================
# AKS Cluster
# =========================================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "sit722-w10-aks"
  location            = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name
  dns_prefix          = "sit722-w10"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    project    = "SIT722"
    managed_by = "Terraform"
  }
}


# =========================================================
# Allow AKS to Pull Images from ACR
# =========================================================

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}


# =========================================================
# Outputs
# =========================================================

output "resource_group_name" {
  description = "Resource group created by Terraform"
  value       = azurerm_resource_group.devops.name
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}
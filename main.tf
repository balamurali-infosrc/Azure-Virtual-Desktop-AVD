terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Resource Group
resource "azurerm_resource_group" "avd_rg" {
  name     = "demo-avd-rg"
  location = "East US"
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "avd_law" {
  name                = "demo-avd-law"
  location            = azurerm_resource_group.avd_rg.location
  resource_group_name = azurerm_resource_group.avd_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Host Pool
resource "azurerm_virtual_desktop_host_pool" "avd_hp" {
  name                = "demo-avd-hostpool"
  location            = azurerm_resource_group.avd_rg.location
  resource_group_name = azurerm_resource_group.avd_rg.name
  friendly_name       = "DemoHostPool"
  validate_environment = false
  type                = "Pooled"
  load_balancer_type  = "BreadthFirst"
  maximum_sessions_allowed = 10
}

# Application Group
resource "azurerm_virtual_desktop_application_group" "avd_ag" {
  name                = "demo-avd-appgroup"
  location            = azurerm_resource_group.avd_rg.location
  resource_group_name = azurerm_resource_group.avd_rg.name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.avd_hp.id
  friendly_name       = "DemoAppGroup"
}

# Workspace
resource "azurerm_virtual_desktop_workspace" "avd_ws" {
  name                = "demo-avd-workspace"
  location            = azurerm_resource_group.avd_rg.location
  resource_group_name = azurerm_resource_group.avd_rg.name
  friendly_name       = "DemoWorkspace"
  description         = "AVD Demo Workspace"
}

# Associate Workspace with App Group
resource "azurerm_virtual_desktop_workspace_application_group_association" "avd_assoc" {
  workspace_id         = azurerm_virtual_desktop_workspace.avd_ws.id
  application_group_id = azurerm_virtual_desktop_application_group.avd_ag.id
}

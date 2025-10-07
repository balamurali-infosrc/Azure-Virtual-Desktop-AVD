terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">=1.8.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
  use_oidc = true
}

provider "azapi" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network & Subnet for session hosts
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "avd-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = []
}

# Public IP (optional) and LB aren't required for AVD session hosts; we create NICs directly
# Network security group (minimal)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_group_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Host Pool (control plane)
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  name                = var.host_pool_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  friendly_name       = var.host_pool_name
  type                = var.host_pool_type
  # Common defaults:
  load_balancer_type        = "BreadthFirst"
  maximum_sessions_allowed  = 10
  validate_environment      = false
}

# Application Group (Desktop)
resource "azurerm_virtual_desktop_application_group" "appgroup" {
  name                = "${var.host_pool_name}-appgroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                = "Desktop"
  friendly_name       = "${var.host_pool_name}-Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
}

# Workspace
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "${var.host_pool_name}-ws"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  friendly_name       = "${var.host_pool_name}-Workspace"
  description         = "AVD Workspace"
}

# Associate app group to workspace
resource "azurerm_virtual_desktop_workspace_application_group_association" "assoc" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.appgroup.id
}

# Create NICs + VMs for session hosts
resource "azurerm_network_interface" "session_nic" {
  count               = var.session_host_count
  name                = "${var.resource_group_name}-nic-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "session_vm" {
  count               = var.session_host_count
  name                = "${var.resource_group_name}-sh-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.session_host_vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  network_interface_ids = [azurerm_network_interface.session_nic[count.index].id]

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

# Then in your VM resource:
os_disk {
  name                 = "${var.resource_group_name}-osdisk-${count.index + 1}"
  caching              = "ReadWrite"
  storage_account_type = var.os_disk_type   # Standard_LRS | StandardSSD_LRS | Premium_LRS
  disk_size_gb         = 128

  # Optional: custom_data for bootstrap (base64-encoded script)
  # custom_data = base64encode(file("scripts/register-avd.ps1"))
}
}
# NOTE: The azurerm provider does not always expose every nested ARM property (eg. personalDesktopAssignmentType).
# If you need to set ARM-only properties at hostPool level, use azapi_resource (example below).

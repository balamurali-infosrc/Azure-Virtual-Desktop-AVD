output "host_pool_id" {
  value = azurerm_virtual_desktop_host_pool.hostpool.id
}

output "app_group_id" {
  value = azurerm_virtual_desktop_application_group.appgroup.id
}

output "workspace_id" {
  value = azurerm_virtual_desktop_workspace.workspace.id
}

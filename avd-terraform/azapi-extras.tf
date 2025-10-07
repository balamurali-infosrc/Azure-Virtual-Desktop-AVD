resource "azapi_resource" "hostpool_raw" {
  type      = "Microsoft.DesktopVirtualization/hostPools@2024-04-03"
  name      = var.host_pool_name
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  body = {
    location = azurerm_resource_group.rg.location
    properties = {
      friendlyName               = var.host_pool_name
      description                = "AVD host pool created via azapi"
      hostPoolType               = var.host_pool_type           # "Pooled" or "Personal"
      loadBalancerType           = "BreadthFirst"              # "BreadthFirst" | "DepthFirst" | "Persistent"
      preferredAppGroupType      = "Desktop"                   # "Desktop" | "RemoteApp"
      personalDesktopAssignmentType = var.host_pool_type == "Personal" ? "Automatic" : null
      # Optional: ring, registrationInfo, etc.
    }
  }
}

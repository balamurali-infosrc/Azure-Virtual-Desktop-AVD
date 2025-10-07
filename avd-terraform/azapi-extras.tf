resource "azapi_resource" "hostpool_raw" {
  type      = "Microsoft.DesktopVirtualization/hostPools@2024-04-03"
  name      = var.host_pool_name
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  body = jsonencode({
    location = azurerm_resource_group.rg.location
    properties = {
      friendlyName               = var.host_pool_name
      description                = "AVD host pool created via azapi"
      hostPoolType               = var.host_pool_type
      loadBalancerType           = "BreadthFirst"
      preferredAppGroupType      = "Desktop"
      personalDesktopAssignmentType = var.host_pool_type == "Personal" ? "Automatic" : null
      # Optional: ring (used for upgrade rings), registrationInfo, etc.
    }
  })

   # update_method is optional and only supported for modifying existing resources
  # remove it if creating a new host pool
  # update_method = "PUT"
}

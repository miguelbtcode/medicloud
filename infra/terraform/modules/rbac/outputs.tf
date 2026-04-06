# --- Module: RBAC | Outputs ---

output "role_definition_ids" {
  description = "Map of custom role names to their resource IDs"
  value = {
    platform_admin    = azurerm_role_definition.platform_admin.role_definition_resource_id
    platform_operator = azurerm_role_definition.platform_operator.role_definition_resource_id
    developer         = azurerm_role_definition.developer.role_definition_resource_id
    security_auditor  = azurerm_role_definition.security_auditor.role_definition_resource_id
    data_operator     = azurerm_role_definition.data_operator.role_definition_resource_id
  }
}

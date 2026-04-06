output "primary" {
  description = "Map of primary region resource group names to IDs"
  value       = { for k, rg in azurerm_resource_group.primary : k => rg.id }
}

output "dr" {
  description = "Map of DR region resource group names to IDs"
  value       = { for k, rg in azurerm_resource_group.dr : k => rg.id }
}

output "shared_id" {
  description = "Shared resource group ID"
  value       = azurerm_resource_group.shared.id
}

output "governance_id" {
  description = "Governance resource group ID"
  value       = azurerm_resource_group.governance.id
}

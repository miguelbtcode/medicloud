# --- Module: Identity | Outputs ---

output "app_client_id" {
  description = "MediCloud API Application (client) ID"
  value       = azuread_application.medicloud_api.client_id
}

output "app_object_id" {
  description = "MediCloud API Application object ID"
  value       = azuread_application.medicloud_api.object_id
}

output "service_principal_id" {
  description = "MediCloud API Service Principal object ID"
  value       = azuread_service_principal.medicloud_api.object_id
}

output "clinical_group_ids" {
  description = "Map of clinical role keys to Entra ID group object IDs"
  value       = { for k, g in azuread_group.clinical_roles : k => g.object_id }
}

output "infra_group_ids" {
  description = "Map of infra role keys to Entra ID group object IDs"
  value       = { for k, g in azuread_group.infra_roles : k => g.object_id }
}

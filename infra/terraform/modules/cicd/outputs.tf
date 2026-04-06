# --- Module: CI/CD | Outputs ---

output "infra_sp" {
  description = "CI/CD Infra Service Principal details"
  value = {
    client_id    = azuread_application.cicd_infra.client_id
    object_id    = azuread_service_principal.cicd_infra.object_id
    display_name = azuread_application.cicd_infra.display_name
  }
}

output "apps_sp" {
  description = "CI/CD Apps Service Principal details"
  value = {
    client_id    = azuread_application.cicd_apps.client_id
    object_id    = azuread_service_principal.cicd_apps.object_id
    display_name = azuread_application.cicd_apps.display_name
  }
}

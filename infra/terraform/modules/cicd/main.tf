# --- Module: CI/CD Service Principals ---
# sp-infra: Terraform/IaC pipeline (broad infra perms)
# sp-apps:  Build + Deploy pipeline (ACR, AKS, App Service)

locals {
  scope = "/subscriptions/${var.subscription_id}"
}

# =====================================================================
# 1. SP Infra — Terraform / IaC Pipeline
# =====================================================================

resource "azuread_application" "cicd_infra" {
  display_name = "sp-medicloud-cicd-infra"
  owners       = [var.owner_object_id]
}

resource "azuread_service_principal" "cicd_infra" {
  client_id = azuread_application.cicd_infra.client_id
  owners    = [var.owner_object_id]
}

resource "azurerm_role_assignment" "infra_contributor" {
  scope                = local.scope
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.cicd_infra.object_id
}

resource "azurerm_role_assignment" "infra_user_access_admin" {
  scope                = local.scope
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.cicd_infra.object_id
}

# =====================================================================
# 2. SP Apps — Build + Deploy Pipeline
# =====================================================================

resource "azuread_application" "cicd_apps" {
  display_name = "sp-medicloud-cicd-apps"
  owners       = [var.owner_object_id]
}

resource "azuread_service_principal" "cicd_apps" {
  client_id = azuread_application.cicd_apps.client_id
  owners    = [var.owner_object_id]
}

resource "azurerm_role_assignment" "apps_acr_push" {
  scope                = local.scope
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.cicd_apps.object_id
}

resource "azurerm_role_assignment" "apps_aks_contributor" {
  scope                = local.scope
  role_definition_name = "Azure Kubernetes Service Contributor Role"
  principal_id         = azuread_service_principal.cicd_apps.object_id
}

resource "azurerm_role_assignment" "apps_aks_cluster_user" {
  scope                = local.scope
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.cicd_apps.object_id
}

resource "azurerm_role_assignment" "apps_website_contributor" {
  scope                = local.scope
  role_definition_name = "Website Contributor"
  principal_id         = azuread_service_principal.cicd_apps.object_id
}

resource "azurerm_role_assignment" "apps_keyvault_reader" {
  scope                = local.scope
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.cicd_apps.object_id
}

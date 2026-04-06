# --- Module: RBAC (WHO can do WHAT) ---
# Custom role definitions + all assignments (infra + clinical).

locals {
  scope = "/subscriptions/${var.subscription_id}"
}

# =====================================================================
# Custom Role Definitions (control plane)
# =====================================================================

# -- 1. Platform Admin (Infra / DevOps senior)
resource "azurerm_role_definition" "platform_admin" {
  name        = "MediCloud Platform Admin"
  scope       = local.scope
  description = "Full control over MediCloud resources, RBAC, policies, and locks."

  permissions {
    actions = [
      "Microsoft.Resources/*",
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Authorization/roleDefinitions/*",
      "Microsoft.Authorization/locks/*",
      "Microsoft.Authorization/policyAssignments/*",
      "Microsoft.Authorization/policyDefinitions/*",
      "Microsoft.ContainerService/*",
      "Microsoft.ContainerRegistry/*",
      "Microsoft.Network/*",
      "Microsoft.Storage/*",
      "Microsoft.Sql/*",
      "Microsoft.DocumentDB/*",
      "Microsoft.Cache/*",
      "Microsoft.ServiceBus/*",
      "Microsoft.KeyVault/*",
      "Microsoft.Web/*",
      "Microsoft.ApiManagement/*",
      "Microsoft.CognitiveServices/*",
      "Microsoft.Search/*",
      "Microsoft.OperationalInsights/*",
      "Microsoft.Insights/*",
      "Microsoft.ManagedIdentity/*",
    ]
    not_actions = [
      "Microsoft.Authorization/elevateAccess/Action",
    ]
  }

  assignable_scopes = [local.scope]
}

# -- 2. Platform Operator (DevOps / SRE)
resource "azurerm_role_definition" "platform_operator" {
  name        = "MediCloud Platform Operator"
  scope       = local.scope
  description = "Operate AKS, ACR, deployments, and monitoring. No networking/security/RBAC."

  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action",
      "Microsoft.ContainerService/managedClusters/agentPools/*",
      "Microsoft.ContainerRegistry/registries/read",
      "Microsoft.ContainerRegistry/registries/push/write",
      "Microsoft.ContainerRegistry/registries/pull/read",
      "Microsoft.Web/sites/*",
      "Microsoft.Web/serverfarms/read",
      "Microsoft.OperationalInsights/workspaces/read",
      "Microsoft.OperationalInsights/workspaces/query/read",
      "Microsoft.Insights/*/read",
      "Microsoft.Insights/actionGroups/*",
      "Microsoft.Insights/alertRules/*",
      "Microsoft.Insights/metricAlerts/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/deployments/read",
    ]
    not_actions = []
  }

  assignable_scopes = [local.scope]
}

# -- 3. Developer (read-only + debugging)
resource "azurerm_role_definition" "developer" {
  name        = "MediCloud Developer"
  scope       = local.scope
  description = "Read-only on infrastructure. Logs, App Insights, and ACR pull."

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/deployments/read",
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action",
      "Microsoft.ContainerRegistry/registries/read",
      "Microsoft.ContainerRegistry/registries/pull/read",
      "Microsoft.OperationalInsights/workspaces/read",
      "Microsoft.OperationalInsights/workspaces/query/read",
      "Microsoft.Insights/*/read",
      "Microsoft.Web/sites/read",
      "Microsoft.Web/sites/config/read",
      "Microsoft.KeyVault/vaults/read",
    ]
    not_actions = []
  }

  assignable_scopes = [local.scope]
}

# -- 4. Security Auditor (read-everything for compliance)
resource "azurerm_role_definition" "security_auditor" {
  name        = "MediCloud Security Auditor"
  scope       = local.scope
  description = "Read-only across all resources. Audit logs, policies, and RBAC review."

  permissions {
    actions = [
      "*/read",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleDefinitions/read",
      "Microsoft.Authorization/policyAssignments/read",
      "Microsoft.Authorization/policyDefinitions/read",
      "Microsoft.Authorization/locks/read",
      "Microsoft.KeyVault/vaults/read",
      "Microsoft.OperationalInsights/workspaces/query/read",
      "Microsoft.Insights/diagnosticSettings/read",
      "Microsoft.Insights/logprofiles/read",
    ]
    not_actions = []
  }

  assignable_scopes = [local.scope]
}

# -- 5. Data Operator (DBA / data team)
resource "azurerm_role_definition" "data_operator" {
  name        = "MediCloud Data Operator"
  scope       = local.scope
  description = "Operate data services (SQL, Cosmos, Redis, Storage). No secrets, no networking."

  permissions {
    actions = [
      "Microsoft.Sql/servers/read",
      "Microsoft.Sql/servers/databases/*",
      "Microsoft.Sql/servers/elasticPools/*",
      "Microsoft.Sql/servers/firewallRules/read",
      "Microsoft.Sql/servers/auditingSettings/read",
      "Microsoft.DocumentDB/databaseAccounts/*",
      "Microsoft.Cache/redis/*",
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/blobServices/*",
      "Microsoft.ServiceBus/namespaces/read",
      "Microsoft.ServiceBus/namespaces/queues/*",
      "Microsoft.ServiceBus/namespaces/topics/*",
      "Microsoft.Insights/*/read",
      "Microsoft.OperationalInsights/workspaces/read",
      "Microsoft.OperationalInsights/workspaces/query/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
    ]
    not_actions = [
      "Microsoft.Storage/storageAccounts/listKeys/action",
      "Microsoft.DocumentDB/databaseAccounts/delete",
    ]
  }

  assignable_scopes = [local.scope]
}

# =====================================================================
# Role Assignments — Infra Group → Custom Role (control plane)
# =====================================================================

resource "azurerm_role_assignment" "platform_admin" {
  scope              = local.scope
  role_definition_id = azurerm_role_definition.platform_admin.role_definition_resource_id
  principal_id       = var.infra_group_ids["platform_admin"]
}

resource "azurerm_role_assignment" "platform_operator" {
  scope              = local.scope
  role_definition_id = azurerm_role_definition.platform_operator.role_definition_resource_id
  principal_id       = var.infra_group_ids["platform_operator"]
}

resource "azurerm_role_assignment" "developer" {
  scope              = local.scope
  role_definition_id = azurerm_role_definition.developer.role_definition_resource_id
  principal_id       = var.infra_group_ids["developer"]
}

resource "azurerm_role_assignment" "security_auditor" {
  scope              = local.scope
  role_definition_id = azurerm_role_definition.security_auditor.role_definition_resource_id
  principal_id       = var.infra_group_ids["security_auditor"]
}

resource "azurerm_role_assignment" "data_operator" {
  scope              = local.scope
  role_definition_id = azurerm_role_definition.data_operator.role_definition_resource_id
  principal_id       = var.infra_group_ids["data_operator"]
}

# =====================================================================
# App Role Assignments — Clinical Group → App Role (data plane)
# =====================================================================

locals {
  clinical_role_assignments = {
    admin         = { group_key = "admin",         app_role_id = "1a2b3c4d-0001-0000-0000-000000000001" }
    medico        = { group_key = "medico",        app_role_id = "1a2b3c4d-0002-0000-0000-000000000002" }
    enfermero     = { group_key = "enfermero",     app_role_id = "1a2b3c4d-0003-0000-0000-000000000003" }
    laboratorista = { group_key = "laboratorista", app_role_id = "1a2b3c4d-0004-0000-0000-000000000004" }
    farmaceutico  = { group_key = "farmaceutico",  app_role_id = "1a2b3c4d-0005-0000-0000-000000000005" }
  }
}

resource "azuread_app_role_assignment" "clinical" {
  for_each = local.clinical_role_assignments

  app_role_id         = each.value.app_role_id
  principal_object_id = var.clinical_group_ids[each.value.group_key]
  resource_object_id  = var.service_principal_id
}

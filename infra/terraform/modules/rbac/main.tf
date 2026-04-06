# ══════════════════════════════════════════════════════════════
# Module: RBAC Custom Roles (Azure Control Plane)
# Principle: Least Privilege + Separation of Duties
# ══════════════════════════════════════════════════════════════

locals {
  scope = "/subscriptions/${var.subscription_id}"
}

# ──────────────────────────────────────────────────────────────
# 1. Platform Admin
#    Who: Infra / DevOps senior
#    Can: Full control on all MediCloud resources, manage RBAC,
#         policies, and locks. Excludes subscription-level ops.
# ──────────────────────────────────────────────────────────────
resource "azurerm_role_definition" "platform_admin" {
  name        = "MediCloud Platform Admin"
  scope       = local.scope
  description = "Full control over MediCloud resources, RBAC, policies, and locks. Cannot modify subscription-level settings."

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

# ──────────────────────────────────────────────────────────────
# 2. Platform Operator
#    Who: DevOps / SRE
#    Can: Operate AKS, manage deployments, ACR push/pull,
#         view monitoring. Cannot modify networking or security.
# ──────────────────────────────────────────────────────────────
resource "azurerm_role_definition" "platform_operator" {
  name        = "MediCloud Platform Operator"
  scope       = local.scope
  description = "Operate AKS, ACR, deployments, and monitoring. Cannot modify networking, security, or RBAC."

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

# ──────────────────────────────────────────────────────────────
# 3. Developer
#    Who: Application developers
#    Can: Read resources, query logs for debugging, pull
#         from ACR. Cannot modify infrastructure.
# ──────────────────────────────────────────────────────────────
resource "azurerm_role_definition" "developer" {
  name        = "MediCloud Developer"
  scope       = local.scope
  description = "Read-only on infrastructure. Access to logs, App Insights, and ACR pull for debugging and local development."

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

# ──────────────────────────────────────────────────────────────
# 4. Security Auditor
#    Who: Security / compliance team
#    Can: Read everything for auditing. Full access to audit
#         logs, policies, and RBAC assignments (read-only).
# ──────────────────────────────────────────────────────────────
resource "azurerm_role_definition" "security_auditor" {
  name        = "MediCloud Security Auditor"
  scope       = local.scope
  description = "Read-only across all resources. Full access to audit logs, security configs, policies, and RBAC assignments for compliance review."

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

# ──────────────────────────────────────────────────────────────
# 5. Data Operator
#    Who: DBA / data team
#    Can: Operate SQL DB, Cosmos DB, Redis, and Storage.
#         Manage backups, scaling, monitoring of data services.
#         Cannot access secrets or modify networking.
# ──────────────────────────────────────────────────────────────
resource "azurerm_role_definition" "data_operator" {
  name        = "MediCloud Data Operator"
  scope       = local.scope
  description = "Operate data services (SQL, Cosmos, Redis, Storage). Manage backups, scaling, and monitoring. Cannot access secrets or modify networking."

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

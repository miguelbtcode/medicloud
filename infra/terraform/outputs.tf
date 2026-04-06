# ══════════════════════════════════════════════════════════════
# Root Outputs
# ══════════════════════════════════════════════════════════════

# ── Resource Groups ───────────────────────────────────────────
output "primary_resource_groups" {
  description = "Map of primary region resource group names to IDs"
  value       = module.resource_groups.primary
}

output "dr_resource_groups" {
  description = "Map of DR region resource group names to IDs"
  value       = module.resource_groups.dr
}

output "shared_resource_group_id" {
  description = "Shared resource group ID"
  value       = module.resource_groups.shared_id
}

output "governance_resource_group_id" {
  description = "Governance resource group ID"
  value       = module.resource_groups.governance_id
}

# ── RBAC ──────────────────────────────────────────────────────
output "custom_role_ids" {
  description = "Map of custom RBAC role names to their definition IDs"
  value       = module.rbac.role_definition_ids
}

# ── Identity ──────────────────────────────────────────────────
output "medicloud_app_client_id" {
  description = "MediCloud API Application (client) ID"
  value       = module.identity.app_client_id
}

output "clinical_group_ids" {
  description = "Map of clinical role keys to Entra ID group object IDs"
  value       = module.identity.group_ids
}

# ── CI/CD ─────────────────────────────────────────────────────
output "cicd_infra_sp" {
  description = "CI/CD Infra Service Principal (Terraform/IaC pipeline)"
  value       = module.cicd.infra_sp
}

output "cicd_apps_sp" {
  description = "CI/CD Apps Service Principal (Build + Deploy pipeline)"
  value       = module.cicd.apps_sp
}

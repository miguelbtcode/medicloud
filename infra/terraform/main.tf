# ══════════════════════════════════════════════════════════════
# MediCloud — Root Module
# Orchestrates all infrastructure modules
# ══════════════════════════════════════════════════════════════

data "azuread_client_config" "current" {}

# ── Resource Groups ───────────────────────────────────────────
module "resource_groups" {
  source = "./modules/resource-groups"

  project          = var.project
  environment      = var.environment
  primary_location = var.primary_location
  dr_location      = var.dr_location
  workloads        = local.workloads
  primary_tags     = local.primary_tags
  dr_tags          = local.dr_tags
  global_tags      = local.global_tags
}

# ── RBAC Custom Roles (Control Plane) ─────────────────────────
module "rbac" {
  source = "./modules/rbac"

  subscription_id = var.subscription_id
}

# ── Identity: App Registration + App Roles + Groups ───────────
module "identity" {
  source = "./modules/identity"

  owner_object_id = data.azuread_client_config.current.object_id
}

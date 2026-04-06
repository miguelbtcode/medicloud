# --- MediCloud | Root Module ---

data "azuread_client_config" "current" {}

# -- Resource Groups
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

# -- Identity (groups, app registration, service principal)
module "identity" {
  source = "./modules/identity"

  owner_object_id = data.azuread_client_config.current.object_id
}

# -- RBAC (custom roles + all assignments)
module "rbac" {
  source = "./modules/rbac"

  subscription_id      = var.subscription_id
  infra_group_ids      = module.identity.infra_group_ids
  clinical_group_ids   = module.identity.clinical_group_ids
  service_principal_id = module.identity.service_principal_id
}

# -- Conditional Access (requires Entra ID P2 license)
# Module preserved at modules/conditional-access/ for reference.
# module "conditional_access" {
#   source             = "./modules/conditional-access"
#   clinical_group_ids = module.identity.clinical_group_ids
#   infra_group_ids    = module.identity.infra_group_ids
# }

# -- CI/CD Service Principals
module "cicd" {
  source = "./modules/cicd"

  owner_object_id = data.azuread_client_config.current.object_id
  subscription_id = var.subscription_id
}

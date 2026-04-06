# --- MediCloud | Locals ---

locals {
  # -- Common tags (CAF)
  common_tags = {
    Project            = var.project
    Environment        = var.environment
    CostCenter         = var.cost_center
    Owner              = var.owner
    ManagedBy          = "terraform"
    DataClassification = "confidential"
  }

  # -- Region-specific tags
  primary_tags = merge(local.common_tags, { Region = var.primary_location, DR = "primary" })
  dr_tags      = merge(local.common_tags, { Region = var.dr_location, DR = "secondary" })
  global_tags  = merge(local.common_tags, { Region = "global", DR = "n/a" })

  # -- Workloads (one RG per workload per region)
  workloads = [
    "networking",
    "aks",
    "data",
    "security",
    "apim",
    "apps",
    "monitoring",
  ]
}

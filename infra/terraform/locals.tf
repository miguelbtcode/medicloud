locals {
  # ──────────────────────────────────────────────
  # Common tags applied to ALL resources (CAF)
  # ──────────────────────────────────────────────
  common_tags = {
    Project            = var.project
    Environment        = var.environment
    CostCenter         = var.cost_center
    Owner              = var.owner
    ManagedBy          = "terraform"
    DataClassification = "confidential"
  }

  # Tags per region (extend common with region-specific)
  primary_tags = merge(local.common_tags, {
    Region = var.primary_location
    DR     = "primary"
  })

  dr_tags = merge(local.common_tags, {
    Region = var.dr_location
    DR     = "secondary"
  })

  global_tags = merge(local.common_tags, {
    Region = "global"
    DR     = "n/a"
  })

  # ──────────────────────────────────────────────
  # Resource Group definitions by workload
  # ──────────────────────────────────────────────
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

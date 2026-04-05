# ══════════════════════════════════════════════════════════════
# Resource Groups — MediCloud
# Naming: rg-<project>-<workload>-<environment>-<region> (CAF)
# ══════════════════════════════════════════════════════════════

# ──────────────────────────────────────────────
# Primary Region (East US 2)
# ──────────────────────────────────────────────
resource "azurerm_resource_group" "primary" {
  for_each = toset(local.workloads)

  name     = "rg-${var.project}-${each.value}-${var.environment}-${var.primary_location}"
  location = var.primary_location

  tags = merge(local.primary_tags, {
    Workload = each.value
  })
}

# ──────────────────────────────────────────────
# DR Region (West US 2)
# ──────────────────────────────────────────────
resource "azurerm_resource_group" "dr" {
  for_each = toset(local.workloads)

  name     = "rg-${var.project}-${each.value}-${var.environment}-${var.dr_location}"
  location = var.dr_location

  tags = merge(local.dr_tags, {
    Workload = each.value
  })
}

# ──────────────────────────────────────────────
# Shared / Global Resources
# ──────────────────────────────────────────────
resource "azurerm_resource_group" "shared" {
  name     = "rg-${var.project}-shared-${var.environment}"
  location = var.primary_location

  tags = merge(local.global_tags, {
    Workload = "shared"
  })
}

resource "azurerm_resource_group" "governance" {
  name     = "rg-${var.project}-governance-${var.environment}"
  location = var.primary_location

  tags = merge(local.global_tags, {
    Workload = "governance"
  })
}

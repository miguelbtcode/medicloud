# ══════════════════════════════════════════════════════════════
# Module: Resource Groups
# Creates RGs per workload in primary, DR, and global scope.
# Naming: rg-<project>-<workload>-<environment>-<region> (CAF)
# ══════════════════════════════════════════════════════════════

# ── Primary Region ────────────────────────────────────────────
resource "azurerm_resource_group" "primary" {
  for_each = toset(var.workloads)

  name     = "rg-${var.project}-${each.value}-${var.environment}-${var.primary_location}"
  location = var.primary_location

  tags = merge(var.primary_tags, {
    Workload = each.value
  })
}

# ── DR Region ─────────────────────────────────────────────────
resource "azurerm_resource_group" "dr" {
  for_each = toset(var.workloads)

  name     = "rg-${var.project}-${each.value}-${var.environment}-${var.dr_location}"
  location = var.dr_location

  tags = merge(var.dr_tags, {
    Workload = each.value
  })
}

# ── Shared / Global ──────────────────────────────────────────
resource "azurerm_resource_group" "shared" {
  name     = "rg-${var.project}-shared-${var.environment}"
  location = var.primary_location

  tags = merge(var.global_tags, {
    Workload = "shared"
  })
}

resource "azurerm_resource_group" "governance" {
  name     = "rg-${var.project}-governance-${var.environment}"
  location = var.primary_location

  tags = merge(var.global_tags, {
    Workload = "governance"
  })
}

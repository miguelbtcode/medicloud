# --- Module: Conditional Access (requires Entra ID P2) ---
# Clínica Salud Regional — Perú
# 4 policies: MFA, geo-block, compliant device, block legacy auth.

locals {
  all_group_ids = concat(values(var.clinical_group_ids), values(var.infra_group_ids))

  critical_group_ids = [
    var.clinical_group_ids["admin"],
    var.infra_group_ids["platform_admin"],
    var.infra_group_ids["data_operator"],
  ]
}

# -- Named Location: Perú
resource "azuread_named_location" "peru" {
  display_name = "MediCloud - Perú"

  country {
    countries_and_regions                 = ["PE"]
    include_unknown_countries_and_regions = false
  }
}

# -- Policy 1: MFA for all users
resource "azuread_conditional_access_policy" "mfa_all_users" {
  display_name = "MediCloud - Require MFA for all users"
  state        = "enabled"

  conditions {
    client_app_types = ["browser", "mobileAppsAndDesktopClients"]
    applications { included_applications = ["All"] }
    users { included_groups = local.all_group_ids }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# -- Policy 2: Block access outside Perú
resource "azuread_conditional_access_policy" "block_outside_peru" {
  display_name = "MediCloud - Block access outside Perú"
  state        = "enabled"

  conditions {
    client_app_types = ["browser", "mobileAppsAndDesktopClients"]
    applications { included_applications = ["All"] }
    users { included_groups = local.all_group_ids }
    locations {
      included_locations = ["All"]
      excluded_locations = [azuread_named_location.peru.id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# -- Policy 3: Compliant device for critical roles (report-only)
resource "azuread_conditional_access_policy" "compliant_device_critical" {
  display_name = "MediCloud - Require compliant device (critical roles)"
  state        = "enabledForReportingButNotEnforced"

  conditions {
    client_app_types = ["browser", "mobileAppsAndDesktopClients"]
    applications { included_applications = ["All"] }
    users { included_groups = local.critical_group_ids }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["compliantDevice"]
  }
}

# -- Policy 4: Block legacy authentication
resource "azuread_conditional_access_policy" "block_legacy_auth" {
  display_name = "MediCloud - Block legacy authentication"
  state        = "enabled"

  conditions {
    client_app_types = ["exchangeActiveSync", "other"]
    applications { included_applications = ["All"] }
    users { included_groups = local.all_group_ids }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

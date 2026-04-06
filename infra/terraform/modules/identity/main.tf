# ══════════════════════════════════════════════════════════════
# Module: Identity (Data Plane)
# App Registration, App Roles, Entra ID Groups, Assignments
# Clinical roles: Admin, Médico, Enfermero, Laboratorista,
#                 Farmacéutico
# ══════════════════════════════════════════════════════════════

# ── App Registration — MediCloud API ─────────────────────────
resource "azuread_application" "medicloud_api" {
  display_name = "MediCloud API"
  owners       = [var.owner_object_id]

  sign_in_audience = "AzureADMyOrg"

  identifier_uris = ["api://medicloud"]

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      id                         = "2b3c4d5e-0001-0000-0000-000000000001"
      admin_consent_description  = "Access MediCloud API on behalf of the signed-in user"
      admin_consent_display_name = "Access MediCloud API"
      user_consent_description   = "Access MediCloud on your behalf"
      user_consent_display_name  = "Access MediCloud"
      value                      = "api.access"
      type                       = "User"
      enabled                    = true
    }
  }

  # ── Clinical App Roles ────────────────────────────────────

  app_role {
    id                   = "1a2b3c4d-0001-0000-0000-000000000001"
    display_name         = "Administrador"
    description          = "Full access to all clinical modules. Manages users, configuration, and audit."
    value                = "Admin"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = "1a2b3c4d-0002-0000-0000-000000000002"
    display_name         = "Médico"
    description          = "Access to appointments, medical records, prescriptions. Can order lab tests."
    value                = "Medico"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = "1a2b3c4d-0003-0000-0000-000000000003"
    display_name         = "Enfermero"
    description          = "Access to appointments, limited medical records (vitals, notes). Cannot prescribe."
    value                = "Enfermero"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = "1a2b3c4d-0004-0000-0000-000000000004"
    display_name         = "Laboratorista"
    description          = "Full access to lab module. Read-only on medical records for test results."
    value                = "Laboratorista"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = "1a2b3c4d-0005-0000-0000-000000000005"
    display_name         = "Farmacéutico"
    description          = "Full access to pharmacy module. Read-only on prescriptions from medical records."
    value                = "Farmaceutico"
    allowed_member_types = ["User"]
    enabled              = true
  }
}

# ── Service Principal ────────────────────────────────────────
resource "azuread_service_principal" "medicloud_api" {
  client_id                    = azuread_application.medicloud_api.client_id
  app_role_assignment_required = true

  owners = [var.owner_object_id]
}

# ── Entra ID Groups (one per clinical role) ──────────────────
resource "azuread_group" "clinical_roles" {
  for_each = {
    admin         = "MediCloud - Administradores"
    medico        = "MediCloud - Médicos"
    enfermero     = "MediCloud - Enfermeros"
    laboratorista = "MediCloud - Laboratoristas"
    farmaceutico  = "MediCloud - Farmacéuticos"
  }

  display_name     = each.value
  security_enabled = true
  owners           = [var.owner_object_id]
}

# ── App Role Assignments (Group → App Role) ──────────────────
locals {
  role_assignments = {
    admin = {
      group_key   = "admin"
      app_role_id = "1a2b3c4d-0001-0000-0000-000000000001"
    }
    medico = {
      group_key   = "medico"
      app_role_id = "1a2b3c4d-0002-0000-0000-000000000002"
    }
    enfermero = {
      group_key   = "enfermero"
      app_role_id = "1a2b3c4d-0003-0000-0000-000000000003"
    }
    laboratorista = {
      group_key   = "laboratorista"
      app_role_id = "1a2b3c4d-0004-0000-0000-000000000004"
    }
    farmaceutico = {
      group_key   = "farmaceutico"
      app_role_id = "1a2b3c4d-0005-0000-0000-000000000005"
    }
  }
}

resource "azuread_app_role_assignment" "clinical" {
  for_each = local.role_assignments

  app_role_id         = each.value.app_role_id
  principal_object_id = azuread_group.clinical_roles[each.value.group_key].object_id
  resource_object_id  = azuread_service_principal.medicloud_api.object_id
}

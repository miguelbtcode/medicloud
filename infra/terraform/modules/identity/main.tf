# --- Module: Identity (WHO exists) ---
# App Registration, Service Principal, Entra ID Groups.
# Assignments live in the rbac module.

# -- App Registration
resource "azuread_application" "medicloud_api" {
  display_name     = "MediCloud API"
  owners           = [var.owner_object_id]
  sign_in_audience = "AzureADMyOrg"
  identifier_uris  = ["api://medicloud"]

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

  # -- App Roles (data plane — travel in JWT)
  app_role {
    id                   = "1a2b3c4d-0001-0000-0000-000000000001"
    display_name         = "Administrador"
    description          = "Full access to all clinical modules."
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
    description          = "Access to appointments, limited medical records. Cannot prescribe."
    value                = "Enfermero"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = "1a2b3c4d-0004-0000-0000-000000000004"
    display_name         = "Laboratorista"
    description          = "Full access to lab module. Read-only on medical records."
    value                = "Laboratorista"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = "1a2b3c4d-0005-0000-0000-000000000005"
    display_name         = "Farmacéutico"
    description          = "Full access to pharmacy module. Read-only on prescriptions."
    value                = "Farmaceutico"
    allowed_member_types = ["User"]
    enabled              = true
  }
}

# -- Service Principal
resource "azuread_service_principal" "medicloud_api" {
  client_id                    = azuread_application.medicloud_api.client_id
  app_role_assignment_required = true
  owners                       = [var.owner_object_id]
}

# -- Clinical Groups (data plane)
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

# -- Infrastructure Groups (control plane)
resource "azuread_group" "infra_roles" {
  for_each = {
    platform_admin    = "MediCloud - Platform Admins"
    platform_operator = "MediCloud - Platform Operators"
    developer         = "MediCloud - Developers"
    security_auditor  = "MediCloud - Security Auditors"
    data_operator     = "MediCloud - Data Operators"
  }

  display_name     = each.value
  security_enabled = true
  owners           = [var.owner_object_id]
}

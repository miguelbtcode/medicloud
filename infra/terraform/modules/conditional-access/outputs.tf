# --- Module: Conditional Access | Outputs ---

output "policy_ids" {
  description = "Map of Conditional Access policy names to IDs"
  value = {
    mfa_all_users             = azuread_conditional_access_policy.mfa_all_users.id
    block_outside_peru        = azuread_conditional_access_policy.block_outside_peru.id
    compliant_device_critical = azuread_conditional_access_policy.compliant_device_critical.id
    block_legacy_auth         = azuread_conditional_access_policy.block_legacy_auth.id
  }
}

output "named_location_id" {
  description = "Named location ID for Perú"
  value       = azuread_named_location.peru.id
}

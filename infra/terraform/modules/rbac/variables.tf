# --- Module: RBAC | Variables ---

variable "subscription_id" {
  description = "Azure subscription ID for role scope"
  type        = string
}

variable "infra_group_ids" {
  description = "Map of infra role keys to Entra ID group object IDs"
  type        = map(string)
}

variable "clinical_group_ids" {
  description = "Map of clinical role keys to Entra ID group object IDs"
  type        = map(string)
}

variable "service_principal_id" {
  description = "MediCloud API Service Principal object ID for app role assignments"
  type        = string
}

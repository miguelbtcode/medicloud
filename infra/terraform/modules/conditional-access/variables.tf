# --- Module: Conditional Access | Variables ---

variable "clinical_group_ids" {
  description = "Map of clinical role keys to Entra ID group object IDs"
  type        = map(string)
}

variable "infra_group_ids" {
  description = "Map of infra role keys to Entra ID group object IDs"
  type        = map(string)
}

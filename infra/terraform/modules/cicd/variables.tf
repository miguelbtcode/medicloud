# --- Module: CI/CD | Variables ---

variable "owner_object_id" {
  description = "Object ID of the owner for the App Registrations"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID for role assignments"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "project" {
  description = "Project name used in resource naming"
  type        = string
  default     = "medicloud"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "primary_location" {
  description = "Primary Azure region"
  type        = string
  default     = "eastus2"
}

variable "dr_location" {
  description = "Disaster Recovery Azure region"
  type        = string
  default     = "westus2"
}

variable "owner" {
  description = "Team or person responsible for these resources"
  type        = string
  default     = "equipo-infra"
}

variable "cost_center" {
  description = "Cost center for billing/chargeback"
  type        = string
  default     = "IT-Clinical"
}

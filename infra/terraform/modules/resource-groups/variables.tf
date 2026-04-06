# --- Module: Resource Groups | Variables ---

variable "project" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
}

variable "primary_location" {
  description = "Primary Azure region"
  type        = string
}

variable "dr_location" {
  description = "Disaster Recovery Azure region"
  type        = string
}

variable "primary_tags" {
  description = "Tags for primary region resources"
  type        = map(string)
}

variable "dr_tags" {
  description = "Tags for DR region resources"
  type        = map(string)
}

variable "global_tags" {
  description = "Tags for global resources"
  type        = map(string)
}

variable "workloads" {
  description = "List of workload names for resource group creation"
  type        = list(string)
}

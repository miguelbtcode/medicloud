terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-medicloud-tfstate-prod"
    storage_account_name = "stmedicloudtfstate"
    container_name       = "tfstate"
    key                  = "medicloud.tfstate"
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

provider "azuread" {}

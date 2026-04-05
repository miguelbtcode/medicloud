#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# Bootstrap — Terraform Remote State (Azure Storage Account)
# Run this ONCE before the first terraform init
# ══════════════════════════════════════════════════════════════
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────
RESOURCE_GROUP="rg-medicloud-tfstate-prod"
LOCATION="eastus2"
# Storage account names: 3-24 chars, lowercase alphanumeric only
STORAGE_ACCOUNT="stmedicloudtfstate"
CONTAINER_NAME="tfstate"
SUBSCRIPTION_ID="${1:?Usage: ./bootstrap-state.sh <subscription-id>}"

# ── Tags (CAF) ────────────────────────────────────────────────
TAGS=(
  "Project=medicloud"
  "Environment=prod"
  "CostCenter=IT-Clinical"
  "Owner=equipo-infra"
  "ManagedBy=az-cli"
  "DataClassification=confidential"
  "Workload=terraform-state"
)

echo "══════════════════════════════════════════════════"
echo " MediCloud — Bootstrap Terraform State Backend"
echo "══════════════════════════════════════════════════"

# Set subscription
echo "→ Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Register resource providers (idempotent — safe to re-run)
echo "→ Registering resource providers..."
PROVIDERS=(
  "Microsoft.Storage"
  "Microsoft.Compute"
  "Microsoft.ContainerService"
  "Microsoft.ContainerRegistry"
  "Microsoft.Network"
  "Microsoft.Sql"
  "Microsoft.DocumentDB"
  "Microsoft.Cache"
  "Microsoft.ServiceBus"
  "Microsoft.KeyVault"
  "Microsoft.Web"
  "Microsoft.ApiManagement"
  "Microsoft.CognitiveServices"
  "Microsoft.Search"
  "Microsoft.OperationalInsights"
  "Microsoft.Insights"
  "Microsoft.ManagedIdentity"
  "Microsoft.Authorization"
)

for provider in "${PROVIDERS[@]}"; do
  echo "  ├─ $provider"
  az provider register --namespace "$provider" --subscription "$SUBSCRIPTION_ID" --wait || true
done
echo "  └─ Done"

# Create Resource Group
echo "→ Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags "${TAGS[@]}"

# Create Storage Account (secure defaults)
echo "→ Creating storage account: $STORAGE_ACCOUNT"
az storage account create \
  --subscription "$SUBSCRIPTION_ID" \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku "Standard_LRS" \
  --kind "StorageV2" \
  --min-tls-version "TLS1_2" \
  --allow-blob-public-access false \
  --https-only true \
  --tags "${TAGS[@]}"

# Enable versioning (state recovery)
echo "→ Enabling blob versioning..."
az storage account blob-service-properties update \
  --subscription "$SUBSCRIPTION_ID" \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true

# Create container
echo "→ Creating container: $CONTAINER_NAME"
az storage container create \
  --subscription "$SUBSCRIPTION_ID" \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login

# Enable delete lock (prevent accidental deletion)
echo "→ Applying CanNotDelete lock..."
az lock create \
  --subscription "$SUBSCRIPTION_ID" \
  --name "tfstate-lock" \
  --resource-group "$RESOURCE_GROUP" \
  --lock-type CanNotDelete \
  --notes "Protects Terraform state backend from accidental deletion"

echo ""
echo "══════════════════════════════════════════════════"
echo " Bootstrap complete!"
echo "══════════════════════════════════════════════════"
echo ""
echo " Add this backend config to your Terraform:"
echo ""
echo "  backend \"azurerm\" {"
echo "    resource_group_name  = \"$RESOURCE_GROUP\""
echo "    storage_account_name = \"$STORAGE_ACCOUNT\""
echo "    container_name       = \"$CONTAINER_NAME\""
echo "    key                  = \"medicloud.tfstate\""
echo "  }"
echo ""

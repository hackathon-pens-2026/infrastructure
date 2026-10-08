#!/usr/bin/env bash
set -e

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-hackathon-rg}"
LOCATION="${LOCATION:-southeastasia}"
APP_NAME="${APP_NAME:-hackathon-backend-$RANDOM}"
IMAGE_NAME="${IMAGE_NAME:-ghcr.io/your-github-user/hackathon-backend:latest}"

echo "=== Deploying .NET 8 Backend Container to Azure App Service ==="
echo "Resource Group : $RESOURCE_GROUP"
echo "Location       : $LOCATION"
echo "App Name       : $APP_NAME"
echo "Container Image: $IMAGE_NAME"

# 1. Create Resource Group if not exists
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# 2. Deploy Bicep template
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file ./infrastructure/azure/main.bicep \
  --parameters appName="$APP_NAME" containerImage="$IMAGE_NAME"

echo "Deployment finished successfully!"

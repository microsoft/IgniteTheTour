#!/usr/bin/env bash
if [ -n "$DEBUG"} ]; then set -eou pipefail; fi

source ./scripts/variables.sh

echo "Creating new ACR in $(acrname) in resource group $(rg), location $(location)"
az acr create --resource-group $(rg) --name $(acrname) --sku Standard --location $(location)

az acr update -n $(acrname) --admin-enabled true

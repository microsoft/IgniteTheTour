#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

echo "Checking for existing $(rg) resource group in $(location)..."

rgCheck=$(az group exists -n $(rg))
echo ''

if [[ "$rgCheck" == "true" ]]; then
    echo "$(rg) already exists..."
    echo ''
else
    echo "Creating $(rg) in $(location) now..."
    echo ''
    # Create resource group
    az group create --resource-group $(rg) --location $(location)
    echo "Resource Group 1 setup has completed successfully."
fi
echo ''

#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

echo "Checking for existing $(rg2) resource group in $(location2)..."

rgCheck2=$(az group exists -n $(rg2))
echo ''

if [[ "$rgCheck2" == "true" ]]; then
    echo "$(rg2) already exists..."
    echo ''
else
    echo "Creating $(rg2) in $(location2) now..."
    echo ''
    # Create resource group
    az group create --resource-group $(rg2) --location $(location2)
    echo "Resource Group 2 setup has completed successfully."
fi
echo ''

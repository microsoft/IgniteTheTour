#!/usr/bin/env bash
set -eou pipefail
source ./scripts/variables.sh

echo "Creating new KeyVault $(akvname) in resource group $(rg)"
az keyvault create --resource-group $(rg) --name $(akvname)

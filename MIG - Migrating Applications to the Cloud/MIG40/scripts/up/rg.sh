#!/usr/bin/env bash
set -eou pipefail
source ./scripts/variables.sh

echo "Creating new resource group $(rg) in location $(location)"
az group create --resource-group $(rg) --location $(location)

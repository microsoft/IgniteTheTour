#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

echo "Creating resource group 2 $(rg2) in location $(location2)"
az group create --resource-group $(rg2) --location $(location2)

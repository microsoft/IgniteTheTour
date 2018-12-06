#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

az acr create --resource-group $(rg) --name $(acrname) --sku Standard --location $(location)

az acr update -n $(acrname) --admin-enabled true

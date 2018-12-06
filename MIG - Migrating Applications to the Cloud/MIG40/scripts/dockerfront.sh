#!/usr/bin/env bash
set -eou pipefail
source ../../scripts/variables.sh

BUILD_COMMAND="az acr build --registry $(acrname) --image "
prompt $BUILD_COMMAND ignite-frontend:latest -f Dockerfile \
    --build-arg PRODUCT_SERVICE_BASE_URL="https://product-service-$(rg).azurewebsites.net" \
    --build-arg INVENTORY_SERVICE_BASE_URL="https://inventory-service-$(rg).azurewebsites.net" \
    .

#!/usr/bin/env bash
set -eou pipefail
source ./scripts/variables.sh

cd src/frontend
BUILD_COMMAND="docker build "
prompt $BUILD_COMMAND  -f Dockerfile \
    --build-arg PRODUCT_SERVICE_BASE_URL="https://product-service-$(rg).azurewebsites.net" \
    --build-arg INVENTORY_SERVICE_BASE_URL="https://inventory-service-$(rg).azurewebsites.net" \
    -t $(acrname).azurecr.io/ignite-frontend:latest \
    .

cd ../inventory-service/InventoryService.Api
BUILD_COMMAND="docker build "
prompt $BUILD_COMMAND -t $(acrname).azurecr.io/ignite-inventory-service:latest \
-f Dockerfile \
.

cd ../../product-service
BUILD_COMMAND="docker build "
prompt $BUILD_COMMAND -t $(acrname).azurecr.io/ignite-product-service:latest \
-f Dockerfile \
.
prompt docker push $(acrname).azurecr.io/ignite-product-service:latest
prompt docker push $(acrname).azurecr.io/ignite-inventory-service:latest
prompt docker push $(acrname).azurecr.io/ignite-frontend:latest
#!/bin/bash
set -eou pipefail
source ../../scripts/variables.sh

BUILD_COMMAND="az acr build --registry $(acrname) --image " 
prompt $BUILD_COMMAND frontend:latest -f Dockerfile \
    --build-arg PRODUCT_SERVICE_BASE_URL="http://product-product.$(routingzone)" \
    --build-arg INVENTORY_SERVICE_BASE_URL="http://inventory-inventory.$(routingzone)" \
    .

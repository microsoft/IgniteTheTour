#!/usr/bin/env bash
set -eou pipefail
source ../../scripts/variables.sh

BUILD_COMMAND="az acr build --registry $(acrname) --image "
prompt $BUILD_COMMAND ignite-product-service:latest \
-f Dockerfile \
.

#!/usr/bin/env bash
set -eou pipefail
source ../../../scripts/variables.sh

BUILD_COMMAND="az acr build --registry $(acrname) --image "
prompt $BUILD_COMMAND ignite-inventory-service:latest \
-f Dockerfile \
.

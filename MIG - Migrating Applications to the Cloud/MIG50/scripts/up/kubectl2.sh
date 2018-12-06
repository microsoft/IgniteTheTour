#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh


az aks get-credentials \
--resource-group $(rg2) \
--name $(clustername2) \
--file .kubeconfig \
--overwrite-existing

#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh


az aks get-credentials \
--resource-group $(rg2) \
--name $(clustername2) \
--file ~/.kube/config \
--overwrite-existing

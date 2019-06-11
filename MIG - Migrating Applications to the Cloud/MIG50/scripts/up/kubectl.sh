#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

# needs to be sudo on many systems b/c it writes the kubectl binary to /usr/local/bin
# add non-sudo so that we can run inside a docker container
#sudo az aks install-cli || az aks install-cli

az aks get-credentials \
--resource-group $(rg) \
--name $(clustername) \
--file ~/.kube/config \
--overwrite-existing

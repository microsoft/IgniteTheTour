#!/bin/bash
#set -eou pipefail
source ./scripts/variables.sh

az acr repository list -n $(acrname) -g $(rg) -o table

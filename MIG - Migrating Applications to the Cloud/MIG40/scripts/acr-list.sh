#!/usr/bin/env bash
set -eou pipefail
source ./scripts/variables.sh

prompt az acr repository list -n $(acrname) -g $(rg) -o table

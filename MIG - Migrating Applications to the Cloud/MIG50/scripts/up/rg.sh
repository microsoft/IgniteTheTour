#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

az group create --resource-group $(rg) --location $(location)

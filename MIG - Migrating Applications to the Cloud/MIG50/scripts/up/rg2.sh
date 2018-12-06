#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

az group create --resource-group $(rg2) --location $(location2)

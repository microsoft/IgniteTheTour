#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

az keyvault create --resource-group $(rg) --name $(akvname)

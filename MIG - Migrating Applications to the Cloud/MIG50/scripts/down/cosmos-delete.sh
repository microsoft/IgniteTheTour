#!/bin/bash
#set -eou pipefail
source ./scripts/variables.sh
az cosmosdb delete --name $(cosmosname) --resource-group $(rg)

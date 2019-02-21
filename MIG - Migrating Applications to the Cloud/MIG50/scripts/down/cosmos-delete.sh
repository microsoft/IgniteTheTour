#!/bin/bash
#set -eou pipefail
source ./scripts/variables.sh

echo "Deleting CosmosDB $(cosmosname) in resource group $(rg)"
az cosmosdb delete --name $(cosmosname) --resource-group $(rg)

#!/usr/bin/env bash
source ./scripts/variables.sh

echo "Deleting cosmos $(cosmosname) in resource group $(rg)"
az cosmosdb delete --name $(cosmosname) --resource-group $(rg)

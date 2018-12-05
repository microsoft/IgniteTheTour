#!/usr/bin/env bash
source ./scripts/variables.sh
az cosmosdb delete --name $(cosmosname) --resource-group $(rg)

#!/usr/bin/env bash
set -eou pipefail
set -x
source ./scripts/variables.sh

COSMOS_KEY=$(az cosmosdb list-keys  --name $(cosmosname) --resource-group $(rg) | jq -r .primaryMasterKey)

mongorestore --host "$(cosmosname).documents.azure.com:10255" --ssl -u $(cosmosname) -p $COSMOS_KEY --dir=dump --batchSize=10 --numParallelCollections=1

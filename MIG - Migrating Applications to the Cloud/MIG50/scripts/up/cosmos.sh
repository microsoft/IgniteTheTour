#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

prog() {
    local w=20 p=$1;  shift
    # create a string of spaces, then change them to dots
    printf -v dots "%*s" "$(( $p*$w/100 ))" ""; dots=${dots// /.};
    # print those dots on a fixed-width space plus the percentage etc. 
    printf "\r\e[K|%-*s| %3d %% %s" "$w" "$dots" "$p" "$*"; 
}

echo "Checking for existing cosmosdb..."
echo ''
#Create Cosmos DB loop
cosmosCheck=$(az cosmosdb list -g $(rg) | jq -r '.[] | .name')
cosmosSucceed=$(az cosmosdb list -g $(rg) | jq -r '.[] | .provisioningState')
if [ "$cosmosCheck" == "$(cosmosname)" ] && [ "$cosmosSucceed" == "Succeeded" ]; then
    echo "$(cosmosname) database already exists and provisioning has succeeded..."
    echo ''
else
    echo "Creating CosmosDB $(cosmosname) in resource group $(rg)"
    echo ''
    echo "This could take a while. Please be patient."
    echo " - Running .."
        # Create a MongoDB API Cosmos DB account with consistent prefix (Local) consistency and multi-master enabled
        az cosmosdb create \
            --resource-group $(rg) \
            --name $(cosmosname) \
            --kind MongoDB \
            --locations "eastus"=0 "westus"=1 \
            --default-consistency-level "ConsistentPrefix" \
            --enable-multiple-write-locations true \
            --enable-automatic-failover true
        ## TODO: Add in loop check to ensure DB is successfully provisioned before loop completes
fi

# make cosmos as idempotent as possible until integrated support exists
# https://github.com/Azure/azure-cli/issues/6272
echo "checking for existing $(dbname) db..."
echo ''
dbCheck=$(az cosmosdb database list -g $(rg) -n $(cosmosname) | jq -r '.[] | .id')
if [[ "$dbCheck" == "$(dbname)" ]]; then
    echo "$(dbname) already exists..."
    echo ''
else
    echo "Creating $(dbname) in the $(rg) resource group and $(cosmosname) cosmos db store now..."
    # Create a database 
    az cosmosdb database create \
    --resource-group $(rg) \
    --name $(cosmosname) \
    --db-name $(dbname)
fi

# make cosmos as idempotent as possible until integrated support exists
# https://github.com/Azure/azure-cli/issues/6272
echo "checking for existing $(collection) collection..."
echo ''
collectionCheck=$(az cosmosdb collection list -g $(rg) -n $(cosmosname) --db-name $(dbname) | jq -r '.[] | .id')
if [[ "$collectionCheck" == "$(collection)" ]]; then
    echo "$(collection) already exists..."
    echo ''
else
    echo "Creating $(collection) in the $(rg) resource group, $(cosmosname) cosmos db store, and $(dbname) database now..."
    echo ''

    # Create a collection with a partition key and 1000 RU/s
    az cosmosdb collection create \
        --resource-group $(rg) \
        --collection-name $(collection) \
        --name $(cosmosname) \
        --db-name $(dbname) \
        --throughput 1000
fi
echo "Cosmos setup has completed successfully."
echo ''

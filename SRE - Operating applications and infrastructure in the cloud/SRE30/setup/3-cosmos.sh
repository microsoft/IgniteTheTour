#!/bin/bash
set -eo pipefail

source ./0-params.sh

# Create a MongoDB API Cosmos DB account with consistent prefix (Local) consistency and multi-master enabled
echo "Creating the Cosmos DB resource for MongoDB."
az cosmosdb create \
    --resource-group $DB_RG \
    --name $COSMOSACCOUNTNAME \
    --kind MongoDB \
    --locations "$COSMOS_LOCATION1"=0 "$COSMOS_LOCATION2"=1 \
    --default-consistency-level "ConsistentPrefix" \
    --enable-multiple-write-locations true \
    -o table &> $base_source_path/../setup/log/3-cosmos.log

# Create a database
echo "Adding a Cosmos DB Database"
az cosmosdb database create \
    --resource-group $DB_RG \
    --name $COSMOSACCOUNTNAME \
    --db-name $DATABASENAME \
    -o table &>> $base_source_path/../setup/log/3-cosmos.log

# Populate data
echo "Loading $NUMBER_OF_ITEMS items to the database."
pushd $base_source_path/src/product-service
DB_CONNECTION_STRING="$(az cosmosdb list-connection-strings --name $COSMOSACCOUNTNAME --resource-group $DB_RG --query connectionStrings[0].connectionString | tr -d '"')"
echo "DB_CONNECTION_STRING=$DB_CONNECTION_STRING" > .env
echo "DB_NAME=$DATABASENAME" >> .env
echo "ITEMS_AMOUNT=$NUMBER_OF_ITEMS" >> .env
npm install &>> $base_source_path/../setup/log/3-cosmos.log
npm run populate:mongodb &>> $base_source_path/../setup/log/3-cosmos.log
popd

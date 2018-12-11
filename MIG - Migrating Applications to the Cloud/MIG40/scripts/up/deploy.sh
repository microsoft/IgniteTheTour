#!/usr/bin/env bash

source ./scripts/variables.sh

APP_SERVICE='app-service-linux'

prompt az appservice plan create \
    -g $(rg) \
    -n $APP_SERVICE \
    --is-linux --sku P1V2


CONTAINER_REGISTRY_PASSWORD=$(az acr credential show -n $(acrname) | jq -r .passwords[0].value)


WEB_APP_1='frontend-'$(rg)
prompt az webapp create \
    -g $(rg) \
    -n $WEB_APP_1 \
    --plan $APP_SERVICE  \
    --deployment-container-image-name 'nginx'

az webapp config container set -g $(rg) -n $WEB_APP_1 \
    --docker-custom-image-name "$(acrname).azurecr.io/ignite-frontend:latest" \
    --docker-registry-server-url "https://$(acrname).azurecr.io" \
    --docker-registry-server-user $(acrname) \
    --docker-registry-server-password $CONTAINER_REGISTRY_PASSWORD

printf "\n\n*** Configuring Frontend app settings ***\n"
az webapp config appsettings set -n $WEB_APP_1 -g $(rg) --settings "INVENTORY_SERVICE_BASE_URL=$(invbaseurl)" "PRODUCT_SERVICE_BASE_URL=$(prodbaseurl)"

WEB_APP_2='inventory-service-'$(rg)
prompt az webapp create \
    -g $(rg) \
    -n $WEB_APP_2 \
    --plan $APP_SERVICE \
    --deployment-container-image-name 'nginx'

az webapp config container set -g $(rg) -n $WEB_APP_2 \
    --docker-custom-image-name "$(acrname).azurecr.io/ignite-inventory-service:latest" \
    --docker-registry-server-url "https://$(acrname).azurecr.io" \
    --docker-registry-server-user $(acrname) \
    --docker-registry-server-password $CONTAINER_REGISTRY_PASSWORD

# appsettings
az webapp config appsettings set -g $(rg) -n $WEB_APP_2 --settings \
    'PORT'='80'
# connection-string
az webapp config connection-string set -g $(rg) -n $WEB_APP_2 --connection-string-type Custom --settings \
    'InventoryContext'='Server=tailwindlp2s4.postgres.database.azure.com;Database=tailwind;Port=5432;UserId=tuser@tailwindlp2s4;Password=asdf1234)(*&^);SslMode=Require;'

WEB_APP_3='product-service-'$(rg)
prompt az webapp create \
    -g $(rg) \
    -n $WEB_APP_3 \
    --plan $APP_SERVICE \
    --deployment-container-image-name 'nginx'

az webapp config container set -g $(rg) -n $WEB_APP_3 \
    --docker-custom-image-name "$(acrname).azurecr.io/ignite-product-service:latest" \
    --docker-registry-server-url "https://$(acrname).azurecr.io" \
    --docker-registry-server-user $(acrname) \
    --docker-registry-server-password $CONTAINER_REGISTRY_PASSWORD

printf "\n\n*** Retrieving Cosmos DB connection string ***\n"
COSMOSDB_CONNECTION_STRING=$(az cosmosdb list-connection-strings -n $(cosmosname) -g $(rg) --query connectionStrings[0].connectionString -o tsv)
# append name of database to connection string
COSMOSDB_CONNECTION_STRING=`echo $COSMOSDB_CONNECTION_STRING | sed -e "s/\?/tailwind\?/"`

printf "\n\n*** Configuring Product Service app settings ***\n"
az webapp config appsettings set -n $WEB_APP_3 -g $(rg) --settings "DB_CONNECTION_STRING=$COSMOSDB_CONNECTION_STRING" COLLECTION_NAME=inventory SEED_DATA=true

INVENTORY_SERVICE_BASE_URL="https://$(az webapp show -n $WEB_APP_2 -g $(rg) --query defaultHostName -o tsv)/"
PRODUCT_SERVICE_BASE_URL="https://$(az webapp show -n $WEB_APP_3 -g $(rg) --query defaultHostName -o tsv)/"
printf "\n$(invbaseurl)\n$(prodbaseurl)\n"

az webapp config appsettings set -n $WEB_APP_1 -g $(rg) --settings "INVENTORY_SERVICE_BASE_URL=$(invbaseurl)" "PRODUCT_SERVICE_BASE_URL=$(prodbaseurl)"

# diagnostic
az webapp log config -g $(rg) -n $WEB_APP_1 --application-logging true --docker-container-logging filesystem --web-server-logging filesystem
az webapp log config -g $(rg) -n $WEB_APP_2 --application-logging true --docker-container-logging filesystem --web-server-logging filesystem
az webapp log config -g $(rg) -n $WEB_APP_3 --application-logging true --docker-container-logging filesystem --web-server-logging filesystem

# This will not end, you must hit CTRL-C to stop it
prompt az webapp log tail -g $(rg) -n $WEB_APP_1

# open website
open "https://${WEB_APP_1}.azurewebsites.net/"

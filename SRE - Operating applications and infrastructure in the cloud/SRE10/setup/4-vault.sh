#!/bin/bash
set -eo pipefail

source ./0-params.sh

echo "Creating the application insights resource for front end."
az resource create \
    --resource-group $INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $front_insights_name \
    --location $LOCATION  \
    --properties '{"ApplicationId": "frontend", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> $base_source_path/../setup/log/4-vault.log

echo "Creating the application insights resource for product service."
az resource create \
    --resource-group $INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $prod_insights_name \
    --location $LOCATION  \
    --properties '{"ApplicationId": "product-service", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &>> $base_source_path/../setup/log/4-vault.log

echo "Creating the application insights resource for inventory service."
az resource create \
    --resource-group $INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $inv_insights_name \
    --location $LOCATION  \
    --properties '{"ApplicationId": "product-service", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &>> $base_source_path/../setup/log/4-vault.log


echo "Ensure that we can provision a keyvault instance."
az provider register -n Microsoft.KeyVault &>> $base_source_path/../setup/log/4-vault.log

echo "Creating keyvault"
az keyvault create --name "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}" --resource-group $KEYVAULT_RG --location $LOCATION &>> $base_source_path/../setup/log/4-vault.log

echo "Adding a key for the inventory service connection string."
connection_string="Server=tcp:${SERVERNAME}.database.windows.net,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=${DBUSER};Password=${DBPASS};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

az keyvault secret set --vault-name "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}" --name "InventoryContextSQL-${APP_ENVIRONMENT}" --value "${connection_string}" &>> $base_source_path/../setup/log/4-vault.log

echo "Adding a key for the mongodb connection string."
mongo_db_connection_string=`az cosmosdb list-connection-strings --name $COSMOSACCOUNTNAME --resource-group $DB_RG --query connectionStrings[0].connectionString | tr -d '"' | sed -e 's/\?ssl=true/tailwind?ssl=true/'` 

az keyvault secret set --vault-name "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}" --name "MongoConnectionString-${APP_ENVIRONMENT}" --value "${mongo_db_connection_string}" &>> $base_source_path/../setup/log/4-vault.log

echo "Adding a key for the inventory service app insights"
inv_app_insights_key=`az resource show -g $INSIGHTS_RG -n $inv_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

az keyvault secret set --vault-name "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}" --name "InventoryInsightsKey-${APP_ENVIRONMENT}" --value $inv_app_insights_key &>> $base_source_path/../setup/log/4-vault.log

echo "Adding a key for the product service app insights"
prod_app_insights_key=`az resource show -g $INSIGHTS_RG -n $prod_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

az keyvault secret set --vault-name "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}" --name "ProductInsightsKey-${APP_ENVIRONMENT}" --value $prod_app_insights_key &>> $base_source_path/../setup/log/4-vault.log

echo "Adding a key for the front end app insights"
front_app_insights_key=`az resource show -g $INSIGHTS_RG -n $front_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

az keyvault secret set --vault-name "${LEARNING_PATH}${SESSION_NUMBER}-${CITY}" --name "FrontendInsightsKey-${APP_ENVIRONMENT}" --value $front_app_insights_key &>> $base_source_path/../setup/log/4-vault.log

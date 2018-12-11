#!/bin/bash
set -eo pipefail

source ./0-params.sh

echo "Creating the application insights resource for front end."
az resource create \
    --resource-group $APP_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $front_insights_name \
    --location $LOCATION  \
    --properties '{"ApplicationId": "frontend", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> $base_source_path/../setup/log/4-setup-apps.log

echo "Creating the application insights resource for product service."
az resource create \
    --resource-group $APP_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $prod_insights_name \
    --location $LOCATION  \
    --properties '{"ApplicationId": "product-service", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> $base_source_path/../setup/log/4-setup-apps.log

echo "Creating the application insights resource for inventory service."
az resource create \
    --resource-group $APP_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $inv_insights_name \
    --location $LOCATION  \
    --properties '{"ApplicationId": "product-service", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> $base_source_path/../setup/log/4-setup-apps.log

front_app_insights_key=`az resource show -g $APP_RG -n $front_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

prod_app_insights_key=`az resource show -g $APP_RG -n $prod_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

inv_app_insights_key=`az resource show -g $APP_RG -n $inv_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

echo "Creating a Linux App Service Plan $app_svc_plan in $APP_RG"
az appservice plan create \
    --name $app_svc_plan \
    --resource-group $APP_RG \
    --is-linux \
    --sku P1V2 \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Creating the .NET Core website for the Inventory app."
az webapp create \
    --resource-group $APP_RG \
    --plan $app_svc_plan \
    --name $inv_app_name \
    --runtime "DOTNETCORE|2.1" \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Configure CORS for the Inventory App"
az webapp cors add -g $APP_RG -n $inv_app_name --allowed-origins "http://${front_app_name}.azurewebsites.net" &>> $base_source_path/../setup/log/4-setup-apps.log
az webapp cors add -g $APP_RG -n $inv_app_name --allowed-origins "https://${front_app_name}.azurewebsites.net" &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Enabling logging for the Inventory app"
az webapp log config \
    -n $inv_app_name \
    -g $APP_RG \
    --web-server-logging filesystem \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Configuring the startup for the Inventory app."
az webapp config set \
    -g $APP_RG \
    -n $inv_app_name \
    --startup-file 'dotnet InventoryService.Api.dll' \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Configuring the connection string for the Inventory app."
az webapp config connection-string set \
    -g $APP_RG \
    -n $inv_app_name \
    -t SQLAzure \
    --settings InventoryContext="Server=tcp:$SERVERNAME.database.windows.net,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=$DBUSER;Password=$DBPASS;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

# az webapp config connection-string set -g $APP_RG -n $inv_app_name -t PostgreSQL \
#     --settings InventoryContext="Server=$SERVERNAME.postgres.database.azure.com;Database=tailwind;Port=5432;User Id=$DBUSER@$SERVERNAME;Password=$DBPASS;SSL=true;SslMode=Require;"

echo "Configuring App Insights"
az webapp config appsettings set \
    -g $APP_RG \
    -n $inv_app_name \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${inv_app_insights_key}" \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log


echo "Creating the NodeJS website for the Product service."
az webapp create \
    --resource-group $APP_RG \
    --plan $app_svc_plan \
    --name $prod_svc_app_name \
    --runtime 'node|8.11' \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Configure CORS for the Product service"
az webapp cors add -g $APP_RG -n $prod_svc_app_name --allowed-origins "http://${front_app_name}.azurewebsites.net" &>> $base_source_path/../setup/log/4-setup-apps.log
az webapp cors add -g $APP_RG -n $prod_svc_app_name --allowed-origins "https://${front_app_name}.azurewebsites.net" &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Enabling logging for the Product service"
az webapp log config \
    -n $prod_svc_app_name \
    -g $APP_RG \
    --web-server-logging filesystem \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Configuring the CosmosDB connection string for the Product service."
mongo_db_connection_string=`az cosmosdb list-connection-strings --name $COSMOSACCOUNTNAME --resource-group $DB_RG --query connectionStrings[0].connectionString | tr -d '"' | sed -e 's/\?ssl=true/tailwind?ssl=true/'`

az webapp config appsettings set \
    -g $APP_RG \
    -n $prod_svc_app_name \
    --settings "DB_CONNECTION_STRING=$mongo_db_connection_string" \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

az webapp config appsettings set \
    -g $APP_RG \
    -n $prod_svc_app_name \
    --settings "COLLECTION_NAME=inventory" \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Configuring App Insights"
az webapp config appsettings set \
    -g $APP_RG \
    -n $prod_svc_app_name \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${prod_app_insights_key}" \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Creating the NodeJS website for the Frontend app."
az webapp create \
    --resource-group $APP_RG \
    --plan $app_svc_plan \
    --name $front_app_name \
    --runtime 'node|8.11' \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Enabling logging for the Frontend app"
az webapp log config \
    -n $front_app_name \
    -g $APP_RG \
    --web-server-logging filesystem \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

echo "Configuring the Product service and Inventory service URLs."
az webapp config appsettings set \
    -g $APP_RG \
    -n $front_app_name \
    --settings "PRODUCT_SERVICE_BASE_URL=https://$prod_svc_app_name.azurewebsites.net" "INVENTORY_SERVICE_BASE_URL=https://$inv_app_name.azurewebsites.net" "APPINSIGHTS_INSTRUMENTATIONKEY=${front_app_insights_key}" \
    -o table &>> $base_source_path/../setup/log/4-setup-apps.log

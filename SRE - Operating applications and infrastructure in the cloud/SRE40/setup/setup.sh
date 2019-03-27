#!/bin/bash
set -eo pipefail

#0 - load parameters
source ./0-params.sh

# 1 - Set up resource group
echo "Ensuring that we are using the right subscription - $SUBSCRIPTION"
az account set --subscription "$SUBSCRIPTION" &> 1-resource_group.log
echo "Creating resource group for apps $APP_RG in $LOCATION"
az group create -l $LOCATION -n $APP_RG -o table &>> 1-resource_group.log
echo ""
echo "Creating resource group for App Insights $INSIGHTS_RG in $LOCATION"
az group create -l $LOCATION -n $INSIGHTS_RG -o table &>> 1-resource_group.log
echo ""
echo "Creating resource group for DBs $DB_RG in $LOCATION"
az group create -l $LOCATION -n $DB_RG -o table &>> 1-resource_group.log
echo ""


#2 - run deployment for databases
### SQL SERVER
# Create a logical server in the resource group
echo "Creating a Azure SQL Server instance $SERVERNAME in $DB_RG."
az sql server create \
	--name $SERVERNAME \
	--resource-group $DB_RG \
	--location $LOCATION  \
	--admin-user $DBUSER \
	--admin-password $DBPASS \
	-o table &> 2-database.log

# Configure a firewall rule for the server
echo "Allowing Azure IPs to the Azure SQL Server instance."
az sql server firewall-rule create \
	--resource-group $DB_RG \
	--server $SERVERNAME \
	-n AllowAllAzureIPs \
	--start-ip-address $startip \
	--end-ip-address $endip \
	-o table &>> 2-database.log

# Create a database in the server with zone redundancy as true
echo "Creating the $DATABASENAME database on $SERVERNAME."
az sql db create \
	--resource-group $DB_RG \
	--server $SERVERNAME \
	--name $DATABASENAME \
	--service-objective S0 \
	--zone-redundant false \
	-o table &>> 2-database.log

# Load Data
echo "Loading starting data in $DATABASENAME on $SERVERNAME."
sqlcmd \
	-S tcp:$SERVERNAME.database.windows.net,1433 \
	-d tailwind \
	-U $DBUSER \
	-P $DBPASS \
	-i ~/source/tailwind-traders/sql_server/tailwind_ss.sql &>> 2-database.log

##COSMOS
# Create a MongoDB API Cosmos DB account with consistent prefix (Local) consistency and multi-master enabled
echo "Creating the Cosmos DB resource for MongoDB."
az cosmosdb create \
    --resource-group $DB_RG \
    --name $COSMOSACCOUNTNAME \
    --kind MongoDB \
    --locations "$LOCATION"=0 \
    --default-consistency-level "ConsistentPrefix" \
    --enable-multiple-write-locations true \
    -o table &> 3-cosmos.log

# Create a database
echo "Adding a Cosmos DB Database"
az cosmosdb database create \
    --resource-group $DB_RG \
    --name $COSMOSACCOUNTNAME \
    --db-name $DATABASENAME \
    -o table &>> 3-cosmos.log

# Populate data
echo "Loading $NUMBER_OF_ITEMS items to the database."
pushd $base_source_path/src/product-service
DB_CONNECTION_STRING="$(az cosmosdb list-connection-strings --name $COSMOSACCOUNTNAME --resource-group $DB_RG --query connectionStrings[0].connectionString | tr -d '"')"
echo "DB_CONNECTION_STRING=$DB_CONNECTION_STRING" > .env
echo "DB_NAME=$DATABASENAME" >> .env
echo "ITEMS_AMOUNT=$NUMBER_OF_ITEMS" >> .env
npm install &>> 3-cosmos.log
npm run populate:mongodb &>> 3-cosmos.log
popd


#5 - create apps
echo "Creating the application insights resource for front end."
az resource create \
    --resource-group $INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $front_insights_name \
    --location $APP_INSIGHTS_LOCATION  \
    --properties '{"ApplicationId": "frontend", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> 4-setup-apps.log

echo "Creating the application insights resource for product service."
az resource create \
    --resource-group $INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $prod_insights_name \
    --location $APP_INSIGHTS_LOCATION  \
    --properties '{"ApplicationId": "product-service", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> 4-setup-apps.log

echo "Creating the application insights resource for inventory service."
az resource create \
    --resource-group $INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $inv_insights_name \
    --location $APP_INSIGHTS_LOCATION  \
    --properties '{"ApplicationId": "product-service", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> 4-setup-apps.log

front_app_insights_key=`az resource show -g $INSIGHTS_RG -n $front_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

prod_app_insights_key=`az resource show -g $INSIGHTS_RG -n $prod_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

inv_app_insights_key=`az resource show -g $INSIGHTS_RG -n $inv_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

echo "Creating a Linux App Service Plan $app_svc_plan in $APP_RG"
az appservice plan create \
    --name $app_svc_plan \
    --resource-group $APP_RG \
    --is-linux \
    --sku B1 \
    -o table &>> 4-setup-apps.log

echo "Creating the .NET Core website for the Inventory app."
az webapp create \
    --resource-group $APP_RG \
    --plan $app_svc_plan \
    --name $inv_app_name \
    --runtime "DOTNETCORE|2.1" \
    -o table &>> 4-setup-apps.log

echo "Configure CORS for the Inventory App"
az webapp cors add -g $APP_RG -n $inv_app_name --allowed-origins "http://${front_app_name}.azurewebsites.net"
az webapp cors add -g $APP_RG -n $inv_app_name --allowed-origins "https://${front_app_name}.azurewebsites.net"

echo "Enabling logging for the Inventory app"
az webapp log config \
    -n $inv_app_name \
    -g $APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps.log

echo "Configuring the startup for the Inventory app."
az webapp config set \
    -g $APP_RG \
    -n $inv_app_name \
    --startup-file 'dotnet InventoryService.Api.dll' \
    -o table &>> 4-setup-apps.log

echo "Configuring the connection string for the Inventory app."
az webapp config connection-string set \
    -g $APP_RG \
    -n $inv_app_name \
    -t SQLAzure \
    --settings InventoryContext="Server=tcp:$SERVERNAME.database.windows.net,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=$DBUSER;Password=$DBPASS;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    -o table &>> 4-setup-apps.log

# az webapp config connection-string set -g $APP_RG -n $inv_app_name -t PostgreSQL \
#     --settings InventoryContext="Server=$SERVERNAME.postgres.database.azure.com;Database=tailwind;Port=5432;User Id=$DBUSER@$SERVERNAME;Password=$DBPASS;SSL=true;SslMode=Require;"

echo "Configuring App Insights"
az webapp config appsettings set \
    -g $APP_RG \
    -n $inv_app_name \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${inv_app_insights_key}" \
    -o table &>> 4-setup-apps.log


echo "Creating the NodeJS website for the Product service."
az webapp create \
    --resource-group $APP_RG \
    --plan $app_svc_plan \
    --name $prod_svc_app_name \
    --runtime 'node|8.11' \
    -o table &>> 4-setup-apps.log

echo "Configure CORS for the Product service"
az webapp cors add -g $APP_RG -n $prod_svc_app_name --allowed-origins "http://${front_app_name}.azurewebsites.net"
az webapp cors add -g $APP_RG -n $prod_svc_app_name --allowed-origins "https://${front_app_name}.azurewebsites.net"

echo "Enabling logging for the Product service"
az webapp log config \
    -n $prod_svc_app_name \
    -g $APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps.log

echo "Configuring the CosmosDB connection string for the Product service."
mongo_db_connection_string=`az cosmosdb list-connection-strings --name $COSMOSACCOUNTNAME --resource-group $DB_RG --query connectionStrings[0].connectionString | tr -d '"' | sed -e 's/\?ssl=true/tailwind?ssl=true/'`

az webapp config appsettings set \
    -g $APP_RG \
    -n $prod_svc_app_name \
    --settings "DB_CONNECTION_STRING=$mongo_db_connection_string" \
    -o table &>> 4-setup-apps.log

az webapp config appsettings set \
    -g $APP_RG \
    -n $prod_svc_app_name \
    --settings "COLLECTION_NAME=inventory" \
    -o table &>> 4-setup-apps.log

echo "Configuring App Insights"
az webapp config appsettings set \
    -g $APP_RG \
    -n $prod_svc_app_name \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${prod_app_insights_key}" \
    -o table &>> 4-setup-apps.log

echo "Creating the static html website for the Frontend app."
az webapp create \
    --resource-group $APP_RG \
    --plan $app_svc_plan \
    --name $front_app_name \
    --runtime 'php|7.2' \
    -o table &>> 4-setup-apps.log

echo "Enabling logging for the Frontend app"
az webapp log config \
    -n $front_app_name \
    -g $APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps.log

echo "Configuring the Product service and Inventory service URLs."
az webapp config appsettings set \
    -g $APP_RG \
    -n $front_app_name \
    --settings "PRODUCT_SERVICE_BASE_URL=https://$prod_svc_app_name.azurewebsites.net" "INVENTORY_SERVICE_BASE_URL=https://$inv_app_name.azurewebsites.net" "APPINSIGHTS_INSTRUMENTATIONKEY=${front_app_insights_key}" \
    -o table &>> 4-setup-apps.log

#6 - deploy the apps.
# Build and publish inventory service
echo "Building the inventory service."
pushd $base_source_path/src/inventory-service &> 5-deploy-apps.log
dotnet publish &>> 5-deploy-apps.log
pushd ./InventoryService.Api/bin/Debug/netcoreapp2.1/publish &>> 5-deploy-apps.log
zip -r publish.zip . &>> 5-deploy-apps.log

echo "Deploying the inventory service."
az webapp deployment source config-zip \
    --resource-group $APP_RG \
    --name $inv_app_name \
    --src publish.zip \
    -o table &>> 5-deploy-apps.log
rm publish.zip &>> 5-deploy-apps.log
popd &>> 5-deploy-apps.log
dotnet clean &>> 5-deploy-apps.log
popd &>> 5-deploy-apps.log

# Build and publish product service
pushd "$base_source_path/src/product-service" &>> 5-deploy-apps.log

echo "Building the product service."
npm install &>> 5-deploy-apps.log
zip -r publish.zip . &>> 5-deploy-apps.log

echo "Deploying the product service."
az webapp deployment source config-zip \
    --resource-group $APP_RG \
    --name $prod_svc_app_name \
    --src publish.zip \
    -o table &>> 5-deploy-apps.log
rm publish.zip &>> 5-deploy-apps.log
popd &>> 5-deploy-apps.log

# Build and publish product service
pushd $base_source_path/src/frontend &>> 5-deploy-apps.log
rm -rf ./dist &>> 5-deploy-apps.log
rm -rf ./.cache &>> 5-deploy-apps.log

# Build and publish frontend site
app_insights_key=`az resource show -g $INSIGHTS_RG -n $front_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey | tr -d '"'`

echo "PRODUCT_SERVICE_BASE_URL=https://$prod_svc_app_name.azurewebsites.net" > .env
echo "INVENTORY_SERVICE_BASE_URL=https://${inv_app_name}.azurewebsites.net" >> .env
echo "APPINSIGHTS_INSTRUMENTATIONKEY==${app_insights_key}" >> .env

echo "Adding app insights key to the app."

echo "Building the frontend app."
pushd ./src &>> 5-deploy-apps.log
sed -i "s/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx/${app_insights_key}/" index.html
popd &>> 5-deploy-apps.log

npm install &>> 5-deploy-apps.log
npm run build &>> 5-deploy-apps.log
pushd dist &>> 5-deploy-apps.log
zip -r publish.zip . &>> 5-deploy-apps.log

echo "Deploying the frontend app."
az webapp deployment source config-zip \
    --resource-group $APP_RG \
    --name $front_app_name \
    --src publish.zip \
    -o table &>> 5-deploy-apps.log
rm publish.zip &>> 5-deploy-apps.log
popd &>> 5-deploy-apps.log 
popd &>> 5-deploy-apps.log

echo ""
echo "Check out https://$front_app_name.azurewebsites.net/index.html"
echo ""
echo "Check the product service at https://$prod_svc_app_name.azurewebsites.net/api/products"
echo ""
echo "Check the inventory service at https://$inv_app_name.azurewebsites.net/swagger"
echo ""

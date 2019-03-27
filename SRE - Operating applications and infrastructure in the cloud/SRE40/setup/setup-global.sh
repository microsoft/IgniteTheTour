#!/bin/bash
set -eo pipefail

#0 - load parameters
source ./0-global-params.sh

# 1 - Set up resource group
echo "1 - SETTING UP RESOURCE GROUPS"
echo "Ensuring that we are using the right subscription - $SUBSCRIPTION"
az account set --subscription "$SUBSCRIPTION" &> 1-resource_group_global.log
echo "Creating resource group for apps $GLOBAL_APP_RG in $LOCATION"
az group create -l $LOCATION -n $GLOBAL_APP_RG -o table &>> 1-resource_group_global.log
echo ""
echo "Creating resource group for App Insights $GLOBAL_INSIGHTS_RG in $LOCATION"
az group create -l $LOCATION -n $GLOBAL_INSIGHTS_RG -o table &>> 1-resource_group_global.log
echo ""
echo "Creating resource group for DBs $GLOBAL_DB_RG in $LOCATION"
az group create -l $LOCATION -n $GLOBAL_DB_RG -o table &>> 1-resource_group_global.log
echo ""


#2 - run deployment for databases
### SQL SERVER
# Create a logical server in the resource group
echo "2 - Creating Azure SQL Databases"
echo "Creating a Azure SQL Server instance $SERVERNAME_PRIMARY in $GLOBAL_DB_RG. - [PRIMARY]"
az sql server create \
	--name $SERVERNAME_PRIMARY \
	--resource-group $GLOBAL_DB_RG \
	--location $LOCATION  \
	--admin-user $DBUSER \
	--admin-password $DBPASS \
	-o table &> 2-database_global.log

# Configure a firewall rule for the server
echo "Allowing Azure IPs to the Azure SQL Server instance by creating a Firewall Rule - [PRIMARY]"
az sql server firewall-rule create \
	--resource-group $GLOBAL_DB_RG \
	--server $SERVERNAME_PRIMARY \
	-n AllowAllAzureIPs \
	--start-ip-address $startip \
	--end-ip-address $endip \
	-o table &>> 2-database_global.log

# Create a database in the server with zone redundancy as true
echo "Creating the $DATABASENAME database on $SERVERNAME_PRIMARY. - [PRIMARY]"
az sql db create \
	--resource-group $GLOBAL_DB_RG \
	--server $SERVERNAME_PRIMARY \
	--name $DATABASENAME \
	--service-objective S0 \
	--zone-redundant false \
	-o table &>> 2-database_global.log

echo "Creating a Azure SQL Server instance $SERVERNAME_SECONDARY in $GLOBAL_DB_RG. - [SECONDARY]"
az sql server create \
	--name $SERVERNAME_SECONDARY \
	--resource-group $GLOBAL_DB_RG \
	--location $SECONDARY_LOCATION  \
	--admin-user $DBUSER \
	--admin-password $DBPASS \
	-o table &> 2-database_global.log

# Configure a firewall rule for the server
echo "Allowing Azure IPs to the Azure SQL Server instance by creating a Firewall Rule - [SECONDARY]"
az sql server firewall-rule create \
	--resource-group $GLOBAL_DB_RG \
	--server $SERVERNAME_SECONDARY\
	-n AllowAllAzureIPs \
	--start-ip-address $startip \
	--end-ip-address $endip \
	-o table &>> 2-database_global.log


echo "Creating replica of Azure SQL DB - [SECONDARY]"
az sql db replica create \
    -g $GLOBAL_DB_RG \
    -s $SERVERNAME_PRIMARY \
    -n $DATABASENAME \
    --partner-server $SERVERNAME_SECONDARY \
    --service-objective S0

# Load Data
echo "Loading starting data in $DATABASENAME on $SERVERNAME_PRIMARY."
sqlcmd \
	-S tcp:$SERVERNAME_PRIMARY.database.windows.net,1433 \
	-d tailwind \
	-U $DBUSER \
	-P $DBPASS \
	-i ~/source/tailwind-traders/sql_server/tailwind_ss.sql &>> 2-database_global.log

##COSMOS
# Create a MongoDB API Cosmos DB account with consistent prefix (Local) consistency and multi-master enabled
echo "3 - Creating CosmosDB Database"
echo "Creating the Cosmos DB resource for MongoDB. - [PRIMARY]"
az cosmosdb create \
    --resource-group $GLOBAL_DB_RG \
    --name $COSMOSACCOUNTNAME \
    --kind MongoDB \
    --locations "$LOCATION"=0 \
    --default-consistency-level "Strong" \
    --enable-multiple-write-locations true \
    -o table &> 3-cosmos_global.log

# Create a database
echo "Adding a Cosmos DB Database - [PRIMARY]"
az cosmosdb database create \
    --resource-group $GLOBAL_DB_RG \
    --name $COSMOSACCOUNTNAME \
    --db-name $DATABASENAME \
    -o table &>> 3-cosmos_global.log

# Populate data
echo "Loading $NUMBER_OF_ITEMS items to cosmosDB database. - [PRIMARY]"
pushd $base_source_path/src/product-service
DB_CONNECTION_STRING="$(az cosmosdb list-connection-strings --name $COSMOSACCOUNTNAME --resource-group $GLOBAL_DB_RG --query connectionStrings[0].connectionString | tr -d '"')"
echo "DB_CONNECTION_STRING=$DB_CONNECTION_STRING" > .env
echo "DB_NAME=$DATABASENAME" >> .env
echo "ITEMS_AMOUNT=$NUMBER_OF_ITEMS" >> .env
npm install &>> 3-cosmos_global.log
npm run populate:mongodb &>> 3-cosmos_global.log
popd


#5 - create apps
echo "4 - Creating the App Service Plans and Web Apps"
echo "Creating the application insights resource for front end."
az resource create \
    --resource-group $GLOBAL_INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $front_insights_name \
    --location $APP_INSIGHTS_LOCATION  \
    --properties '{"ApplicationId": "frontend", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> 4-setup-apps_global.log

echo "Creating the application insights resource for product service."
az resource create \
    --resource-group $GLOBAL_INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $prod_insights_name \
    --location $APP_INSIGHTS_LOCATION  \
    --properties '{"ApplicationId": "product-service", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> 4-setup-apps_global.log

echo "Creating the application insights resource for inventory service."
az resource create \
    --resource-group $GLOBAL_INSIGHTS_RG \
    --resource-type "Microsoft.Insights/components" \
    --name $inv_insights_name \
    --location $APP_INSIGHTS_LOCATION  \
    --properties '{"ApplicationId": "product-service", "Application_Type": "Node.JS", "Flow_Type": "Redfield", "Request_Source": "IbizaAIExtension"}' \
    -o table &> 4-setup-apps_global.log

front_app_insights_key=`az resource show -g $GLOBAL_INSIGHTS_RG -n $front_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

prod_app_insights_key=`az resource show -g $GLOBAL_INSIGHTS_RG -n $prod_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

inv_app_insights_key=`az resource show -g $GLOBAL_INSIGHTS_RG -n $inv_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey -o tsv`

echo "Creating a Linux App Service Plan $app_svc_plan_primary in $GLOBAL_APP_RG - [PRIMARY]"
az appservice plan create \
    --name $app_svc_plan_primary \
    --resource-group $GLOBAL_APP_RG \
    --location $LOCATION  \
    --is-linux \
    --sku B1 \
    -o table &>> 4-setup-apps_global.log

echo "Creating a Linux App Service Plan $app_svc_plan_secondary in $GLOBAL_APP_RG - [SECONDARY]"
az appservice plan create \
    --name $app_svc_plan_secondary \
    --resource-group $GLOBAL_APP_RG \
    --location $SECONDARY_LOCATION  \
    --is-linux \
    --sku B1 \
    -o table &>> 4-setup-apps_global.log

echo "Creating the .NET Core website for the Inventory app. [PRIMARY]"
az webapp create \
    --resource-group $GLOBAL_APP_RG \
    --plan $app_svc_plan_primary \
    --name $inv_app_name_primary \
    --runtime "DOTNETCORE|2.1" \
    -o table &>> 4-setup-apps_global.log

echo "Configure CORS for the Inventory App [PRIMARY]"
az webapp cors add -g $GLOBAL_APP_RG -n $inv_app_name_primary --allowed-origins "http://${front_app_name_primary}.azurewebsites.net"
az webapp cors add -g $GLOBAL_APP_RG -n $inv_app_name_primary --allowed-origins "https://${front_app_name_primary}.azurewebsites.net"

echo "Enabling logging for the Inventory app [PRIMARY]"
az webapp log config \
    -n $inv_app_name_primary \
    -g $GLOBAL_APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps_global.log

echo "Configuring the startup for the Inventory app. [PRIMARY]"
az webapp config set \
    -g $GLOBAL_APP_RG \
    -n $inv_app_name_primary \
    --startup-file 'dotnet InventoryService.Api.dll' \
    -o table &>> 4-setup-apps_global.log

echo "Configuring the connection string for the Inventory app. [PRIMARY]"
az webapp config connection-string set \
    -g $GLOBAL_APP_RG \
    -n $inv_app_name_primary \
    -t SQLAzure \
    --settings InventoryContext="Server=tcp:$SERVERNAME_PRIMARY.database.windows.net,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=$DBUSER;Password=$DBPASS;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    -o table &>> 4-setup-apps_global.log

# az webapp config connection-string set -g $GLOBAL_APP_RG -n $inv_app_name_primary -t PostgreSQL \
#     --settings InventoryContext="Server=$SERVERNAME_PRIMARY.postgres.database.azure.com;Database=tailwind;Port=5432;User Id=$DBUSER@$SERVERNAME_PRIMARY;Password=$DBPASS;SSL=true;SslMode=Require;"

echo "Configuring App Insights for the Inventory App [PRIMARY]"
az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $inv_app_name_primary \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${inv_app_insights_key}" \
    -o table &>> 4-setup-apps_global.log


echo "Creating the NodeJS website for the Product service. [PRIMARY]"
az webapp create \
    --resource-group $GLOBAL_APP_RG \
    --plan $app_svc_plan_primary \
    --name $prod_svc_app_name_primary \
    --runtime 'node|8.11' \
    -o table &>> 4-setup-apps_global.log

echo "Configure CORS for the Product service [PRIMARY]"
az webapp cors add -g $GLOBAL_APP_RG -n $prod_svc_app_name_primary --allowed-origins "http://${front_app_name_primary}.azurewebsites.net"
az webapp cors add -g $GLOBAL_APP_RG -n $prod_svc_app_name_primary --allowed-origins "https://${front_app_name_primary}.azurewebsites.net"

echo "Enabling logging for the Product service [PRIMARY]"
az webapp log config \
    -n $prod_svc_app_name_primary \
    -g $GLOBAL_APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps_global.log

echo "Configuring the CosmosDB connection string for the Product service. [PRIMARY]"
mongo_db_connection_string=`az cosmosdb list-connection-strings --name $COSMOSACCOUNTNAME --resource-group $GLOBAL_DB_RG --query connectionStrings[0].connectionString | tr -d '"' | sed -e 's/\?ssl=true/tailwind?ssl=true/'`

az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $prod_svc_app_name_primary \
    --settings "DB_CONNECTION_STRING=$mongo_db_connection_string" \
    -o table &>> 4-setup-apps_global.log

az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $prod_svc_app_name_primary \
    --settings "COLLECTION_NAME=inventory" \
    -o table &>> 4-setup-apps_global.log

echo "Configuring App Insights for the Product Service [PRIMARY]"
az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $prod_svc_app_name_primary \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${prod_app_insights_key}" \
    -o table &>> 4-setup-apps_global.log

echo "Creating the static html website for the Frontend app. [PRIMARY]"
az webapp create \
    --resource-group $GLOBAL_APP_RG \
    --plan $app_svc_plan_primary \
    --name $front_app_name_primary \
    --runtime 'php|7.2'
    -o table &>> 4-setup-apps_global.log

echo "Enabling logging for the Frontend app [PRIMARY]"
az webapp log config \
    -n $front_app_name_primary \
    -g $GLOBAL_APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps_global.log

echo "Configuring the Product service and Inventory service URLs. [PRIMARY]"
az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $front_app_name_primary \
    --settings "PRODUCT_SERVICE_BASE_URL=https://$prod_svc_app_name_primary.azurewebsites.net" "INVENTORY_SERVICE_BASE_URL=https://$inv_app_name_primary.azurewebsites.net" "APPINSIGHTS_INSTRUMENTATIONKEY=${front_app_insights_key}" \
    -o table &>> 4-setup-apps_global.log

#6 - deploy the apps.
# Build and publish inventory service
echo "5 - Deploying the Apps - [PRIMARY]"
echo "Building the inventory service. [PRIMARY]"
pushd $base_source_path/src/inventory-service &> 5-deploy-apps_global.log
dotnet publish &>> 5-deploy-apps_global.log
pushd ./InventoryService.Api/bin/Debug/netcoreapp2.1/publish &>> 5-deploy-apps_global.log
zip -r publish.zip . &>> 5-deploy-apps_global.log

echo "Deploying the inventory service. [PRIMARY]"
az webapp deployment source config-zip \
    --resource-group $GLOBAL_APP_RG \
    --name $inv_app_name_primary \
    --src publish.zip \
    -o table &>> 5-deploy-apps_global.log
rm publish.zip &>> 5-deploy-apps_global.log
popd &>> 5-deploy-apps_global.log
dotnet clean &>> 5-deploy-apps_global.log
popd &>> 5-deploy-apps_global.log

# Build and publish product service
pushd "$base_source_path/src/product-service" &>> 5-deploy-apps_global.log

echo "Building the product service. [PRIMARY]"
npm install &>> 5-deploy-apps_global.log
zip -r publish.zip . &>> 5-deploy-apps_global.log

echo "Deploying the product service. [PRIMARY]"
az webapp deployment source config-zip \
    --resource-group $GLOBAL_APP_RG \
    --name $prod_svc_app_name_primary \
    --src publish.zip \
    -o table &>> 5-deploy-apps_global.log
rm publish.zip &>> 5-deploy-apps_global.log
popd &>> 5-deploy-apps_global.log

# Build and publish product service
pushd $base_source_path/src/frontend &>> 5-deploy-apps_global.log
rm -rf ./dist &>> 5-deploy-apps_global.log
rm -rf ./.cache &>> 5-deploy-apps_global.log

# Build and publish frontend site
app_insights_key=`az resource show -g $GLOBAL_INSIGHTS_RG -n $front_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey | tr -d '"'`

echo "PRODUCT_SERVICE_BASE_URL=https://$prod_svc_app_name_primary.azurewebsites.net" >> .env
echo "INVENTORY_SERVICE_BASE_URL=https://${inv_app_name_primary}.azurewebsites.net" >> .env
echo "APPINSIGHTS_INSTRUMENTATIONKEY==${app_insights_key}" >> .env


echo "Building the frontend app. - [PRIMARY]"
pushd ./src &>> 5-deploy-apps_global.log
sed -i "s/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx/${app_insights_key}/" index.html
popd &>> 5-deploy-apps_global.log

npm install &>> 5-deploy-apps_global.log
npm run build &>> 5-deploy-apps_global.log
pushd dist &>> 5-deploy-apps_global.log
zip -r publish.zip . &>> 5-deploy-apps_global.log

echo "Deploying the frontend app. [PRIMARY]"
az webapp deployment source config-zip \
    --resource-group $GLOBAL_APP_RG \
    --name $front_app_name_primary \
    --src publish.zip \
    -o table &>> 5-deploy-apps_global.log
rm publish.zip &>> 5-deploy-apps_global.log
popd &>> 5-deploy-apps_global.log 
popd &>> 5-deploy-apps_global.log

#SEcondary sites
echo "4 - Creating the Web Apps - [SECONDARY]"
echo "Creating the .NET Core website for the Inventory app. [SECONDARY]"
az webapp create \
    --resource-group $GLOBAL_APP_RG \
    --plan $app_svc_plan_secondary \
    --name $inv_app_name_secondary \
    --runtime "DOTNETCORE|2.1" \
    -o table &>> 4-setup-apps_global.log

echo "Configure CORS for the Inventory App [SECONDARY]"
az webapp cors add -g $GLOBAL_APP_RG -n $inv_app_name_secondary --allowed-origins "http://${front_app_name_secondary}.azurewebsites.net"
az webapp cors add -g $GLOBAL_APP_RG -n $inv_app_name_secondary --allowed-origins "https://${front_app_name_secondary}.azurewebsites.net"

echo "Enabling logging for the Inventory app [SECONDARY]"
az webapp log config \
    -n $inv_app_name_secondary \
    -g $GLOBAL_APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps_global.log

echo "Configuring the startup for the Inventory app. [SECONDARY]"
az webapp config set \
    -g $GLOBAL_APP_RG \
    -n $inv_app_name_secondary \
    --startup-file 'dotnet InventoryService.Api.dll' \
    -o table &>> 4-setup-apps_global.log

echo "Configuring the connection string for the Inventory app. [SECONDARY]"
az webapp config connection-string set \
    -g $GLOBAL_APP_RG \
    -n $inv_app_name_secondary \
    -t SQLAzure \
    --settings InventoryContext="Server=tcp:$SERVERNAME_PRIMARY.database.windows.net,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=$DBUSER;Password=$DBPASS;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    -o table &>> 4-setup-apps_global.log

# az webapp config connection-string set -g $GLOBAL_APP_RG -n $inv_app_name_secondary -t PostgreSQL \
#     --settings InventoryContext="Server=$SERVERNAME_PRIMARY.postgres.database.azure.com;Database=tailwind;Port=5432;User Id=$DBUSER@$SERVERNAME_PRIMARY;Password=$DBPASS;SSL=true;SslMode=Require;"

echo "Configuring App Insights for the Inventory App [SECONDARY]"
az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $inv_app_name_secondary \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${inv_app_insights_key}" \
    -o table &>> 4-setup-apps_global.log


echo "Creating the NodeJS website for the Product service. [SECONDARY]"
az webapp create \
    --resource-group $GLOBAL_APP_RG \
    --plan $app_svc_plan_secondary \
    --name $prod_svc_app_name_secondary \
    --runtime 'node|8.11' \
    -o table &>> 4-setup-apps_global.log

echo "Configure CORS for the Product service [SECONDARY]"
az webapp cors add -g $GLOBAL_APP_RG -n $prod_svc_app_name_secondary --allowed-origins "http://${front_app_name_secondary}.azurewebsites.net"
az webapp cors add -g $GLOBAL_APP_RG -n $prod_svc_app_name_secondary --allowed-origins "https://${front_app_name_secondary}.azurewebsites.net"

echo "Enabling logging for the Product service [SECONDARY]"
az webapp log config \
    -n $prod_svc_app_name_secondary \
    -g $GLOBAL_APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps_global.log

echo "Configuring the CosmosDB connection string for the Product service. [SECONDARY]"
mongo_db_connection_string=`az cosmosdb list-connection-strings --name $COSMOSACCOUNTNAME --resource-group $GLOBAL_DB_RG --query connectionStrings[0].connectionString | tr -d '"' | sed -e 's/\?ssl=true/tailwind?ssl=true/'`

az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $prod_svc_app_name_secondary \
    --settings "DB_CONNECTION_STRING=$mongo_db_connection_string" \
    -o table &>> 4-setup-apps_global.log

az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $prod_svc_app_name_secondary \
    --settings "COLLECTION_NAME=inventory" \
    -o table &>> 4-setup-apps_global.log

echo "Configuring App Insights for the product service - [SECONDARY]"
az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $prod_svc_app_name_secondary \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${prod_app_insights_key}" \
    -o table &>> 4-setup-apps_global.log

echo "Creating the static html website for the Frontend app. [SECONDARY]"
az webapp create \
    --resource-group $GLOBAL_APP_RG \
    --plan $app_svc_plan_secondary \
    --name $front_app_name_secondary \
    --runtime 'php|7.2' \
    -o table &>> 4-setup-apps_global.log

echo "Enabling logging for the Frontend app [SECONDARY]"
az webapp log config \
    -n $front_app_name_secondary \
    -g $GLOBAL_APP_RG \
    --web-server-logging filesystem \
    -o table &>> 4-setup-apps_global.log

echo "Configuring the Product service and Inventory service URLs. [SECONDARY]"
az webapp config appsettings set \
    -g $GLOBAL_APP_RG \
    -n $front_app_name_secondary \
    --settings "PRODUCT_SERVICE_BASE_URL=https://$prod_svc_app_name_secondary.azurewebsites.net" "INVENTORY_SERVICE_BASE_URL=https://$inv_app_name_secondary.azurewebsites.net" "APPINSIGHTS_INSTRUMENTATIONKEY=${front_app_insights_key}" \
    -o table &>> 4-setup-apps_global.log

#6 - deploy the apps.
# Build and publish inventory service
echo "5 - Deploying the Web Apps - [SECONDARY]"
echo "Building the inventory service. [SECONDARY]"
pushd $base_source_path/src/inventory-service &> 5-deploy-apps_global.log
dotnet publish &>> 5-deploy-apps_global.log
pushd ./InventoryService.Api/bin/Debug/netcoreapp2.1/publish &>> 5-deploy-apps_global.log
zip -r publish.zip . &>> 5-deploy-apps_global.log

echo "Deploying the inventory service. [SECONDARY]"
az webapp deployment source config-zip \
    --resource-group $GLOBAL_APP_RG \
    --name $inv_app_name_secondary \
    --src publish.zip \
    -o table &>> 5-deploy-apps_global.log
rm publish.zip &>> 5-deploy-apps_global.log
popd &>> 5-deploy-apps_global.log
dotnet clean &>> 5-deploy-apps_global.log
popd &>> 5-deploy-apps_global.log

# Build and publish product service
pushd "$base_source_path/src/product-service" &>> 5-deploy-apps_global.log

echo "Building the product service. [SECONDARY]"
npm install &>> 5-deploy-apps_global.log
zip -r publish.zip . &>> 5-deploy-apps_global.log

echo "Deploying the product service. [SECONDARY]"
az webapp deployment source config-zip \
    --resource-group $GLOBAL_APP_RG \
    --name $prod_svc_app_name_secondary \
    --src publish.zip \
    -o table &>> 5-deploy-apps_global.log
rm publish.zip &>> 5-deploy-apps_global.log
popd &>> 5-deploy-apps_global.log

# Build and publish product service
pushd $base_source_path/src/frontend &>> 5-deploy-apps_global.log
rm -rf ./dist &>> 5-deploy-apps_global.log
rm -rf ./.cache &>> 5-deploy-apps_global.log

# Build and publish frontend site
app_insights_key=`az resource show -g $GLOBAL_INSIGHTS_RG -n $front_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey | tr -d '"'`

echo "PRODUCT_SERVICE_BASE_URL=https://$prod_svc_app_name_secondary.azurewebsites.net" >> .env
echo "INVENTORY_SERVICE_BASE_URL=https://${inv_app_name_secondary}.azurewebsites.net" >> .env
echo "APPINSIGHTS_INSTRUMENTATIONKEY==${app_insights_key}" >> .env


echo "Building the frontend app. [SECONDARY]"
pushd ./src &>> 5-deploy-apps_global.log
sed -i "s/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx/${app_insights_key}/" index.html
popd &>> 5-deploy-apps_global.log

npm install &>> 5-deploy-apps_global.log
npm run build &>> 5-deploy-apps_global.log
pushd dist &>> 5-deploy-apps_global.log
zip -r publish.zip . &>> 5-deploy-apps_global.log

echo "Deploying the frontend app. [SECONDARY]"
az webapp deployment source config-zip \
    --resource-group $GLOBAL_APP_RG \
    --name $front_app_name_secondary \
    --src publish.zip \
    -o table &>> 5-deploy-apps_global.log
rm publish.zip &>> 5-deploy-apps_global.log
popd &>> 5-deploy-apps_global.log 
popd &>> 5-deploy-apps_global.log

echo ""
echo "PRIMARY WEB APPS"
echo "Check out https://$front_app_name_primary.azurewebsites.net/index.html"
echo ""
echo "Check the product service at https://$prod_svc_app_name_primary.azurewebsites.net/api/products"
echo ""
echo "Check the inventory service at https://$inv_app_name_primary.azurewebsites.net/swagger"
echo ""
echo ""
echo "SECONDARY WEB APPS"
echo "Check out https://$front_app_name_secondary.azurewebsites.net/index.html"
echo ""
echo "Check the product service at https://$prod_svc_app_name_secondary.azurewebsites.net/api/products"
echo ""
echo "Check the inventory service at https://$inv_app_name_secondary.azurewebsites.net/swagger"
echo ""

read -p 'New resource group name: ' RESOURCE_GROUP_NAME
read -p 'Unique prefix (applied to all resources): ' RESOURCE_PREFIX
read -sp 'SQL Server Admin Password: ' SQL_ADMIN_PASSWORD

REGISTRY_NAME="$RESOURCE_PREFIX"registry
PRODUCT_SERVICE_NAME="$RESOURCE_PREFIX"product
INVENTORY_SERVICE_NAME="$RESOURCE_PREFIX"inventory
FRONTEND_NAME="$RESOURCE_PREFIX"frontend
COSMOSDB_NAME="$RESOURCE_PREFIX"cosmosdb

PRODUCT_SERVICE_IMAGE='tailwind-product-service:0.1'
INVENTORY_SERVICE_IMAGE='tailwind-inventory-service:0.1'
FRONTEND_IMAGE='tailwind-frontend:0.1'

MAIN_REGION=westus2

printf "\n*** Creating resource group $RESOURCE_GROUP_NAME ***\n"
az group create -n $RESOURCE_GROUP_NAME -l $MAIN_REGION

printf "\n*** Deploying resources: this will take a few minutes... ***\n"
az group deployment create -g $RESOURCE_GROUP_NAME --template-file azuredeploy.json --parameters prefix=$RESOURCE_PREFIX location=$MAIN_REGION "sqlAdminPassword=$SQL_ADMIN_PASSWORD"


printf "\n*** Building Product Service image in ACR ***\n"
az acr build -t $PRODUCT_SERVICE_IMAGE -r $REGISTRY_NAME ../src/product-service

printf "\n*** Building Inventory Service image in ACR ***\n"
az acr build -t $INVENTORY_SERVICE_IMAGE -r $REGISTRY_NAME ../src/inventory-service/InventoryService.Api

printf "\n\n*** Building Frontend image in ACR ***\n"
az acr build -t $FRONTEND_IMAGE -r $REGISTRY_NAME ../src/frontend


printf "\n\n*** Retrieving ACR information ***\n"
ACR_SERVER=$(az acr show -n $REGISTRY_NAME --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show -n $REGISTRY_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show -n $REGISTRY_NAME --query passwords[0].value -o tsv)
printf "\n\n*** $ACR_SERVER $ACR_USERNAME ***\n"


printf "\n\n*** Configuring Inventory Service to use ACR image ***\n"
az webapp config container set -n $INVENTORY_SERVICE_NAME -g $RESOURCE_GROUP_NAME -i "$ACR_SERVER/$INVENTORY_SERVICE_IMAGE" -u $ACR_USERNAME -p $ACR_PASSWORD



printf "\n\n*** Configuring Product Service to use ACR image ***\n"
az webapp config container set -n $PRODUCT_SERVICE_NAME -g $RESOURCE_GROUP_NAME -i "$ACR_SERVER/$PRODUCT_SERVICE_IMAGE" -u $ACR_USERNAME -p $ACR_PASSWORD

printf "\n\n*** Retrieving Cosmos DB connection string ***\n"
COSMOSDB_CONNECTION_STRING=$(az cosmosdb list-connection-strings -n $COSMOSDB_NAME -g $RESOURCE_GROUP_NAME --query connectionStrings[0].connectionString -o tsv)
# append name of database to connection string
COSMOSDB_CONNECTION_STRING=`echo $COSMOSDB_CONNECTION_STRING | sed -e "s/\?/tailwind\?/"`

printf "\n\n*** Configuring Product Service app settings ***\n"
az webapp config appsettings set -n $PRODUCT_SERVICE_NAME -g $RESOURCE_GROUP_NAME --settings "DB_CONNECTION_STRING=$COSMOSDB_CONNECTION_STRING" COLLECTION_NAME=inventory SEED_DATA=true


printf "\n\n*** Configuring Frontend to use ACR image ***\n"
az webapp config container set -n $FRONTEND_NAME -g $RESOURCE_GROUP_NAME -i "$ACR_SERVER/$FRONTEND_IMAGE" -u $ACR_USERNAME -p $ACR_PASSWORD

printf "\n\n*** Retrieving backend URLs ***\n"
INVENTORY_SERVICE_BASE_URL="https://$(az webapp show -n $INVENTORY_SERVICE_NAME -g $RESOURCE_GROUP_NAME --query defaultHostName -o tsv)/"
PRODUCT_SERVICE_BASE_URL="https://$(az webapp show -n $PRODUCT_SERVICE_NAME -g $RESOURCE_GROUP_NAME --query defaultHostName -o tsv)/"
printf "\n$INVENTORY_SERVICE_BASE_URL\n$PRODUCT_SERVICE_BASE_URL\n"

printf "\n\n*** Configuring Frontend app settings ***\n"
az webapp config appsettings set -n $FRONTEND_NAME -g $RESOURCE_GROUP_NAME --settings "INVENTORY_SERVICE_BASE_URL=$INVENTORY_SERVICE_BASE_URL" "PRODUCT_SERVICE_BASE_URL=$PRODUCT_SERVICE_BASE_URL"

FRONTEND_BASE_URL="https://$(az webapp show -n $FRONTEND_NAME -g $RESOURCE_GROUP_NAME --query defaultHostName -o tsv)/"

printf "\n\n*** Deployment to $RESOURCE_GROUP_NAME completed ***\n"
printf "$FRONTEND_BASE_URL\n"
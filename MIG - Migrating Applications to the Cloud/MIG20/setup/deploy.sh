read -p 'Subscription to use: ' SUBSCRIPTION
read -p 'New resource group name: ' RESOURCE_GROUP_NAME
read -p 'Unique prefix (applied to all resources): ' RESOURCE_PREFIX
read -p 'Username (applied to all resources): ' USERNAME
read -sp 'Password (applied to all resources): ' PASSWORD

echo ""

echo "Welcome to Tailwind Traders Data Migration!!"

REGISTRY_NAME="$RESOURCE_PREFIX"registry
PRODUCT_SERVICE_NAME="$RESOURCE_PREFIX"product
INVENTORY_SERVICE_NAME="$RESOURCE_PREFIX"inventory
FRONTEND_NAME="$RESOURCE_PREFIX"frontend
COSMOSDB_NAME="$RESOURCE_PREFIX"cosmosdb
SQL_MI_NAME="$RESOURCE_PREFIX"sqlmi
SQL_DMS_NAME="$RESOURCE_PREFIX"dms
SQL2012_VM_NAME='sql2012'
MONGO_VM_NAME='mongo'

PRODUCT_SERVICE_IMAGE='tailwind-product-service:0.1'
INVENTORY_SERVICE_IMAGE='tailwind-inventory-service:0.1'
FRONTEND_IMAGE='tailwind-frontend:0.1'

MAIN_REGION=eastus

printf "\n*** Setting the subsription to $SUBSCRIPTION***\n"
az account set --subscription $SUBSCRIPTION

printf "\n*** Creating resource group $RESOURCE_GROUP_NAME ***\n"
az group create -n $RESOURCE_GROUP_NAME -l $MAIN_REGION

printf "\n*** Creating the SQL Server 2012 Virtual Machine (can take 20 minutes) ***\n"
az group deployment create -g $RESOURCE_GROUP_NAME --template-file sqlvmdeploy.json \
    --parameters adminUsername=$USERNAME adminPassword=$PASSWORD sqlAuthenticationPassword=$PASSWORD sqlAuthenticationLogin=$USERNAME virtualMachineName=$SQL2012_VM_NAME

SQL2012_VM_IP_ADDRESS=$(az vm list-ip-addresses -g $RESOURCE_GROUP_NAME -n $SQL2012_VM_NAME | jq -r '.[0].virtualMachine.network.publicIpAddresses[0].ipAddress')

printf "\n*** Creating the MongoDB Virtual Machine ***\n"

sed -i -e "s/REPLACEUSERNAME/${USERNAME}/g" mongocloudinit.sh
sed -i -e "s/REPLACEPASSWORD/${PASSWORD}/g" mongocloudinit.sh

az vm create --resource-group $RESOURCE_GROUP_NAME --name $MONGO_VM_NAME \
    --size Standard_D2s_v3 --image UbuntuLTS --custom-data mongocloudinit.sh \
    --admin-username azureuser --generate-ssh-keys

az vm user update -u azureuser --ssh-key-value "$(< ~/.ssh/id_rsa.pub)" -g $RESOURCE_GROUP_NAME -n $MONGO_VM_NAME

MONGO_IP_ADDRESS=$(az vm list-ip-addresses -g $RESOURCE_GROUP_NAME -n $MONGO_VM_NAME | jq -r '.[0].virtualMachine.network.publicIpAddresses[0].ipAddress')

printf "\n*** Creating the necessary Mongo VM NSGs ***\n"
az network nsg rule create -n MongoDB --nsg-name "${MONGO_VM_NAME}NSG" -g $RESOURCE_GROUP_NAME --access Allow --direction Inbound --priority 500 --source-address-prefixes AzureCloud --destination-port-ranges 27017

printf "\n*** Cloning into DEV10: Designing Resilient Cloud Applications repository ***\n"
git clone https://github.com/Azure-Samples/ignite-tour-lp1s1.git

printf "\n*** Deploying the App Services and Cosmos DB ***\n"

az group deployment create -g $RESOURCE_GROUP_NAME --template-file appservicedeploy.json --parameters prefix=$RESOURCE_PREFIX location=$MAIN_REGION sqlVMIPAddress=$SQL2012_VM_IP_ADDRESS sqlAdminLogin=$USERNAME sqlAdminPassword=$PASSWORD

cd ignite-tour-lp1s1/deployment

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

MONGODB_CONNECTION_STRING="mongodb://${USERNAME}:${PASSWORD}@${MONGO_IP_ADDRESS}:27017/tailwind"

printf "\n\n*** Configuring Product Service app settings ***\n"
az webapp config appsettings set -n $PRODUCT_SERVICE_NAME -g $RESOURCE_GROUP_NAME --settings "DB_CONNECTION_STRING=$MONGODB_CONNECTION_STRING" COLLECTION_NAME=inventory SEED_DATA=true


printf "\n\n*** Configuring Frontend to use ACR image ***\n"
az webapp config container set -n $FRONTEND_NAME -g $RESOURCE_GROUP_NAME -i "$ACR_SERVER/$FRONTEND_IMAGE" -u $ACR_USERNAME -p $ACR_PASSWORD

printf "\n\n*** Retrieving backend URLs ***\n"
INVENTORY_SERVICE_BASE_URL="https://$(az webapp show -n $INVENTORY_SERVICE_NAME -g $RESOURCE_GROUP_NAME --query defaultHostName -o tsv)/"
PRODUCT_SERVICE_BASE_URL="https://$(az webapp show -n $PRODUCT_SERVICE_NAME -g $RESOURCE_GROUP_NAME --query defaultHostName -o tsv)/"
printf "\n$INVENTORY_SERVICE_BASE_URL\n$PRODUCT_SERVICE_BASE_URL\n"

printf "\n\n*** Configuring Frontend app settings ***\n"
az webapp config appsettings set -n $FRONTEND_NAME -g $RESOURCE_GROUP_NAME --settings "INVENTORY_SERVICE_BASE_URL=$INVENTORY_SERVICE_BASE_URL" "PRODUCT_SERVICE_BASE_URL=$PRODUCT_SERVICE_BASE_URL"

FRONTEND_BASE_URL="https://$(az webapp show -n $FRONTEND_NAME -g $RESOURCE_GROUP_NAME --query defaultHostName -o tsv)/"

# Finished with app service, go back to top level directory
cd ../../

printf "\n\n*** Creating the SQL Managed Instance ***\n"
az group deployment create -g $RESOURCE_GROUP_NAME --template-file managedinstancedeploy.json \
    --parameters managedInstanceName=$SQL_MI_NAME location=$MAIN_REGION administratorLogin=$USERNAME administratorLoginPassword=$PASSWORD virtualNetworkResourceGroupName=$RESOURCE_GROUP_NAME virtualNetworkName=sqlmivnet subnetName=sqlmisubnet \
    --no-wait

printf "\n******************************************************\n"
printf "\n\n*** Deployment to $RESOURCE_GROUP_NAME completed ***\n"
printf "\n******************************************************\n"

printf "\n You're going to want to write all of the following down:\n"
printf "Front end url: $FRONTEND_BASE_URL\n"
printf "Product service url: $PRODUCT_SERVICE_BASE_URL\n"
printf "Inventory service url: $INVENTORY_SERVICE_BASE_URL\n"
printf "Cosmos connection string: $COSMOSDB_CONNECTION_STRING\n"
printf "MongoDB VM connection string: $MONGODB_CONNECTION_STRING\n"
printf "SQL VM IP address: $SQL2012_VM_IP_ADDRESS"

printf "\n******************************************************\n"
printf "\n*** The SQL Managed Instance is still deploying. It will take up to 6 hours to finish. ***\n"
printf "\n*** DON'T FORGET TO RUN THE DATAMIGRATIONSERVICE-DEPLOY.SH AFTER IT FINISHES!!! ***\n"
printf "\n******************************************************\n"
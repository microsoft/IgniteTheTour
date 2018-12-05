read -p 'New resource group name: ' RESOURCE_GROUP_NAME
read -p 'Unique prefix (applied to all resources): ' RESOURCE_PREFIX

SQL_DMS_NAME="$RESOURCE_PREFIX"dms
MAIN_REGION=eastus

az network vnet subnet create -g $RESOURCE_GROUP_NAME --vnet-name sqlmivnet -n dms --address-prefix 10.0.1.0/24

printf "\n\n*** Creating the SQL Data Migration Service ***\n"
SUBNET_ID=$(az network vnet subnet show -g $RESOURCE_GROUP_NAME -n dms --vnet-name sqlmivnet | jq -r .id)

az dms create -g $RESOURCE_GROUP_NAME -l $MAIN_REGION -n $SQL_DMS_NAME \
    --sku-name BusinessCritical_4vCores --subnet $SUBNET_ID
RESOURCE_GROUP=policyEnforceName
POLICY_NAME=policyEnforceName
NAME_PATTERN=storage??
POLICY=./azuredeploy.json
PARAM=./azurepolicy.parameters.json

# Create  resource group
az group create --name $RESOURCE_GROUP --location eastus

# Get resource group id
SCOPE=$(az group show --name $RESOURCE_GROUP --query id -o tsv)

# Create policy
az policy definition create --name $POLICY_NAME --display-name $POLICY_NAME --description $POLICY_NAME --rules $POLICY --params $PARAM --mode All

# Assign policy
az policy assignment create --display-name $POLICY_NAME --scope $SCOPE --policy $POLICY_NAME -p '{"namePattern": {"value":"'"$NAME_PATTERN"'"},"resourceType": {"value":"Microsoft.Storage/storageAccounts"}}'
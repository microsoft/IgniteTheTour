#!/usr/bin/env bash
set -eou pipefail
source ./scripts/variables.sh

cd ./src/reports
echo "Running npm install for Azure function"
npm install

echo "Installing function extensions"
func extensions install
cd ../../

echo "Creating function resource group $(rgfunc) in location $(location)"
az group create --resource-group $(rgfunc) --location $(location)


# create storage account

echo "Creating function storage account $(storageaccount) in resource group $(rgfunc) and location $(location)"
az storage account create -g $(rgfunc) -n $(storageaccount) -l $(location) --sku Standard_LRS

#CONNECTION_STRING=$(az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME | jq -r .connectionString)
#echo $CONNECTION_STRING

# create functionapp
echo "Creating new function $(funcname) in resource group $(rgfunc)"
az functionapp create -g $(rgfunc) -n $(funcname) \
--storage-account $(storageaccount) \
--consumption-plan-location $(location)

FUNC_SENDGRID_API_KEY=`cat ./src/reports/local.settings.json | jq .Values.SENDGRID_API_KEY | sed 's/"//g'`
FUNC_SENDGRID_TEMPLATE_ID=`cat ./src/reports/local.settings.json | jq .Values.SENDGRID_TEMPLATE_ID | sed 's/"//g'`

az functionapp config appsettings set -g $(rgfunc) -n $(funcname) \
--settings WEBSITE_NODE_DEFAULT_VERSION='8.11.1' \
FUNCTIONS_WORKER_RUNTIME="node" \
PG_CONNECTION="$(funcpgconnection)?ssl=true" \
SENDGRID_API_KEY="$FUNC_SENDGRID_API_KEY" \
SENDGRID_TEMPLATE_ID="$FUNC_SENDGRID_TEMPLATE_ID"

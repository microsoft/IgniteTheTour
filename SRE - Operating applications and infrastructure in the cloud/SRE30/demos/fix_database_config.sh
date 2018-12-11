#!/bin/bash
set -eo pipefail

pushd ../setup
source ./0-params.sh
popd

echo "Resetting the connection string."
az webapp config connection-string set \
    -g $APP_RG \
    -n $inv_app_name \
    -t SQLAzure \
    --settings InventoryContext="Server=tcp:$SERVERNAME.database.windows.net,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=$DBUSER;Password=$DBPASS;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

sleep 10
echo "Restarting the app."
az webapp restart --name $inv_app_name --resource-group $APP_RG
sleep 10

echo "Let's try it again."
echo "Check out https://${front_app_name}.azurewebsites.net/index.html"

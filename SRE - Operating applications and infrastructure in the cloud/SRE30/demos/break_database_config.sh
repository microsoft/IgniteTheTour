#!/bin/bash
set -eo pipefail

pushd ../setup
source ./0-params.sh
popd

az webapp config connection-string set \
    -g $APP_RG \
    -n $inv_app_name \
    -t SQLAzure \
    --settings InventoryContext="Server=tcp:$SERVERNAME.database.windows.net,1433;Initial Catalog=tailwind;Persist Security Info=False;User ID=$DBUSER;Password='';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    -o table

az webapp restart --name $inv_app_name --resource-group $APP_RG

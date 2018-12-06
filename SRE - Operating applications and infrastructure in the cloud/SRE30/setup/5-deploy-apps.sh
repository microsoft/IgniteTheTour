#!/bin/bash
set -eo pipefail

source ./0-params.sh

# Build and publish inventory service
echo "Building the inventory service."
pushd $base_source_path/src/inventory-service &> $base_source_path/../setup/log/5-deploy-apps.log
dotnet publish &>> $base_source_path/../setup/log/5-deploy-apps.log
pushd ./InventoryService.Api/bin/Debug/netcoreapp2.1/publish &>> $base_source_path/../setup/log/5-deploy-apps.log
zip -r publish.zip . &>> $base_source_path/../setup/log/5-deploy-apps.log

echo "Deploying the inventory service."
az webapp deployment source config-zip \
    --resource-group $APP_RG \
    --name $inv_app_name \
    --src publish.zip \
    -o table &>> $base_source_path/../setup/log/5-deploy-apps.log
rm publish.zip &>> $base_source_path/../setup/log/5-deploy-apps.log
popd &>> $base_source_path/../setup/log/5-deploy-apps.log
dotnet clean &>> $base_source_path/../setup/log/5-deploy-apps.log
popd &>> $base_source_path/../setup/log/5-deploy-apps.log

# Build and publish product service
pushd "$base_source_path/src/product-service" &>> $base_source_path/../setup/log/5-deploy-apps.log

echo "Building the product service."
npm install &>> $base_source_path/../setup/log/5-deploy-apps.log
zip -r publish.zip . &>> $base_source_path/../setup/log/5-deploy-apps.log

echo "Deploying the product service."
az webapp deployment source config-zip \
    --resource-group $APP_RG \
    --name $prod_svc_app_name \
    --src publish.zip \
    -o table &>> $base_source_path/../setup/log/5-deploy-apps.log
rm publish.zip &>> $base_source_path/../setup/log/5-deploy-apps.log
popd &>> $base_source_path/../setup/log/5-deploy-apps.log

# Build and publish product service
pushd $base_source_path/src/frontend &>> $base_source_path/../setup/log/5-deploy-apps.log
rm -rf ./dist &>> $base_source_path/../setup/log/5-deploy-apps.log
rm -rf ./.cache &>> $base_source_path/../setup/log/5-deploy-apps.log

# Build and publish frontend site
app_insights_key=`az resource show -g $APP_RG -n $front_insights_name --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey | tr -d '"'`

echo "PRODUCT_SERVICE_BASE_URL=https://${prod_svc_app_name}.azurewebsites.net" > .env
echo "INVENTORY_SERVICE_BASE_URL=https://${inv_app_name}.azurewebsites.net" >> .env
echo "APPINSIGHTS_INSTRUMENTATIONKEY=${app_insights_key}" >> .env

echo "Adding app insights key to the app."

echo "Building the frontend app."
pushd ./src &>> $base_source_path/../setup/log/5-deploy-apps.log
sed -i "s/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx/${app_insights_key}/" index.html
popd &>> $base_source_path/../setup/log/5-deploy-apps.log

npm install &>> $base_source_path/../setup/log/5-deploy-apps.log
npm run build &>> $base_source_path/../setup/log/5-deploy-apps.log
pushd dist &>> $base_source_path/../setup/log/5-deploy-apps.log
zip -r publish.zip . &>> $base_source_path/../setup/log/5-deploy-apps.log

echo "Deploying the frontend app."
az webapp deployment source config-zip \
    --resource-group $APP_RG \
    --name $front_app_name \
    --src publish.zip \
    -o table &>> $base_source_path/../setup/log/5-deploy-apps.log
rm publish.zip &>> $base_source_path/../setup/log/5-deploy-apps.log
popd &>> $base_source_path/../setup/log/5-deploy-apps.log 
popd &>> $base_source_path/../setup/log/5-deploy-apps.log

echo ""
echo "Check out https://$front_app_name.azurewebsites.net/index.html"
echo ""
echo "Check the product service at https://$prod_svc_app_name.azurewebsites.net/api/products"
echo ""
echo "Check the inventory service at https://$inv_app_name.azurewebsites.net/www"
echo ""

#!/bin/bash
set -eo pipefail

source ./0-params.sh

# Set up resource group
echo "Ensuring that we are using the right subscription - $SUBSCRIPTION"
az account set --subscription "$SUBSCRIPTION" &> $base_source_path/../setup/log/1-resource_group.log
echo "Creating resource group for apps $APP_RG in $LOCATION"
az group create -l $LOCATION -n $APP_RG -o table &>> $base_source_path/../setup/log/1-resource_group.log
echo ""
echo "Creating resource group for DBs $DB_RG in $LOCATION"
az group create -l $LOCATION -n $DB_RG -o table &>> $base_source_path/../setup/log/1-resource_group.log
echo ""

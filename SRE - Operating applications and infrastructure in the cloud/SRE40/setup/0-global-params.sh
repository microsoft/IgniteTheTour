#!/bin/bash
set -eo pipefail

## Common parameters
LEARNING_PATH="lp5"
SESSION_NUMBER="s4"
SUBSCRIPTION="Ignite the Tour"
APP_RG="${LEARNING_PATH}${SESSION_NUMBER}-app-${USER}"
#INSIGHTS_RG="${LEARNING_PATH}${SESSION_NUMBER}-insights-${USER}"
INSIGHTS_RG="${APP_RG}"
DB_RG="${LEARNING_PATH}${SESSION_NUMBER}-db-${USER}"
GLOBAL_APP_RG="${LEARNING_PATH}${SESSION_NUMBER}-app-global-${USER}"
GLOBAL_DB_RG="${LEARNING_PATH}${SESSION_NUMBER}-db-global-${USER}"
GLOBAL_INSIGHTS_RG="${GLOBAL_APP_RG}"

LOCATION="northeurope"
SECONDARY_LOCATION="westeurope"
APP_INSIGHTS_LOCATION="westus2"

## SQL and Cosmos Database settings
SERVERNAME_PRIMARY="tw-sql-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-primary"
SERVERNAME_SECONDARY="tw-sql-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-secondary"
DBUSER="admin${LEARNING_PATH}${SESSION_NUMBER}"
if [ -a "$PWD/.dbpass" ]
then
      DBPASS="$(<.dbpass)"      
else
      DBPASS="$(pwsh -nop -noni -nol -c '(New-Guid).Guid')"
      echo $DBPASS > .dbpass
fi
DATABASENAME='tailwind' 
COSMOSACCOUNTNAME="tw${LEARNING_PATH}${SESSION_NUMBER}${USER}-global"
NUMBER_OF_ITEMS=100

# separate locations for CosmosDB instances, should be distinct
COSMOS_LOCATION1='West US 2'
COSMOS_LOCATION2='West Central US'

## Used to allow database access from all Azure IPs
startip='0.0.0.0'
endip='0.0.0.0'

## Application settings
base_insights_name="tw-insights-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-global"
front_insights_name="front-${base_insights_name}"
prod_insights_name="prod-${base_insights_name}"
inv_insights_name="inv-${base_insights_name}"
app_svc_plan_primary="tw-svcs-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-primary"
app_svc_plan_secondary="tw-svcs-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-secondary"
front_app_name_primary="tw-frontend-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-primary"
prod_svc_app_name_primary="tw-product-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-primary"
inv_app_name_primary="tw-inventory-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-primary"
front_app_name_secondary="tw-frontend-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-secondary"
prod_svc_app_name_secondary="tw-product-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-secondary"
inv_app_name_secondary="tw-inventory-${LEARNING_PATH}${SESSION_NUMBER}-${USER}-secondary"
base_source_path="$HOME/source/ignite-tour-lp5-s4/speaker-setup"

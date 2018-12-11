#!/bin/bash
set -eo pipefail

## Common parameters
LEARNING_PATH="SRE"
SESSION_NUMBER="40"
CITY="berlin"
SUBSCRIPTION="Ignite the Tour"
APP_RG="${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}"
#INSIGHTS_RG="${LEARNING_PATH}${SESSION_NUMBER}-insights-${CITY}"
INSIGHTS_RG="${APP_RG}"
DB_RG="${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}"
GLOBAL_APP_RG="${LEARNING_PATH}${SESSION_NUMBER}-app-global-${CITY}"
GLOBAL_DB_RG="${LEARNING_PATH}${SESSION_NUMBER}-db-global-${CITY}"
GLOBAL_INSIGHTS_RG="${GLOBAL_APP_RG}"

LOCATION="northeurope"
SECONDARY_LOCATION="westeurope"
APP_INSIGHTS_LOCATION="westus2"

## SQL and Cosmos Database settings
SERVERNAME_PRIMARY="tw-sql-${LEARNING_PATH,,}${SESSION_NUMBER}-${CITY}-primary"
SERVERNAME_SECONDARY="tw-sql-${LEARNING_PATH,,}${SESSION_NUMBER}-${CITY}-secondary"
DBUSER="admin${LEARNING_PATH}${SESSION_NUMBER}"
if [ -a "$PWD/.dbpass" ]
then
      DBPASS="$(<.dbpass)"      
else
      DBPASS="$(pwsh -nop -noni -nol -c '(New-Guid).Guid')"
      echo $DBPASS > .dbpass
fi
DATABASENAME='tailwind' 
COSMOSACCOUNTNAME="tw${LEARNING_PATH,,}${SESSION_NUMBER}${CITY}-global"
NUMBER_OF_ITEMS=100

# separate locations for CosmosDB instances, should be distinct
COSMOS_LOCATION1='West US 2'
COSMOS_LOCATION2='West Central US'

## Used to allow database access from all Azure IPs
startip='0.0.0.0'
endip='0.0.0.0'

## Application settings
base_insights_name="tw-insights-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-global"
front_insights_name="front-${base_insights_name}"
prod_insights_name="prod-${base_insights_name}"
inv_insights_name="inv-${base_insights_name}"
app_svc_plan_primary="tw-svcs-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-primary"
app_svc_plan_secondary="tw-svcs-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-secondary"
front_app_name_primary="tw-frontend-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-primary"
prod_svc_app_name_primary="tw-product-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-primary"
inv_app_name_primary="tw-inventory-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-primary"
front_app_name_secondary="tw-frontend-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-secondary"
prod_svc_app_name_secondary="tw-product-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-secondary"
inv_app_name_secondary="tw-inventory-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-secondary"
base_source_path="$HOME/source/ignitethetour/SRE - Operating applications and infrastructure in the cloud/SRE40/setup"

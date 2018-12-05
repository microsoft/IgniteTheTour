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

LOCATION="westus2"
SECONDARY_LOCATION="westcentralus"
APP_INSIGHTS_LOCATION="westus2"

## SQL and Cosmos Database settings
SERVERNAME="tw-sql-${LEARNING_PATH}${SESSION_NUMBER}-${USER}"
DBUSER="admin${LEARNING_PATH}${SESSION_NUMBER}"
if [ -a "$PWD/.dbpass" ]
then
      DBPASS="$(<.dbpass)"      
else
      DBPASS="$(pwsh -nop -noni -nol -c '(New-Guid).Guid')"
      echo $DBPASS > .dbpass
fi
DATABASENAME='tailwind' 
COSMOSACCOUNTNAME="tw${LEARNING_PATH}${SESSION_NUMBER}${USER}"
NUMBER_OF_ITEMS=100

# separate locations for CosmosDB instances, should be distinct
COSMOS_LOCATION1='North Central US'
COSMOS_LOCATION2='South Central US'

## Used to allow database access from all Azure IPs
startip='0.0.0.0'
endip='0.0.0.0'

## Application settings
base_insights_name="tw-insights-${LEARNING_PATH}${SESSION_NUMBER}-${USER}"
front_insights_name="front-${base_insights_name}"
prod_insights_name="prod-${base_insights_name}"
inv_insights_name="inv-${base_insights_name}"
app_svc_plan="tw-svcs-${LEARNING_PATH}${SESSION_NUMBER}-${USER}"
front_app_name="tw-frontend-${LEARNING_PATH}${SESSION_NUMBER}-${USER}"
prod_svc_app_name="tw-product-${LEARNING_PATH}${SESSION_NUMBER}-${USER}"
inv_app_name="tw-inventory-${LEARNING_PATH}${SESSION_NUMBER}-${USER}"
base_source_path="$HOME/source/ignite-tour-lp5-s4/speaker-setup"

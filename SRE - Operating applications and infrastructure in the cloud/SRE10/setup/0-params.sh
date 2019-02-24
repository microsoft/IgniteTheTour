#!/bin/bash
set -eo pipefail

## Common Parameters
if [ -z "$APP_ENVIRONMENT" ]; then
  APP_ENVIRONMENT="dev"
fi 

CITY="berlin"
LEARNING_PATH="SRE"
SESSION_NUMBER="10"
SUBSCRIPTION="Ignite the Tour"
LOCATION="westeurope"

### Source Code
base_source_path="$HOME/source/SRE - Operating applications and infrastructure in the cloud/SRE10/demos"

## Resource Group Names
APP_RG="${LEARNING_PATH}${SESSION_NUMBER}-app-${CITY}-${APP_ENVIRONMENT}"
DB_RG="${LEARNING_PATH}${SESSION_NUMBER}-db-${CITY}-${APP_ENVIRONMENT}"
KEYVAULT_RG="${LEARNING_PATH}${SESSION_NUMBER}-vault-${CITY}"
INSIGHTS_RG="${LEARNING_PATH}${SESSION_NUMBER}-insights-${CITY}-${APP_ENVIRONMENT}"

## SQL and Cosmos Database settings
SERVERNAME="tw-sql${SESSION_NUMBER}-${CITY}-${APP_ENVIRONMENT}"
DBUSER="admin${LEARNING_PATH}${SESSION_NUMBER}"
if [ -a "$PWD/.dbpass" ]
then
      DBPASS="$(<.dbpass)"      
else
      DBPASS="$(pwsh -nop -noni -nol -c '(New-Guid).Guid')"
      echo $DBPASS > .dbpass
fi
DATABASENAME='tailwind' 
COSMOSACCOUNTNAME="twmongo${SESSION_NUMBER}${CITY}${APP_ENVIRONMENT}"
NUMBER_OF_ITEMS=100

### separate locations for CosmosDB instances, should be distinct
COSMOS_LOCATION1='North Central US'
COSMOS_LOCATION2='South Central US'

## Used to allow database access from all Azure IPs
startip='0.0.0.0'
endip='0.0.0.0'

## Application settings

### App Insights
base_insights_name="tw-insights-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-${APP_ENVIRONMENT}"
front_insights_name="front-${base_insights_name}"
prod_insights_name="prod-${base_insights_name}"
inv_insights_name="inv-${base_insights_name}"

### App Service
app_svc_plan="tw-svcs-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-${APP_ENVIRONMENT}"
front_app_name="tw-frontend-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-${APP_ENVIRONMENT}"
prod_svc_app_name="tw-product-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-${APP_ENVIRONMENT}"
inv_app_name="tw-inventory-${LEARNING_PATH}${SESSION_NUMBER}-${CITY}-${APP_ENVIRONMENT}"

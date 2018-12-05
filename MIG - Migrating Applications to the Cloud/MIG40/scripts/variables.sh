#!/usr/bin/env bash


BASE=mig40
EMAIL=`az account show | jq .user.name | sed 's/"//g'`
PRESENTER=`az account show | jq .user.name | sed 's/^"\([^@]*\)@.*.com"$/\1/'`
LOCATION=eastus
SUB='Ignite the Tour'
DB_BASE=tailwind
PG_HOST_BASE=".postgres.database.azure.com"
PG_USER_BASE=tuser
PG_USER="tuser@tailwindlp2s4"
PG_PASS='asdf1234)(*&^)'
COLLECTION=inventory

SQL_USERNAME="username"
SQL_DATABASE="tailwind"
SQL_PASSWORD=`az keyvault secret show --vault-name ignitetour-credentials --name 'SQLPassword' | jq .value | sed 's/"//g'`
SQL_SERVER=`az keyvault secret show --vault-name ignitetour-credentials --name 'SQLServer' | jq .value | sed 's/"//g'`
SENDGRID_API_KEY=`az keyvault secret show --vault-name ignitetour-credentials --name 'SendGridAPIKey' | jq .value | sed 's/"//g'`
SENDGRID_TEMPLATE_ID="d-f6aad27b127643e29f4ce3de5ca7d5f9"

function prompt(){
  dryrun=${DRY_RUN:-}
  disable=${DISABLE_PROMPT:-}

  echo -e "\n\n\033[1;32m$@\033[0m"

  if [ -z "$disable" ]; then
    read -rse -n1 key
  fi

  if [ -z "$dryrun" ]; then
    $@
  fi
}

function base() 
{
    local  base=$BASE
    echo "$base"
}
function presenter() 
{
    local  presenter=$PRESENTER
    echo "$presenter"
}
function rg()
{
    local rg=$(base)$(presenter)
    echo "$rg"

}
function location() 
{
    local  location=$LOCATION
    echo "$location"
}
function subscription() 
{
    local  subscription=$SUB
    echo "$subscription"
}
function acrname() 
{
    local  acrname=$(rg)
    echo "$acrname"
}

function pgname() 
{
    local  pgname=$DB_BASE-$(presenter)-$(base)
    echo "$pgname"
}
function pghost() 
{
    local  pghost=$(pgname)$PG_HOST_BASE
    echo "$pghost"
}

function pguserbase() 
{
    local  pguserbase=$PG_USER_BASE
    echo "$pguserbase"
}

function pguser() 
{
    local  pguser=$PG_USER_BASE@$(pgname)
    echo "$pguser"
}
function pgpass() 
{
    local  pgpass=$PG_PASS
    echo "$pgpass"
}
function dbname() 
{
    local  dbname=$DB_BASE
    echo "$dbname"
}
function cosmosname()
{
    local cosmosname=$BASE-cosmos-$PRESENTER
    echo "$cosmosname"
}
function collection()
{
    local collection=$COLLECTION
    echo "$collection"
}
function akvname()
{
    local akvname=$BASE-$PRESENTER-vlt
    echo "$akvname"
}
function rgfunc()
{
    local rgfunc=$(rg)-func
    echo "$rgfunc" 
}

function storageaccount()
{
    local storageaccount=$(rg)stor
    echo "$storageaccount"
}
function funcname()
{
    local funcname=function$(rg)
    echo "$funcname"
}
function prodbaseurl()
{
    local prodbaseurl="https://product-service-$(rg).azurewebsites.net"
    echo "$prodbaseurl"
}
function invbaseurl()
{
    local invbaseurl="https://inventory-service-$(rg).azurewebsites.net"
    echo "$invbaseurl"
}
function dotnetconnection()
{
    local dotnetconnection="Server=$(pghost);Database=$(dbname);Port=5432;UserId=$(pguser);Password=$(pgpass);SslMode=Require;"
    echo "$dotnetconnection"
}

# tests below
#echo Base: $(base)
#echo Presenter: $(presenter)
#echo RG: $(rg)
#echo Location: $(location)
#echo Subscription: $(subscription)
#echo ACR Name: $(acrname)
#echo PG Name: $(pgname)
#echo PG Host: $(pghost)
#echo PG User: $(pguser)
#echo PG Password: $(pgpass)
#echo PG DB Name: $(dbname)
#echo Cosmos Name: $(cosmosname)
#echo Collection: $(collection)
#echo Azure Key Vault Name: $(akvname)
#echo Function RG Name: $(rgfunc)
#echo Storage Account Name: $(storageaccount)
#echo Function Name: $(funcname)
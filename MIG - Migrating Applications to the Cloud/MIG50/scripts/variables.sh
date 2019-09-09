#!/bin/bash
#set -eou pipefail

BASE=mig50
PRESENTER=`az account show | jq .user.name | sed 's/^"\([^@]*\)@.*.com"$/\1/'`
LOCATION=eastus
LOCATION2=westus2
SUB='Ignite the Tour'
DB_BASE=tailwind
PG_HOST_BASE=".postgres.database.azure.com"
PG_USER_BASE=tuser
PG_PASS='asdf1234)(*&^)'
COLLECTION=inventory
KUBERNETESVERSION=1.14.6
CLUSTER_NAME=mig50
NODECOUNT=3

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
function rg2()
{
    local rg2=$(base)$(presenter)2
    echo "$rg2"

}
function location() 
{
    local  location=$LOCATION
    echo "$location"
}
function location2() 
{
    local  location2=$LOCATION2
    echo "$location2"
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
function kubernetesversion()
{
    local kubernetesversion=$KUBERNETESVERSION
    echo "$kubernetesversion"
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
function clustername()
{
    local clustername=$CLUSTER_NAME
    echo "$clustername"
}
function clustername2()
{
    local clustername2="$CLUSTER_NAME"2
    echo "$clustername2"
}
function nodecount()
{
    local nodecount=$NODECOUNT
    echo "$nodecount"
}

function routingzone()
{
    local routingzone=`az aks show --resource-group $(rg) --name $(clustername) --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o tsv`
    echo "$routingzone"
}
function routingzone2()
{
    local routingzone2=`az aks show --resource-group $(rg2) --name $(clustername2) --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o tsv`
    echo "$routingzone2"
}

function fdproduct()
{
    local fdproduct=product-product.$(routingzone)
    echo "$fdproduct"
}
function fdfrontend()
{
    local fdfrontend=frontend-frontend.$(routingzone)
    echo "$fdfrontend"
}
function fdinventory()
{
    local fdinventory=inventory-inventory.$(routingzone)
    echo "$fdinventory"
}
function fdproduct2()
{
    local fdproduct2=product-product.$(routingzone2)
    echo "$fdproduct2"
}
function fdfrontend2()
{
    local fdfrontend2=frontend-frontend.$(routingzone2)
    echo "$fdfrontend2"
}
function fdinventory2()
{
    local fdinventory2=inventory-inventory.$(routingzone2)
    echo "$fdinventory2"
}
function fdname()
{
    local fdname=$(rg)fd
    echo "$fdname"
}
function fdaddress()
{
    local fdaddress=$(rg).azurefd.net
    echo "$fdaddress"
}
# function revisionId(){
#     local revisionId=$(helm ls --output json | jq -r '.Releases[0].Revision')
#     echo "$revisionId"
# }

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
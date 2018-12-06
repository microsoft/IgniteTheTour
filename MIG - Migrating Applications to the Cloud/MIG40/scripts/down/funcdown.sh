#!/usr/bin/env bash
source ./scripts/variables.sh

# delete storage account
az storage account delete --yes -g $(rgfunc) -n $(storageaccount)

# delete functionapp
az functionapp delete -g $(rgfunc) -n $(funcname)
az group delete --yes --resource-group $(rgfunc)


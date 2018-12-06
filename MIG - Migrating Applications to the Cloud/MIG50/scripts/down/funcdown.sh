#!/bin/bash
#set -eou pipefail
source ./scripts/variables.sh

# create storage account
az storage account delete --yes -g $(rgfunc) -n $(storageaccount)

# create functionapp
az functionapp delete -g $(rgfunc) -n $(funcname)
az group delete --yes --resource-group $(rgfunc)


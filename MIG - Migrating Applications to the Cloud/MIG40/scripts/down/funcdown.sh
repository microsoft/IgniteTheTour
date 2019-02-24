#!/usr/bin/env bash
source ./scripts/variables.sh

rm -f src/reports/local.settings.json
rm -f src/reports/CreateReport/function.json
rm -f src/reports/RunCreateReport/function.json

# delete storage account
echo "Removing function storage account $(storageaccount) in resource group $(rg)"
az storage account delete --yes -g $(rgfunc) -n $(storageaccount)

# delete functionapp
echo "Removing function app $(funcname) in resource group $(rgfunc)"
az functionapp delete -g $(rgfunc) -n $(funcname)

echo "Removing function resource group $(rgfunc)"
az group delete --yes --resource-group $(rgfunc)


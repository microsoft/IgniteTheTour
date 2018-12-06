#!/usr/bin/env bash
source ./scripts/variables.sh
az group delete --yes --resource-group $(rg)

az group delete --yes --resource-group $(rgfunc)

#!/usr/bin/env bash
source ./scripts/variables.sh

echo "Deleting main resource group $(rg)"
az group delete --yes --resource-group $(rg)

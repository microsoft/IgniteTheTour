#!/usr/bin/env bash

source ./scripts/variables.sh

# delete front door
echo "Deleting front door $(fdname) in resource group $(rg)"
az network front-door delete -g $(rg) -n $(fdname)

# helm
kubectl config use-context $(clustername)
echo "Helm deleting 'frontend', 'inventory' and 'product' releases"
helm delete --purge frontend inventory product

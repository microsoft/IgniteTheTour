#!/usr/bin/env bash

source ./scripts/variables.sh

# delete front door
az network front-door delete -g $(rg) -n $(fdname)

# helm
kubectl config use-context $(clustername)
helm delete --purge frontend inventory product
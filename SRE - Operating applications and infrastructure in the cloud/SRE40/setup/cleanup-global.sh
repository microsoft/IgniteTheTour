#!/bin/bash
set -eo pipefail

#0 - load parameters
source ./0-global-params.sh

#delete groups
echo "deleting ${GLOBAL_APP_RG} resource group"
az group delete \
    -n $GLOBAL_APP_RG

echo "deleting ${GLOBAL_DB_RG} resource group"
az group delete \
    -n $GLOBAL_DB_RG

echo "Clean Up complete"
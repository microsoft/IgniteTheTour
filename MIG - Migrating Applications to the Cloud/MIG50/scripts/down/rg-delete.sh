#!/bin/bash
#set -eou pipefail
source ./scripts/variables.sh
az group delete --yes --resource-group $(rg)
az group delete --yes --resource-group $(rg2)
az group delete --yes --resource-group $(rgfunc)

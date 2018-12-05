#!/usr/bin/env bash
set -eou pipefail
source ./scripts/variables.sh

prompt az keyvault secret set \
    --vault-name $(akvname) \
    --name 'web3-mongo-connection' \
    --value $(az cosmosdb list-connection-strings --name $(cosmosname) --resource-group $(rg) | jq -r .connectionStrings[0].connectionString | sed "s/\?ssl=true/tailwind?ssl=true/g")

prompt az keyvault secret set \
    --vault-name $(akvname) \
    --name 'web2-db-connection' \
    --value "$(dotnetconnection)"

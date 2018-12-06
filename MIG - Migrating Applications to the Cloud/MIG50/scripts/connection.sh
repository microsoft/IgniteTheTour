#!/bin/bash
set -eou pipefail

# extract connection string with jq and use sed to add database name to the string
az cosmosdb list-connection-strings --name $(cosmosname) --resource-group $(rg) | jq -r .connectionStrings[0].connectionString | sed "s/\?ssl=true/tailwind?ssl=true/g"

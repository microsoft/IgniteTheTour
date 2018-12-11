#!/usr/bin/env bash
set -eou pipefail
source ./scripts/variables.sh
PG_CONNECTION="$(funcpgconnection)"

# create src/reports/local.settings.json
if [ -f "src/reports/local.settings.json" ]; then
echo "generating local.settings.json"
cat << EOF > ./src/reports/local.settings.json
{
    "IsEncrypted": false,
    "Values": {
      "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=storagelp2s4;AccountKey=vlEFjLfGLi9PLbyyk+Ojrx1eXnUQFEEIaT41+V9FNFpjpweCZntMAyZ37F4XFDu6syo3BBgxbu5PeJt8M64L1Q==",
      "FUNCTIONS_WORKER_RUNTIME": "node",
      "PG_CONNECTION": "${PG_CONNECTION}",
      "SENDGRID_API_KEY": "${SENDGRID_API_KEY}",
      "SENDGRID_TEMPLATE_ID": "${SENDGRID_TEMPLATE_ID}"
    }
  }
EOF
fi

# resource group
scripts/up/rg.sh

# azure container registry
scripts/up/acr.sh

# postgres 
#
# TODO: do we need to parameterize 'postgres-tailwind' into an env var
scripts/up/postgres.sh

# cosmosdb
scripts/up/cosmos.sh

# key-vault
scripts/up/vault.sh

# functions
scripts/up/funcsetup.sh

docker pull microsoft/dotnet:2.1-sdk
docker pull microsoft/dotnet:2.1-runtime-deps-alpine
docker pull node:10.12.0-jessie
docker pull node:10-alpine
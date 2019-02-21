#!/usr/bin/env bash
set -eou pipefail
source ./scripts/variables.sh
PG_CONNECTION="$(funcpgconnection)"

# create src/reports/local.settings.json
if [ -f "src/reports/local.settings.json" ]; then
    echo "local.settings.json found, skipping generation"
else
    echo "generating local.settings.json"
cat >./src/reports/local.settings.json << EOL
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=storagelp2s4;AccountKey=vlEFjLfGLi9PLbyyk+Ojrx1eXnUQFEEIaT41+V9FNFpjpweCZntMAyZ37F4XFDu6syo3BBgxbu5PeJt8M64L1Q==",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "PG_CONNECTION": "${PG_CONNECTION}?ssl=true",
    "SENDGRID_API_KEY": "${SENDGRID_API_KEY}",
    "SENDGRID_TEMPLATE_ID": "${SENDGRID_TEMPLATE_ID}"
  }
}
EOL
fi

if [ -f src/reports/CreateReport/function.json ]; then
    echo "src/reports/CreateReport/function.json found, skipping generation";
else
    echo "generating src/reports/CreateReport/function.json"
cat >./src/reports/CreateReport/function.json <<EOL
{
  "disabled": false,
  "bindings": [
    {
      "name": "myTimer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 0 */24 * * *"
    },
    {
      "type": "sendGrid",
      "name": "message",
      "apiKey": "SENDGRID_API_KEY",
      "to": "${EMAIL}",
      "from": "tailwind.reports@tailwind.com",
      "subject": "Tailwind Report",
      "direction": "out"
    }
  ]
}
EOL
fi

if [ -f src/reports/RunCreateReport/function.json ]; then
    echo "Found src/reports/RunCreateReport/function.json, skipping generation"
else
    echo "Generating src/reports/RunCreateReport/function.json"
cat >./src/reports/RunCreateReport/function.json <<EOL
{
  "disabled": false,
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": [
        "get",
        "post"
      ]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    },
    {
      "type": "sendGrid",
      "name": "message",
      "apiKey": "SENDGRID_API_KEY",
      "to": "${EMAIL}",
      "from": "tailwind.reports@tailwind.com",
      "subject": "Tailwind Report",
      "direction": "out"
    }
  ]
}
EOL
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

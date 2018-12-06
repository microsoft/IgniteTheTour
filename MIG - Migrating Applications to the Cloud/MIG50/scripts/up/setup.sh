#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

# resource group
scripts/up/rg.sh
scripts/up/rg2.sh

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

docker pull microsoft/dotnet:2.1-sdk
docker pull microsoft/dotnet:2.1-runtime-deps-alpine
docker pull node:10.12.0-jessie
docker pull node:10-alpine

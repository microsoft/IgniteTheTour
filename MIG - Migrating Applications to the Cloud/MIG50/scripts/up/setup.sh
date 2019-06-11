#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

echo "This script will now setup the following resources in the $(subscription): "
echo ''
echo "Resource Group $(rg) in $(location)"
echo "Resource Group $(rg2) in $(location2)"
echo "$(acrname) Azure Container Registry in the $(rg) resource group"
echo "$(cosmosname) Cosmos DB in the $(rg) resource group"
echo "$(akvname) Azure Key Vault in the $(rg) resource group"

az account set --subscription "$(subscription)"

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

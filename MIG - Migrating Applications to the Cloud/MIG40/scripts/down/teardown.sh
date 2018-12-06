#!/usr/bin/env bash

# let it fail so we're sure all the things get deleted even if the top ones fail
source ./scripts/variables.sh

# func app
scripts/down/funcdown.sh

# cosmosdb
scripts/down/cosmos-delete.sh

# resource group
scripts/down/rg-delete.sh

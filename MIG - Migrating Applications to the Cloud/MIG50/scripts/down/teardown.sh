#!/bin/bash
#set -eou pipefail
# let it fail so we're sure all the things get deleted even if the top ones fail
source ./scripts/variables.sh

# cosmosdb
scripts/down/cosmos-delete.sh

# resource group
scripts/down/rg-delete.sh

#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

prompt az group deployment create -g $(rg) --mode Incremental --template-file scripts/frontdoor/template.json \
    --parameters frontDoorName=$(fdname) \
    --parameters host1_frontend=$(fdfrontend) \
    --parameters host2_product=$(fdproduct) \
    --parameters host3_inventory=$(fdinventory) \
    --parameters host1_frontend2=$(fdfrontend2) \
    --parameters host2_product2=$(fdproduct2) \
    --parameters host3_inventory2=$(fdinventory2)

open https://$(fdname).azurefd.net
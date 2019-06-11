#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

PUBLIC_IP=`curl -4 ifconfig.co`

echo "Creating PostgreSQL $(pgname) in location $(location)"
echo ''

az postgres server create -l $(location) -g $(rg) -n $(pgname) -u $(pguserbase) -p $(pgpass) --sku-name GP_Gen5_2
az postgres db create -g $(rg) -s $(pgname) -n $(dbname)
az postgres server firewall-rule create -g $(rg) -s $(pgname) -n allowall --start-ip-address $PUBLIC_IP --end-ip-address $PUBLIC_IP

az postgres server firewall-rule create -g $(rg) -s $(pgname) -n internal --start-ip-address "0.0.0.0" --end-ip-address "0.0.0.0"

#!/bin/bash
set -eou pipefail
source ../../scripts/variables.sh

if [ "$(clustername)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername)
fi

DBCS=$(az keyvault secret show --vault-name $(akvname) --name web2-db-connection --query value -o tsv)
echo -n $DBCS > tmp.txt

prompt helm upgrade inventory --install \
--namespace default \
--set image.registry="$(acrname).azurecr.io",applicationroutingzone=$(routingzone) \
--set-file connectionstring=tmp.txt \
./

rm tmp.txt


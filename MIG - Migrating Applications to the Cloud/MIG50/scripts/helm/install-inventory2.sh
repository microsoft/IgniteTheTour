#!/bin/bash
set -eou pipefail
source ../../scripts/variables.sh

if [ "$(clustername2)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername2)
fi

DBCS=$(az keyvault secret show --vault-name $(akvname) --name web2-db-connection --query value -o tsv)
echo -n $DBCS > tmp.txt

prompt helm upgrade inventory --install \
--namespace default \
--set image.registry="$(acrname).azurecr.io",applicationroutingzone=$(routingzone2) \
--set-file connectionstring=tmp.txt \
./

rm tmp.txt


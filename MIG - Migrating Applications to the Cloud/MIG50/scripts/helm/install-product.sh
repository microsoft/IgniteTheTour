#!/bin/bash
set -eou pipefail
source ../../scripts/variables.sh

if [ "$(clustername)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername)
fi
MDBCS=$(az keyvault secret show --vault-name $(akvname) --name web3-mongo-connection --query value -o tsv)
echo -n $MDBCS > tmp.txt

prompt helm upgrade product --install \
--namespace default \
--set image.registry="$(acrname).azurecr.io",applicationroutingzone=$(routingzone) \
--set-file connectionstring=tmp.txt \
./

rm tmp.txt
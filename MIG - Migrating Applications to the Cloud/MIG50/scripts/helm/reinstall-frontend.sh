#!/bin/bash
set -eou pipefail
source ../../scripts/variables.sh

if [ "$(clustername)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername)
fi

revisionId1=$(helm ls --output json | jq -r '.Releases[0].Revision') && echo $revisionId1 > rev1.txt
echo "Before this upgrade, your current Helm release is version $revisionId1"

prompt helm upgrade frontend --install --recreate-pods \
--namespace default \
--set image.registry="$(acrname).azurecr.io",ingress.enabled=True,ingress.hosts[0]=dashboard.kubernetes,applicationroutingzone=$(routingzone) \
--set producturl=/products \
--set inventoryurl=/inventory \
./

if [ "$(clustername2)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername2)
fi

revisionId2=$(helm ls --output json | jq -r '.Releases[0].Revision') && echo $revisionId2 > rev2.txt
echo "Before this upgrade, your current Helm release is version $revisionId2"

prompt helm upgrade frontend --install --recreate-pods \
--namespace default \
--set image.registry="$(acrname).azurecr.io",ingress.enabled=True,ingress.hosts[0]=dashboard.kubernetes,applicationroutingzone=$(routingzone2) \
--set producturl=/products \
--set inventoryurl=/inventory \
./

open https://$(fdname).azurefd.net
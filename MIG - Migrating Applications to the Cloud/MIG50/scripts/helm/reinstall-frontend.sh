#!/bin/bash
set -eou pipefail
source ../../scripts/variables.sh

if [ "$(clustername)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername)
fi
prompt helm upgrade frontend --install --recreate-pods \
--namespace default \
--set image.registry="$(acrname).azurecr.io",ingress.enabled=True,ingress.hosts[0]=dashboard.kubernetes,applicationroutingzone=$(routingzone) \
--set producturl=/products \
--set inventoryurl=/inventory \
./

if [ "$(clustername2)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername2)
fi
prompt helm upgrade frontend --install --recreate-pods \
--namespace default \
--set image.registry="$(acrname).azurecr.io",ingress.enabled=True,ingress.hosts[0]=dashboard.kubernetes,applicationroutingzone=$(routingzone2) \
--set producturl=/products \
--set inventoryurl=/inventory \
./

open https://$(fdname).azurefd.net
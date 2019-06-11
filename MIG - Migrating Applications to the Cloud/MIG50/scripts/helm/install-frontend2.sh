#!/bin/bash
set -eou pipefail
source ../../scripts/variables.sh

if [ "$(clustername2)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername2)
fi
prompt helm upgrade frontend --install \
--namespace default \
--set image.registry="$(acrname).azurecr.io",ingress.enabled=True,ingress.hosts[0]=dashboard.kubernetes,applicationroutingzone=$(routingzone2) \
--set producturl=http://$(fdproduct2) \
--set inventoryurl=http://$(fdinventory2) \
./
